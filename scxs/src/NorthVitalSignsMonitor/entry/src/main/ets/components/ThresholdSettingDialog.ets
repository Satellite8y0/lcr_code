import promptAction from '@ohos.promptAction';
import { ThresholdRdb, ThresholdData } from '../common/database/ThresholdRdb';

@CustomDialog
export struct ThresholdSettingDialog {
  controller: CustomDialogController;
  hospitalId: string = '';
  threshold?: ThresholdData;  // 接收传入的阈值
  onConfirm: (threshold: ThresholdData) => void = () => {};

  // 添加状态变量来管理输入框的显示值
  @State private systolicMinInput: string = '';
  @State private systolicMaxInput: string = '';
  @State private diastolicMinInput: string = '';
  @State private diastolicMaxInput: string = '';

  @State currentThreshold: ThresholdData = {
    hospitalId: '',
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

  aboutToAppear() {
    // 如果有传入阈值，使用传入的值
    if (this.threshold) {
      this.currentThreshold.hospitalId = this.hospitalId;
      this.currentThreshold.temperatureMin = this.threshold.temperatureMin;
      this.currentThreshold.temperatureMax = this.threshold.temperatureMax;
      this.currentThreshold.systolicPressureMin = this.threshold.systolicPressureMin;
      this.currentThreshold.systolicPressureMax = this.threshold.systolicPressureMax;
      this.currentThreshold.diastolicPressureMin = this.threshold.diastolicPressureMin;
      this.currentThreshold.diastolicPressureMax = this.threshold.diastolicPressureMax;
      this.currentThreshold.heartRateMin = this.threshold.heartRateMin;
      this.currentThreshold.heartRateMax = this.threshold.heartRateMax;
      this.currentThreshold.bloodOxygenMin = this.threshold.bloodOxygenMin;
      this.currentThreshold.bloodOxygenMax = this.threshold.bloodOxygenMax;
      this.currentThreshold.updateTime = new Date().toISOString();

      // 初始化输入框显示值
      this.systolicMinInput = this.threshold.systolicPressureMin.toString();
      this.systolicMaxInput = this.threshold.systolicPressureMax.toString();
      this.diastolicMinInput = this.threshold.diastolicPressureMin.toString();
      this.diastolicMaxInput = this.threshold.diastolicPressureMax.toString();
    } else {
      this.currentThreshold.hospitalId = this.hospitalId;
      // 初始化输入框显示值为默认值
      this.systolicMinInput = this.currentThreshold.systolicPressureMin.toString();
      this.systolicMaxInput = this.currentThreshold.systolicPressureMax.toString();
      this.diastolicMinInput = this.currentThreshold.diastolicPressureMin.toString();
      this.diastolicMaxInput = this.currentThreshold.diastolicPressureMax.toString();
    }
  }

  validateInputs(): boolean {
    // 体温范围验证 (35-42℃)
    if (this.currentThreshold.temperatureMin < 35 || this.currentThreshold.temperatureMax > 42 ||
      this.currentThreshold.temperatureMin >= this.currentThreshold.temperatureMax) {
      promptAction.showToast({ message: '体温范围应在35-42°C之间，且最小值应小于最大值' });
      return false;
    }

    // 收缩压范围验证 (70-200mmHg)
    if (this.currentThreshold.systolicPressureMin < 70 || this.currentThreshold.systolicPressureMax > 200 ||
      this.currentThreshold.systolicPressureMin >= this.currentThreshold.systolicPressureMax) {
      promptAction.showToast({ message: '收缩压范围应在70-200mmHg之间，且最小值应小于最大值' });
      return false;
    }

    // 舒张压范围验证 (40-130mmHg)
    if (this.currentThreshold.diastolicPressureMin < 40 || this.currentThreshold.diastolicPressureMax > 130 ||
      this.currentThreshold.diastolicPressureMin >= this.currentThreshold.diastolicPressureMax) {
      promptAction.showToast({ message: '舒张压范围应在40-130mmHg之间，且最小值应小于最大值' });
      return false;
    }

    // 心率范围验证 (40-200次/分)
    if (this.currentThreshold.heartRateMin < 40 || this.currentThreshold.heartRateMax > 200 ||
      this.currentThreshold.heartRateMin >= this.currentThreshold.heartRateMax) {
      promptAction.showToast({ message: '心率范围应在40-200次/分钟之间，且最小值应小于最大值' });
      return false;
    }

    // 血氧范围验证 (85-100%)
    if (this.currentThreshold.bloodOxygenMin < 85 || this.currentThreshold.bloodOxygenMax > 100 ||
      this.currentThreshold.bloodOxygenMin >= this.currentThreshold.bloodOxygenMax) {
      promptAction.showToast({ message: '血氧范围应在85-100%之间，且最小值应小于最大值' });
      return false;
    }

    return true;
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

  @Builder
  private ThresholdItem(title: string, unit: string, minValue: number, maxValue: number, onMinChange: (value: number) => void, onMaxChange: (value: number) => void) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })
        .textAlign(TextAlign.Center)

      Row() {
        Blank()
        TextInput({ text: minValue.toString() })
          .type(InputType.Number)
          .width(80)
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .inputFilter('^[0-9.]+$')  // 允许输入数字和小数点
          .onChange((value: string) => {
            // 处理空输入和非法输入
            if (value === '') {
              // 如果输入为空，保持原值不变
              return;
            }
            let num = parseFloat(value);
            if (!isNaN(num)) {
              // 对于体温，保留一位小数
              if (title === '体温') {
                num = parseFloat(num.toFixed(1));
              }
              onMinChange(num);
            }
          })

        Text('-')
          .fontSize(16)
          .margin({ left: 12, right: 12 })

        TextInput({ text: maxValue.toString() })
          .type(InputType.Number)
          .width(80)
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .inputFilter('^[0-9.]+$')  // 允许输入数字和小数点
          .onChange((value: string) => {
            // 处理空输入和非法输入
            if (value === '') {
              // 如果输入为空，保持原值不变
              return;
            }
            let num = parseFloat(value);
            if (!isNaN(num)) {
              // 对于体温，保留一位小数
              if (title === '体温') {
                num = parseFloat(num.toFixed(1));
              }
              onMaxChange(num);
            }
          })

        Text(unit)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  @Builder
  private BPItem(title: string, minValue: number, maxValue: number, onMinChange: (value: number) => void, onMaxChange: (value: number) => void) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .width(60)

      Blank()
      TextInput({ text: minValue.toString() })
        .type(InputType.Number)
        .width(80)
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(4)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .onChange((value: string) => {
          // 处理空输入和非法输入
          if (value === '') {
            // 如果输入为空，保持原值不变
            return;
          }
          const num = Number(value);
          if (!isNaN(num)) {
            onMinChange(num);
          }
        })

      Text('-')
        .fontSize(16)
        .margin({ left: 12, right: 12 })

      TextInput({ text: maxValue.toString() })
        .type(InputType.Number)
        .width(80)
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(4)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .onChange((value: string) => {
          // 处理空输入和非法输入
          if (value === '') {
            // 如果输入为空，保持原值不变
            return;
          }
          const num = Number(value);
          if (!isNaN(num)) {
            onMaxChange(num);
          }
        })
      Blank()
    }
    .width('100%')
    .margin({ bottom: 12 })
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

      // 内容区域（可滚动）
      Scroll() {
        Column() {
          // 体温
          Column() {
            this.ThresholdItem('体温', '°C',
              this.currentThreshold.temperatureMin, this.currentThreshold.temperatureMax,
              (value) => this.currentThreshold.temperatureMin = value,
              (value) => this.currentThreshold.temperatureMax = value)
          }
          .margin({ top: 0 })

          // 血压
          Text('血压 (mmHg)')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Row() {
            TextInput({
              text: this.systolicMinInput
            })
              .type(InputType.Number)
              .width(120)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .margin({ right: 8 })
              .onChange((value) => {
                this.systolicMinInput = value;
                if (value !== '') {
                  const num = parseInt(value);
                  if (!isNaN(num)) {
                    this.currentThreshold.systolicPressureMin = num;
                  }
                }
              })
            Text('-')
              .fontSize(16)
            TextInput({
              text: this.systolicMaxInput
            })
              .type(InputType.Number)
              .width(120)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .margin({ left: 8 })
              .onChange((value) => {
                this.systolicMaxInput = value;
                if (value !== '') {
                  const num = parseInt(value);
                  if (!isNaN(num)) {
                    this.currentThreshold.systolicPressureMax = num;
                  }
                }
              })
          }
          .margin({ bottom: 16 })

          Row() {
            TextInput({
              text: this.diastolicMinInput
            })
              .type(InputType.Number)
              .width(120)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .margin({ right: 8 })
              .onChange((value) => {
                this.diastolicMinInput = value;
                if (value !== '') {
                  const num = parseInt(value);
                  if (!isNaN(num)) {
                    this.currentThreshold.diastolicPressureMin = num;
                  }
                }
              })
            Text('-')
              .fontSize(16)
            TextInput({
              text: this.diastolicMaxInput
            })
              .type(InputType.Number)
              .width(120)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(4)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .margin({ left: 8 })
              .onChange((value) => {
                this.diastolicMaxInput = value;
                if (value !== '') {
                  const num = parseInt(value);
                  if (!isNaN(num)) {
                    this.currentThreshold.diastolicPressureMax = num;
                  }
                }
              })
          }
          .margin({ bottom: 16 })

          // 心率
          this.ThresholdItem('心率', '次/分',
            this.currentThreshold.heartRateMin, this.currentThreshold.heartRateMax,
            (value) => this.currentThreshold.heartRateMin = value,
            (value) => this.currentThreshold.heartRateMax = value)

          // 血氧
          this.ThresholdItem('血氧', '%',
            this.currentThreshold.bloodOxygenMin, this.currentThreshold.bloodOxygenMax,
            (value) => this.currentThreshold.bloodOxygenMin = value,
            (value) => this.currentThreshold.bloodOxygenMax = value)
        }
        .padding({ left: 24, right: 24, top: 16, bottom: 16 })
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

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
            if (!this.validateInputs()) {
              return;
            }

            const newThreshold: ThresholdData = {
              hospitalId: this.hospitalId,
              temperatureMin: this.validateAndFormatNumber(this.currentThreshold.temperatureMin.toString(), 35.0, 42.0),
              temperatureMax: this.validateAndFormatNumber(this.currentThreshold.temperatureMax.toString(), 35.0, 42.0),
              systolicPressureMin: this.currentThreshold.systolicPressureMin,
              systolicPressureMax: this.currentThreshold.systolicPressureMax,
              diastolicPressureMin: this.currentThreshold.diastolicPressureMin,
              diastolicPressureMax: this.currentThreshold.diastolicPressureMax,
              heartRateMin: this.currentThreshold.heartRateMin,
              heartRateMax: this.currentThreshold.heartRateMax,
              bloodOxygenMin: this.currentThreshold.bloodOxygenMin,
              bloodOxygenMax: this.currentThreshold.bloodOxygenMax,
              updateTime: new Date().toISOString()
            };

            this.onConfirm(newThreshold);
            this.controller.close();
          })
      }
      .margin({ bottom: 24, left: 24, right: 24 })
    }
    .width('100%')
    .height('90%')
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}