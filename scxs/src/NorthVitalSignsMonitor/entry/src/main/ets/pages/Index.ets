import { PatientPage } from './PatientPage';
import { AlarmPage } from './AlarmPage';
import { MyProfilePage } from './MyProfilePage';
import router from '@ohos.router';

/**
 * 应用主页面组件
 * 功能：
 * 1. 作为应用的入口页面
 * 2. 提供导航到各个功能模块的入口
 * 3. 显示应用的基本信息
 * 
 * 页面结构：
 * - 顶部标题栏
 * - 功能模块导航区
 * - 底部信息栏
 */
@Entry
@Component
struct Index {
  /**
   * 构建页面UI
   * 包含以下部分：
   * 1. 顶部标题栏
   *    - 应用名称
   *    - 版本信息
   * 2. 功能模块导航区
   *    - 患者管理
   *    - 设备管理
   *    - 告警中心
   *    - 日志管理
   * 3. 底部信息栏
   *    - 版权信息
   *    - 技术支持
   */
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @Builder TabBuilder(title: string, index: number, normalImg: Resource, selectedImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width(20)
        .height(20)
      Text(title)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#2196F3' : '#999999')
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('生命体征监测系统')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Text('v1.0.0')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 功能模块导航区
      Grid() {
        GridItem() {
          NavigationLink() {
            Column() {
              Image($r('app.media.ic_patient'))
                .width(48)
                .height(48)
              Text('患者管理')
                .fontSize(16)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          .url('pages/PatientPage')
        }

        GridItem() {
          NavigationLink() {
            Column() {
              Image($r('app.media.ic_device'))
                .width(48)
                .height(48)
              Text('设备管理')
                .fontSize(16)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          .url('pages/DeviceBindPage')
        }

        GridItem() {
          NavigationLink() {
            Column() {
              Image($r('app.media.ic_alarm'))
                .width(48)
                .height(48)
              Text('告警中心')
                .fontSize(16)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          .url('pages/AlarmPage')
        }

        GridItem() {
          NavigationLink() {
            Column() {
              Image($r('app.media.ic_log'))
                .width(48)
                .height(48)
              Text('日志管理')
                .fontSize(16)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          .url('pages/LogManagePage')
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .padding(16)
      .layoutWeight(1)

      // 底部信息栏
      Column() {
        Text('© 2024 生命体征监测系统')
          .fontSize(12)
          .fontColor('#999999')
        Text('技术支持：xxx公司')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}