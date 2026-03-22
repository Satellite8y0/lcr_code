# 目录操作示例代码

## 代码说明
本代码演示了在OpenHarmony系统中如何使用HAL文件接口进行目录操作和文件管理。

## 头文件引入
```c
#include <stdio.h>
#include "los_task.h"      // OpenHarmony任务管理
#include "ohos_init.h"     // OpenHarmony初始化
#include "utils_file.h"    // 文件工具
#include "hal_file.h"      // HAL文件操作接口
#include "dirent.h"        // 目录操作

#define FILE_NAME1    "test.txt"       // 测试文件名1
#define FILE_NAME2    "helloworld.c"   // 测试文件名2  
#define ENTRY_MAXSIZE 32               // 目录条目最大数量
#define DIR_PATH      "./"             // 要操作的目录路径

/**
 * 读取目录内容
 * @param path        目录路径
 * @param entry       目录条目数组
 * @param entry_max   数组最大容量
 * @param entry_length 实际读取到的条目数
 * @return 0表示成功，非0表示失败
 */
extern int HalFileReadDir(const char *path, struct dirent *entry, 
                         int entry_max, int *entry_length);

     void hal_dir_process()
{
    int fd;
    struct dirent entry[ENTRY_MAXSIZE]; // 目录条目数组
    int entry_length = 0;               // 实际条目数
    int ret;
    int i;

    // 创建测试文件1
    fd = HalFileOpen(FILE_NAME1, O_RDWR_FS | O_CREAT_FS | O_TRUNC_FS, 0);
    if (fd == -1) {
        printf("%s 文件创建失败!\n", FILE_NAME1);
        return;
    }
    HalFileClose(fd);

    // 创建测试文件2
    fd = HalFileOpen(FILE_NAME2, O_RDWR_FS | O_CREAT_FS | O_TRUNC_FS, 0);
    if (fd == -1) {
        printf("%s 文件创建失败!\n", FILE_NAME2);
        return;
    }
    HalFileClose(fd);

    // 循环读取目录内容
    while (1) {
        memset(entry, 0, sizeof(entry));
        entry_length = 0;

        // 读取目录内容
        ret = HalFileReadDir(DIR_PATH, &entry[0], ENTRY_MAXSIZE, &entry_length);
        if (ret != 0) {
            printf("目录读取失败(%d)\n", ret);
        } else {
            printf("找到 %d 个目录项\n", entry_length);
            // 遍历并打印每个目录项信息
            for (i = 0; i < entry_length; i++) {
                switch (entry[i].d_type) {
                    case DT_BLK:
                        printf("索引(%d), 名称(%s), 类型(%d)(块设备)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_CHR:
                        printf("索引(%d), 名称(%s), 类型(%d)(字符设备)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_DIR:
                        printf("索引(%d), 名称(%s), 类型(%d)(目录)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_FIFO:
                        printf("索引(%d), 名称(%s), 类型(%d)(管道)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_LNK:
                        printf("索引(%d), 名称(%s), 类型(%d)(符号链接)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_REG:
                        printf("索引(%d), 名称(%s), 类型(%d)(普通文件)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    case DT_SOCK:
                        printf("索引(%d), 名称(%s), 类型(%d)(套接字)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                    default:
                        printf("索引(%d), 名称(%s), 类型(%d)(未知类型)\n", i, entry[i].d_name, entry[i].d_type);
                        break;
                }
            }
        }
        
        printf("\n");
        LOS_Msleep(5000);  // 休眠5秒
    }
}        

//示例入口函数
void dir_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret = LOS_OK;
    
    // 配置任务参数
    task.pfnTaskEntry = (TSK_ENTRY_FUNC)hal_dir_process;  // 任务入口函数
    task.uwStackSize = 1024 * 1024;                      // 任务栈大小
    task.pcName = "hal_dir_thread";                       // 任务名称
    task.usTaskPrio = 25;                                 // 任务优先级
    
    // 创建目录处理任务
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("创建目录线程失败:0x%x\n", ret);
        return;
    }
}

// 注册示例到系统初始化
APP_FEATURE_INIT(dir_example);