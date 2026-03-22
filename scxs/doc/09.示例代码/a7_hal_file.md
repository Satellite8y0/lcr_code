# HarmonyOS 文件操作示例代码

该代码展示了使用HarmonyOS HAL层API实现的文件读写操作。

```c
#include <stdio.h>
#include "los_task.h"
#include "ohos_init.h"
#include "utils_file.h"
#include "hal_file.h"

#define FILE_NAME           "test.txt"  //定义操作的文件名称为"test.txt"

//文件操作线程函数
void hal_file_thread()
{
    int fd; // 文件描述符
    char buffer[1024]; // 1KB读写缓冲区
    int read_length, write_length;// 实际读取长度，实际写入长度
    int current = 0; //写入计数器

    /* 打开文件并清空内容 */
    fd = HalFileOpen(FILE_NAME, O_RDWR_FS | O_CREAT_FS | O_TRUNC_FS, 0);//文件名 读写模式 不存在则创建 清空文件内容 默认权限
    if (fd == -1)// // 文件打开失败处理
    {
        printf("%s HalFileOpen failed!\n", FILE_NAME);
        return;
    }

    while (1)
    {
         /* --- 读取文件部分 --- */
        HalFileSeek(fd, 0, SEEK_SET);// 移动文件指针到开头
        memset(buffer, 0, sizeof(buffer));// 清空缓冲区
        read_length = HalFileRead(fd, buffer, sizeof(buffer)); // 文件描述符 读取缓冲区 读取长度
        
        // 打印读取结果
        printf("read: \n");
        printf("    length = %d\n", read_length);
        printf("    content = %s\n", buffer);

        /* --- 写入文件部分 --- */
        HalFileSeek(fd, 0, SEEK_SET);// 再次移动指针到开头
        memset(buffer, 0, sizeof(buffer));// 清空缓冲区
       
       // 格式化写入内容
        snprintf(buffer, sizeof(buffer), "Hello World(%d) => ", current);
        write_length = HalFileWrite(fd, buffer, strlen(buffer));// 文件描述符 写入数据 数据长度

        current++;// 计数器递增
        LOS_Msleep(5000);  // 每5秒执行一次读写操作
    }

    HalFileClose(fd);  // 关闭文件(实际不会执行到这里)
}

//初始化函数
void file_example()
{
    unsigned int thread_id;// 线程ID存储变量
    TSK_INIT_PARAM_S task = {0}; // 线程参数结构体
    unsigned int ret = LOS_OK;// 函数返回值

 // 配置线程参数
    task.pfnTaskEntry = (TSK_ENTRY_FUNC)hal_file_thread;  // 设置线程入口函数
    task.uwStackSize = 1024 * 10;  // 10KB栈空间
    task.pcName = "hal_file_thread";  // 线程名称
    task.usTaskPrio = 25;  // 线程优先级
    
     // 创建线程
    ret = LOS_TaskCreate(&thread_id, &task);  // 创建文件操作线程
    if (ret != LOS_OK) // 线程创建失败处理
    {
        printf("Falied to create hal_file_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(file_example);  // 注册为系统初始化函数