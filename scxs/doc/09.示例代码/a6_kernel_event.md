
## 代码概述
本示例演示了HarmonyOS中LiteOS内核事件机制的使用，包括：
- 事件的初始化和创建
- 事件写入和读取操作
- 主从线程间通过事件进行同步通信


### 事件定义
```c

#include "los_event.h"
#include "los_task.h"
#include "ohos_init.h"

#define EVENT_WAIT 0x00000001  // 事件掩码定义(bit0)
static EVENT_CB_S m_event;     // 事件控制块

//主线程函数（事件生产者）每隔2秒写入一次事件标志，写入后清除所有事件标志
void event_master_thread()
{
    unsigned int ret = LOS_OK;

    LOS_Msleep(1000);  // 初始延迟1秒

    while (1)
    {
        printf("%s 写入事件:0x%x\n", __func__, EVENT_WAIT);
        ret = LOS_EventWrite(&m_event, EVENT_WAIT);  // 写入事件标志
        if (ret != LOS_OK) {
            printf("%s 写入事件失败 ret:0x%x\n", __func__, ret);
        }

        /* 延迟2秒 */
        LOS_Msleep(2000);  // 每次事件写入间隔2秒
        LOS_EventClear(&m_event, ~m_event.uwEventID);  // 清除所有事件标志
    }
}

//从线程函数（事件消费者） 无限等待事件标志的到来，打印收到的事件并延迟1秒
void event_slave_thread()
{
    unsigned int event;

    while (1)
    {
        /* 阻塞式读取事件，等待事件到达 */
        event = LOS_EventRead(&m_event, EVENT_WAIT, LOS_WAITMODE_AND, LOS_WAIT_FOREVER);
        printf("%s 读取到事件:0x%x\n", __func__, event);
        LOS_Msleep(1000);  // 收到事件后延迟1秒
    }
}


//初始化函数
void event_example()
{
    unsigned int thread_id1;
    unsigned int thread_id2;
    TSK_INIT_PARAM_S task1 = {0};
    TSK_INIT_PARAM_S task2 = {0};
    unsigned int ret = LOS_OK;

    ret = LOS_EventInit(&m_event);  // 初始化事件控制块
    if (ret != LOS_OK)
    {
        printf("创建EventFlags失败\n");
        return;
    }

    // 配置主线程参数
    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)event_master_thread;
    task1.uwStackSize = 2048;  // 2KB栈空间
    task1.pcName = "event_master_thread";  // 线程名称
    task1.usTaskPrio = 5;  // 线程优先级
    ret = LOS_TaskCreate(&thread_id1, &task1);  // 创建主线程
    if (ret != LOS_OK)
    {
        printf("创建event_master_thread失败 ret:0x%x\n", ret);
        return;
    }

    // 配置从线程参数
    task2.pfnTaskEntry = (TSK_ENTRY_FUNC)event_slave_thread;
    task2.uwStackSize = 2048;
    task2.pcName = "event_slave_thread";
    task2.usTaskPrio = 5;
    ret = LOS_TaskCreate(&thread_id2, &task2);  // 创建从线程
    if (ret != LOS_OK)
    {
        printf("创建event_slave_thread失败 ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(event_example);  // 注册为系统初始化函数