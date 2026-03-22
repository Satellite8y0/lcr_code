#include "max30102.h"
#include <string.h>
#include <stdio.h>
#include "iot_i2c.h"
#include "ohos_types.h"
#include "osal_time.h"

#define MAX30102_I2C_BUS 0  // 根据实际硬件配置修改I2C总线号
#define MAX30102_I2C_BAUDRATE EI2C_FRE_100K  // 100 kHz
static uint8_t i2c_addr = MAX30102_ADDRESS;

// Private function prototypes
static uint8_t read_register8(uint8_t reg);
static void write_register8(uint8_t reg, uint8_t value);
static void bit_mask(uint8_t reg, uint8_t mask, uint8_t thing);

bool max30102_begin(void) {
    // 初始化I2C
    if (IoTI2cInit(MAX30102_I2C_BUS, MAX30102_I2C_BAUDRATE) != HDF_SUCCESS) {
        printf("I2C init failed for bus %d\n", MAX30102_I2C_BUS);
        return false;
    }
    
    // 设置I2C频率
    if (IoTI2cSetBaudrate(MAX30102_I2C_BUS, EI2C_FRE_400K) != HDF_SUCCESS) {
        printf("Failed to set I2C baudrate\n");
        return false;
    }
    
    // 检查设备是否响应
    uint8_t part_id = read_register8(MAX30102_PARTID);
    if (part_id != 0x15) { // MAX30102 has part ID 0x15
        printf("MAX30102 not found, part ID: 0x%02X\n", part_id);
        return false;
    }
    
    return true;
}

void max30102_soft_reset(void) {
    bit_mask(MAX30102_MODECONFIG, 0xBF, 0x40);
    
    // 等待复位完成
    uint32_t timeout = 100; // 100ms 超时
    while (timeout-- > 0) {
        uint8_t response = read_register8(MAX30102_MODECONFIG);
        if ((response & 0x40) == 0) break;
        OsalMSleep(1); // 1ms 延迟
    }
}

void max30102_shutdown(void) {
    bit_mask(MAX30102_MODECONFIG, 0x7F, 0x80);
}

void max30102_wakeup(void) {
    bit_mask(MAX30102_MODECONFIG, 0x7F, 0x00);
}

void max30102_set_led_mode(uint8_t mode) {
    bit_mask(MAX30102_MODECONFIG, 0xF8, mode);
}

void max30102_set_adc_range(uint8_t adc_range) {
    bit_mask(MAX30102_PARTICLECONFIG, 0x9F, adc_range);
}

void max30102_set_sample_rate(uint8_t sample_rate) {
    bit_mask(MAX30102_PARTICLECONFIG, 0xE3, sample_rate);
}

void max30102_set_pulse_width(uint8_t pulse_width) {
    bit_mask(MAX30102_PARTICLECONFIG, 0xFC, pulse_width);
}

void max30102_set_pulse_amplitude_red(uint8_t amplitude) {
    write_register8(MAX30102_LED1_PULSEAMP, amplitude);
}

void max30102_set_pulse_amplitude_ir(uint8_t amplitude) {
    write_register8(MAX30102_LED2_PULSEAMP, amplitude);
}

void max30102_set_fifo_average(uint8_t samples) {
    bit_mask(MAX30102_FIFOCONFIG, 0x1F, samples);
}

void max30102_enable_fifo_rollover(void) {
    bit_mask(MAX30102_FIFOCONFIG, 0xEF, 0x10);
}

void max30102_clear_fifo(void) {
    write_register8(MAX30102_FIFOWRITEPTR, 0);
    write_register8(MAX30102_FIFOOVERFLOW, 0);
    write_register8(MAX30102_FIFOREADPTR, 0);
}

void max30102_setup(uint8_t power_level, uint8_t sample_average, uint8_t led_mode, 
                   uint8_t sample_rate, uint8_t pulse_width, uint8_t adc_range) {
    max30102_soft_reset();
    
    // FIFO 配置
    switch (sample_average) {
        case 1: max30102_set_fifo_average(MAX30102_SAMPLEAVG_1); break;
        case 2: max30102_set_fifo_average(MAX30102_SAMPLEAVG_2); break;
        case 4: max30102_set_fifo_average(MAX30102_SAMPLEAVG_4); break;
        case 8: max30102_set_fifo_average(MAX30102_SAMPLEAVG_8); break;
        case 16: max30102_set_fifo_average(MAX30102_SAMPLEAVG_16); break;
        case 32: max30102_set_fifo_average(MAX30102_SAMPLEAVG_32); break;
        default: max30102_set_fifo_average(MAX30102_SAMPLEAVG_4); break;
    }
    
    max30102_enable_fifo_rollover();
    
    // 模式配置
    switch (led_mode) {
        case 3: max30102_set_led_mode(MAX30102_MODE_MULTILED); break;
        case 2: max30102_set_led_mode(MAX30102_MODE_REDIRONLY); break;
        default: max30102_set_led_mode(MAX30102_MODE_REDONLY); break;
    }
    
    // 颗粒感应配置
    if (adc_range < 4096) max30102_set_adc_range(MAX30102_ADCRANGE_2048);
    else if (adc_range < 8192) max30102_set_adc_range(MAX30102_ADCRANGE_4096);
    else if (adc_range < 16384) max30102_set_adc_range(MAX30102_ADCRANGE_8192);
    else max30102_set_adc_range(MAX30102_ADCRANGE_16384);
    
    if (sample_rate < 100) max30102_set_sample_rate(MAX30102_SAMPLERATE_50);
    else if (sample_rate < 200) max30102_set_sample_rate(MAX30102_SAMPLERATE_100);
    else if (sample_rate < 400) max30102_set_sample_rate(MAX30102_SAMPLERATE_200);
    else if (sample_rate < 800) max30102_set_sample_rate(MAX30102_SAMPLERATE_400);
    else if (sample_rate < 1000) max30102_set_sample_rate(MAX30102_SAMPLERATE_800);
    else if (sample_rate < 1600) max30102_set_sample_rate(MAX30102_SAMPLERATE_1000);
    else if (sample_rate < 3200) max30102_set_sample_rate(MAX30102_SAMPLERATE_1600);
    else max30102_set_sample_rate(MAX30102_SAMPLERATE_3200);
    
    if (pulse_width < 118) max30102_set_pulse_width(MAX30102_PULSEWIDTH_69);
    else if (pulse_width < 215) max30102_set_pulse_width(MAX30102_PULSEWIDTH_118);
    else if (pulse_width < 411) max30102_set_pulse_width(MAX30102_PULSEWIDTH_215);
    else max30102_set_pulse_width(MAX30102_PULSEWIDTH_411);
    
    // LED 脉冲幅度配置
    max30102_set_pulse_amplitude_red(power_level);
    max30102_set_pulse_amplitude_ir(power_level);
    
    max30102_clear_fifo();
}

bool max30102_get_raw_data(max30102_data_t *data) {
    uint8_t buffer[6];
    uint8_t reg = MAX30102_FIFODATA;
    
    if (IoTI2cWrite(MAX30102_I2C_BUS, i2c_addr, &reg, 1) != HDF_SUCCESS) {
        printf("I2C write failed for bus %d\n", MAX30102_I2C_BUS);
        return false;
    }
    
    if (IoTI2cRead(MAX30102_I2C_BUS, i2c_addr, buffer, 6) != HDF_SUCCESS) {
        printf("I2C read failed for bus %d\n", MAX30102_I2C_BUS);
        return false;
    }
    
    // 组合字节形成18位值 (MAX30102 有18位ADC)
    data->red = ((buffer[0] << 16) | (buffer[1] << 8) | buffer[2]) & 0x3FFFF;
    data->ir = ((buffer[3] << 16) | (buffer[4] << 8) | buffer[5]) & 0x3FFFF;
    
    return true;
}

uint8_t max30102_read_part_id(void) {
    return read_register8(MAX30102_PARTID);
}

uint8_t max30102_read_revision_id(void) {
    return read_register8(MAX30102_REVISIONID);
}

// 私有函数
static uint8_t read_register8(uint8_t reg) {
    uint8_t value;
    int32_t ret = IoTI2cRead(MAX30102_I2C_BUS, i2c_addr, &value, 1);
    if (ret != HDF_SUCCESS) {
        printf("I2C read failed for reg 0x%02X, ret: %d\n", reg, ret);
        return 0;
    }
    return value;
}

static void write_register8(uint8_t reg, uint8_t value) {
    uint8_t buffer[2] = {reg, value};
    int32_t ret = IoTI2cWrite(MAX30102_I2C_BUS, i2c_addr, buffer, 2);
    if (ret != HDF_SUCCESS) {
        printf("I2C write failed for reg 0x%02X, ret: %d\n", reg, ret);
    }
}

static void bit_mask(uint8_t reg, uint8_t mask, uint8_t thing) {
    uint8_t original_contents = read_register8(reg);
    original_contents = original_contents & mask;
    write_register8(reg, original_contents | thing);
}