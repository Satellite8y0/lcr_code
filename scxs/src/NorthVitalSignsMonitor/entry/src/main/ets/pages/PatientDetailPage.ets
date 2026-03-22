import router from '@ohos.router';
import { deviceRdbInstance, DeviceData } from '../common/database/DeviceRdb';
import patientRdbInstance, { VisitRecord } from '../common/database/PatientRdb';
import ThresholdRdb, { ThresholdData } from '../common/database/ThresholdRdb';
import { IdCardUtil } from '../common/utils/IdCardUtil';
import promptAction from '@ohos.promptAction';
import { vitalSignsRdbInstance, TemperatureData, BloodPressureData, HeartRateData, BloodOxygenData } from '../common/database/VitalSignsRdb';
import common from '@ohos.app.ability.common';

interface CombinedVitalSignData {
  measureTime: string;
  temperature: string;
  bloodPressure: string;
  heartRate: string;
  bloodOxygen: string;
  hasAbnormal: boolean;
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

interface GeneratedTypeLiteralInterface_2 {
  combinedData: CombinedVitalSignData[];
  hospitalId: string;
  date: string;
}

interface RouterParams {
  url: string;
  params: GeneratedTypeLiteralInterface_2
}

interface VitalSignData {
  title: string;
  value: string | number;
  isAbnormal: boolean;
  unit: string;
  type: string;
  hospitalId?: string;
  timestamp: number;
}

@CustomDialog
struct ThresholdDialog {
  @Link threshold: ThresholdData;
  controller: CustomDialogController;

  @Builder
  ThresholdItem(title: string, value: string, unit: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#666666')
      Row() {
        Text(value)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(unit)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 12, bottom: 12 })
    .borderWidth(title !== '血氧' ? { bottom: 1 } : 0)
    .borderColor(title !== '血氧' ? { bottom: '#EEEEEE' } : 'transparent')
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('监测阈值设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('关闭', { type: ButtonType.Normal })
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      // 阈值列表
      Column() {
        this.ThresholdItem('体温', `${this.threshold.temperatureMin} - ${this.threshold.temperatureMax}`, '℃')
        this.ThresholdItem('收缩压', `${this.threshold.systolicPressureMin} - ${this.threshold.systolicPressureMax}`, 'mmHg')
        this.ThresholdItem('舒张压', `${this.threshold.diastolicPressureMin} - ${this.threshold.diastolicPressureMax}`, 'mmHg')
        this.ThresholdItem('心率', `${this.threshold.heartRateMin} - ${this.threshold.heartRateMax}`, '次/分')
        this.ThresholdItem('血氧', `${this.threshold.bloodOxygenMin} - ${this.threshold.bloodOxygenMax}`, '%')
      }
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

interface GeneratedTypeLiteralInterface_1 {
  visit: VisitRecord;
}

@Component
struct VitalSignItemComponent {
  @Prop vitalSignData: VitalSignData;

  build() {
    Column() {
      Row() {
        Text(this.vitalSignData.title)
          .fontSize(14)
          .fontColor('#666666')
        Text(this.vitalSignData.isAbnormal ? '异常' : '正常')
          .fontSize(12)
          .fontColor(this.vitalSignData.isAbnormal ? '#F44336' : '#4CAF50')
          .backgroundColor(this.vitalSignData.isAbnormal ? '#FFEBEE' : '#E8F5E9')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 4 })

      Row() {
        Text(this.vitalSignData.value.toString())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.vitalSignData.isAbnormal ? '#F44336' : '#333333')
        Text(this.vitalSignData.unit)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 4 })
      }
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(12)
    .width('48%')
    .height(100)
    .shadow({ radius: 1, color: 'rgba(0, 0, 0, 0.05)', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/VitalSignTrendPage',
        params: {
          type: this.vitalSignData.type,
          title: this.vitalSignData.title + '趋势',
          hospitalId: this.vitalSignData.hospitalId,
          timestamp: this.vitalSignData.timestamp
        }
      });
    })
  }
}

@CustomDialog
struct VisitDialog {
  controller: CustomDialogController;
  @Link isEditing: boolean;
  @Link editingVisit: VisitForm;
  private loadVisits: () => Promise<void> = () => Promise.resolve();

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
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

@Entry
@Component
struct PatientDetailPage {
  @State visit: VisitRecord | null = null;
  @State device: DeviceData | null = null;
  @State threshold: ThresholdData | null = null;
  @State latestTemperature: TemperatureData | null = null;
  @State latestBloodPressure: BloodPressureData | null = null;
  @State latestHeartRate: HeartRateData | null = null;
  @State latestBloodOxygen: BloodOxygenData | null = null;
  @State combinedData: CombinedVitalSignData[] = [];
  @State updateTimestamp: number = 0;
  @State searchText: string = '';
  @State isEditing: boolean = false;
  @State editingVisit: VisitForm = {
    name: '',
    phone: '',
    idCard: '',
    deviceId: '',
    diagnosis: '',
    createTime: new Date().toISOString(),
    remark: ''
  };
  private refreshTimer: number = -1;
  private readonly refreshInterval: number = 5000; // 5秒刷新一次
  private dataSource: VisitDataSource = new VisitDataSource();
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: VisitDialog({
      isEditing: $isEditing,
      editingVisit: $editingVisit,
      loadVisits: this.loadVisits.bind(this)
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -24 }
  });
  thresholdDialogController: CustomDialogController = new CustomDialogController({
    builder: ThresholdDialog({
      threshold: $threshold
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    offset: { dx: 0, dy: -24 }
  });

  aboutToAppear() {
    // 初始化生命体征数据库
    const context = getContext(this) as common.Context;

    // 初始化阈值数据库
    try {
      ThresholdRdb.initDb(context).then(() => {
        console.info('阈值数据库初始化成功');
      });
    } catch (error) {
      console.error('阈值数据库初始化失败:', error);
    }

    vitalSignsRdbInstance.initDb(context).then(() => {
      this.loadData().then(() => {
        // 设置定时器，每3秒刷新一次数据
        this.startRefreshTimer();
      });
    });
  }

  aboutToDisappear() {
    this.stopRefreshTimer();
  }

  private startRefreshTimer() {
    // 清除已存在的定时器
    this.stopRefreshTimer();

    // 创建新的定时器
    this.refreshTimer = setInterval(() => {
      console.info('定时刷新生命体征数据');
      this.refreshVitalSigns();
    }, this.refreshInterval);
  }

  private stopRefreshTimer() {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  // 添加刷新生命体征数据的方法
  private async refreshVitalSigns() {
    if (!this.visit?.hospitalId || this.visit.diagnosis) return;

    try {
      // 确保阈值数据已加载
      if (!this.threshold) {
        this.threshold = await ThresholdRdb.getThresholdByHospitalId(this.visit.hospitalId);
        console.info('刷新时重新获取阈值数据:', JSON.stringify(this.threshold));
        if (!this.threshold) {
          console.error('未找到阈值数据');
          return;
        }
      }

      // 获取最新的生命体征数据
      const temperatures = await vitalSignsRdbInstance.getTemperaturesByHospitalId(this.visit.hospitalId);
      const newTemperature = temperatures.length > 0 ? temperatures[0] : null;

      console.info('当前显示的体温数据:', JSON.stringify(this.latestTemperature));
      console.info('数据库中的最新体温数据:', JSON.stringify(newTemperature));
      console.info('当前阈值设置 - 体温:', this.threshold.temperatureMin, '-', this.threshold.temperatureMax);

      if (newTemperature) {
        // 检查体温是否异常
        const isTemperatureAbnormal = newTemperature.value < this.threshold.temperatureMin ||
          newTemperature.value > this.threshold.temperatureMax;

        const updatedTemperature: TemperatureData = {
          id: newTemperature.id,
          hospitalId: newTemperature.hospitalId,
          value: newTemperature.value,
          measureTime: newTemperature.measureTime,
          isAbnormal: isTemperatureAbnormal
        };

        this.updateTimestamp = new Date().getTime();
        this.latestTemperature = updatedTemperature;

        console.info('体温数据已更新 - 值:', updatedTemperature.value,
          '是否异常:', isTemperatureAbnormal,
          '阈值范围:', this.threshold.temperatureMin, '-', this.threshold.temperatureMax);
      }

      const bloodPressures = await vitalSignsRdbInstance.getBloodPressuresByHospitalId(this.visit.hospitalId);
      const newBloodPressure = bloodPressures.length > 0 ? bloodPressures[0] : null;
      if (newBloodPressure && (!this.latestBloodPressure ||
        newBloodPressure.measureTime !== this.latestBloodPressure.measureTime)) {
        // 检查血压是否异常
        const isSystolicAbnormal = newBloodPressure.systolic < this.threshold.systolicPressureMin ||
          newBloodPressure.systolic > this.threshold.systolicPressureMax;
        const isDiastolicAbnormal = newBloodPressure.diastolic < this.threshold.diastolicPressureMin ||
          newBloodPressure.diastolic > this.threshold.diastolicPressureMax;

        const updatedBloodPressure: BloodPressureData = {
          id: newBloodPressure.id,
          hospitalId: newBloodPressure.hospitalId,
          systolic: newBloodPressure.systolic,
          diastolic: newBloodPressure.diastolic,
          measureTime: newBloodPressure.measureTime,
          isAbnormal: isSystolicAbnormal || isDiastolicAbnormal
        };

        this.updateTimestamp = new Date().getTime();
        this.latestBloodPressure = updatedBloodPressure;

        console.info('血压数据已更新:', JSON.stringify(updatedBloodPressure),
          '是否异常:', isSystolicAbnormal || isDiastolicAbnormal,
          '收缩压阈值:', this.threshold.systolicPressureMin, '-', this.threshold.systolicPressureMax,
          '舒张压阈值:', this.threshold.diastolicPressureMin, '-', this.threshold.diastolicPressureMax);
      }

      const heartRates = await vitalSignsRdbInstance.getHeartRatesByHospitalId(this.visit.hospitalId);
      const newHeartRate = heartRates.length > 0 ? heartRates[0] : null;
      if (newHeartRate && (!this.latestHeartRate ||
        newHeartRate.measureTime !== this.latestHeartRate.measureTime)) {
        // 检查心率是否异常
        const isHeartRateAbnormal = newHeartRate.value < this.threshold.heartRateMin ||
          newHeartRate.value > this.threshold.heartRateMax;

        const updatedHeartRate: HeartRateData = {
          id: newHeartRate.id,
          hospitalId: newHeartRate.hospitalId,
          value: newHeartRate.value,
          measureTime: newHeartRate.measureTime,
          isAbnormal: isHeartRateAbnormal
        };

        this.updateTimestamp = new Date().getTime();
        this.latestHeartRate = updatedHeartRate;

        console.info('心率数据已更新:', JSON.stringify(updatedHeartRate),
          '是否异常:', isHeartRateAbnormal,
          '阈值范围:', this.threshold.heartRateMin, '-', this.threshold.heartRateMax);
      }

      const bloodOxygens = await vitalSignsRdbInstance.getBloodOxygensByHospitalId(this.visit.hospitalId);
      const newBloodOxygen = bloodOxygens.length > 0 ? bloodOxygens[0] : null;
      if (newBloodOxygen && (!this.latestBloodOxygen ||
        newBloodOxygen.measureTime !== this.latestBloodOxygen.measureTime)) {
        // 检查血氧是否异常
        const isBloodOxygenAbnormal = newBloodOxygen.value < this.threshold.bloodOxygenMin ||
          newBloodOxygen.value > this.threshold.bloodOxygenMax;

        const updatedBloodOxygen: BloodOxygenData = {
          id: newBloodOxygen.id,
          hospitalId: newBloodOxygen.hospitalId,
          value: newBloodOxygen.value,
          measureTime: newBloodOxygen.measureTime,
          isAbnormal: isBloodOxygenAbnormal
        };

        this.updateTimestamp = new Date().getTime();
        this.latestBloodOxygen = updatedBloodOxygen;

        console.info('血氧数据已更新:', JSON.stringify(updatedBloodOxygen),
          '是否异常:', isBloodOxygenAbnormal,
          '阈值范围:', this.threshold.bloodOxygenMin, '-', this.threshold.bloodOxygenMax);
      }

    } catch (error) {
      console.error('刷新生命体征数据失败:', error);
    }
  }

  async loadData() {
    try {
      const params = router.getParams() as GeneratedTypeLiteralInterface_1;
      if (!params?.visit) {
        promptAction.showToast({ message: '未找到就诊记录' });
        router.back();
        return;
      }
      this.visit = params.visit;

      if (this.visit.hospitalId) {
        console.info(`正在加载患者数据，住院号: ${this.visit.hospitalId}`);
        // 加载阈值数据
        try {
          this.threshold = await ThresholdRdb.getThresholdByHospitalId(this.visit.hospitalId);
          console.info('获取到患者[%s]的阈值设置: %s', this.visit.hospitalId, JSON.stringify(this.threshold));

          if (!this.threshold) {
            // 如果没有找到阈值数据，创建新的阈值记录
            const defaultThreshold: ThresholdData = {
              hospitalId: this.visit.hospitalId,
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
              updateTime: new Date().toISOString(),
              isDefault: false
            };

            const success = await ThresholdRdb.insertThreshold(defaultThreshold);
            if (success) {
              this.threshold = defaultThreshold;
              console.info('创建阈值数据成功:', JSON.stringify(this.threshold));
            } else {
              console.error('创建阈值数据失败');
            }
          }
        } catch (error) {
          console.error('加载或创建阈值数据失败:', error);
        }

        if (this.visit.deviceId && !this.visit.diagnosis) {
          const deviceData = await deviceRdbInstance.getDeviceById(this.visit.deviceId);
          this.device = deviceData || null;

          // 获取最新的生命体征数据
          await this.refreshVitalSigns();
        }
      }
    } catch (error) {
      console.error('加载数据失败:', error);
      promptAction.showToast({ message: '加载数据失败' });
    }
  }

  @Builder
  SearchBuilder() {
    Column() {
      Row() {
        Search({ value: this.searchText, placeholder: '搜索姓名、电话、身份证号或时间(2024-01-20)' })
          .layoutWeight(1)
          .height(40)
          .margin({ right: 16 })
          .onChange((value: string) => {
            this.searchText = value;
            this.filterVisits();
          })
          .onSubmit((value: string) => {
            this.searchText = value;
            this.filterVisits();
          })

        Button('添加就诊')
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(() => {
            this.isEditing = false;
            this.editingVisit = {
              name: '',
              phone: '',
              idCard: '',
              deviceId: '',
              diagnosis: '',
              createTime: new Date().toISOString(),
              remark: ''
            };
            this.dialogController.open();
          })
      }
      .width('100%')
      .padding(4)
      .backgroundColor('#FFFFFF')

      if (this.searchText) {
        Text('支持格式：2024-01-20 或 2024-01')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 16, top: 4 })
      }
    }
    .backgroundColor('#FFFFFF')
  }

  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  private async loadCombinedData() {
    if (!this.visit?.hospitalId) return;

    try {
      const temperatures = await vitalSignsRdbInstance.getTemperaturesByHospitalId(this.visit.hospitalId);
      const bloodPressures = await vitalSignsRdbInstance.getBloodPressuresByHospitalId(this.visit.hospitalId);
      const heartRates = await vitalSignsRdbInstance.getHeartRatesByHospitalId(this.visit.hospitalId);
      const bloodOxygens = await vitalSignsRdbInstance.getBloodOxygensByHospitalId(this.visit.hospitalId);

      // 获取所有测量时间并去重排序
      const allTimes = new Set([
        ...temperatures.map(t => t.measureTime),
        ...bloodPressures.map(bp => bp.measureTime),
        ...heartRates.map(hr => hr.measureTime),
        ...bloodOxygens.map(bo => bo.measureTime)
      ]);

      this.combinedData = Array.from(allTimes).sort((a, b) => new Date(b).getTime() - new Date(a).getTime())
        .map(time => {
          const temp = temperatures.find(t => t.measureTime === time);
          const bp = bloodPressures.find(b => b.measureTime === time);
          const hr = heartRates.find(h => h.measureTime === time);
          const bo = bloodOxygens.find(b => b.measureTime === time);

          const data: CombinedVitalSignData = {
            measureTime: this.formatTime(new Date(time)),
            temperature: temp ? `${temp.value.toFixed(1)}℃` : '--',
            bloodPressure: bp ? `${bp.systolic}/${bp.diastolic}` : '--',
            heartRate: hr ? `${hr.value}` : '--',
            bloodOxygen: bo ? `${bo.value}%` : '--',
            hasAbnormal: (temp?.isAbnormal || bp?.isAbnormal || hr?.isAbnormal || bo?.isAbnormal) || false
          };
          return data;
        });
    } catch (error) {
      console.error('加载组合数据失败:', error);
    }
  }

  private filterVisits(): void {
    if (!this.searchText) {
      this.loadVisits();
      return;
    }

    // 获取所有记录并应用过滤
    patientRdbInstance.getAllVisitRecords().then(visits => {
      const filtered = this.filterVisitsBySearch(visits);
      this.dataSource.addData(filtered);
    }).catch((error: Error) => {
      console.error('获取就诊记录失败:', error.message);
      promptAction.showToast({ message: '获取就诊记录失败' });
    });
  }

  private filterVisitsBySearch(visits: VisitRecord[]): VisitRecord[] {
    if (!this.searchText) {
      return visits;
    }

    // 尝试解析搜索文本是否为日期格式 (支持 2024-01-20 或 2024-01 或 2024/01/20 或 2024/01)
    const isDateSearch = this.searchText.match(/^\d{4}(-|\/)\d{1,2}((-|\/)\d{1,2})?$/);

    return visits.filter(visit => {
      // 如果是日期搜索
      if (isDateSearch) {
        const visitDate = new Date(visit.createTime);
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
      return visit.name.toLowerCase().includes(searchLower) ||
      visit.phone.includes(this.searchText) ||
      visit.idCard.includes(this.searchText) ||
        (visit.hospitalId ? visit.hospitalId.includes(this.searchText) : false);
    });
  }

  async loadVisits(): Promise<void> {
    try {
      console.info('开始加载就诊记录');
      const newVisits = await patientRdbInstance.getAllVisitRecords();
      console.info('获取到就诊记录数量:', newVisits.length);

      if (this.searchText) {
        const filtered = this.filterVisitsBySearch(newVisits);
        this.dataSource.addData(filtered);
      } else {
        this.dataSource.addData(newVisits);
      }
    } catch (error) {
      console.error('加载就诊记录失败:', error);
      promptAction.showToast({ message: '加载就诊记录失败' });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
          .onClick(() => {
            router.back();
          })
        Text('患者详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Blank()
        if (this.visit) {
          if (this.visit.diagnosis) {
            Row() {
              Image($r('app.media.visit_selected'))
                .width(16)
                .height(16)
                .margin({ right: 8 })
              Text('已完成就诊')
                .fontSize(14)
                .fontColor('#4CAF50')
            }
            .backgroundColor('#E8F5E9')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
          } else if (this.visit.deviceId) {
            Row() {
              Image($r('app.media.device_bound'))
                .width(16)
                .height(16)
                .margin({ right: 8 })
              Text('正在就诊')
                .fontSize(14)
                .fontColor('#FFA000')
            }
            .backgroundColor('#FFF3E0')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
          } else {
            Row() {
              Image($r('app.media.device_unbound'))
                .width(16)
                .height(16)
                .margin({ right: 8 })
              Text('待绑定')
                .fontSize(14)
                .fontColor('#F44336')
            }
            .backgroundColor('#FFEBEE')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
          }
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2196F3')

      if (this.visit) {
        Column() {
          Scroll() {
            Column() {
              // 患者基本信息卡片
              Column() {
                Row() {
                  Image($r('app.media.ic_public_avatar'))
                    .width(60)
                    .height(60)
                    .borderRadius(30)
                    .margin({ right: 12 })

                  Column() {
                    Text(this.visit.name)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                    Text(`${IdCardUtil.getGender(this.visit.idCard)} | ${IdCardUtil.getAge(this.visit.idCard)}岁`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                    Row() {
                      Text(`住院号: ${this.visit.hospitalId}`)
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 16, bottom: 8 })

                if (this.visit.hospitalId && (this.visit.deviceId || this.visit.diagnosis)) {
                  Button({ type: ButtonType.Normal }) {
                    Row() {
                      Image($r('app.media.ic_threshold'))
                        .width(20)
                        .height(20)
                        .margin({ right: 8 })
                      Text('查看监测阈值设置')
                        .fontSize(16)
                        .fontColor('#2196F3')
                    }
                  }
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ffffffff')
                  .margin({ top: 6, bottom: 12 })
                  .onClick(() => {
                    if (this.threshold) {
                      this.thresholdDialogController.open();
                    } else {
                      promptAction.showToast({ message: '暂无阈值数据' });
                    }
                  })
                }
              }
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ left: 16, right: 16, top: 12 })
              .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

              // 设备信息和生命体征数据卡片（仅在正在就诊时显示）
              if (this.device && !this.visit.diagnosis) {
                Column() {
                  // 标题栏和状态信息
                  Row() {
                    Text('设备信息')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                    Row() {
                      Text(this.getStatusText(this.device.status))
                        .fontSize(12)
                        .fontColor(this.getStatusColor(this.device.status))
                      Text('•')
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ left: 8, right: 8 })
                      Text(`电量: ${this.device.batteryLevel}%`)
                        .fontSize(12)
                        .fontColor(this.device.batteryLevel > 20 ? '#4CAF50' : '#F44336')
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .margin({ bottom: 12 })

                  // 设备详细信息
                  Column({ space: 8 }) {
                    // 设备名称
                    Row() {
                      Text('设备名称')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width('25%')
                      Text(this.device.deviceName)
                        .fontSize(14)
                        .fontColor('#333333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('75%')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)

                    // 设备ID
                    Row() {
                      Text('设备ID')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width('25%')
                      Text(this.device.deviceId)
                        .fontSize(14)
                        .fontColor('#333333')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('75%')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                  }
                  .backgroundColor('#F8F9FA')
                  .padding(12)
                  .borderRadius(8)
                }
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .margin({ top: 12, left: 16, right: 16 })
                .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

                // 生命体征数据卡片
                Column() {
                  Row() {
                    Text('实时生命体征')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                    Text('点击查看趋势')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .margin({ bottom: 12 })

                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                    if (this.latestTemperature) {
                      VitalSignItemComponent({
                        vitalSignData: {
                          title: '体温',
                          value: this.latestTemperature.value.toFixed(1),
                          isAbnormal: this.latestTemperature.isAbnormal,
                          unit: '℃',
                          type: 'temperature',
                          hospitalId: this.visit?.hospitalId,
                          timestamp: this.updateTimestamp
                        }
                      })
                    }

                    if (this.latestBloodPressure) {
                      VitalSignItemComponent({
                        vitalSignData: {
                          title: '血压',
                          value: `${this.latestBloodPressure.systolic}/${this.latestBloodPressure.diastolic}`,
                          isAbnormal: this.latestBloodPressure.isAbnormal,
                          unit: 'mmHg',
                          type: 'bloodPressure',
                          hospitalId: this.visit?.hospitalId,
                          timestamp: this.updateTimestamp
                        }
                      })
                    }

                    if (this.latestHeartRate) {
                      VitalSignItemComponent({
                        vitalSignData: {
                          title: '心率',
                          value: this.latestHeartRate.value,
                          isAbnormal: this.latestHeartRate.isAbnormal,
                          unit: '次/分',
                          type: 'heartRate',
                          hospitalId: this.visit?.hospitalId,
                          timestamp: this.updateTimestamp
                        }
                      })
                    }

                    if (this.latestBloodOxygen) {
                      VitalSignItemComponent({
                        vitalSignData: {
                          title: '血氧',
                          value: this.latestBloodOxygen.value,
                          isAbnormal: this.latestBloodOxygen.isAbnormal,
                          unit: '%',
                          type: 'oxygen',
                          hospitalId: this.visit?.hospitalId,
                          timestamp: this.updateTimestamp
                        }
                      })
                    }
                  }
                }
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .margin({ top: 12, left: 16, right: 16 })
                .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })
              }

              if (this.visit.diagnosis) {
                // 数据卡片
                Column() {
                  Row() {
                    Text('历史生命体征')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                    Text('点击查看趋势')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .margin({ bottom: 12 })

                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                    Column() {
                      Text('体温')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ bottom: 8 })
                      Row() {
                        Image($r('app.media.ic_temperature'))
                          .width(24)
                          .height(24)
                          .margin({ right: 8 })
                        Text('查看趋势')
                          .fontSize(16)
                          .fontColor('#2196F3')
                      }
                    }
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .padding(12)
                    .width('48%')
                    .height(80)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/VitalSignTrendPage',
                        params: {
                          type: 'temperature',
                          title: '体温趋势',
                          hospitalId: this.visit?.hospitalId
                        }
                      });
                    })

                    Column() {
                      Text('血压')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ bottom: 8 })
                      Row() {
                        Image($r('app.media.ic_blood_pressure'))
                          .width(24)
                          .height(24)
                          .margin({ right: 8 })
                        Text('查看趋势')
                          .fontSize(16)
                          .fontColor('#2196F3')
                      }
                    }
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .padding(12)
                    .width('48%')
                    .height(80)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/VitalSignTrendPage',
                        params: {
                          type: 'bloodPressure',
                          title: '血压趋势',
                          hospitalId: this.visit?.hospitalId
                        }
                      });
                    })

                    Column() {
                      Text('心率')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ bottom: 8 })
                      Row() {
                        Image($r('app.media.ic_heart_rate'))
                          .width(24)
                          .height(24)
                          .margin({ right: 8 })
                        Text('查看趋势')
                          .fontSize(16)
                          .fontColor('#2196F3')
                      }
                    }
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .padding(12)
                    .width('48%')
                    .height(80)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/VitalSignTrendPage',
                        params: {
                          type: 'heartRate',
                          title: '心率趋势',
                          hospitalId: this.visit?.hospitalId
                        }
                      });
                    })

                    Column() {
                      Text('血氧')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ bottom: 8 })
                      Row() {
                        Image($r('app.media.ic_data'))
                          .width(24)
                          .height(24)
                          .margin({ right: 8 })
                        Text('查看趋势')
                          .fontSize(16)
                          .fontColor('#2196F3')
                      }
                    }
                    .backgroundColor('#FFFFFF')
                    .borderRadius(16)
                    .padding(12)
                    .width('48%')
                    .height(80)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/VitalSignTrendPage',
                        params: {
                          type: 'oxygen',
                          title: '血氧趋势',
                          hospitalId: this.visit?.hospitalId
                        }
                      });
                    })
                  }
                }
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .margin({ top: 12, left: 16, right: 16 })
                .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })
              }

              // 底部占位，为固定按钮留出空间
              Column()
                .height(80)
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .layoutWeight(1)

          // 底部按钮，固定在滚动区域下方
          Button() {
            Row() {
              Image($r('app.media.ic_heart_rate'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('查看所有体征数据')
                .fontSize(16)
                .fontColor('#FFFFFF')
            }
          }
          .width('90%')
          .height(48)
          .backgroundColor('#2196F3')
          .margin({ bottom: 20 })
          .onClick(() => {
            this.loadCombinedData().then(() => {
              const routerParams: RouterParams = {
                url: 'pages/AllVitalSignsPage',
                params: {
                  combinedData: this.combinedData,
                  hospitalId: this.visit?.hospitalId || '',
                  date: new Date().toLocaleDateString('zh-CN')
                }
              };
              router.pushUrl(routerParams);
            });
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F0F3F8')
      } else {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
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

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return 0;
  }

  getData(index: number): VisitRecord {
    return {} as VisitRecord;  // 返回一个空对象而不是 null
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
  private visits: VisitRecord[] = [];

  public totalCount(): number {
    return this.visits.length;
  }

  public getData(index: number): VisitRecord {
    return this.visits[index];
  }

  public addData(visits: VisitRecord[]): void {
    this.visits = visits;
    this.notifyDataReload();
  }
}