import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PasswordUtil } from '../common/utils/PasswordUtil';
import common from '@ohos.app.ability.common';
import { ThresholdSettingDialog } from '../components/ThresholdSettingDialog';
import { ThresholdData, ThresholdRdb } from '../common/database/ThresholdRdb';
import { MockDataGenerator } from '../common/utils/MockDataGenerator';

@CustomDialog
struct ChangePasswordDialog {
  controller: CustomDialogController;
  onSuccess: () => void = () => {};
  @State message: string = '请绘制新的解锁图案';
  @State firstPassword: number[] = [];
  @State isConfirming: boolean = false;
  private patternLockController: PatternLockController = new PatternLockController();

  build() {
    Column() {
      Row() {
        Text('修改密码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('关闭')
          .backgroundColor(Color.Transparent)
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      Text(this.message)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ bottom: 20 })
        .textAlign(TextAlign.Center)

      PatternLock(this.patternLockController)
        .sideLength(300)
        .circleRadius(12)
        .pathStrokeWidth(8)
        .activeColor('#4CAF50')
        .selectedColor('#4CAF50')
        .pathColor('#4CAF50')
        .backgroundColor('#F5F5F5')
        .autoReset(true)
        .activateCircleStyle({
          color: '#81C784',
          enableWaveEffect: true
        })
        .onPatternComplete(async (input: Array<number>) => {
          if (!input || input.length < 4) {
            this.message = '至少连接4个点，请重新输入';
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG);
            setTimeout(() => {
              this.patternLockController.reset();
            }, 1000);
            return;
          }

          if (!this.isConfirming) {
            // 第一次输入
            this.firstPassword = input;
            this.isConfirming = true;
            this.message = '请再次绘制图案确认';
            this.patternLockController.reset();
          } else {
            // 确认密码
            if (input.toString() === this.firstPassword.toString()) {
              // 保存新密码
              const context = getContext(this) as common.Context;
              const passwordUtil = PasswordUtil.getInstance();
              await passwordUtil.init(context);
              const success = await passwordUtil.setPassword(input);
              if (success) {
                promptAction.showToast({ message: '密码修改成功' });
                this.controller.close();
                this.onSuccess();
              } else {
                promptAction.showToast({ message: '密码修改失败' });
              }
            } else {
              this.message = '两次图案不一致，请重新输入';
              this.isConfirming = false;
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG);
              setTimeout(() => {
                this.patternLockController.reset();
              }, 1000);
            }
          }
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

@CustomDialog
struct MockDataDialog {
  controller: CustomDialogController;
  @State hospitalId: string = '';
  private context: common.Context = getContext(this) as common.Context;

  build() {
    Column() {
      Text('生成模拟数据')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 16 })

      TextInput({ placeholder: '请输入住院号' })
        .width('90%')
        .height(48)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.hospitalId = value;
        })

      Row() {
        Button('取消')
          .width(120)
          .height(40)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .margin({ right: 16 })
          .onClick(() => {
            this.controller.close();
          })

        Button('确定')
          .width(120)
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(async () => {
            if (!this.hospitalId) {
              promptAction.showToast({ message: '请输入住院号' });
              return;
            }
            try {
              MockDataGenerator.setHospitalId(this.hospitalId);
              await MockDataGenerator.generateAllMockData(this.context);
              promptAction.showToast({ message: '模拟数据生成成功' });
              this.controller.close();
            } catch (error) {
              console.error('生成模拟数据失败:', error);
              promptAction.showToast({ message: '生成模拟数据失败' });
            }
          })
      }
      .margin({ bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 });
  }
}

@Entry
@Component
export struct MyProfilePage {
  @State message: string = '';
  private changePasswordDialog: CustomDialogController = new CustomDialogController({
    builder: ChangePasswordDialog({
      onSuccess: () => {
        // 密码修改成功后的回调
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    autoCancel: false
  });

  @State private defaultThreshold: ThresholdData = {
    hospitalId: 'default',  // 使用'default'作为默认阈值的标识
    temperatureMin: 36.0,
    temperatureMax: 37.0,
    systolicPressureMin: 90,
    systolicPressureMax: 140,
    diastolicPressureMin: 60,
    diastolicPressureMax: 90,
    heartRateMin: 60,
    heartRateMax: 100,
    bloodOxygenMin: 95,
    bloodOxygenMax: 100,
    updateTime: new Date().toISOString()
  };

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ThresholdSettingDialog({
      hospitalId: 'default',  // 使用'default'作为默认阈值的标识
      threshold: this.defaultThreshold,  // Changed from defaultThreshold to threshold
      onConfirm: (threshold: ThresholdData) => this.saveThreshold(threshold)
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: false
  });

  private mockDataDialog: CustomDialogController = new CustomDialogController({
    builder: MockDataDialog({}),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: false
  });

  async aboutToAppear(): Promise<void> {
    // 初始化数据库
    const context = getContext(this) as common.Context;
    await ThresholdRdb.getInstance().initDb(context);

    // 获取默认阈值
    const defaultThreshold = await ThresholdRdb.getInstance().getDefaultThreshold();
    if (defaultThreshold) {
      this.defaultThreshold = defaultThreshold;
      // 更新对话框的默认值
      this.dialogController = new CustomDialogController({
        builder: ThresholdSettingDialog({
          hospitalId: 'default',  // 使用'default'作为默认阈值的标识
          threshold: this.defaultThreshold,  // Changed from defaultThreshold to threshold
          onConfirm: (threshold: ThresholdData) => this.saveThreshold(threshold)
        }),
        alignment: DialogAlignment.Bottom,
        customStyle: true,
        autoCancel: false
      });
    }
  }

  private async saveThreshold(threshold: ThresholdData): Promise<void> {
    // 确保设置为默认阈值
    threshold.hospitalId = 'default';  // 使用'default'作为默认阈值的标识
    const success = await ThresholdRdb.getInstance().updateDefaultThreshold(threshold);
    if (success) {
      this.defaultThreshold = threshold;
      promptAction.showToast({ message: '默认阈值设置已保存' });
    } else {
      promptAction.showToast({ message: '保存默认阈值设置失败' });
    }
  }

  @Builder
  private SettingItem(icon: Resource, title: string, onClick: () => void) {
    Row() {
      Row({ space: 12 }) {
        Image(icon)
          .width(24)
          .height(24)
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
      }

      Image($r('app.media.ic_public_arrow_right'))
        .width(20)
        .height(20)
    }
    .width('100%')
    .height(56)
    .padding({ left: 24, right: 24 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(onClick)
  }

  build() {
    Column() {
      // 顶部用户信息区域
      Column() {
        Image($r('app.media.profile_normal'))
          .width(64)
          .height(64)
          .margin({ top: 40, bottom: 12 })
        Text('医生')
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 4 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ bottom: 20 })

      // 设置列表
      List() {
        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_password'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('修改密码')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.changePasswordDialog.open();
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_threshold'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('阈值设置')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.dialogController.open();
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_data'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('模拟数据')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.mockDataDialog.open();
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_device_health'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('设备管理')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DeviceBindPage',
              params: { fromProfile: true }
            });
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_device_health'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('网络管理')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/TcpManagePage'
            });
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)

        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_data'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('日志管理')
                .fontSize(16)
                .fontColor('#333333')
            }

            Image($r('app.media.ic_public_arrow_right'))
              .width(16)
              .height(16)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/LogManagePage'
            });
          })
        }
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .margin({ top: 12 })
      .divider({
        strokeWidth: 1,
        color: '#F5F5F5'
      })

      // 退出登录按钮
      Button('退出登录', { type: ButtonType.Normal })
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .fontColor('#FF4081')
        .fontSize(16)
        .margin({ top: 12 })
        .onClick(() => {
          AlertDialog.show({
            title: '提示',
            message: '确定要退出登录吗？',
            primaryButton: {
              value: '取消',
              action: () => {}
            },
            secondaryButton: {
              value: '确定',
              action: () => {
                router.replaceUrl({ url: 'pages/LoginPage' });
              }
            }
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ left: 16, right: 16 })
  }
}