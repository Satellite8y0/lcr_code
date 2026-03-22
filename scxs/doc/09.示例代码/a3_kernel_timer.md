## 代码概述
这段代码演示了在OpenHarmony系统中使用软件定时器的基本方法，创建了两个周期性定时器并设置了不同的超时时间。

#include "los_swtmr.h"
#include "ohos_init.h"

/* 定时器1超时回调函数 */
void timer1_timeout(void *arg)
{
    printf("This is Timer1 Timeout function\n");  // 定时器1触发时执行
}


/* 定时器示例主函数 */
void timer_example()
{
    unsigned int timer_id1, timer_id2;  // 定时器ID
    unsigned int ret;  // 操作返回值

    /* 创建并启动定时器1 */
    ret = LOS_SwtmrCreate(
        1000,                     // 定时周期1000ms(1秒)
        LOS_SWTMR_MODE_PERIOD,    // 周期性定时模式
        timer1_timeout,           // 回调函数
        &timer_id1,               // 返回的定时器ID
        NULL                      // 回调参数(无)
    );
    
    if (ret == LOS_OK)  // 创建成功
    {
        ret = LOS_SwtmrStart(timer_id1);  // 启动定时器
        if (ret != LOS_OK)
        {
            printf("start timer1 fail ret:0x%x\n", ret);
            return;
        }
    }
    else  // 创建失败
    {
        printf("create timer1 fail ret:0x%x\n", ret);
        return;
    }

}

/* 注册模块初始化函数 */
APP_FEATURE_INIT(timer_example);