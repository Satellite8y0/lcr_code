## 代码概述
这段代码演示了在OpenHarmony系统中使用互斥锁实现线程间同步，保护共享数据的读写操作。

#include "los_swtmr.h"
#include "ohos_init.h"
static unsigned int m_mutex_id;  // 互斥锁ID存储变量
static unsigned int m_data = 0;  // 共享数据变量

/* 定时器1回调函数 - 每次触发时打印消息 */
void timer1_timeout(void *arg)
{
    printf("这是定时器1的超时函数\n");
}

void timer_example()
{
    unsigned int timer_id1, timer_id2;
    unsigned int ret;
    
    /* 创建定时器1 (1000ms周期) */
    ret = LOS_SwtmrCreate(
        1000,                    // 间隔: 1000毫秒(1秒)
        LOS_SWTMR_MODE_PERIOD,   // 模式: 周期性定时器
        timer1_timeout,          // 回调函数
        &timer_id1,              // 返回定时器ID
        NULL                     // 回调参数(无)
    );
    
    if (ret == LOS_OK) {
        ret = LOS_SwtmrStart(timer_id1);  // 启动定时器1
        if (ret != LOS_OK) {
            printf("启动定时器1失败 ret:0x%x\n", ret);
            return;
        }
    } else {
        printf("创建定时器1失败 ret:0x%x\n", ret);
        return;
    }

}

APP_FEATURE_INIT(timer_example);  // 注册初始化函数