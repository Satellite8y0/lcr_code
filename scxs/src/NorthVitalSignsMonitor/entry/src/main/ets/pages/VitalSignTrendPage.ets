import router from '@ohos.router';
import { vitalSignsRdbInstance, TemperatureData, BloodPressureData, HeartRateData, BloodOxygenData } from '../common/database/VitalSignsRdb';
import common from '@ohos.app.ability.common';
import { McLineChart, Options } from '@mcui/mccharts'

interface GeneratedTypeLiteralInterface_2 {
  color: string;
  width: number;
}

interface GeneratedTypeLiteralInterface_1 {
  length: number;
  lineStyle: GeneratedTypeLiteralInterface_2;
}

interface GeneratedTypeLiteralInterface_3 {
  show: boolean;
}

interface GeneratedTypeLiteralInterface_5 {
  color: string;
  width: number;
}

interface GeneratedTypeLiteralInterface_4 {
  show: boolean;
  lineStyle: GeneratedTypeLiteralInterface_5;
}

interface GeneratedTypeLiteralInterface_6 {
  color: string;
  fontSize: number;
  fontWeight: number | string;
}

interface ChartYAxis {
  name: string;
  axisTick: GeneratedTypeLiteralInterface_1;
  axisLine: GeneratedTypeLiteralInterface_3;
  splitLine: GeneratedTypeLiteralInterface_4;
  axisLabel: GeneratedTypeLiteralInterface_6
}

interface GeneratedTypeLiteralInterface_7 {
  width: number;
  color: string;
}

interface GeneratedTypeLiteralInterface_8 {
  symbol: string;
  symbolSize: number;
}

interface ChartSeries {
  name: string;
  color: string;
  lineStyle: GeneratedTypeLiteralInterface_7;
  itemStyle: GeneratedTypeLiteralInterface_8;
  data: number[];
}

@Entry
@Component
struct VitalSignTrendPage {
  @State type: string = '';
  @State title: string = '';
  @State hospitalId: string = '';
  @State selectedTimeRange: string = '近6小时';
  @State currentDate: string = new Date().toLocaleDateString('zh-CN');
  @State data: TemperatureData[] | BloodPressureData[] | HeartRateData[] | BloodOxygenData[] = [];
  @State isLoading: boolean = true;
  @State average: string = '--';
  @State highest: string = '--';
  @State lowest: string = '--';
  @State chartOptions: Options = new Options({
    grid: {
      left: '10%',
      right: '10%',
      top: '10%',
      bottom: '10%'
    },
    xAxis: {
      type: 'category',
      data: [],
      axisLabel: {
        color: '#838383',
        fontSize: 28,
        fontWeight: '600'
      },
      axisLine: {
        show: true,
        lineStyle: {
          color: '#838383',
          width: 1
        }
      },
      axisTick: {
        show: true,
        length: 6,
        lineStyle: {
          color: '#838383',
          width: 1
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        color: '#838383',
        fontSize: 28,
        fontWeight: '600'
      },
      axisLine: {
        show: true,
        lineStyle: {
          color: '#838383',
          width: 1
        }
      },
      axisTick: {
        show: true,
        length: 6,
        lineStyle: {
          color: '#838383',
          width: 1
        }
      },
      splitLine: {
        show: true,
        lineStyle: {
          color: '#e5e5e5',
          width: 1
        }
      }
    },
    series: [],
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'line',
        lineStyle: {
          color: '#D9D9D9',
          width: 1
        }
      }
    }
  })


  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.type = params?.type || 'temperature';
    this.title = params?.title || '体征趋势';
    this.hospitalId = params?.hospitalId || '';
    this.loadData();
  }

  private calculateStatistics(data: TemperatureData[] | BloodPressureData[] | HeartRateData[] | BloodOxygenData[]) {
    // 如果数据为空，显示默认值
    if (!data || data.length === 0) {
      this.highest = '--';
      this.average = '--';
      this.lowest = '--';
      console.info('数据为空，显示默认值');
      return;
    }

    console.info(`开始计算统计值，数据长度: ${data.length}`);

    // 血压数据的特殊处理
    if (this.type === 'bloodPressure') {
      const bpData = data as BloodPressureData[];
      console.info('处理血压数据');

      let maxSystolic = Number(bpData[0].systolic);
      let minSystolic = Number(bpData[0].systolic);
      let maxDiastolic = Number(bpData[0].diastolic);
      let minDiastolic = Number(bpData[0].diastolic);
      let sumSystolic = 0;
      let sumDiastolic = 0;

      // 使用for循环计算
      for (let i = 0; i < bpData.length; i++) {
        const systolic = Number(bpData[i].systolic);
        const diastolic = Number(bpData[i].diastolic);

        if (systolic > maxSystolic) maxSystolic = systolic;
        if (systolic < minSystolic) minSystolic = systolic;
        if (diastolic > maxDiastolic) maxDiastolic = diastolic;
        if (diastolic < minDiastolic) minDiastolic = diastolic;

        sumSystolic += systolic;
        sumDiastolic += diastolic;
      }

      const avgSystolic = Math.round(sumSystolic / bpData.length);
      const avgDiastolic = Math.round(sumDiastolic / bpData.length);

      // 使用setTimeout确保状态更新在UI线程上执行
      setTimeout(() => {
        this.highest = `${maxSystolic}/${maxDiastolic}`;
        this.average = `${avgSystolic}/${avgDiastolic}`;
        this.lowest = `${minSystolic}/${minDiastolic}`;
      }, 0);

      return;
    }

    // 处理其他类型的数据（体温、心率、血氧）
    const typedData = data as Array<TemperatureData | HeartRateData | BloodOxygenData>;

    let max = Number(typedData[0].value);
    let min = Number(typedData[0].value);
    let sum = 0;

    // 使用for循环计算
    for (let i = 0; i < typedData.length; i++) {
      const value = Number(typedData[i].value);
      if (value > max) max = value;
      if (value < min) min = value;
      sum += value;
    }

    const avg = sum / typedData.length;

    // 使用setTimeout确保状态更新在UI线程上执行
    setTimeout(() => {
      switch (this.type) {
        case 'temperature':
          this.highest = max.toFixed(1);
          this.lowest = min.toFixed(1);
          this.average = avg.toFixed(1);
          break;
        case 'heartRate':
        case 'oxygen':
          this.highest = Math.round(max).toString();
          this.lowest = Math.round(min).toString();
          this.average = Math.round(avg).toString();
          break;
      }
    }, 0);
  }

  async loadData() {
    if (!this.hospitalId) return;

    try {
      this.isLoading = true;
      const context = getContext(this) as common.Context;
      await vitalSignsRdbInstance.initDb(context);

      switch (this.type) {
        case 'temperature': {
          const data = await vitalSignsRdbInstance.getTemperaturesByHospitalId(this.hospitalId);
          // 先计算统计数据
          this.calculateStatistics(data);

          if (data.length > 0) {
            this.chartOptions = new Options({
              grid: {
                left: '10%',
                right: '10%',
                top: '10%',
                bottom: '10%'
              },
              xAxis: {
                type: 'category',
                data: data.map(item => new Date(item.measureTime).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })),
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                }
              },
              yAxis: {
                type: 'value',
                name: '体温(℃)',
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                splitLine: {
                  show: true,
                  lineStyle: {
                    color: '#e5e5e5',
                    width: 1
                  }
                }
              },
              series: [{
                name: '体温',
                type: 'line',
                data: data.map(item => item.value),
                color: '#4CAF50',
                lineStyle: {
                  width: 2,
                  color: '#4CAF50'
                },
                itemStyle: {
                  symbol: 'solidCircle',
                  symbolSize: 4
                }
              }],
              tooltip: {
                trigger: 'axis',
                axisPointer: {
                  type: 'line',
                  lineStyle: {
                    color: '#D9D9D9',
                    width: 1
                  }
                }
              }
            });
          }
          this.data = data;
          break;
        }
        case 'bloodPressure': {
          const data = await vitalSignsRdbInstance.getBloodPressuresByHospitalId(this.hospitalId);
          // 先计算统计数据
          this.calculateStatistics(data);

          if (data.length > 0) {
            this.chartOptions = new Options({
              grid: {
                left: '10%',
                right: '10%',
                top: '10%',
                bottom: '10%'
              },
              xAxis: {
                type: 'category',
                data: data.map(item => new Date(item.measureTime).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })),
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                }
              },
              yAxis: {
                type: 'value',
                name: '血压(mmHg)',
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                splitLine: {
                  show: true,
                  lineStyle: {
                    color: '#e5e5e5',
                    width: 1
                  }
                }
              },
              series: [
                {
                  name: '收缩压',
                  type: 'line',
                  data: data.map(item => item.systolic),
                  color: '#F44336',
                  lineStyle: {
                    width: 2,
                    color: '#F44336'
                  },
                  itemStyle: {
                    symbol: 'solidCircle',
                    symbolSize: 4
                  }
                },
                {
                  name: '舒张压',
                  type: 'line',
                  data: data.map(item => item.diastolic),
                  color: '#52C41A',
                  lineStyle: {
                    width: 2,
                    color: '#52C41A'
                  },
                  itemStyle: {
                    symbol: 'solidCircle',
                    symbolSize: 4
                  }
                }
              ],
              tooltip: {
                trigger: 'axis',
                axisPointer: {
                  type: 'line',
                  lineStyle: {
                    color: '#D9D9D9',
                    width: 1
                  }
                }
              }
            });
          }
          this.data = data;
          break;
        }
        case 'heartRate': {
          const data = await vitalSignsRdbInstance.getHeartRatesByHospitalId(this.hospitalId);
          // 先计算统计数据
          this.calculateStatistics(data);

          if (data.length > 0) {
            this.chartOptions = new Options({
              grid: {
                left: '10%',
                right: '10%',
                top: '10%',
                bottom: '10%'
              },
              xAxis: {
                type: 'category',
                data: data.map(item => new Date(item.measureTime).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })),
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                }
              },
              yAxis: {
                type: 'value',
                name: '心率(次/分)',
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                splitLine: {
                  show: true,
                  lineStyle: {
                    color: '#e5e5e5',
                    width: 1
                  }
                }
              },
              series: [{
                name: '心率',
                type: 'line',
                data: data.map(item => item.value),
                color: '#9C27B0',
                lineStyle: {
                  width: 2,
                  color: '#9C27B0'
                },
                itemStyle: {
                  symbol: 'solidCircle',
                  symbolSize: 4
                }
              }],
              tooltip: {
                trigger: 'axis',
                axisPointer: {
                  type: 'line',
                  lineStyle: {
                    color: '#D9D9D9',
                    width: 1
                  }
                }
              }
            });
          }
          this.data = data;
          break;
        }
        case 'oxygen': {
          const data = await vitalSignsRdbInstance.getBloodOxygensByHospitalId(this.hospitalId);
          // 先计算统计数据
          this.calculateStatistics(data);

          if (data.length > 0) {
            this.chartOptions = new Options({
              grid: {
                left: '10%',
                right: '10%',
                top: '10%',
                bottom: '10%'
              },
              xAxis: {
                type: 'category',
                data: data.map(item => new Date(item.measureTime).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })),
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                }
              },
              yAxis: {
                type: 'value',
                name: '血氧(%)',
                axisLabel: {
                  color: '#838383',
                  fontSize: 28,
                  fontWeight: '600'
                },
                axisLine: {
                  show: true,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                axisTick: {
                  show: true,
                  length: 6,
                  lineStyle: {
                    color: '#838383',
                    width: 1
                  }
                },
                splitLine: {
                  show: true,
                  lineStyle: {
                    color: '#e5e5e5',
                    width: 1
                  }
                }
              },
              series: [{
                name: '血氧',
                type: 'line',
                data: data.map(item => item.value),
                color: '#2196F3',
                lineStyle: {
                  width: 2,
                  color: '#2196F3'
                },
                itemStyle: {
                  symbol: 'solidCircle',
                  symbolSize: 4
                }
              }],
              tooltip: {
                trigger: 'axis',
                axisPointer: {
                  type: 'line',
                  lineStyle: {
                    color: '#D9D9D9',
                    width: 1
                  }
                }
              }
            });
          }
          this.data = data;
          break;
        }
      }
    } catch (error) {
      console.error('加载趋势数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private getTypeColor(): string {
    switch (this.type) {
      case 'temperature':
        return '#4CAF50';
      case 'oxygen':
        return '#2196F3';
      case 'bloodPressure':
        return '#F44336';
      case 'heartRate':
        return '#9C27B0';
      default:
        return '#999999';
    }
  }

  @Builder
  StatisticCard(title: string, value: string) {
    Column() {
      Row() {
        if (value.includes('/')) {
          Text(value.split('/')[0])
            .fontSize(24)
            .fontWeight(500)
            .fontColor(this.getTypeColor())
          Text('/' + value.split('/')[1])
            .fontSize(24)
            .fontWeight(500)
            .fontColor('#52C41A')
        } else {
          Text(value)
            .fontSize(24)
            .fontWeight(500)
            .fontColor(this.getTypeColor())
        }
      }
      .margin({ bottom: 8 })
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Text(title)
        .fontSize(16)
        .fontColor('#999999')
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .width('32%')
    .height(80)
    .padding(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: 6,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.back();
            })
          Text(this.title)
            .fontSize(20)
            .fontWeight(500)
            .fontColor('#FFFFFF')
            .margin({ left: 16 })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.getTypeColor())

      Scroll() {
        Column() {
          // 标题和日期
          Row() {
            Text(this.title)
              .fontSize(24)
              .fontWeight(500)
            Text(this.currentDate)
              .fontSize(16)
              .fontColor('#666666')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ top: 16, bottom: 16, left: 16, right: 16 })

          // 图表区域
          Column() {
            if (this.data.length === 0) {
              Column() {
                Image($r('app.media.ic_data'))
                  .width(120)
                  .height(120)
                  .margin({ bottom: 16 })
                Text('暂无数据')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            } else {
              McLineChart({ options: this.chartOptions })
                .width('100%')
                .height(300)
            }
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(16)
          .margin({ left: 16, right: 16, bottom: 16 })

          // 数据统计区域
          Row() {
            if (this.type === 'bloodPressure') {
              Column() {
                // 收缩压统计行
                Row() {
                  // 收缩压最高值
                  Column() {
                    Row() {
                      Text(this.highest.split('/')[0])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#F44336')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('最高值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })

                  // 收缩压平均值
                  Column() {
                    Row() {
                      Text(this.average.split('/')[0])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#F44336')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('平均值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })

                  // 最低值
                  Column() {
                    Row() {
                      Text(this.lowest.split('/')[0])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#F44336')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('最低值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 16 })

                // 舒张压统计行
                Row() {
                  // 舒张压最高值
                  Column() {
                    Row() {
                      Text(this.highest.split('/')[1])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#52C41A')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('最高值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })

                  // 舒张压平均值
                  Column() {
                    Row() {
                      Text(this.average.split('/')[1])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#52C41A')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('平均值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })

                  // 舒张压最低值
                  Column() {
                    Row() {
                      Text(this.lowest.split('/')[1])
                        .fontSize(24)
                        .fontWeight(500)
                        .fontColor('#52C41A')
                      Text('mmHg')
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ left: 4 })
                    }
                    .margin({ bottom: 8 })
                    .width('100%')
                    .justifyContent(FlexAlign.Center)

                    Text('最低值')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .width('32%')
                  .height(80)
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .shadow({
                    radius: 6,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
            } else {
              // 其他类型数据的统计显示
              Column() {
                Row() {
                  Text(this.highest)
                    .fontSize(24)
                    .fontWeight(500)
                    .fontColor(this.getTypeColor())
                  if (this.type === 'temperature') {
                    Text('℃')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'heartRate') {
                    Text('次/分')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'oxygen') {
                    Text('%')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  }
                }
                .margin({ bottom: 8 })
                .width('100%')
                .justifyContent(FlexAlign.Center)

                Text('最高值')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .width('32%')
              .height(80)
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .shadow({
                radius: 6,
                color: '#1A000000',
                offsetX: 0,
                offsetY: 2
              })

              Column() {
                Row() {
                  Text(this.average)
                    .fontSize(24)
                    .fontWeight(500)
                    .fontColor(this.getTypeColor())
                  if (this.type === 'temperature') {
                    Text('℃')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'heartRate') {
                    Text('次/分')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'oxygen') {
                    Text('%')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  }
                }
                .margin({ bottom: 8 })
                .width('100%')
                .justifyContent(FlexAlign.Center)

                Text('平均值')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .width('32%')
              .height(80)
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .shadow({
                radius: 6,
                color: '#1A000000',
                offsetX: 0,
                offsetY: 2
              })

              Column() {
                Row() {
                  Text(this.lowest)
                    .fontSize(24)
                    .fontWeight(500)
                    .fontColor(this.getTypeColor())
                  if (this.type === 'temperature') {
                    Text('℃')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'heartRate') {
                    Text('次/分')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  } else if (this.type === 'oxygen') {
                    Text('%')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 4 })
                  }
                }
                .margin({ bottom: 8 })
                .width('100%')
                .justifyContent(FlexAlign.Center)

                Text('最低值')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .width('32%')
              .height(80)
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .shadow({
                radius: 6,
                color: '#1A000000',
                offsetX: 0,
                offsetY: 2
              })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          // 添加查看详情按钮
          Button('查看详细数据')
            .width('90%')
            .height(48)
            .fontSize(16)
            .fontWeight(500)
            .backgroundColor(this.getTypeColor())
            .margin({ bottom: 20 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/PatientDetailDataPage',
                params: {
                  type: this.type,
                  title: this.title,
                  hospitalId: this.hospitalId,
                  date: this.currentDate
                }
              });
            })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}