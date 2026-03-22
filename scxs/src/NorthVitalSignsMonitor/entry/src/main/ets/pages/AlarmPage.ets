import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AlarmRdb, AlarmRecord, AlarmType } from '../common/database/AlarmRdb';
import common from '@ohos.app.ability.common';
import PatientRdb from '../common/database/PatientRdb';
import type { VisitRecord } from '../common/database/PatientRdb';
import vibrator from '@ohos.vibrator';

/**
 * 告警类型映射类
 * 用于处理告警类型的文本、单位和背景颜色映射
 * 支持的告警类型：
 * - temperature: 体温异常告警
 * - bloodPressure: 血压异常告警
 * - heartRate: 心率异常告警
 * - bloodOxygen: 血氧异常告警
 */
class AlarmTypeMappings {
  /**
   * 获取告警类型的文本描述
   * @param type 告警类型
   * @returns 对应的文本描述
   */
  static getText(type: AlarmType): string {
    switch (type) {
      case 'temperature':
        return '体温异常告警';
      case 'bloodPressure':
        return '血压异常告警';
      case 'heartRate':
        return '心率异常告警';
      case 'bloodOxygen':
        return '血氧异常告警';
      default:
        return '未知告警';
    }
  }

  /**
   * 获取告警类型的单位
   * @param type 告警类型
   * @returns 对应的单位
   */
  static getUnit(type: AlarmType): string {
    switch (type) {
      case 'temperature':
        return '°C';
      case 'bloodPressure':
        return 'mmHg';
      case 'heartRate':
        return '次/分';
      case 'bloodOxygen':
        return '%';
      default:
        return '';
    }
  }

  /**
   * 获取告警类型的背景颜色
   * @param type 告警类型
   * @returns 对应的背景颜色
   */
  static getBackgroundColor(type: AlarmType): string {
    switch (type) {
      case 'temperature':
        return '#FFF3E0';  // 橙色背景，表示体温
      case 'bloodPressure':
        return '#E8F5E9';  // 绿色背景，表示血压
      case 'heartRate':
        return '#FFEBEE';  // 红色背景，表示心率
      case 'bloodOxygen':
        return '#E3F2FD';  // 蓝色背景，表示血氧
      default:
        return '#FFFFFF';
    }
  }
}

/**
 * 就诊记录接口扩展
 * 在基础就诊记录上添加设备ID等额外信息
 * 包含字段：
 * - deviceId: 设备ID
 * - name: 患者姓名
 * - hospitalId: 住院号
 * - phone: 联系电话
 * - idCard: 身份证号
 * - diagnosis: 诊断信息
 * - createTime: 创建时间
 * - remark: 备注信息
 */
interface AlarmVisitRecord extends VisitRecord {
  deviceId: string;
  name: string;
  hospitalId: string;
  phone: string;
  idCard: string;
  diagnosis: string;
  createTime: string;
  remark: string;
}

/**
 * 历史告警记录对话框组件
 * 用于显示和查询历史告警记录
 * 功能：
 * 1. 支持按日期范围查询
 * 2. 支持快速选择时间范围（今天、最近7天、最近30天）
 * 3. 显示告警详情（类型、患者信息、时间、状态等）
 */
@CustomDialog
struct HistoryAlarmDialog {
  controller: CustomDialogController;
  @State startDate: string = '';
  @State endDate: string = '';
  @State historyAlarms: AlarmRecord[] = [];
  @State isLoading: boolean = false;
  @State startDateObj: Date = new Date();
  @State endDateObj: Date = new Date();

  aboutToAppear() {
    const end = new Date();
    const start = new Date();
    start.setDate(end.getDate() - 6);
    this.startDateObj = start;
    this.endDateObj = end;
    this.startDate = this.formatDateToString(start);
    this.endDate = this.formatDateToString(end);
    this.loadHistoryData();
  }

  private formatDateToString(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private validateDateFormat(dateStr: string): boolean {
    // 验证日期格式 YYYY-MM-DD
    const regex = /^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/;
    if (!regex.test(dateStr)) {
      return false;
    }

    // 验证日期是否有效
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) {
      return false;
    }

    // 验证月份和日期是否匹配
    const dateParts = dateStr.split('-');
    const year = Number(dateParts[0]);
    const month = Number(dateParts[1]);
    const day = Number(dateParts[2]);
    const lastDayOfMonth = new Date(year, month, 0).getDate();
    return day <= lastDayOfMonth;
  }

  // 清理之前的状态并设置新的日期范围
  private setDateRange(start: Date, end: Date) {
    // 清理之前的状态
    this.historyAlarms = [];

    // 设置新的日期范围
    this.startDateObj = start;
    this.endDateObj = end;
    this.startDate = this.formatDateToString(start);
    this.endDate = this.formatDateToString(end);

    // 加载新的数据
    this.loadHistoryData();
  }

  private async loadHistoryData() {
    if (!this.startDate || !this.endDate) {
      promptAction.showToast({ message: '请选择日期范围' });
      return;
    }

    this.isLoading = true;
    try {
      // 使用本地时间格式
      const formatDateTime = (date: string, isEnd: boolean = false) => {
        const parts = date.split('-');
        const year = parseInt(parts[0]);
        const month = parseInt(parts[1]);
        const day = parseInt(parts[2]);

        // 使用本地时区创建日期
        const localDate = new Date(year, month - 1, day);
        if (isEnd) {
          localDate.setHours(23, 59, 59, 999);
        } else {
          localDate.setHours(0, 0, 0, 0);
        }

        // 调整时区：将本地时间转换为UTC时间
        const utcDate = new Date(localDate.getTime() - (localDate.getTimezoneOffset() * 60 * 1000));
        return utcDate.toISOString();
      };

      const startDateTime = formatDateTime(this.startDate);
      const endDateTime = formatDateTime(this.endDate, true);

      console.info('查询历史告警，日期范围：', this.startDate, '至', this.endDate);
      console.info('查询历史告警，时间范围：', startDateTime, '至', endDateTime);

      this.historyAlarms = await AlarmRdb.getHistoryAlarms(startDateTime, endDateTime);
      console.info('查询到历史告警数量:', this.historyAlarms.length);

      if (this.historyAlarms.length > 0) {
        console.info('首条告警记录:', JSON.stringify(this.historyAlarms[0]));
        console.info('末条告警记录:', JSON.stringify(this.historyAlarms[this.historyAlarms.length - 1]));
      }

      // 如果是查询当天数据，显示更明确的提示
      if (this.startDate === this.endDate) {
        const count = this.historyAlarms.length;
        promptAction.showToast({
          message: count > 0 ? `当天共有 ${count} 条告警记录` : '当天暂无告警记录'
        });
      } else {
        // 显示日期范围的提示
        const count = this.historyAlarms.length;
        promptAction.showToast({
          message: count > 0 ?
            `${this.startDate} 至 ${this.endDate} 共有 ${count} 条告警记录` :
            `${this.startDate} 至 ${this.endDate} 暂无告警记录`
        });
      }
    } catch (error) {
      console.error('查询历史告警失败:', error);
      promptAction.showToast({ message: '查询失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('历史告警记录')
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
        .padding({ top: 40, bottom: 12, left: 24, right: 24 })

        Column({ space: 12 }) {
          Row() {
            Text('开始日期')
              .fontSize(16)
              .fontColor('#333333')
              .width(80)
            TextInput({ text: this.startDate, placeholder: 'YYYY-MM-DD' })
              .width(200)
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .fontSize(16)
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.startDate = value;
                if (!this.validateDateFormat(value)) {
                  promptAction.showToast({ message: '请输入正确的日期格式：YYYY-MM-DD' });
                  return;
                }
                const date = new Date(value);
                // 设置时间为当天的开始
                date.setHours(0, 0, 0, 0);
                if (date > this.endDateObj) {
                  // promptAction.showToast({ message: '开始日期不能大于结束日期' });
                  return;
                }
                this.startDateObj = date;
                this.loadHistoryData();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('结束日期')
              .fontSize(16)
              .fontColor('#333333')
              .width(80)
            TextInput({ text: this.endDate, placeholder: 'YYYY-MM-DD' })
              .width(200)
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .fontSize(16)
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.endDate = value;
                if (!this.validateDateFormat(value)) {
                  promptAction.showToast({ message: '请输入正确的日期格式：YYYY-MM-DD' });
                  return;
                }
                const date = new Date(value);
                // 设置时间为当天的结束
                date.setHours(23, 59, 59, 999);
                if (date < this.startDateObj) {
                  // promptAction.showToast({ message: '结束日期不能小于开始日期' });
                  return;
                }
                this.endDateObj = date;
                this.loadHistoryData();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row({ space: 8 }) {
            Button('今天', { type: ButtonType.Normal })
              .height(32)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .borderRadius(16)
              .onClick(() => {
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const endOfDay = new Date(today);
                endOfDay.setHours(23, 59, 59, 999);
                this.setDateRange(today, endOfDay);
              })

            Button('最近7天', { type: ButtonType.Normal })
              .height(32)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .borderRadius(16)
              .onClick(() => {
                const now = new Date();
                const end = new Date(now);
                end.setHours(23, 59, 59, 999);
                const start = new Date(now);
                start.setDate(now.getDate() - 6);
                start.setHours(0, 0, 0, 0);
                this.setDateRange(start, end);
              })

            Button('最近30天', { type: ButtonType.Normal })
              .height(32)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .borderRadius(16)
              .onClick(() => {
                const now = new Date();
                const end = new Date(now);
                end.setHours(23, 59, 59, 999);
                const start = new Date(now);
                start.setDate(now.getDate() - 29);
                start.setHours(0, 0, 0, 0);
                this.setDateRange(start, end);
              })
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .padding({ left: 24, right: 24 })

        if (!this.isLoading && this.historyAlarms.length === 0) {
          Column() {
            Image($r('app.media.ic_data'))
              .width(120)
              .height(120)
            Text('暂无告警记录')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
          }
          .width('100%')
          .margin({ top: 40 })
        } else {
          List() {
            ForEach(this.historyAlarms, (alarm: AlarmRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(AlarmTypeMappings.getText(alarm.alarmType))
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                      Text(`患者：${alarm.patientName} - ${alarm.hospitalId}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)

                    Column() {
                      Text(this.formatTime(alarm.alarmTime))
                        .fontSize(14)
                        .fontColor('#999999')
                      Text(alarm.status === 1 ? '已处理' : (alarm.status === 2 ? '已延迟' : '未处理'))
                        .fontSize(14)
                        .fontColor(alarm.status === 1 ? '#4CAF50' : (alarm.status === 2 ? '#FFA000' : '#FF5252'))
                    }
                    .alignItems(HorizontalAlign.End)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  Text() {
                    Span('数值：')
                      .fontSize(16)
                      .fontColor('#333333')
                    Span(alarm.alarmValue.toString())
                      .fontSize(16)
                      .fontColor('#FF4081')
                    Span(AlarmTypeMappings.getUnit(alarm.alarmType))
                      .fontSize(16)
                      .fontColor('#FF4081')
                  }
                  .margin({ top: 8 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(AlarmTypeMappings.getBackgroundColor(alarm.alarmType))
                .borderRadius(12)
                .margin({ bottom: 12 })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .margin({ top: 16 })
          .padding({ left: 24, right: 24 })
        }
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 24, topRight: 24 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  private formatTime(isoTime: string): string {
    try {
      const date = new Date(isoTime);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const day = date.getDate().toString().padStart(2, '0');
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${month}-${day} ${hours}:${minutes}`;
    } catch (error) {
      console.error('时间格式化失败:', error);
      return isoTime;
    }
  }
}

/**
 * 告警中心页面组件
 * 主要功能：
 * 1. 显示实时告警信息
 * 2. 支持告警处理（标记已读、延迟处理）
 * 3. 支持历史告警查询
 * 4. 支持告警搜索和过滤
 * 5. 支持一键标记全部已读
 * 
 * 状态管理：
 * - selectedDelay: 选中的延迟时间索引（0: 5分钟, 1: 15分钟, 2: 30分钟）
 * - searchText: 搜索文本，用于过滤患者姓名或住院号
 * - alarms: 所有告警记录，包含未处理和已延迟的告警
 * - isLoading: 加载状态，控制加载动画显示
 * - isRefreshing: 刷新状态，控制下拉刷新动画
 * - filteredAlarms: 过滤后的告警记录，用于搜索结果显示
 */
@Component
export struct AlarmPage {
  @State private selectedDelay: number = 0; // 选中的延迟时间索引（0: 5分钟, 1: 15分钟, 2: 30分钟）
  @State private searchText: string = ''; // 搜索文本，用于过滤患者姓名或住院号
  @State private alarms: AlarmRecord[] = []; // 所有告警记录，包含未处理和已延迟的告警
  @State private isLoading: boolean = true; // 加载状态，控制加载动画显示
  @State private isRefreshing: boolean = false; // 刷新状态，控制下拉刷新动画
  @State private filteredAlarms: AlarmRecord[] = []; // 过滤后的告警记录，用于搜索结果显示
  private context = getContext(this) as common.UIAbilityContext; // 上下文对象，用于数据库操作
  private historyDialog: CustomDialogController = new CustomDialogController({ // 历史记录对话框控制器
    builder: HistoryAlarmDialog({}),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: false
  });

  private refreshTimer: number = -1; // 定时刷新定时器ID，用于定期更新告警数据

  /**
   * 组件初始化
   * 执行操作：
   * 1. 初始化数据库连接
   * 2. 加载告警数据
   * 3. 启动定时刷新
   */
  async aboutToAppear() {
    try {
      this.isLoading = true;
      const context = getContext(this) as common.Context;
      await AlarmRdb.initDb(context);
      await this.loadAlarms();

      // 启动定时器
      this.startTimer();
    } catch (error) {
      console.error('初始化告警页面失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '初始化告警页面失败' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 页面显示时执行
   * 确保定时器运行并加载最新告警数据
   */
  onPageShow() {
    if (this.refreshTimer === -1) {
      this.startTimer();
    }
    this.loadAlarms();
  }

  /**
   * 页面隐藏时执行
   * 停止定时器以节省资源
   */
  onPageHide() {
    this.stopTimer();
  }

  /**
   * 组件销毁时执行
   * 清理定时器资源
   */
  aboutToDisappear() {
    this.stopTimer();
  }

  /**
   * 启动定时刷新
   * 每6.315秒刷新一次告警数据
   * 刷新间隔设置为非整数秒，避免与其他定时任务冲突
   */
  private startTimer() {
    // 先清除可能存在的旧定时器
    this.stopTimer();

    // 设置新的定时器，每3秒执行一次
    this.refreshTimer = setInterval(() => {
      this.loadAlarms();
    }, 6315);
  }

  /**
   * 停止定时刷新
   * 清理定时器资源
   */
  private stopTimer() {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  /**
   * 加载告警数据
   * 执行操作：
   * 1. 获取所有活动告警（状态为0和2）
   * 2. 检查延迟告警是否到期
   * 3. 更新到期告警状态
   * 4. 过滤显示未处理告警
   * 5. 更新UI显示
   */
  private async loadAlarms(): Promise<void> {
    try {
      this.isLoading = true;
      console.info('开始加载告警数据');

      // 获取所有活动告警（状态为0和2）
      const activeAlarms = await AlarmRdb.getAllActiveAlarms();

      // 检查延迟告警是否已到提醒时间
      const now = new Date();
      const delayedAlarms = activeAlarms.filter(alarm => {
        if (alarm.status === 2 && alarm.delayTime) {
          const delayTime = new Date(alarm.delayTime);
          return delayTime <= now;
        }
        return false;
      });

      // 如果有延迟告警已到提醒时间，更新其状态为未处理
      for (const alarm of delayedAlarms) {
        if (alarm.id) {
          await AlarmRdb.updateAlarmStatus(alarm.id, 0);
          // 振动提示
          await this.vibrateAlert();
          // 显示提醒
          promptAction.showToast({
            message: `患者 ${alarm.patientName} 的${AlarmTypeMappings.getText(alarm.alarmType)}需要处理`
          });
        }
      }

      // 重新加载告警数据，并只显示状态为0的告警记录
      const updatedAlarms = await AlarmRdb.getAllActiveAlarms();
      this.alarms = updatedAlarms.filter(alarm => alarm.status === 0);
      this.filteredAlarms = this.alarms;

      console.info(`加载到 ${this.alarms.length} 条未处理的告警`);
    } catch (error) {
      console.error('加载告警数据失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '加载告警数据失败' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 振动提示
   * 用于告警处理时的触觉反馈
   * 振动时长：100ms
   */
  private async vibrateAlert(): Promise<void> {
    try {
      // 短振动提示
      await vibrator.vibrate(100);
    } catch (error) {
      console.error('振动提示失败:', error instanceof Error ? error.message : String(error));
    }
  }

  /**
   * 标记告警为已读
   * 执行操作：
   * 1. 更新告警状态为已读(1)
   * 2. 振动提示
   * 3. 刷新告警列表
   * @param alarm 要标记的告警记录
   */
  private async handleMarkAsRead(alarm: AlarmRecord): Promise<void> {
    if (alarm.id) {
      const success = await AlarmRdb.updateAlarmStatus(alarm.id, 1);
      if (success) {
        await this.vibrateAlert();
        promptAction.showToast({ message: '已标记为已读' });
        this.loadAlarms();
      } else {
        promptAction.showToast({ message: '操作失败' });
      }
    }
  }

  /**
   * 设置告警延迟处理
   * 执行操作：
   * 1. 计算延迟时间
   * 2. 更新告警状态为已延迟(2)
   * 3. 设置延迟提醒时间
   * 4. 振动提示
   * 5. 刷新告警列表
   * @param alarm 要延迟的告警记录
   * @param minutes 延迟分钟数
   */
  private async handleDelay(alarm: AlarmRecord, minutes: number): Promise<void> {
    if (alarm.id) {
      try {
        // 计算延迟时间
        const delayTime = new Date(Date.now() + minutes * 60 * 1000).toISOString();

        // 更新告警状态为已延迟(2)并设置延迟时间
        const success = await AlarmRdb.updateAlarmDelay(alarm.id, delayTime);

        if (success) {
          // 振动提示
          await this.vibrateAlert();
          // 显示成功提示
          promptAction.showToast({ message: `已设置${minutes}分钟后提醒` });
          // 重新加载告警数据
          await this.loadAlarms();
        } else {
          promptAction.showToast({ message: '设置延迟提醒失败' });
        }
      } catch (error) {
        console.error('设置延迟提醒失败:', error instanceof Error ? error.message : String(error));
        promptAction.showToast({ message: '设置延迟提醒失败' });
      }
    }
  }

  /**
   * 格式化时间显示
   * 将ISO格式时间转换为本地时间格式
   * 格式：MM-DD HH:mm
   * @param isoTime ISO格式的时间字符串
   * @returns 格式化后的时间字符串
   */
  private formatTime(isoTime: string): string {
    try {
      const date = new Date(isoTime);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const day = date.getDate().toString().padStart(2, '0');
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${month}-${day} ${hours}:${minutes}`;
    } catch (error) {
      console.error('时间格式化失败:', error);
      return isoTime;
    }
  }

  /**
   * 获取就诊记录
   * 根据住院号查询患者就诊信息
   * @param hospitalId 住院号
   * @returns 就诊记录信息，包含患者基本信息和设备信息
   */
  private async getVisitRecord(hospitalId: string): Promise<AlarmVisitRecord | null> {
    try {
      const visitRecord = await PatientRdb.getVisitByHospitalId(hospitalId);
      if (visitRecord) {
        return {
          id: visitRecord.id,
          hospitalId: visitRecord.hospitalId,
          name: visitRecord.name,
          phone: visitRecord.phone,
          idCard: visitRecord.idCard,
          deviceId: visitRecord.deviceId,
          diagnosis: visitRecord.diagnosis,
          createTime: visitRecord.createTime,
          remark: visitRecord.remark || ''
        };
      }
      return null;
    } catch (error) {
      console.error('获取就诊记录失败:', error instanceof Error ? error.message : String(error));
      return null;
    }
  }

  /**
   * 下拉刷新处理
   * 执行操作：
   * 1. 重新加载告警数据
   * 2. 振动提示
   * 3. 更新刷新状态
   */
  async onPullDownRefresh() {
    try {
      this.isRefreshing = true;
      await this.loadAlarms();
      await this.vibrateAlert();
    } catch (error) {
      console.error('刷新失败:', error);
      promptAction.showToast({ message: '刷新失败' });
    } finally {
      this.isRefreshing = false;
    }
  }

  /**
   * 一键标记全部告警为已读
   * 执行操作：
   * 1. 遍历所有未处理告警
   * 2. 更新状态为已读
   * 3. 振动提示
   * 4. 刷新告警列表
   */
  async markAllAsRead() {
    try {
      let success = true;
      for (const alarm of this.alarms) {
        if (alarm.id && alarm.status === 0) {
          const result = await AlarmRdb.updateAlarmStatus(alarm.id, 1);
          if (!result) {
            success = false;
          }
        }
      }
      if (success) {
        await this.vibrateAlert();
        promptAction.showToast({ message: '已全部标记为已读' });
        await this.loadAlarms();
      } else {
        promptAction.showToast({ message: '部分操作失败' });
      }
    } catch (error) {
      console.error('标记全部已读失败:', error);
      promptAction.showToast({ message: '操作失败' });
    }
  }

  /**
   * 根据搜索文本过滤告警记录
   * 支持按患者姓名或住院号搜索 /,
   * @param searchText 搜索文本
   */
  private filterAlarms(searchText: string) {
    if (!searchText.trim()) {
      this.filteredAlarms = this.alarms;
      return;
    }

    const searchLower = searchText.toLowerCase();
    this.filteredAlarms = this.alarms.filter(alarm => {
      return alarm.patientName.toLowerCase().includes(searchLower) ||
      alarm.hospitalId.toLowerCase().includes(searchLower);
    });
  }

  /**
   * 构建页面UI
   * 包含以下部分：
   * 1. 顶部工具栏
   *    - 标题
   *    - 全部已读按钮
   * 2. 搜索区域
   *    - 搜索框
   *    - 历史记录按钮
   * 3. 告警列表
   *    - 告警类型
   *    - 患者信息
   *    - 告警时间
   *    - 告警数值
   *    - 操作按钮（查看详情、标记已读、延迟处理）
   * 4. 加载状态
   * 5. 空状态
   */
  build() {
    Column() {
      // 顶部工具栏
      Column() {
        Row() {
          Text('告警中心')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)

          Blank()

          Button('全部已读')
            .height(36)
            .backgroundColor('#4CAF50')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              if (this.alarms.length > 0) {
                this.markAllAsRead();
              } else {
                promptAction.showToast({ message: '没有未读告警' });
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })

        Row() {
          Row() {
            Image($r('app.media.ic_public_search'))
              .width(24)
              .height(24)
              .margin({ right: 8 })
            TextInput({ placeholder: '搜索患者姓名或住院号' })
              .width('100%')
              .height(40)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#999999')
              .fontSize(16)
              .onChange((value: string) => {
                this.searchText = value;
                this.filterAlarms(value);
              })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
          .borderRadius(20)
          .backgroundColor('#F5F5F5')
          .alignItems(VerticalAlign.Center)

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_history'))
              .width(24)
              .height(24)
              .fillColor('#666666')
          }
          .width(40)
          .height(40)
          .backgroundColor('#F5F5F5')
          .margin({ left: 12 })
          .onClick(() => {
            this.historyDialog.open();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }
      .width('100%')
      .backgroundColor(Color.White)

      // 告警列表
      Refresh({ refreshing: this.isRefreshing }) {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
            Text('加载中...')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.filteredAlarms.length === 0) {
          Column() {
            Image($r('app.media.ic_data'))
              .width(120)
              .height(120)
            Text(this.searchText ? '未找到匹配的告警记录' : '暂无告警信息')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.filteredAlarms, (alarm: AlarmRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(AlarmTypeMappings.getText(alarm.alarmType))
                        .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                      Text(`患者：${alarm.patientName} - ${alarm.hospitalId}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)

                    Text(this.formatTime(alarm.alarmTime))
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  Text() {
                    Span('数值：')
                      .fontSize(16)
                      .fontColor('#333333')
                    Span(alarm.alarmValue.toString())
                      .fontSize(16)
                      .fontColor('#FF4081')
                    Span(AlarmTypeMappings.getUnit(alarm.alarmType))
                      .fontSize(16)
                      .fontColor('#FF4081')
                  }
                  .margin({ top: 8 })

                  Row() {
                    Button('查看详情', { type: ButtonType.Normal })
                      .height(32)
                      .backgroundColor('#2196F3')
                      .fontColor('#FFFFFF')
                      .borderRadius(16)
                      .margin({ right: 8 })
                      .onClick(async () => {
                        try {
                          const visitRecord = await this.getVisitRecord(alarm.hospitalId);
                          if (visitRecord) {
                            router.pushUrl({
                              url: 'pages/PatientDetailPage',
                              params: { visit: visitRecord }
                            });
                          } else {
                            promptAction.showToast({ message: '未找到相关就诊记录' });
                          }
                        } catch (error) {
                          console.error('跳转到患者详情页失败:', error instanceof Error ? error.message : String(error));
                          promptAction.showToast({ message: '跳转失败' });
                        }
                      })

                    Button('标记已读', { type: ButtonType.Normal })
                      .height(32)
                      .backgroundColor('#4CAF50')
                      .fontColor('#FFFFFF')
                      .borderRadius(16)
                      .margin({ right: 8 })
                      .onClick(() => {
                        this.handleMarkAsRead(alarm);
                      })

                    Select([
                      { value: '5分钟后提醒' },
                      { value: '15分钟后提醒' },
                      { value: '30分钟后提醒' }
                    ])
                      .selected(this.selectedDelay)
                      .value('稍后处理')
                      .font({ size: 14, weight: 400 })
                      .fontColor('#666666')
                      .selectedOptionFont({ size: 14, weight: 400 })
                      .optionFont({ size: 14, weight: 400 })
                      .arrowPosition(ArrowPosition.END)
                      .menuAlign(MenuAlignType.END)
                      .optionWidth(140)
                      .height(32)
                      .backgroundColor('#F5F5F5')
                      .borderRadius(16)
                      .onSelect((index: number) => {
                        this.selectedDelay = index;
                        const minutes = [5, 15, 30][index];
                        this.handleDelay(alarm, minutes);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .margin({ top: 12 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(AlarmTypeMappings.getBackgroundColor(alarm.alarmType))
                .borderRadius(12)
                .margin({ bottom: 12 })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding(16)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .onRefreshing(async () => {
        await this.onPullDownRefresh();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 