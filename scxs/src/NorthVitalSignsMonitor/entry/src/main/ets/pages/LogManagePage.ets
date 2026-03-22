import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import PatientRdb, { VisitRecord } from '../common/database/PatientRdb';
import { IdCardUtil } from '../common/utils/IdCardUtil';
import { AlarmRdb } from '../common/database/AlarmRdb';
import dataRdb from '@ohos.data.relationalStore';
import { DeviceRdb, deviceRdbInstance } from '../common/database/DeviceRdb';
import { vitalSignsRdbInstance } from '../common/database/VitalSignsRdb';
import ThresholdRdb from '../common/database/ThresholdRdb';

/**
 * 数据源基类
 * 实现IDataSource接口，提供数据变更通知机制
 * 功能：
 * 1. 管理数据变更监听器
 * 2. 提供数据变更通知方法
 * 3. 支持数据重载、添加、修改、删除等操作的通知
 */
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []; // 数据变更监听器数组

  /**
   * 获取数据总数
   * @returns 数据总数
   */
  totalCount(): number {
    return 0;
  }

  /**
   * 获取指定索引的数据
   * @param index 数据索引
   * @returns 对应的数据记录
   */
  getData(index: number): VisitRecord {
    return {
      hospitalId: '',
      name: '',
      phone: '',
      idCard: '',
      deviceId: '',
      diagnosis: '',
      createTime: '',
      remark: ''
    };
  }

  /**
   * 注册数据变更监听器
   * @param listener 数据变更监听器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销数据变更监听器
   * @param listener 要注销的监听器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 通知数据重载
   * 触发所有监听器的onDataReloaded事件
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  /**
   * 通知数据添加
   * @param index 新添加数据的索引
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  /**
   * 通知数据修改
   * @param index 被修改数据的索引
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  /**
   * 通知数据删除
   * @param index 被删除数据的索引
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }
}

/**
 * 患者记录数据源
 * 继承自BasicDataSource，实现患者记录的具体数据管理
 * 功能：
 * 1. 管理患者记录列表
 * 2. 提供记录添加、获取方法
 * 3. 支持数据变更通知
 */
class PatientDataSource extends BasicDataSource {
  private records: VisitRecord[] = []; // 患者记录数组

  /**
   * 获取记录总数
   * @returns 记录数量
   */
  public totalCount(): number {
    return this.records.length;
  }

  /**
   * 获取指定索引的记录
   * @param index 记录索引
   * @returns 对应的患者记录
   */
  public getData(index: number): VisitRecord {
    return this.records[index];
  }

  /**
   * 添加记录数据
   * @param records 要添加的记录数组
   */
  public addData(records: VisitRecord[]): void {
    this.records = records;
    this.notifyDataReload();
  }

  /**
   * 获取所有记录
   * @returns 记录数组
   */
  public getDataList(): VisitRecord[] {
    return this.records;
  }
}

/**
 * 日志管理页面组件
 * 主要功能：
 * 1. 管理患者就诊记录
 * 2. 支持记录搜索和过滤
 * 3. 支持批量删除记录
 * 4. 支持按时间范围删除记录
 * 5. 支持记录详情查看
 * 
 * 状态管理：
 * - dataSource: 患者记录数据源
 * - searchText: 搜索文本
 * - isLoading: 加载状态
 * - isSelectionMode: 选择模式状态
 * - selectedRecords: 选中的记录ID集合
 * - daysToDelete: 默认删除天数
 */
@Entry
@Component
struct LogManagementPage {
  @State private dataSource: PatientDataSource = new PatientDataSource(); // 数据源，管理患者记录
  @State searchText: string = ''; // 搜索文本，用于过滤记录
  @State private isLoading: boolean = false; // 加载状态，控制加载动画显示
  @State private isSelectionMode: boolean = false; // 选择模式状态，控制多选UI
  @State private selectedRecords: Set<string> = new Set(); // 选中的记录ID集合
  @State private daysToDelete: number = 30; // 默认删除天数
  private context = getContext(this) as common.UIAbilityContext; // 上下文对象，用于数据库操作

  /**
   * 组件初始化
   * 执行操作：
   * 1. 初始化数据库连接
   * 2. 加载患者记录
   */
  async aboutToAppear() {
    try {
      // 初始化数据库
      await PatientRdb.initRdbStore(this.context);
      await this.loadRecords();
    } catch (error) {
      console.error('初始化失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '加载数据失败' });
    }
  }

  /**
   * 加载患者记录
   * 执行操作：
   * 1. 从数据库获取所有就诊记录
   * 2. 更新数据源
   * 3. 更新UI显示
   */
  async loadRecords() {
    try {
      this.isLoading = true;
      const records = await PatientRdb.getAllVisitRecords();
      this.dataSource.addData(records);
    } catch (error) {
      console.error('加载记录失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '加载记录失败' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除患者记录
   * 执行操作：
   * 1. 删除设备绑定信息
   * 2. 删除生命体征数据
   * 3. 删除阈值设置
   * 4. 删除告警记录
   * 5. 删除患者记录
   * 6. 更新UI显示
   * @param records 要删除的记录数组
   */
  async deleteRecords(records: VisitRecord[]) {
    try {
      this.isLoading = true;
      let successCount = 0;
      let failCount = 0;

      for (const record of records) {
        try {
          if (!record.id) continue;

          // 1. 删除设备绑定
          if (record.deviceId) {
            const device = await deviceRdbInstance.getDeviceById(record.deviceId);
            if (device) {
              device.isBound = false;
              device.hospitalId = '';
              device.status = 'IDLE';
              await deviceRdbInstance.upsertDevice(device);
              console.info(`解除设备绑定成功: ${record.deviceId}`);
            }
          }

          // 2. 删除生命体征数据
          await vitalSignsRdbInstance.deleteTemperaturesByHospitalId(record.hospitalId);
          await vitalSignsRdbInstance.deleteBloodPressuresByHospitalId(record.hospitalId);
          await vitalSignsRdbInstance.deleteHeartRatesByHospitalId(record.hospitalId);
          await vitalSignsRdbInstance.deleteBloodOxygensByHospitalId(record.hospitalId);
          console.info(`删除生命体征数据成功: ${record.hospitalId}`);

          // 3. 删除阈值设置
          await ThresholdRdb.deleteThresholdByHospitalId(record.hospitalId);
          console.info(`删除阈值设置成功: ${record.hospitalId}`);

          // 4. 删除告警记录
          await AlarmRdb.deleteAlarmsByHospitalId(record.hospitalId);
          console.info(`删除告警记录成功: ${record.hospitalId}`);

          // 5. 删除患者记录
          const success = await PatientRdb.deleteVisitRecord(record.id);
          if (success) {
            successCount++;
            console.info(`删除患者记录成功: ${record.hospitalId}`);
          } else {
            failCount++;
            console.error(`删除患者记录失败: ${record.hospitalId}`);
          }
        } catch (error) {
          failCount++;
          const errorMessage = error instanceof Error ? error.message : String(error);
          console.error(`删除记录失败: ${record.hospitalId}`, errorMessage);
        }
      }

      // 显示删除结果
      if (successCount > 0) {
        promptAction.showToast({
          message: `成功删除${successCount}条记录${failCount > 0 ? `，${failCount}条失败` : ''}`
        });
        this.context.eventHub.emit('deviceBound', {});
        await this.loadRecords();
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('批量删除失败:', errorMessage);
      promptAction.showToast({ message: '批量删除失败' });
    } finally {
      this.isLoading = false;
      this.isSelectionMode = false;
      this.selectedRecords.clear();
    }
  }

  /**
   * 根据搜索条件过滤记录
   * 支持按以下条件搜索：
   * 1. 日期（YYYY-MM-DD 或 YYYY-MM）
   * 2. 患者姓名
   * 3. 住院号
   * 4. 电话号码
   * 5. 身份证号
   * @param records 要过滤的记录数组
   * @returns 过滤后的记录数组
   */
  private filterRecordsBySearch(records: VisitRecord[]): VisitRecord[] {
    if (!this.searchText) {
      return records;
    }

    // 尝试解析搜索文本是否为日期格式 (支持 2024-01-20 或 2024-01 或 2024/01/20 或 2024/01)
    const isDateSearch = this.searchText.match(/^\d{4}(-|\/)\d{1,2}((-|\/)\d{1,2})?$/);

    return records.filter(record => {
      // 如果是日期搜索
      if (isDateSearch) {
        const visitDate = new Date(record.createTime);
        const searchParts = this.searchText.split(/[-\/]/);
        const searchYear = parseInt(searchParts[0]);
        const searchMonth = parseInt(searchParts[1]) - 1; // 月份从0开始

        // 如果只输入了年月（如 2024-01）
        if (searchParts.length === 2) {
          return visitDate.getFullYear() === searchYear &&
            visitDate.getMonth() === searchMonth;
        }

        // 如果输入了完整日期（如 2024-01-20）
        const searchDay = parseInt(searchParts[2]);
        return visitDate.getFullYear() === searchYear &&
          visitDate.getMonth() === searchMonth &&
          visitDate.getDate() === searchDay;
      }

      // 常规搜索（姓名、电话、身份证、住院号）
      const searchLower = this.searchText.toLowerCase();
      return record.name.toLowerCase().includes(searchLower) ||
      record.phone.includes(this.searchText) ||
      record.idCard.includes(this.searchText) ||
        (record.hospitalId ? record.hospitalId.includes(this.searchText) : false);
    });
  }

  /**
   * 执行记录过滤
   * 根据当前搜索文本过滤记录并更新数据源
   */
  private async filterRecords() {
    if (!this.searchText) {
      await this.loadRecords();
      return;
    }

    try {
      const allRecords = await PatientRdb.getAllVisitRecords();
      const filtered = this.filterRecordsBySearch(allRecords);
      this.dataSource.addData(filtered);
    } catch (error) {
      console.error('搜索记录失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '搜索失败' });
    }
  }

  /**
   * 页面头部构建器
   * 包含：
   * 1. 标题和副标题
   * 2. 选择模式下的计数显示
   */
  @Builder
  HeaderBuilder() {
    Row() {
      Column() {
        Text('日志管理')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Text('管理患者就诊记录和相关数据')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      if (this.isSelectionMode) {
        Text(`已选择 ${this.selectedRecords.size} 项`)
          .fontSize(16)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 20, bottom: 16 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 搜索栏构建器
   * 包含：
   * 1. 搜索框
   * 2. 批量删除按钮
   * 3. 日期格式提示
   */
  @Builder
  SearchBuilder() {
    Column() {
      Row() {
        if (!this.isSelectionMode) {
          Search({ value: this.searchText, placeholder: '搜索患者姓名、住院号、电话或时间(2024-01-20)' })
            .layoutWeight(1)
            .height(40)
            .margin({ right: 16 })
            .borderRadius(20)
            .placeholderColor('#999999')
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.searchText = value;
              this.filterRecords();
            })
            .onSubmit((value: string) => {
              this.searchText = value;
              this.filterRecords();
            })

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_delete'))
              .width(20)
              .height(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#FF4081')
          .margin({ right: 16 })
          .onClick(() => {
            TextPickerDialog.show({
              range: ['7天', '15天', '30天', '60天', '90天'],
              selected: 2,
              onAccept: (value: TextPickerResult): void => {
                const dayOptions: number[] = [7, 15, 30, 60, 90];
                let selectedDays: number = 30;
                let currentIndex = 0;
                for (const days of dayOptions) {
                  if (currentIndex === value.index) {
                    selectedDays = days;
                    break;
                  }
                  currentIndex++;
                }
                this.daysToDelete = selectedDays;
                const date = new Date();
                date.setDate(date.getDate() - selectedDays);

                const records: VisitRecord[] = this.dataSource.getDataList().filter((record: VisitRecord) =>
                new Date(record.createTime) < date
                );

                if (records.length === 0) {
                  promptAction.showToast({ message: `没有${selectedDays}天前的数据` });
                  return;
                }

                AlertDialog.show({
                  title: '批量删除确认',
                  message: `确定要删除${selectedDays}天前的${records.length}条记录吗？此操作将同时删除相关的生命体征数据和告警记录。`,
                  primaryButton: {
                    value: '取消',
                    action: (): void => {
                      console.info('取消批量删除');
                    }
                  },
                  secondaryButton: {
                    value: '确定',
                    action: (): void => {
                      this.deleteRecords(records);
                    }
                  }
                });
              },
              onCancel: (): void => {
                console.info('取消选择天数');
              }
            });
          })
        } else {
          Row() {
            Button('取消选择', { type: ButtonType.Normal })
              .height(40)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .margin({ right: 16 })
              .onClick(() => {
                this.isSelectionMode = false;
                this.selectedRecords.clear();
              })

            Button('删除选中', { type: ButtonType.Normal })
              .height(40)
              .backgroundColor('#FF4081')
              .fontColor('#FFFFFF')
              .enabled(this.selectedRecords.size > 0)
              .onClick(() => {
                const records = this.dataSource.getDataList()
                  .filter(record => record.id && this.selectedRecords.has(record.id.toString()));

                AlertDialog.show({
                  title: '批量删除确认',
                  message: `确定要删除选中的${records.length}条记录吗？此操作将同时删除相关的生命体征数据和告警记录。`,
                  primaryButton: {
                    value: '取消',
                    action: () => {
                      console.info('取消批量删除');
                    }
                  },
                  secondaryButton: {
                    value: '确定',
                    action: () => {
                      this.deleteRecords(records);
                    }
                  }
                });
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      if (this.searchText) {
        Text('支持格式：2024-01-20 或 2024-01')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 16, top: 4, bottom: 4 })
      }
    }
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 8 })
  }

  /**
   * 空状态构建器
   * 当没有记录时显示：
   * 1. 空列表图标
   * 2. 提示文本
   */
  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.ic_public_list'))
        .width(120)
        .height(120)
        .opacity(0.6)
      Text('暂无就诊记录')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
      Text('当前没有任何就诊记录数据')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 加载状态构建器
   * 数据加载过程中显示：
   * 1. 加载动画
   * 2. 加载提示文本
   */
  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#FF4081')
      Text('正在加载数据...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 患者记录构建器
   * 构建单个患者记录的显示内容：
   * 1. 患者基本信息（姓名、住院号）
   * 2. 就诊状态
   * 3. 联系方式
   * 4. 身份证号
   * 5. 就诊时间
   * 6. 备注信息
   * 7. 删除按钮
   * @param record 患者记录
   */
  @Builder
  PatientRecordBuilder(record: VisitRecord) {
    Column() {
      Row() {
        if (this.isSelectionMode) {
          Toggle({ type: ToggleType.Checkbox, isOn: record.id ? this.selectedRecords.has(record.id.toString()) : false })
            .margin({ right: 16 })
            .onChange((isOn: boolean) => {
              if (!record.id) return;
              if (isOn) {
                this.selectedRecords.add(record.id.toString());
              } else {
                this.selectedRecords.delete(record.id.toString());
              }
            })
        }

        Column() {
          Text(record.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text(`住院号：${record.hospitalId}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(record.diagnosis ? '已完成就诊' : (record.deviceId ? '就诊中' : '待就诊'))
          .fontSize(14)
          .fontColor(record.diagnosis ? '#4CAF50' : (record.deviceId ? '#FFA000' : '#666666'))
          .backgroundColor(record.diagnosis ? '#E8F5E9' : (record.deviceId ? '#FFF3E0' : '#F5F5F5'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8, left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Text('联系方式：')
            .fontSize(14)
            .fontColor('#999999')
          Text(record.phone)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 4 })

        Row() {
          Text('身份证号：')
            .fontSize(14)
            .fontColor('#999999')
          Text(record.idCard)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 4 })

        Row() {
          Text('就诊时间：')
            .fontSize(14)
            .fontColor('#999999')
          Text(new Date(record.createTime).toLocaleString('zh-CN'))
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 4 })

        if (record.remark) {
          Row() {
            Text('备注：')
              .fontSize(14)
              .fontColor('#999999')
            Text(record.remark)
              .fontSize(14)
              .fontColor('#333333')
          }
          .width('100%')
          .margin({ top: 4 })
        }
      }
      .padding({ left: 16, right: 16 })

      if (!this.isSelectionMode) {
        Row() {
          Button('删除', { type: ButtonType.Normal })
            .height(32)
            .backgroundColor('#FF4081')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .onClick(() => {
              AlertDialog.show({
                title: '确认删除',
                message: '删除就诊记录将同时删除该患者的所有告警记录和生命体征数据，是否确认删除？',
                primaryButton: {
                  value: '取消',
                  action: () => {
                    console.info('取消删除');
                  }
                },
                secondaryButton: {
                  value: '确认',
                  action: () => {
                    this.deleteRecords([record]);
                  }
                }
              });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding({ right: 16, bottom: 12 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (!this.isSelectionMode && record.id) {
            this.isSelectionMode = true;
            this.selectedRecords.add(record.id.toString());
          }
        })
    )
  }

  /**
   * 构建页面UI
   * 包含以下部分：
   * 1. 头部区域
   *    - 标题
   *    - 选择模式计数
   * 2. 搜索区域
   *    - 搜索框
   *    - 批量删除按钮
   * 3. 记录列表
   *    - 患者基本信息
   *    - 就诊状态
   *    - 联系方式
   *    - 操作按钮
   * 4. 加载状态
   * 5. 空状态
   */
  build() {
    Column() {
      this.HeaderBuilder()
      this.SearchBuilder()

      if (this.isLoading) {
        this.LoadingStateBuilder()
      } else if (this.dataSource.totalCount() === 0) {
        this.EmptyStateBuilder()
      } else {
        List() {
          LazyForEach(this.dataSource, (record: VisitRecord) => {
            ListItem() {
              this.PatientRecordBuilder(record)
            }
            .stateStyles({
              pressed: {
                opacity: 0.7
              }
            })
          }, (item: VisitRecord) => item.id?.toString() || item.hospitalId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
