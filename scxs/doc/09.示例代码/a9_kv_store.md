# OpenHarmony KV存储示例代码

## 代码说明
本示例演示了在OpenHarmony系统中如何使用轻量级键值(KV)存储功能，包含写入和读取两个线程。

## 头文件引入
```c
#include "los_task.h"      // OpenHarmony任务管理
#include "ohos_init.h"     // OpenHarmony初始化
#include "kv_store.h"      // KV存储功能接口
#include <stdio.h>         // 标准输入输出

const char key[] = "key_sample";  // 用于测试的键名

/**
 * KV存储写入线程函数
 * 功能：每秒向KV存储中写入一个递增的测试值
 */
void kv_store_write_thread()
{
    int ret = 0;
    char defValue[50] = {0};  // 存储值的缓冲区
    int current = 0;          // 当前计数值

    while (1)
    {
        // 格式化要写入的值
        snprintf(defValue, sizeof(defValue), "test value %d.", current);
        
        // 写入KV存储
        ret = UtilsSetValue(key, defValue);
        if (ret < 0)
        {
            printf("[写入错误] 错误码: %d\r\n", ret);
        }
        else
        {
            printf("[写入成功]\r\n");
        }

        current++;            // 计数器递增
        LOS_Msleep(1000);     // 休眠1秒
    }
}

/**
 * KV存储读取线程函数
 * 功能：每秒从KV存储中读取并打印指定键的值
 */
void kv_store_read_thread()
{
    int ret = 0;
    char value1[50] = {0};   // 存储读取值的缓冲区

    while (1)
    {
        // 从KV存储读取值
        ret = UtilsGetValue(key, value1, sizeof(value1));
        if (ret < 0)
        {
            printf("[读取错误] 错误码: %d\r\n", ret);
        }
        else
        {
            printf("[读取] 键: %s 值:%s\r\n", key, value1);
        }

        LOS_Msleep(1000);     // 休眠1秒
    }
}

/**
 * KV存储示例入口函数
 * 功能：创建读写两个线程
 */
void kv_store_example()
{
    unsigned int thread_id1, thread_id2;
    TSK_INIT_PARAM_S task1 = {0}, task2 = {0};
    unsigned int ret = LOS_OK;

    // 配置写入线程参数
    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)kv_store_write_thread;  // 线程入口函数
    task1.uwStackSize = 1024 * 10;                              // 线程栈大小(10KB)
    task1.pcName = "kv_store_write_thread";                     // 线程名称
    task1.usTaskPrio = 25;                                      // 线程优先级
    
    // 配置读取线程参数
    task2.pfnTaskEntry = (TSK_ENTRY_FUNC)kv_store_read_thread;
    task2.uwStackSize = 1024 * 10;
    task2.pcName = "kv_store_read_thread";
    task2.usTaskPrio = 25;

    // 创建写入线程
    ret = LOS_TaskCreate(&thread_id1, &task1);
    if (ret != LOS_OK)
    {
        printf("创建写入线程失败:0x%x\n", ret);
        return;
    }

    // 创建读取线程
    ret = LOS_TaskCreate(&thread_id2, &task2);
    if (ret != LOS_OK)
    {
        printf("创建读取线程失败:0x%x\n", ret);
        return;
    }
}

// 注册示例到系统初始化
APP_FEATURE_INIT(kv_store_example);