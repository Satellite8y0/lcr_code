import router from '@ohos.router';
import { vitalSignsRdbInstance, TemperatureData, BloodPressureData, HeartRateData, BloodOxygenData } from '../common/database/VitalSignsRdb';
import ThresholdRdb, { ThresholdData } from '../common/database/ThresholdRdb';
import common from '@ohos.app.ability.common';

// 定义路由参数接口
interface RouteParams {
  type: string;
  title: string;
  hospitalId: string;
  date: string;
}

// 定义测量数据项的接口
interface MeasurementItem {
  time: string;
  value: string;
  isAbnormal: boolean;
  abnormalReason?: string;
}

// 定义血压值的接口
interface BloodPressureValue {
  systolic: number;
  diastolic: number;
}

@Entry
@Component
struct PatientDetailDataPage {
  @State type: string = '';
  @State title: string = '';
  @State hospitalId: string = '';
  @State date: string = '';
  @State measureData: MeasurementItem[] = [];
  @State isLoading: boolean = true;
  @State threshold: ThresholdData | null = null;

  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 获取异常原因
  private getAbnormalReason(type: string, value: number | BloodPressureValue): string {
    if (!this.threshold) return '';

    switch (type) {
      case 'temperature':
        if (typeof value === 'number') {
          if (value > this.threshold.temperatureMax) return '体温偏高';
          if (value < this.threshold.temperatureMin) return '体温偏低';
        }
        break;
      case 'bloodPressure':
        if (typeof value === 'object') {
          if (value.systolic > this.threshold.systolicPressureMax) return '收缩压偏高';
          if (value.systolic < this.threshold.systolicPressureMin) return '收缩压偏低';
          if (value.diastolic > this.threshold.diastolicPressureMax) return '舒张压偏高';
          if (value.diastolic < this.threshold.diastolicPressureMin) return '舒张压偏低';
        }
        break;
      case 'heartRate':
        if (typeof value === 'number') {
          if (value > this.threshold.heartRateMax) return '心率偏快';
          if (value < this.threshold.heartRateMin) return '心率偏慢';
        }
        break;
      case 'oxygen':
        if (typeof value === 'number') {
          if (value < this.threshold.bloodOxygenMin) return '血氧偏低';
        }
        break;
    }
    return '';
  }

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    this.type = params?.type || 'temperature';
    this.title = params?.title || '详情数据';
    this.hospitalId = params?.hospitalId || '';
    this.date = params?.date || '';
    this.loadData();
  }

  async loadData() {
    if (!this.hospitalId) {
      console.error('hospitalId is empty');
      return;
    }

    try {
      this.isLoading = true;
      console.info(`Loading data for hospitalId: ${this.hospitalId}, type: ${this.type}`);

      const context = getContext(this) as common.Context;
      await vitalSignsRdbInstance.initDb(context);

      // 初始化并加载阈值数据
      await ThresholdRdb.initDb(context);
      this.threshold = await ThresholdRdb.getThresholdByHospitalId(this.hospitalId);
      console.info('Loaded threshold data:', this.threshold);

      if (!this.threshold) {
        console.error('未找到阈值设置');
        // 继续加载数据，即使没有阈值设置
      }

      let data: TemperatureData[] | BloodPressureData[] | HeartRateData[] | BloodOxygenData[] = [];
      switch (this.type) {
        case 'temperature': {
          data = await vitalSignsRdbInstance.getTemperaturesByHospitalId(this.hospitalId);
          console.info('Loaded temperature data:', data);
          this.measureData = data.map((item: TemperatureData): MeasurementItem => ({
            time: this.formatTime(new Date(item.measureTime)),
            value: item.value.toFixed(1) + '°C',
            isAbnormal: item.isAbnormal,
            abnormalReason: this.getAbnormalReason('temperature', item.value)
          }));
          break;
        }
        case 'bloodPressure': {
          data = await vitalSignsRdbInstance.getBloodPressuresByHospitalId(this.hospitalId);
          this.measureData = data.map((item: BloodPressureData): MeasurementItem => ({
            time: this.formatTime(new Date(item.measureTime)),
            value: `${item.systolic}/${item.diastolic} mmHg`,
            isAbnormal: item.isAbnormal,
            abnormalReason: this.getAbnormalReason('bloodPressure', {
              systolic: item.systolic,
              diastolic: item.diastolic
            })
          }));
          break;
        }
        case 'heartRate': {
          data = await vitalSignsRdbInstance.getHeartRatesByHospitalId(this.hospitalId);
          this.measureData = data.map((item: HeartRateData): MeasurementItem => ({
            time: this.formatTime(new Date(item.measureTime)),
            value: item.value + '次/分',
            isAbnormal: item.isAbnormal,
            abnormalReason: this.getAbnormalReason('heartRate', item.value)
          }));
          break;
        }
        case 'oxygen': {
          data = await vitalSignsRdbInstance.getBloodOxygensByHospitalId(this.hospitalId);
          this.measureData = data.map((item: BloodOxygenData): MeasurementItem => ({
            time: this.formatTime(new Date(item.measureTime)),
            value: item.value + '%',
            isAbnormal: item.isAbnormal,
            abnormalReason: this.getAbnormalReason('oxygen', item.value)
          }));
          break;
        }
      }
    } catch (error) {
      console.error('加载详细数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 获取值的显示颜色
  private getValueColor(value: string, isAbnormal: boolean): string {
    if (!this.threshold) return '#333333'; // 如果没有阈值设置，显示默认颜色

    // 解析值
    try {
      switch (this.type) {
        case 'temperature': {
          const temp = parseFloat(value.replace('°C', ''));
          return (temp >= this.threshold.temperatureMin && temp <= this.threshold.temperatureMax)
            ? '#4CAF50' // 正常
            : '#F44336'; // 异常
        }
        case 'bloodPressure': {
          const values = value.split('/');
          const systolic = parseInt(values[0]);
          const diastolic = parseInt(values[1]);
          return (systolic >= this.threshold.systolicPressureMin &&
            systolic <= this.threshold.systolicPressureMax &&
            diastolic >= this.threshold.diastolicPressureMin &&
            diastolic <= this.threshold.diastolicPressureMax)
            ? '#4CAF50'
            : '#F44336';
        }
        case 'heartRate': {
          const rate = parseInt(value.replace('次/分', ''));
          return (rate >= this.threshold.heartRateMin && rate <= this.threshold.heartRateMax)
            ? '#4CAF50'
            : '#F44336';
        }
        case 'oxygen': {
          const oxygen = parseInt(value.replace('%', ''));
          return (oxygen >= this.threshold.bloodOxygenMin)
            ? '#4CAF50'
            : '#F44336';
        }
        default:
          return '#333333';
      }
    } catch (error) {
      console.error('解析值失败:', error);
      return '#333333';
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
        Text(this.title + '详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2B2B2B')

      // 页面内容
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 日期显示
            Text(this.date)
              .fontSize(16)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 16, top: 16, bottom: 16 })

            // 阈值信息显示
            if (this.threshold) {
              Column() {
                Text('参考范围')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })

                Row() {
                  Text(this.getThresholdText())
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
            }

            // 数据表格
            Column() {
              // 表头
              Row() {
                Text('时间')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('25%')
                Text('测量值')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('35%')
                Text('状态')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('40%')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 12 })
              .backgroundColor('#F5F5F5')
              .borderRadius({ topLeft: 16, topRight: 16 })

              // 表格内容
              List() {
                ForEach(this.measureData, (item: MeasurementItem) => {
                  ListItem() {
                    Row() {
                      Text(item.time)
                        .fontSize(14)
                        .width('25%')
                        .fontColor('#333333')
                      Text(item.value)
                        .fontSize(14)
                        .width('35%')
                        .fontColor(this.getValueColor(item.value, item.isAbnormal))
                      Column() {
                        if (item.isAbnormal && item.abnormalReason) {
                          Text(item.abnormalReason)
                            .fontSize(14)
                            .fontColor('#F44336')
                            .backgroundColor('#FFEBEE')
                            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                            .borderRadius(12)
                        } else {
                          Text('正常')
                            .fontSize(14)
                            .fontColor('#4CAF50')
                            .backgroundColor('#E8F5E9')
                            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                            .borderRadius(12)
                        }
                      }
                      .width('40%')
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  }
                })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })

              // 底部说明
              Row() {
                Text('颜色说明：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#666666')
                Text('正常')
                  .fontSize(14)
                  .fontColor('#4CAF50')
                  .margin({ right: 16, left: 4 })
                Text('异常')
                  .fontSize(14)
                  .fontColor('#F44336')
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Start)
              .margin({ top: 12 })
            }
            .width('100%')
            .margin({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F0F3F8')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }

  // 获取阈值显示文本
  private getThresholdText(): string {
    if (!this.threshold) return '';

    switch (this.type) {
      case 'temperature':
        return `体温：${this.threshold.temperatureMin.toFixed(1)}°C - ${this.threshold.temperatureMax.toFixed(1)}°C`;
      case 'bloodPressure':
        return `收缩压：${this.threshold.systolicPressureMin}-${this.threshold.systolicPressureMax} mmHg\n` +
          `舒张压：${this.threshold.diastolicPressureMin}-${this.threshold.diastolicPressureMax} mmHg`;
      case 'heartRate':
        return `心率：${this.threshold.heartRateMin}-${this.threshold.heartRateMax} 次/分`;
      case 'oxygen':
        return `血氧：${this.threshold.bloodOxygenMin}%-${this.threshold.bloodOxygenMax}%`;
      default:
        return '';
    }
  }
}