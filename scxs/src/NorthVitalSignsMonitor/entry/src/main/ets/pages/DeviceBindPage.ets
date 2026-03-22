import router from '@ohos.router';

import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { ThresholdSettingDialog } from '../components/ThresholdSettingDialog';
import { ThresholdRdb, ThresholdData } from '../common/database/ThresholdRdb';
import { deviceRdbInstance, DeviceData } from '../common/database/DeviceRdb';
import patientRdbInstance from '../common/database/PatientRdb';
import type { VisitRecord } from '../common/database/PatientRdb';
import emitter from '@ohos.events.emitter';

// 定义路由参数接口
interface RouterParams {
  visit?: VisitRecord;
  fromProfile?: boolean;
  eventId?: number;
}

// 定义事件名称
const EVENT_DEVICE_BOUND = 'deviceBound';

// 扩展 DeviceData 类型以包含时间戳
interface DeviceDataWithTimestamp extends DeviceData {
  timestamp: number;
}

/**
 * 添加设备对话框组件
 * 功能：
 * 1. 提供设备ID和名称输入界面
 * 2. 验证输入信息的完整性
 * 3. 处理设备添加操作
 * 
 * 状态管理：
 * - controller: 对话框控制器，用于控制对话框的显示和关闭
 * - onSuccess: 添加成功后的回调函数
 * - newDeviceId: 新设备的ID
 * - newDeviceName: 新设备的名称
 */
@CustomDialog
struct AddDeviceDialog {
  controller: CustomDialogController; // 对话框控制器
  onSuccess: () => void = () => {}; // 添加成功回调
  @Link newDeviceId: string; // 设备ID输入框的值
  @Link newDeviceName: string; // 设备名称输入框的值

  build() {
    Column() {
      // 对话框标题栏
      Row() {
        Text('添加新设备')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('关闭')
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      // 设备ID输入框
      TextInput({
        placeholder: '设备ID',
        text: this.newDeviceId
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 16, left: 24, right: 24 })
        .onChange((value: string) => {
          this.newDeviceId = value;
        })

      // 设备名称输入框
      TextInput({
        placeholder: '设备名称',
        text: this.newDeviceName
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 24, left: 24, right: 24 })
        .onChange((value: string) => {
          this.newDeviceName = value;
        })

      // 操作按钮区域
      Row() {
        Button('取消')
          .width(120)
          .height(40)
          .backgroundColor('#CCCCCC')
          .margin({ right: 16 })
          .onClick(() => {
            this.controller.close();
          })

        Button('添加')
          .width(120)
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(() => {
            // 验证输入信息
            if (!this.newDeviceId.trim() || !this.newDeviceName.trim()) {
              promptAction.showToast({ message: '请填写完整的设备信息' });
              return;
            }
            this.controller.close();
            this.onSuccess();
          })
      }
      .margin({ bottom: 24 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

@Entry
@Component
struct DeviceBindPage {
  private context = getContext(this) as common.UIAbilityContext;
  @State devices: DeviceDataWithTimestamp[] = [];
  @State filteredDevices: DeviceDataWithTimestamp[] = [];
  @State searchText: string = '';
  @State newDeviceId: string = '';
  @State newDeviceName: string = '';
  @State showAddDialog: boolean = false;
  @State visit: VisitRecord | null = null;
  @State fromProfile: boolean = false;
  private thresholdDialogController: CustomDialogController = new CustomDialogController({
    builder: ThresholdSettingDialog({
      hospitalId: '',
      onConfirm: (threshold: ThresholdData) => {
        this.handleDeviceBind(this.selectedDevice!, threshold);
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    autoCancel: false
  });
  @State selectedDevice: DeviceData | null = null;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddDeviceDialog({
      onSuccess: (): Promise<void> => this.addNewDevice(),
      newDeviceId: $newDeviceId,
      newDeviceName: $newDeviceName
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    autoCancel: false
  });

  async aboutToAppear() {
    try {
      console.info('开始初始化设备绑定页面');
      // 初始化数据库
      await deviceRdbInstance.initDb(getContext(this));
      console.info('设备数据库初始化完成');
      await ThresholdRdb.getInstance().initDb(getContext(this));
      await patientRdbInstance.initRdbStore(getContext(this));

      // 获取路由参数
      const params = router.getParams() as RouterParams;
      this.visit = params?.visit ?? null;
      this.fromProfile = params?.fromProfile ?? false;

      if (this.visit && !this.visit.hospitalId) {
        promptAction.showToast({ message: '缺少就诊记录信息' });
        router.back();
        return;
      }

      // 加载设备列表
      console.info('开始加载设备列表');
      await this.refreshDeviceList();
      console.info('设备列表加载完成，设备数量:', this.devices.length);
    } catch (error) {
      console.error('初始化失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '初始化失败' });
    }
  }

  /**
   * 添加新设备
   * 执行操作：
   * 1. 检查设备ID是否已存在
   * 2. 创建新设备对象
   * 3. 保存设备信息到数据库
   * 4. 刷新设备列表
   * 5. 清空输入框
   * 6. 显示操作结果提示
   * 
   * 设备对象属性：
   * - deviceId: 设备唯一标识
   * - deviceName: 设备显示名称
   * - batteryLevel: 电池电量（默认100%）
   * - status: 设备状态（默认IDLE）
   * - isBound: 是否已绑定（默认false）
   * - lastUpdateTime: 最后更新时间
   */
  async addNewDevice() {
    try {
      // 检查设备ID是否已存在
      const existingDevice = await deviceRdbInstance.getDeviceById(this.newDeviceId);
      if (existingDevice) {
        promptAction.showToast({ message: '设备ID已存在' });
        return;
      }

      // 创建新设备对象
      const newDevice: DeviceData = {
        deviceId: this.newDeviceId,
        deviceName: this.newDeviceName,
        batteryLevel: 100,  // 新设备默认电量100%
        status: 'IDLE',     // 默认状态为空闲
        isBound: false,     // 默认未绑定
        lastUpdateTime: new Date().toISOString() // 设置当前时间
      };

      // 保存设备信息
      await deviceRdbInstance.upsertDevice(newDevice);
      
      // 刷新设备列表
      await this.refreshDeviceList();
      
      // 清空输入框
      this.newDeviceId = '';
      this.newDeviceName = '';
      
      // 显示成功提示
      promptAction.showToast({ message: '添加设备成功' });
    } catch (error) {
      console.error('添加设备失败:', error);
      promptAction.showToast({ message: '添加设备失败' });
    }
  }

  // 刷新设备列表
  async refreshDeviceList() {
    try {
      const deviceList = await deviceRdbInstance.getAllDevices();
      const timestamp = new Date().getTime();
      this.devices = deviceList.map(device => {
        const deviceWithTimestamp: DeviceDataWithTimestamp = {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          batteryLevel: device.batteryLevel,
          status: device.status,
          isBound: device.isBound,
          lastUpdateTime: device.lastUpdateTime,
          hospitalId: device.hospitalId,
          timestamp: timestamp
        };
        return deviceWithTimestamp;
      });
      this.filterDevices();
    } catch (error) {
      console.error('刷新设备列表失败:', error);
      promptAction.showToast({ message: '刷新设备列表失败' });
    }
  }

  // 过滤设备列表
  filterDevices() {
    if (!this.searchText) {
      this.filteredDevices = [...this.devices];
      return;
    }

    const searchLower = this.searchText.toLowerCase();
    this.filteredDevices = this.devices.filter(device =>
    device.deviceId.toLowerCase().includes(searchLower) ||
    device.deviceName.toLowerCase().includes(searchLower)
    );
  }

  // 处理设备绑定的点击事件
  async showThresholdDialog(device: DeviceData) {
    if (!this.visit || !this.visit.hospitalId) {
      promptAction.showToast({ message: '无效的就诊记录，请检查' });
      router.back();
      return;
    }

    this.selectedDevice = device;

    try {
      // 获取默认阈值
      const defaultThreshold = await ThresholdRdb.getInstance().getDefaultThreshold();
      if (!defaultThreshold) {
        promptAction.showToast({ message: '获取默认阈值失败' });
        return;
      }

      // 更新对话框控制器
      this.thresholdDialogController = new CustomDialogController({
        builder: ThresholdSettingDialog({
          hospitalId: this.visit.hospitalId,
          threshold: defaultThreshold,  // 传入默认阈值
          onConfirm: (threshold: ThresholdData) => {
            this.handleDeviceBind(device, threshold);
          }
        }),
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -20 },
        customStyle: true,
        autoCancel: false
      });

      // 显示阈值设置对话框
      this.thresholdDialogController.open();
    } catch (error) {
      console.error('显示阈值设置对话框失败:', error);
      promptAction.showToast({ message: '显示阈值设置对话框失败' });
    }
  }

  // 处理设备绑定
  async handleDeviceBind(device: DeviceData, threshold: ThresholdData): Promise<void> {
    try {
      // 1. 保存阈值设置
      const thresholdSuccess = await ThresholdRdb.getInstance().insertThreshold(threshold);
      if (!thresholdSuccess) {
        promptAction.showToast({ message: '保存阈值设置失败' });
        return;
      }

      // 2. 更新设备状态
      device.isBound = true;
      device.status = 'IN_USE';
      device.hospitalId = this.visit!.hospitalId;
      const deviceUpdateSuccess: boolean = await deviceRdbInstance.upsertDevice(device);
      if (!deviceUpdateSuccess) {
        promptAction.showToast({ message: '更新设备状态失败' });
        return;
      }

      // 3. 更新就诊记录
      const updatedVisit: VisitRecord = {
        id: this.visit!.id,
        hospitalId: this.visit!.hospitalId,
        name: this.visit!.name,
        phone: this.visit!.phone,
        idCard: this.visit!.idCard,
        deviceId: device.deviceId,
        diagnosis: this.visit!.diagnosis,
        createTime: this.visit!.createTime,
        remark: this.visit!.remark
      };
      const visitUpdateSuccess: boolean = await patientRdbInstance.updateVisitRecord(updatedVisit);
      if (!visitUpdateSuccess) {
        promptAction.showToast({ message: '更新就诊记录失败' });
        // 回滚设备状态
        device.isBound = false;
        device.status = 'IDLE';
        await deviceRdbInstance.upsertDevice(device);
        return;
      }

      promptAction.showToast({ message: '绑定成功' });

      // 发送设备绑定成功事件
      this.context.eventHub.emit(EVENT_DEVICE_BOUND);

      setTimeout(() => {
        router.back();
      }, 500);
    } catch (error) {
      console.error('绑定设备失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '绑定失败' });
    }
  }

  // 解绑设备
  async unbindDevice(device: DeviceData) {
    try {
      if (device.hospitalId) {
        // 先完成就诊记录
        const success = await patientRdbInstance.completeVisit(device.hospitalId);
        if (!success) {
          promptAction.showToast({ message: '完成就诊记录失败' });
          return;
        }
      }

      // 更新设备状态
      device.isBound = false;
      device.status = 'IDLE';
      device.hospitalId = undefined;  // 清除绑定的住院号
      device.lastUpdateTime = new Date().toISOString();
      const success = await deviceRdbInstance.upsertDevice(device);

      if (success) {
        promptAction.showToast({ message: '解绑成功' });
        // 发送设备状态变更事件，通知就诊界面刷新
        this.context.eventHub.emit(EVENT_DEVICE_BOUND);
        await this.refreshDeviceList();
      } else {
        promptAction.showToast({ message: '解绑失败' });
      }
    } catch (error) {
      console.error('解绑设备失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '解绑失败' });
    }
  }

  // 添加删除设备的方法
  async deleteDevice(device: DeviceData) {
    try {
      if (device.isBound) {
        promptAction.showToast({ message: '设备正在使用中，无法删除' });
        return;
      }

      const success = await deviceRdbInstance.deleteDevice(device.deviceId);
      if (success) {
        promptAction.showToast({ message: '删除成功' });
        await this.refreshDeviceList();
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    } catch (error) {
      console.error('删除设备失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // 获取电池电量图标
  @Builder BatteryIcon(level: number) {
    Stack() {
      Row() {
        Stack() {
          Image($r('app.media.ic_battery'))
            .width(20)
            .height(20)
            .fillColor(level > 20 ? (level > 80 ? '#4CAF50' : '#FFA000') : '#F44336')
        }
        .backgroundColor(Color.Transparent)

        Text(`${level}%`)
          .fontSize(12)
          .fontColor(level > 20 ? '#666666' : '#F44336')
          .margin({ left: 4 })
      }
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.ic_public_arrow_left'))
              .width(24)
              .height(24)
              .onClick(() => {
                router.back();
              })
            Text(this.fromProfile ? '设备管理' : '设备绑定')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }

          Blank()

          Button('添加设备')
            .height(32)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .fontSize(14)
            .fontColor('#2196F3')
            .onClick(() => {
              this.newDeviceId = '';
              this.newDeviceName = '';
              this.dialogController.open();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#2196F3')

        // 如果有住院号，在导航栏下方显示
        if (this.visit?.hospitalId) {
          Row() {
            Text('当前患者住院号：')
              .fontSize(14)
              .fontColor('#666666')
            Text(this.visit.hospitalId)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2196F3')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .padding(12)
          .margin({ bottom: 8 })
        }

        Column() {
          // 搜索框
          Row() {
            Image($r('app.media.ic_public_search'))
              .width(20)
              .height(20)
              .margin({ right: 8 })
            TextInput({ placeholder: '搜索设备ID或名称' })
              .width('100%')
              .height(36)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#999999')
              .fontSize(14)
              .onChange((value: string) => {
                this.searchText = value;
                this.filterDevices();
              })
          }
          .width('100%')
          .height(44)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 16, bottom: 20 })

          // 设备列表
          if (this.devices.length === 0) {
            Column() {
              Image($r('app.media.ic_device_health'))
                .width(48)
                .height(48)
                .fillColor('#CCCCCC')
                .margin({ bottom: 16 })
              Text('暂无设备')
                .fontSize(16)
                .fontColor('#999999')
              Text('点击右上角添加设备')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          } else if (this.filteredDevices.length === 0 && this.searchText) {
            Column() {
              Image($r('app.media.ic_device_health'))
                .width(48)
                .height(48)
                .fillColor('#CCCCCC')
                .margin({ bottom: 16 })
              Text('未找到匹配的设备')
                .fontSize(16)
                .fontColor('#999999')
              Text(`没有找到包含"${this.searchText}"的设备`)
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            List() {
              ForEach(this.filteredDevices, (device: DeviceDataWithTimestamp) => {
                ListItem() {
                  Column() {
                    Row() {
                      Column() {
                        Text(device.deviceName)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .width('100%')
                          .textAlign(TextAlign.Start)

                        Text(`ID: ${device.deviceId}`)
                          .fontSize(14)
                          .fontColor('#666666')
                          .margin({ top: 4 })

                        if (device.hospitalId) {
                          Row() {
                            Text('绑定住院号：')
                              .fontSize(14)
                              .fontColor('#666666')
                            Text(device.hospitalId)
                              .fontSize(14)
                              .fontColor('#2196F3')
                              .fontWeight(FontWeight.Medium)
                          }
                          .margin({ top: 4 })
                        }

                        Row() {
                          Text(this.getStatusText(device.status))
                            .fontSize(14)
                            .fontColor(this.getStatusColor(device.status))

                          Stack() {
                            this.BatteryIcon(device.batteryLevel)
                          }
                          .margin({ left: 12 })
                        }
                        .margin({ top: 8 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      if (this.fromProfile) {
                        // 从"我的"页面进入时显示解绑和删除按钮
                        Row() {
                          if (device.isBound) {
                            Button('解绑')
                              .height(36)
                              .width(64)
                              .backgroundColor('#FF4081')
                              .borderRadius(18)
                              .fontSize(14)
                              .fontColor('#FFFFFF')
                              .margin({ right: 8 })
                              .onClick(() => {
                                AlertDialog.show({
                                  title: '确认解绑',
                                  message: device.hospitalId ?
                                    `确定要解绑该设备吗？\n当前绑定患者：${device.hospitalId}\n解绑后将自动完成该患者的就诊记录` :
                                    '确定要解绑该设备吗？',
                                  primaryButton: {
                                    value: '取消',
                                    action: () => {}
                                  },
                                  secondaryButton: {
                                    value: '确定',
                                    action: () => {
                                      this.unbindDevice(device);
                                    }
                                  }
                                });
                              })
                          }

                          Button('删除')
                            .height(36)
                            .width(64)
                            .backgroundColor(device.isBound ? '#CCCCCC' : '#F44336')
                            .borderRadius(18)
                            .fontSize(14)
                            .fontColor('#FFFFFF')
                            .enabled(!device.isBound)
                            .onClick(() => {
                              AlertDialog.show({
                                title: '确认删除',
                                message: '确定要删除该设备吗？此操作不可恢复',
                                primaryButton: {
                                  value: '取消',
                                  action: () => {}
                                },
                                secondaryButton: {
                                  value: '确定',
                                  action: () => {
                                    this.deleteDevice(device);
                                  }
                                }
                              });
                            })
                        }
                      } else {
                        // 从就诊页面进入时显示绑定按钮
                        if (device.isBound) {
                          Row() {
                            Image($r('app.media.visit_selected'))
                              .width(16)
                              .height(16)
                              .margin({ right: 4 })
                            Text('已绑定')
                              .fontSize(14)
                              .fontColor('#4CAF50')
                          }
                          .height(36)
                          .padding({ left: 12, right: 12 })
                          .backgroundColor('#E8F5E9')
                          .borderRadius(18)
                        } else {
                          Button('绑定')
                            .height(36)
                            .width(64)
                            .backgroundColor(device.status === 'IDLE' ? '#4CAF50' : '#CCCCCC')
                            .borderRadius(18)
                            .fontSize(14)
                            .fontColor('#FFFFFF')
                            .enabled(device.status === 'IDLE')
                            .onClick(() => {
                              if (device.status === 'IDLE') {
                                this.showThresholdDialog(device);
                              }
                            })
                        }
                      }
                    }
                    .width('100%')
                    .padding({ top: 16, bottom: 16, left: 16, right: 16 })
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .margin({ bottom: 8 })
                  .width('100%')
                }
              }, (item: DeviceDataWithTimestamp) => item.deviceId + '_' + item.timestamp.toString())
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
        .backgroundColor('#F0F3F8')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'IDLE':
        return '空闲可用';
      case 'IN_USE':
        return '使用中';
      case 'OFFLINE':
        return '离线';
      default:
        return '未知状态';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'IDLE':
        return '#4CAF50';
      case 'IN_USE':
        return '#FFA000';
      case 'OFFLINE':
        return '#999999';
      default:
        return '#999999';
    }
  }
}
@CustomDialog
struct ThresholdDialog {
  controller: CustomDialogController;
  onSuccess: (threshold: ThresholdData) => void = () => {};
  @State threshold: ThresholdData = {
    hospitalId: '',
    temperatureMin: 36.3,
    temperatureMax: 37.2,
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

  aboutToAppear() {
    // No need to set deviceId as it's not part of ThresholdData
  }

  // 验证并格式化数值
  private validateAndFormatNumber(value: string, min: number, max: number, precision: number = 1): number {
    let num = parseFloat(value);
    if (isNaN(num)) {
      return min;
    }
    num = Math.max(min, Math.min(max, num));
    return parseFloat(num.toFixed(precision));
  }

  build() {
    Column() {
      Row() {
        Text('设置阈值')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('关闭')
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      Scroll() {
        Column() {
          // 体温
          Text('体温 (℃)')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Row() {
            TextInput({ text: this.threshold.temperatureMin.toString() })
              .width(120)
              .height(48)
              .margin({ right: 8 })
              .type(InputType.Number)
              .onChange((value) => {
                this.threshold.temperatureMin = this.validateAndFormatNumber(value, 35.0, 42.0);
              })
            Text('-')
              .fontSize(16)
            TextInput({ text: this.threshold.temperatureMax.toString() })
              .width(120)
              .height(48)
              .margin({ left: 8 })
              .type(InputType.Number)
              .onChange((value) => {
                this.threshold.temperatureMax = this.validateAndFormatNumber(value, 35.0, 42.0);
              })
          }
          .margin({ bottom: 16 })

          // 血压
          Text('血压 (mmHg)')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Row() {
            TextInput({ text: this.threshold.systolicPressureMin.toString() })
              .width(120)
              .height(48)
              .margin({ right: 8 })
              .onChange((value) => {
                this.threshold.systolicPressureMin = parseInt(value);
              })
            Text('-')
              .fontSize(16)
            TextInput({ text: this.threshold.systolicPressureMax.toString() })
              .width(120)
              .height(48)
              .margin({ left: 8 })
              .onChange((value) => {
                this.threshold.systolicPressureMax = parseInt(value);
              })
          }
          .margin({ bottom: 16 })

          // 心率
          Text('心率 (次/分)')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Row() {
            TextInput({ text: this.threshold.heartRateMin.toString() })
              .width(120)
              .height(48)
              .margin({ right: 8 })
              .onChange((value) => {
                this.threshold.heartRateMin = parseInt(value);
              })
            Text('-')
              .fontSize(16)
            TextInput({ text: this.threshold.heartRateMax.toString() })
              .width(120)
              .height(48)
              .margin({ left: 8 })
              .onChange((value) => {
                this.threshold.heartRateMax = parseInt(value);
              })
          }
          .margin({ bottom: 16 })

          // 血氧
          Text('血氧 (%)')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Row() {
            TextInput({ text: this.threshold.bloodOxygenMin.toString() })
              .width(120)
              .height(48)
              .margin({ right: 8 })
              .onChange((value) => {
                this.threshold.bloodOxygenMin = parseInt(value);
              })
            Text('-')
              .fontSize(16)
            TextInput({ text: this.threshold.bloodOxygenMax.toString() })
              .width(120)
              .height(48)
              .margin({ left: 8 })
              .onChange((value) => {
                this.threshold.bloodOxygenMax = parseInt(value);
              })
          }
          .margin({ bottom: 24 })
        }
        .padding({ left: 24, right: 24 })
      }
      .layoutWeight(1)

      Row() {
        Button('取消')
          .width(120)
          .height(40)
          .backgroundColor('#CCCCCC')
          .margin({ right: 16 })
          .onClick(() => {
            this.controller.close();
          })

        Button('确定')
          .width(120)
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(() => {
            // 验证输入值的合法性
            if (this.threshold.temperatureMin < 35.0 || this.threshold.temperatureMax > 42.0 ||
              this.threshold.temperatureMin >= this.threshold.temperatureMax) {
              promptAction.showToast({ message: '体温范围应在35.0-42.0℃之间，且最小值应小于最大值' });
              return;
            }

            if (this.threshold.systolicPressureMin >= this.threshold.systolicPressureMax) {
              promptAction.showToast({ message: '收缩压最小值应小于最大值' });
              return;
            }

            if (this.threshold.diastolicPressureMin >= this.threshold.diastolicPressureMax) {
              promptAction.showToast({ message: '舒张压最小值应小于最大值' });
              return;
            }

            if (this.threshold.heartRateMin >= this.threshold.heartRateMax) {
              promptAction.showToast({ message: '心率最小值应小于最大值' });
              return;
            }

            if (this.threshold.bloodOxygenMin >= this.threshold.bloodOxygenMax) {
              promptAction.showToast({ message: '血氧最小值应小于最大值' });
              return;
            }

            const newThreshold: ThresholdData = {
              hospitalId: this.threshold.hospitalId,
              temperatureMin: this.validateAndFormatNumber(this.threshold.temperatureMin.toString(), 35.0, 42.0),
              temperatureMax: this.validateAndFormatNumber(this.threshold.temperatureMax.toString(), 35.0, 42.0),
              systolicPressureMin: this.threshold.systolicPressureMin,
              systolicPressureMax: this.threshold.systolicPressureMax,
              diastolicPressureMin: this.threshold.diastolicPressureMin,
              diastolicPressureMax: this.threshold.diastolicPressureMax,
              heartRateMin: this.threshold.heartRateMin,
              heartRateMax: this.threshold.heartRateMax,
              bloodOxygenMin: this.threshold.bloodOxygenMin,
              bloodOxygenMax: this.threshold.bloodOxygenMax,
              updateTime: new Date().toISOString()
            };

            this.onSuccess(newThreshold);
            this.controller.close();
          })
      }
      .margin({ bottom: 24, left: 24, right: 24 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}
