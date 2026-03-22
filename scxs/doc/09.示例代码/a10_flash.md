# Flash操作示例代码分析

## 代码概述
这段代码演示了在OpenHarmony系统中对Flash存储器的基本操作，包括擦除、写入和读取功能。

## 关键定义

```c
#include "ohos_init.h"
#include "cmsis_os2.h"
#include "los_task.h"

#include "link.h"
#include "lz_hardware.h"

#define LOG_TAG                 "flash"                         // 模块日志标签
#define FLASH_ADDRESS_START     (0x700000)                      // Flash起始地址
#define FLASH_ADDRESS_LENGTH    (0x100000)                      // Flash地址空间长度
#define FLASH_BLOCK_SIZE        (PART_BLOCK_SIZE)               // Flash块大小
#define FLASH_ERASE_BLOCK_SIZE  (4096)                          // Flash擦除块大小


//flash_process函数
void flash_process(void *args)
{
    uint32_t flash_base_address = FLASH_ADDRESS_START;  // Flash基地址
    uint8_t flash_erase_buffer[FLASH_ERASE_BLOCK_SIZE]; // 擦除缓冲区
    int ret;                                            // 操作返回值
    uint8_t ch = 'a';                                   // 写入的测试字符
    
    // 初始化Flash
    FlashDeinit();  // 反初始化Flash
    FlashInit();    // 初始化Flash

    while (1)       // 循环测试
    {
        // 每次处理16字节范围的Flash空间
        for (uint32_t i = 0; i < 16; i += FLASH_ERASE_BLOCK_SIZE)
        {
            uint32_t flash_address = flash_base_address + i;
            uint32_t flash_length = FLASH_ERASE_BLOCK_SIZE;

            // 1. Flash擦除操作
            printf("Flash擦除: 地址 = 0x%x, 长度 = 0x%x\n", flash_address, flash_length);
            ret = FlashErase(flash_address, flash_length);
            if (ret != LZ_HARDWARE_SUCCESS) {
                printf("Flash擦除失败\n");
                goto flash_out;
            }

            // 2. Flash写入操作
            printf("Flash写入: 地址 = 0x%x, 长度 = 0x%x, 字符 = %c\n", 
                  flash_address, flash_length, ch);
            memset(flash_erase_buffer, ch, sizeof(flash_erase_buffer));
            ret = FlashWrite(flash_address, sizeof(flash_erase_buffer), 
                          flash_erase_buffer, 0);
            if (ret != LZ_HARDWARE_SUCCESS) {
                printf("Flash写入失败\n");
                goto flash_out;
            }
            ch++;  // 每次写入不同字符

            // 3. Flash读取操作
            printf("Flash读取: 地址 = 0x%x, 长度 = 0x%x\n", flash_address, flash_length);
            memset(flash_erase_buffer, 0, sizeof(flash_erase_buffer));
            ret = FlashRead(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer);
            if (ret != LZ_HARDWARE_SUCCESS) {
                printf("Flash读取失败\n");
                goto flash_out;
            }
            // 打印前16字节内容
            for (uint32_t offset = 0; offset < 16; offset++) {
                printf("    [%d] = %c\n", offset, flash_erase_buffer[offset]);
            }

        flash_out:
            LOS_Msleep(1000);  // 每次操作间隔1秒
        }
    }
}

//创建Flash操作任务
void flash_example(void)
{
    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};

    // 配置任务参数
    task.pfnTaskEntry = (TSK_ENTRY_FUNC)flash_process;  // 任务入口函数
    task.uwStackSize = 1024 * 512;                     // 任务栈大小
    task.pcName = "flash_process";                      // 任务名称
    task.usTaskPrio = 24;                               // 任务优先级
    
    // 创建任务
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("创建flash_process任务失败 ret:0x%x\n", ret);
        return;
    }
}

// 注册模块初始化函数
APP_FEATURE_INIT(flash_example);