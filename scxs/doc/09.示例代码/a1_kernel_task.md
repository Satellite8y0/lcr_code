
## 代码概述
该代码展示了在HarmonyOS上创建和管理两个任务（线程）的示例，主要演示了：
1. 任务创建
2. 任务状态检查
3. 任务删除

#include "los_task.h"
#include "ohos_init.h"

unsigned int thread_id1;  // 线程标识符存储变量

/* 线程1的任务函数 */
void task_one()
{
    while (1)  // 无限循环
    {
        printf("This is %s\n", __func__);  // 打印当前函数名
        LOS_Msleep(1000);  // 休眠1000毫秒
    }
}

/* 线程2的任务函数 */
void task_two()
{
    int count = 0;
    while (1)  // 无限循环
    {
        printf("This is %s\n", __func__);  // 打印当前函数名
        LOS_Msleep(2000);  // 休眠2000毫秒
        count++;

        /* 当计数达到5次时，尝试删除线程1 */
        if (count >= 5)
        {
            UINT32 taskStatus;
            /* 获取线程1的状态 */
            UINT32 ret = LOS_TaskStatusGet(thread_id1, &taskStatus);
            printf("ret = %d\r\n", ret);
            
            /* 检查线程1状态是否正常且未退出 */
            if((ret == LOS_OK) && (taskStatus != OS_TASK_STATUS_EXIT)){
                printf("delete task 1\n");
                LOS_TaskDelete(thread_id1);  // 删除线程1
            }
        }
    }
}

/* 任务创建示例函数 */
void task_example()
{
    unsigned int thread_id2;
    TSK_INIT_PARAM_S task1 = {0};  // 线程1初始化参数结构体
    TSK_INIT_PARAM_S task2 = {0};  // 线程2初始化参数结构体
    unsigned int ret = LOS_OK;

    /* 设置线程1的参数 */
    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)task_one;  // 任务入口函数
    task1.uwStackSize = 2048;  // 栈大小
    task1.pcName = "Task_One";  // 任务名称
    task1.usTaskPrio = 26;  // 任务优先级
    ret = LOS_TaskCreate(&thread_id1, &task1);  // 创建线程1
    if (ret != LOS_OK)
    {
        printf("Falied to create Task_One ret:0x%x\n", ret);
        return;
    }

}

/* 注册模块初始化函数 */
APP_FEATURE_INIT(task_example);