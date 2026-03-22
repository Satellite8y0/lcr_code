import router from '@ohos.router';
import { vitalSignsRdbInstance } from '../common/database/VitalSignsRdb';

interface CombinedVitalSignData {
  measureTime: string;
  temperature: string;
  bloodPressure: string;
  heartRate: string;
  bloodOxygen: string;
  temperatureAbnormal: boolean;
  bloodPressureAbnormal: boolean;
  heartRateAbnormal: boolean;
  bloodOxygenAbnormal: boolean;
}

interface RouteParams {
  combinedData: CombinedVitalSignData[];
  hospitalId: string;
  date: string;
}

@Entry
@Component
struct AllVitalSignsPage {
  @State combinedData: CombinedVitalSignData[] = [];
  @State date: string = '';
  @State hospitalId: string = '';

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    console.info('AllVitalSignsPage - Received params:', JSON.stringify(params));
    this.combinedData = params.combinedData || [];
    console.info('AllVitalSignsPage - Combined data length:', this.combinedData.length);
    this.hospitalId = params.hospitalId || '';
    this.date = params.date || '';
  }

  private getValueColor(value: string, hasAbnormal: boolean): string {
    if (value === '--') return '#999999';
    return hasAbnormal ? '#F44336' : '#4CAF50';
  }

  @Builder
  TableHeader() {
    Row() {
      Text('时间')
        .fontSize(14)
        .fontColor('#666666')
        .width('20%')
        .textAlign(TextAlign.Center)
      Text('体温')
        .fontSize(14)
        .fontColor('#666666')
        .width('20%')
        .textAlign(TextAlign.Center)
      Text('血压')
        .fontSize(14)
        .fontColor('#666666')
        .width('20%')
        .textAlign(TextAlign.Center)
      Text('心率')
        .fontSize(14)
        .fontColor('#666666')
        .width('20%')
        .textAlign(TextAlign.Center)
      Text('血氧')
        .fontSize(14)
        .fontColor('#666666')
        .width('20%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(40)
    .backgroundColor('#F5F5F5')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  TableCell(text: string, isAbnormal: boolean = false) {
    Text(text || '--')
      .fontSize(14)
      .fontColor(text === '--' ? '#999999' : (isAbnormal ? '#FF0000' : '#182431'))
      .textAlign(TextAlign.Center)
      .width('20%')
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
        Text('生命体征数据')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2196F3')

      // 日期显示
      Text(this.date)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })
        .textAlign(TextAlign.Center)
        .width('100%')

      // 表格头部
      this.TableHeader()

      // 数据列表
      List() {
        ForEach(this.combinedData, (item: CombinedVitalSignData) => {
          ListItem() {
            Row() {
              this.TableCell(item.measureTime)
              this.TableCell(item.temperature, item.temperatureAbnormal)
              this.TableCell(item.bloodPressure, item.bloodPressureAbnormal)
              this.TableCell(item.heartRate, item.heartRateAbnormal)
              this.TableCell(item.bloodOxygen, item.bloodOxygenAbnormal)
            }
            .width('100%')
            .height(40)
            .backgroundColor('#FFFFFF')
            .padding({ left: 16, right: 16 })
            .borderWidth({ bottom: 1 })
            .borderColor('#EEEEEE')
          }
        })
      }
      .width('100%')
      .layoutWeight(1)

      // 底部说明
      Row() {
        Row() {
          Text('●')
            .fontSize(16)
            .fontColor('#182431')
            .margin({ right: 4 })
          Text('正常')
            .fontSize(14)
            .fontColor('#666666')
        }
        .margin({ right: 16 })

        Row() {
          Text('--')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 4 })
          Text('无数据')
            .fontSize(14)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#EEEEEE' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}