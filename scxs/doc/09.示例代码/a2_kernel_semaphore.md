## 代码概述
这段代码演示了在OpenHarmony系统中使用计数信号量实现线程同步的典型用法，包含一个控制线程和两个工作线程。

#include "los_sem.h"
#include "ohos_init.h"

#define MAX_COUNT 4  // 信号量最大计数值
static unsigned int m_sem;  // 信号量ID存储变量

/* 控制线程函数 */
void control_thread()
{
    unsigned int count = 0;

    while (1)
    {
        /* 通过count%3的结果决定释放信号量的次数：
         * - 余数为0：释放两次信号量（两个线程同时执行）
         * - 余数非0：释放一次信号量（两个线程交替执行） */
        if (count++%3)
        {
            LOS_SemPost(m_sem);  // 释放信号量
            printf("control_thread Release once Semaphore\n");
        }
        else
        {
            LOS_SemPost(m_sem);
            LOS_SemPost(m_sem);  // 连续释放两次信号量
            printf("control_thread Release twice Semaphore\n");
        }
        
        LOS_Msleep(1000);  // 休眠1秒
    }
}

/* 信号量线程1 */
void sem_one_thread()
{
    while (1)
    {
        LOS_SemPend(m_sem, LOS_WAIT_FOREVER);  // 永久等待信号量
        printf("sem_one_thread get Semaphore\n");
        LOS_Msleep(100);  // 模拟任务处理
    }
}


/* 信号量示例主函数 */
void semaphore_example()
{
    unsigned int thread_crtl, thread_id1, thread_id2;
    TSK_INIT_PARAM_S task1 = {0}, task2 = {0}, task3 = {0};
    unsigned int ret = LOS_OK;

    /* 创建计数信号量，最大计数值为4 */
    ret = LOS_SemCreate(MAX_COUNT, &m_sem);
    if (ret != LOS_OK)
    {
        printf("Falied to create Semaphore\n");
        return;
    }

    /* 创建控制线程 */
    task1.pfnTaskEntry = (TSK_ENTRY_FUNC)control_thread;
    task1.uwStackSize = 2048;  // 栈大小2KB
    task1.pcName = "control_thread";
    task1.usTaskPrio = 24;  // 优先级24
    ret = LOS_TaskCreate(&thread_crtl, &task1);

}

/* 注册模块初始化函数 */
APP_FEATURE_INIT(semaphore_example);