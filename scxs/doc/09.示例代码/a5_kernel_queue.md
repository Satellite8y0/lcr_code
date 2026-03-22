# HarmonyOS 消息队列示例代码分析

## 代码概述
本示例演示了HarmonyOS中LiteOS内核消息队列的使用，包括：
- 消息队列的创建和初始化
- 通过消息队列实现线程间通信
- 数据生产者和消费者模式实现

## 核心组件

### 消息写入线程
```c
#include "los_task.h"
#include "ohos_init.h"

#define MSG_QUEUE_LENGTH  16  // 消息队列最大容量（可存储16条消息）
#define BUFFER_LEN       50   // 单条消息最大长度（50字节）

static unsigned int m_msg_queue;  // 消息队列ID存储变量

void msg_write_thread(void *arg)
{
    unsigned int data = 0;
    unsigned int ret = LOS_OK;

    while (1)
    {
        data++;  // 数据自增
        // 向消息队列写入数据(永久等待模式)
        ret = LOS_QueueWrite(m_msg_queue, (void *)&data, sizeof(data), LOS_WAIT_FOREVER);
        if (LOS_OK != ret)
        {
            printf("%s 写入消息队列失败 ret:0x%x\n", __func__, ret);
        }
        else
        {
            printf("%s 写入消息队列数据:%u\n", __func__, data);
        }

        LOS_Msleep(1000);  // 延迟1秒
    }
}

void msg_read_thread(void *arg)
{
    unsigned int addr;
    unsigned int ret = LOS_OK;
    unsigned int *pData = NULL;

    while (1)
    {
        // 从消息队列读取数据(永久等待模式)
        ret = LOS_QueueRead(m_msg_queue, (void *)&addr, BUFFER_LEN, LOS_WAIT_FOREVER);
        if (ret == LOS_OK)
        {
            pData = addr;  // 获取数据指针
            printf("%s 读取消息队列数据:%u\n", __func__, *pData);
        }
        else
        {
            printf("%s 读取消息队列失败 ret:0x%x\n", __func__, ret);
        }
    }
}

void queue_example()
{
    unsigned int thread_id1, thread_id2;
    TSK_INIT_PARAM_S task1 = {0}, task2 = {0};
    unsigned int ret = LOS_OK;

    // 创建消息队列
    ret = LOS_QueueCreate("queue",          // 队列名称
                         MSG_QUEUE_LENGTH, // 队列长度
                         &m_msg_queue,     // 队列ID
                         0,               // 队列读写模式标志
                         BUFFER_LEN);     // 消息节点大小
    
    // 创建写入线程
    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)msg_write_thread;
    task1.uwStackSize = 2048;    // 栈大小2KB
    task1.pcName = "msg_write_thread";
    task1.usTaskPrio = 24;       // 优先级24
    
    // 创建读取线程
    task2.pfnTaskEntry = (TSK_ENTRY_FUNC)msg_read_thread;
    task2.uwStackSize = 2048;    // 栈大小2KB
    task2.pcName = "msg_read_thread";
    task2.usTaskPrio = 25;       // 优先级25(比写入线程低)
}

APP_FEATURE_INIT(queue_example);  // 注册初始化函数