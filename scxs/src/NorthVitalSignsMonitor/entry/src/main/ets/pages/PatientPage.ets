import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import PatientRdb, { VisitRecord } from '../common/database/PatientRdb';
import { deviceRdbInstance } from '../common/database/DeviceRdb';
import { ValidationUtil } from '../common/utils/IdCardUtil';

// 扩展 VisitRecord 类型以包含时间戳
interface VisitRecordWithTimestamp extends VisitRecord {
  timestamp: number;
}

interface VisitForm {
  id?: number;
  hospitalId?: string;
  name: string;
  phone: string;
  idCard: string;
  deviceId: string;
  diagnosis: string;
  createTime: string;
  remark: string;
}

@CustomDialog
struct VisitDialog {
  controller: CustomDialogController;
  @Link isEditing: boolean;
  @Link editingVisit: VisitForm;
  private loadVisits: () => Promise<void> = () => Promise.resolve();

  // 添加验证方法
  private validatePhone(phone: string): boolean {
    // 验证手机号：1开头的11位数字
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  build() {
    Column() {
      Row() {
        Text(this.isEditing ? '编辑就诊记录' : '添加就诊记录')
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

      TextInput({
        placeholder: '姓名',
        text: this.editingVisit.name
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 16, left: 24, right: 24 })
        .onChange((value: string) => {
          this.editingVisit.name = value;
        })

      TextInput({
        placeholder: '电话',
        text: this.editingVisit.phone
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 16, left: 24, right: 24 })
        .onChange((value: string) => {
          this.editingVisit.phone = value;
        })
        .onBlur(() => {
          if (this.editingVisit.phone && !ValidationUtil.isValidPhone(this.editingVisit.phone)) {
            promptAction.showToast({ message: '请输入正确的手机号码' });
          }
        })

      TextInput({
        placeholder: '身份证号',
        text: this.editingVisit.idCard
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 16, left: 24, right: 24 })
        .onChange((value: string) => {
          this.editingVisit.idCard = value;
        })
        .onBlur(() => {
          if (this.editingVisit.idCard) {
            if (this.editingVisit.idCard.length === 18) {
              if (!ValidationUtil.isValidIdCard(this.editingVisit.idCard)) {
                promptAction.showToast({ message: '请输入有效的身份证号' });
              }
            } else if (this.editingVisit.idCard.length > 18) {
              promptAction.showToast({ message: '身份证号不能超过18位' });
            }
          }
        })

      TextInput({
        placeholder: '备注',
        text: this.editingVisit.remark
      })
        .width('100%')
        .height(48)
        .margin({ bottom: 24, left: 24, right: 24 })
        .onChange((value: string) => {
          this.editingVisit.remark = value;
        })

      Row() {
        Button('取消')
          .width(120)
          .height(40)
          .backgroundColor('#CCCCCC')
          .margin({ right: 16 })
          .onClick(() => {
            this.controller.close();
          })

        Button(this.isEditing ? '保存' : '添加')
          .width(120)
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(async () => {
            if (!this.editingVisit.phone?.trim()) {
              promptAction.showToast({ message: '请输入电话号码' });
              return;
            }

            if (!ValidationUtil.isValidPhone(this.editingVisit.phone)) {
              promptAction.showToast({ message: '请输入正确的手机号码' });
              return;
            }

            if (!this.editingVisit.idCard?.trim()) {
              promptAction.showToast({ message: '请输入身份证号' });
              return;
            }

            if (!ValidationUtil.isValidIdCard(this.editingVisit.idCard)) {
              promptAction.showToast({ message: '请输入有效的身份证号' });
              return;
            }

            // 继续原有的保存逻辑
            this.editingVisit.createTime = new Date().toISOString();
            this.editingVisit.deviceId = '';
            this.editingVisit.diagnosis = '';

            try {
              let success: boolean;
              if (this.isEditing && this.editingVisit.id) {
                success = await PatientRdb.updateVisitRecord(this.editingVisit as VisitRecord);
              } else {
                // 生成住院号：年月日 + 4位随机数
                const now = new Date();
                const year = now.getFullYear().toString().slice(-2);
                const month = (now.getMonth() + 1).toString().padStart(2, '0');
                const day = now.getDate().toString().padStart(2, '0');
                const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
                const hospitalId = `${year}${month}${day}${random}`;

                const visitRecord: VisitRecord = {
                  name: this.editingVisit.name,
                  phone: this.editingVisit.phone,
                  idCard: this.editingVisit.idCard,
                  hospitalId: hospitalId,  // 添加生成的住院号
                  deviceId: '',
                  diagnosis: '',
                  createTime: this.editingVisit.createTime,
                  remark: this.editingVisit.remark || ''
                };
                success = await PatientRdb.addVisitRecord(visitRecord);
              }

              if (success) {
                promptAction.showToast({ message: this.isEditing ? '更新成功' : '添加成功' });
                this.controller.close();
                await this.loadVisits();
              } else {
                promptAction.showToast({ message: this.isEditing ? '更新失败' : '添加失败' });
              }
            } catch (error) {
              console.error(this.isEditing ? '更新就诊记录失败:' : '添加就诊记录失败:', error instanceof Error ? error.message : String(error));
              promptAction.showToast({ message: this.isEditing ? '更新失败' : '添加失败' });
            }
          })
      }
      .margin({ bottom: 24 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return 0;
  }

  getData(index: number): VisitRecordWithTimestamp {
    return {
      id: 0,
      hospitalId: '',
      name: '',
      phone: '',
      idCard: '',
      deviceId: '',
      diagnosis: '',
      createTime: '',
      remark: '',
      timestamp: 0
    };
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }
}

class VisitDataSource extends BasicDataSource {
  private visits: VisitRecordWithTimestamp[] = [];

  public totalCount(): number {
    return this.visits.length;
  }

  public getData(index: number): VisitRecordWithTimestamp {
    return this.visits[index];
  }

  public addData(visits: VisitRecord[]): void {
    // 将 VisitRecord 转换为 VisitRecordWithTimestamp
    const timestamp = new Date().getTime();
    this.visits = visits.map(visit => {
      const visitWithTimestamp: VisitRecordWithTimestamp = {
        id: visit.id,
        hospitalId: visit.hospitalId,
        name: visit.name,
        phone: visit.phone,
        idCard: visit.idCard,
        deviceId: visit.deviceId,
        diagnosis: visit.diagnosis,
        createTime: visit.createTime,
        remark: visit.remark,
        timestamp: timestamp
      };
      return visitWithTimestamp;
    });
    this.notifyDataReload();
  }
}

// 定义事件名称
const EVENT_DEVICE_BOUND = 'deviceBound';

/**
 * 患者管理页面组件
 * 功能：
 * 1. 管理患者就诊记录
 * 2. 支持患者信息的增删改查
 * 3. 提供患者搜索和筛选
 * 4. 支持设备绑定和解绑
 * 
 * 状态管理：
 * - patients: 患者记录列表
 * - searchText: 搜索关键词
 * - isLoading: 加载状态
 * - isRefreshing: 刷新状态
 * - selectedPatient: 选中的患者记录
 */
@Entry
@Component
struct PatientPage {
  @State private patients: VisitRecord[] = []; // 患者记录列表
  @State private searchText: string = ''; // 搜索关键词
  @State private isLoading: boolean = true; // 加载状态
  @State private isRefreshing: boolean = false; // 刷新状态
  @State private selectedPatient: VisitRecord | null = null; // 选中的患者记录
  private context = getContext(this) as common.UIAbilityContext; // 上下文对象

  /**
   * 组件初始化
   * 执行操作：
   * 1. 初始化数据库连接
   * 2. 加载患者记录
   */
  async aboutToAppear() {
    try {
      this.isLoading = true;
      await PatientRdb.initRdbStore(this.context);
      await this.loadPatients();
    } catch (error) {
      console.error('初始化失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '加载数据失败' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载患者记录
   * 执行操作：
   * 1. 从数据库获取所有患者记录
   * 2. 更新状态
   * 3. 处理错误情况
   */
  async loadPatients() {
    try {
      const records = await PatientRdb.getAllVisitRecords();
      this.patients = records;
    } catch (error) {
      console.error('加载患者记录失败:', error instanceof Error ? error.message : String(error));
      promptAction.showToast({ message: '加载患者记录失败' });
    }
  }

  /**
   * 搜索患者
   * 支持按以下条件搜索：
   * 1. 患者姓名
   * 2. 住院号
   * 3. 电话号码
   * 4. 身份证号
   */
  private filterPatients() {
    if (!this.searchText) {
      this.loadPatients();
      return;
    }

    const searchLower = this.searchText.toLowerCase();
    this.patients = this.patients.filter(patient =>
      patient.name.toLowerCase().includes(searchLower) ||
      patient.hospitalId.toLowerCase().includes(searchLower) ||
      patient.phone.includes(this.searchText) ||
      patient.idCard.includes(this.searchText)
    );
  }

  /**
   * 添加新患者
   * 执行操作：
   * 1. 跳转到患者详情页
   * 2. 传递空记录表示新建
   */
  private addNewPatient() {
    router.pushUrl({
      url: 'pages/PatientDetailPage',
      params: { visit: null }
    });
  }

  /**
   * 编辑患者信息
   * 执行操作：
   * 1. 跳转到患者详情页
   * 2. 传递选中的患者记录
   * @param patient 要编辑的患者记录
   */
  private editPatient(patient: VisitRecord) {
    router.pushUrl({
      url: 'pages/PatientDetailPage',
      params: { visit: patient }
    });
  }

  /**
   * 删除患者记录
   * 执行操作：
   * 1. 显示确认对话框
   * 2. 删除患者记录
   * 3. 刷新列表
   * @param patient 要删除的患者记录
   */
  private async deletePatient(patient: VisitRecord) {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除该患者的就诊记录吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: async () => {
          try {
            if (patient.id) {
              const success = await PatientRdb.deleteVisitRecord(patient.id);
              if (success) {
                promptAction.showToast({ message: '删除成功' });
                await this.loadPatients();
              } else {
                promptAction.showToast({ message: '删除失败' });
              }
            }
          } catch (error) {
            console.error('删除患者记录失败:', error instanceof Error ? error.message : String(error));
            promptAction.showToast({ message: '删除失败' });
          }
        }
      }
    });
  }

  /**
   * 构建页面UI
   * 包含以下部分：
   * 1. 顶部工具栏
   *    - 标题
   *    - 添加按钮
   * 2. 搜索栏
   *    - 搜索框
   *    - 清除按钮
   * 3. 患者列表
   *    - 患者基本信息
   *    - 操作按钮
   * 4. 加载状态
   * 5. 空状态
   */
  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Text('患者管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('添加')
          .height(36)
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .borderRadius(18)
          .padding({ left: 20, right: 20 })
          .onClick(() => {
            this.addNewPatient();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')

      // 搜索栏
      Row() {
        Search({ value: this.searchText, placeholder: '搜索患者姓名、住院号、电话或身份证号' })
          .layoutWeight(1)
          .height(40)
          .margin({ right: 16 })
          .borderRadius(20)
          .placeholderColor('#999999')
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => {
            this.searchText = value;
            this.filterPatients();
          })
          .onSubmit((value: string) => {
            this.searchText = value;
            this.filterPatients();
          })

        if (this.searchText) {
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_clear'))
              .width(20)
              .height(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            this.searchText = '';
            this.loadPatients();
          })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 患者列表
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
        } else if (this.patients.length === 0) {
          Column() {
            Image($r('app.media.ic_patient'))
              .width(120)
              .height(120)
            Text('暂无患者记录')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
            Text('点击右上角添加患者')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.patients, (patient: VisitRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(patient.name)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                      Text(`住院号：${patient.hospitalId}`)
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text(patient.diagnosis ? '已完成就诊' : (patient.deviceId ? '就诊中' : '待就诊'))
                      .fontSize(14)
                      .fontColor(patient.diagnosis ? '#4CAF50' : (patient.deviceId ? '#FFA000' : '#666666'))
                      .backgroundColor(patient.diagnosis ? '#E8F5E9' : (patient.deviceId ? '#FFF3E0' : '#F5F5F5'))
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(12)
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 8, left: 16, right: 16 })

                  Column() {
                    Row() {
                      Text('联系方式：')
                        .fontSize(14)
                        .fontColor('#999999')
                      Text(patient.phone)
                        .fontSize(14)
                        .fontColor('#333333')
                    }
                    .width('100%')
                    .margin({ top: 4 })

                    Row() {
                      Text('身份证号：')
                        .fontSize(14)
                        .fontColor('#999999')
                      Text(patient.idCard)
                        .fontSize(14)
                        .fontColor('#333333')
                    }
                    .width('100%')
                    .margin({ top: 4 })

                    Row() {
                      Text('就诊时间：')
                        .fontSize(14)
                        .fontColor('#999999')
                      Text(new Date(patient.createTime).toLocaleString('zh-CN'))
                        .fontSize(14)
                        .fontColor('#333333')
                    }
                    .width('100%')
                    .margin({ top: 4 })
                  }
                  .padding({ left: 16, right: 16 })

                  Row() {
                    Button('编辑', { type: ButtonType.Normal })
                      .height(32)
                      .backgroundColor('#2196F3')
                      .fontColor('#FFFFFF')
                      .borderRadius(16)
                      .margin({ right: 8 })
                      .onClick(() => {
                        this.editPatient(patient);
                      })

                    Button('删除', { type: ButtonType.Normal })
                      .height(32)
                      .backgroundColor('#FF4081')
                      .fontColor('#FFFFFF')
                      .borderRadius(16)
                      .onClick(() => {
                        this.deletePatient(patient);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .padding({ right: 16, bottom: 12 })
                }
                .width('100%')
                .backgroundColor('#FFFFFF')
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
        this.isRefreshing = true;
        await this.loadPatients();
        this.isRefreshing = false;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}