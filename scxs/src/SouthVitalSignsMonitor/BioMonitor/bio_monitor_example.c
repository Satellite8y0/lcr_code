#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include "los_task.h"
#include "ohos_init.h"
#include "los_event.h"
#include "los_mux.h"
#include "cJSON.h"

#include "max30102.h"
#include "heart_rate.h"
#include "spo2_algorithm.h"
#include "blood_pressure.h"
#include "temperature.h"

#include "config_network.h"
#include "lwip/tcp.h"
#include "lwip/ip_addr.h"
#include "lwip/priv/tcp_priv.h"

#define TAG "MAX30102_EXAMPLE"
#define SAMPLE_INTERVAL_MS 40
#define BUFFER_SIZE (25 * 4)
#define EVENT_WIFI_CONNECTED 0x01
#define EVENT_DATA_READY 0x02
#define OC_SERVER_IP "222.24.74.38"
#define SERVER_PORT 9009
#define ROUTE_SSID "401"
#define ROUTE_PASSWORD "11223344"

static EVENT_CB_S g_event;
static unsigned int g_mutex_id;
static char* g_json_data = NULL;



// 传感器数据结构
static struct {
    uint32_t ir_buffer[BUFFER_SIZE];
    uint32_t red_buffer[BUFFER_SIZE];
    int32_t buffer_index;
    max30102_data_t raw_data;
    int32_t heart_rate;
    int32_t spo2;
    float temperature;
} sensor = { .buffer_index = 0 };

// 初始化同步机制
static void InitSyncMechanisms(void)
{
    if (LOS_MuxCreate(&g_mutex_id) != LOS_OK) {
        printf("Failed to create mutex\n");
    }
    if (LOS_EventInit(&g_event) != LOS_OK) {
        printf("Failed to create event\n");
    }
}

/*********************** WiFi 连接线程 ************************/
static void WifiProcess(void* args)
{
    WifiLinkedInfo info;
    uint8_t mac_address[6] = { 0x00, 0xdc, 0xb6, 0x90, 0x00, 0x00 };

    FlashInit();
    VendorSet(VENDOR_ID_WIFI_MODE, "STA", 3);
    VendorSet(VENDOR_ID_MAC, mac_address, 6);
    VendorSet(VENDOR_ID_WIFI_ROUTE_SSID, ROUTE_SSID, sizeof(ROUTE_SSID));
    VendorSet(VENDOR_ID_WIFI_ROUTE_PASSWD, ROUTE_PASSWORD, sizeof(ROUTE_PASSWORD));

    SetWifiModeOff();
    SetWifiModeOn();

    while (1) {
        if (GetLinkedInfo(&info) == WIFI_SUCCESS && info.connState == WIFI_CONNECTED) {
            printf("WiFi connected, IP: %s\n", inet_ntoa(info.ipAddress));
            LOS_EventWrite(&g_event, EVENT_WIFI_CONNECTED);
            break;
        }
        LOS_Msleep(1000);
    }
    LOS_TaskDelete(LOS_CurTaskIDGet());
}

/*********************** TCP 客户端线程 ***********************/
static void TcpClientTask(void* args)
{
    UINT32 ret;
    int client_fd = -1;
    struct sockaddr_in server_addr = { 0 };

    // 等待WiFi连接成功
    ret = LOS_EventRead(&g_event, EVENT_WIFI_CONNECTED, LOS_WAITMODE_OR, LOS_WAIT_FOREVER);
    if (!(ret & EVENT_WIFI_CONNECTED)) {
        printf("Wait WiFi connected timeout\n");
        goto exit;
    }

    // 创建TCP套接字
    if ((client_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("Create socket failed\n");
        goto exit;
    }

    // 配置服务器地址
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(OC_SERVER_IP);
    server_addr.sin_port = htons(SERVER_PORT);

    // 连接服务器
    if (connect(client_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        printf("Connect server failed\n");
        goto cleanup;
    }

    printf("Connected to %s:%d\n", OC_SERVER_IP, SERVER_PORT);

    // 数据发送循环
    while (1) {
        // 等待数据就绪事件
        ret = LOS_EventRead(&g_event, EVENT_DATA_READY, LOS_WAITMODE_OR, LOS_WAIT_FOREVER);
        if (ret & EVENT_DATA_READY) {
            LOS_MuxPend(g_mutex_id, LOS_WAIT_FOREVER);
            if (g_json_data != NULL) {
                send(client_fd, g_json_data, strlen(g_json_data), 0);
                printf("Sent: %s\n", g_json_data);
                free(g_json_data);
                g_json_data = NULL;
            }
            LOS_MuxPost(g_mutex_id);
            LOS_EventClear(&g_event, EVENT_DATA_READY);
        }
    }

cleanup:
    if (client_fd >= 0) lwip_close(client_fd);
exit:
    LOS_TaskDelete(LOS_CurTaskIDGet());
}

/*********************** 数据采集处理线程 *********************/
static void DataCollectorTask(void* arg)
{
    // 传感器初始化
    if (!max30102_begin()) {
        printf("Sensor init failed\n");
        goto exit;
    }
    max30102_setup(0x1F, 4, 2, 100, 411, 16384);


    // 血压相关变量初始化
    WaveFeatures_t bp_features = { 0 };
    BloodPressure_t blood_pressure = { 0 };
    while (1) {
        if (max30102_get_raw_data(&sensor.raw_data)) {
            // 存储原始数据
            sensor.ir_buffer[sensor.buffer_index] = sensor.raw_data.ir;
            sensor.red_buffer[sensor.buffer_index] = sensor.raw_data.red;

            // 缓冲区处理
            if (++sensor.buffer_index >= BUFFER_SIZE) {
                sensor.buffer_index = 0;

                // 数据处理
                sensor.temperature = temperature_read();
                maxim_heart_rate_and_oxygen_saturation(
                    sensor.ir_buffer, BUFFER_SIZE,
                    sensor.red_buffer, &sensor.spo2, NULL,
                    &sensor.heart_rate, NULL);


                extract_wave_features(sensor.ir_buffer, BUFFER_SIZE, &bp_features);
                calculate_blood_pressure(&bp_features, &blood_pressure);



                cJSON* root = cJSON_CreateObject();
                if (root == NULL) {
                    return NULL;
                }

                cJSON_AddStringToObject(root, "deviceId", "10:dc:b6:90:00:00");
                cJSON_AddStringToObject(root, "timestamp", "");

                cJSON* vitalSigns = cJSON_CreateObject();
                if (vitalSigns == NULL) {
                    cJSON_Delete(root);
                    return NULL;
                }

                cJSON_AddItemToObject(root, "vitalSigns", vitalSigns);
                cJSON_AddNumberToObject(vitalSigns, "temperature", sensor.temperature);

                cJSON* bloodPressure = cJSON_CreateObject();
                if (bloodPressure == NULL) {
                    cJSON_Delete(root);
                    return NULL;
                }

                cJSON_AddItemToObject(vitalSigns, "bloodPressure", bloodPressure);
                cJSON_AddNumberToObject(bloodPressure, "systolic", blood_pressure.systolic);
                cJSON_AddNumberToObject(bloodPressure, "diastolic", blood_pressure.diastolic);

                cJSON_AddNumberToObject(vitalSigns, "heartRate", sensor.heart_rate);
                cJSON_AddNumberToObject(vitalSigns, "bloodOxygen", sensor.spo2);

                char* json_str = cJSON_Print(root);
                if (json_str != NULL) {
                    LOS_MuxPend(g_mutex_id, LOS_WAIT_FOREVER);
                    if (g_json_data != NULL) free(g_json_data);
                    g_json_data = json_str;
                    LOS_MuxPost(g_mutex_id);
                    LOS_EventWrite(&g_event, EVENT_DATA_READY);
                }
                cJSON_Delete(root);
            }
        }
        LOS_Msleep(SAMPLE_INTERVAL_MS);
    }

exit:
    LOS_TaskDelete(LOS_CurTaskIDGet());
}

/*********************** 初始化函数 **************************/
void bio_monitor_example()
{
    InitSyncMechanisms();

    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = { 0 };

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)WifiProcess;
    task.uwStackSize = 10240;
    task.pcName = "wifi_process";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create wifi_process ret:0x%x\n", ret);
        return;
    }

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)TcpClientTask;
    task.uwStackSize = 10240;
    task.pcName = "wifi_process";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create wifi_process ret:0x%x\n", ret);
        return;
    }

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)DataCollectorTask;
    task.uwStackSize = 10240;
    task.pcName = "wifi_process";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create wifi_process ret:0x%x\n", ret);
        return;
    }

}

APP_FEATURE_INIT(bio_monitor_example);
