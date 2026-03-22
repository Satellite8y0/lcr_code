import { vitalSignsRdbInstance } from '../database/VitalSignsRdb';
import thresholdRdb, { ThresholdData } from '../database/ThresholdRdb';
import { AlarmRdb, AlarmType } from '../database/AlarmRdb';
import patientRdb from '../database/PatientRdb';
import common from '@ohos.app.ability.common';

export class MockDataGenerator {
  private static hospitalId: string = '2504130050';
  private static initialized: boolean = false;
  private static thresholdData: ThresholdData | null = null;

  // 设置住院号
  public static setHospitalId(id: string): void {
    console.info(`设置模拟数据住院号: ${id}`);
    MockDataGenerator.hospitalId = id;
  }

  // 获取患者姓名
  private static async getPatientName(): Promise<string> {
    try {
      const visitRecord = await patientRdb.getVisitByHospitalId(MockDataGenerator.hospitalId);
      if (visitRecord && visitRecord.name) {
        return visitRecord.name;
      }
      console.warn(`未找到住院号 ${MockDataGenerator.hospitalId} 对应的患者信息`);
      return '未知患者';
    } catch (error) {
      console.error('获取患者信息失败:', error);
      return '未知患者';
    }
  }

  // 初始化数据库和阈值
  private static async initializeDatabase(context: common.Context): Promise<boolean> {
    if (!MockDataGenerator.initialized) {
      try {
        await vitalSignsRdbInstance.initDb(context);
        await thresholdRdb.initDb(context);
        await AlarmRdb.initDb(context);
        MockDataGenerator.initialized = true;
        console.info('数据库初始化成功');

        // 获取阈值设置
        MockDataGenerator.thresholdData = await thresholdRdb.getThresholdByHospitalId(MockDataGenerator.hospitalId);
        if (!MockDataGenerator.thresholdData) {
          console.error('获取阈值设置失败');
          return false;
        }
        console.info('获取到阈值设置:', JSON.stringify(MockDataGenerator.thresholdData));
        return true;
      } catch (error) {
        console.error('数据库初始化失败:', error);
        return false;
      }
    }
    return true;
  }

  // 生成指定范围内的随机数
  private static getRandomNumber(min: number, max: number, isInteger: boolean = false): number {
    const random = Math.random() * (max - min) + min;
    return isInteger ? Math.round(random) : Number(random.toFixed(1));
  }

  // 生成时间序列
  private static generateTimeSequence(count: number): string[] {
    const times: string[] = [];
    const baseTime = new Date();

    for (let i = 0; i < count; i++) {
      const time = new Date(baseTime.getTime() - i * 5 * 60 * 1000);
      times.push(time.toISOString());
    }
    return times;
  }

  // 检查并创建告警记录
  private static async createAlarmIfNeeded(
    type: AlarmType,
    value: number,
    time: string,
    isAbnormal: boolean
  ): Promise<void> {
    if (isAbnormal) {
      const patientName = await MockDataGenerator.getPatientName();
      await AlarmRdb.createAlarmFromAbnormalData(
        MockDataGenerator.hospitalId,
        patientName,
        type,
        value,
        time
      );
    }
  }

  // 生成体温数据
  private static async generateTemperatureData() {
    if (!MockDataGenerator.thresholdData) return;

    const times = MockDataGenerator.generateTimeSequence(12);
    console.info(`开始生成体温数据，住院号: ${MockDataGenerator.hospitalId}`);

    for (const time of times) {
      const shouldBeAbnormal = Math.random() < 0.2;
      let value: number;
      let isAbnormal: boolean;

      if (shouldBeAbnormal) {
        // 生成异常数据：高于上限或低于下限
        const isHigh = Math.random() < 0.5;
        value = isHigh ?
        MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.temperatureMax, MockDataGenerator.thresholdData.temperatureMax + 2, false) :
        MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.temperatureMin - 2, MockDataGenerator.thresholdData.temperatureMin, false);
        isAbnormal = true;
      } else {
        // 生成正常数据
        value = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.temperatureMin,
          MockDataGenerator.thresholdData.temperatureMax,
          false
        );
        isAbnormal = false;
      }

      const success = await vitalSignsRdbInstance.insertTemperature({
        hospitalId: MockDataGenerator.hospitalId,
        value: value,
        measureTime: time,
        isAbnormal: isAbnormal
      });

      if (success) {
        await MockDataGenerator.createAlarmIfNeeded('temperature', value, time, isAbnormal);
      } else {
        console.error(`插入体温数据失败: ${value}℃, ${time}`);
      }
    }
    console.info('体温数据生成完成');
  }

  // 生成血压数据
  private static async generateBloodPressureData() {
    if (!MockDataGenerator.thresholdData) return;

    const times = MockDataGenerator.generateTimeSequence(12);
    console.info(`开始生成血压数据，住院号: ${MockDataGenerator.hospitalId}`);

    for (const time of times) {
      const shouldBeAbnormal = Math.random() < 0.2;
      let systolic: number;
      let diastolic: number;
      let isAbnormal: boolean;

      if (shouldBeAbnormal) {
        // 生成异常数据
        const isHigh = Math.random() < 0.5;
        if (isHigh) {
          systolic = MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.systolicPressureMax, MockDataGenerator.thresholdData.systolicPressureMax + 30, true);
          diastolic = MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.diastolicPressureMax, MockDataGenerator.thresholdData.diastolicPressureMax + 20, true);
        } else {
          systolic = MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.systolicPressureMin - 20, MockDataGenerator.thresholdData.systolicPressureMin, true);
          diastolic = MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.diastolicPressureMin - 15, MockDataGenerator.thresholdData.diastolicPressureMin, true);
        }
        isAbnormal = true;
      } else {
        // 生成正常数据
        systolic = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.systolicPressureMin,
          MockDataGenerator.thresholdData.systolicPressureMax,
          true
        );
        diastolic = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.diastolicPressureMin,
          MockDataGenerator.thresholdData.diastolicPressureMax,
          true
        );
        isAbnormal = false;
      }

      const success = await vitalSignsRdbInstance.insertBloodPressure({
        hospitalId: MockDataGenerator.hospitalId,
        systolic: systolic,
        diastolic: diastolic,
        measureTime: time,
        isAbnormal: isAbnormal
      });

      if (success) {
        await MockDataGenerator.createAlarmIfNeeded('bloodPressure', systolic, time, isAbnormal);
      } else {
        console.error(`插入血压数据失败: ${systolic}/${diastolic}mmHg, ${time}`);
      }
    }
    console.info('血压数据生成完成');
  }

  // 生成心率数据
  private static async generateHeartRateData() {
    if (!MockDataGenerator.thresholdData) return;

    const times = MockDataGenerator.generateTimeSequence(12);
    console.info(`开始生成心率数据，住院号: ${MockDataGenerator.hospitalId}`);

    for (const time of times) {
      const shouldBeAbnormal = Math.random() < 0.2;
      let value: number;
      let isAbnormal: boolean;

      if (shouldBeAbnormal) {
        // 生成异常数据
        const isHigh = Math.random() < 0.5;
        value = isHigh ?
        MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.heartRateMax, MockDataGenerator.thresholdData.heartRateMax + 30, true) :
        MockDataGenerator.getRandomNumber(MockDataGenerator.thresholdData.heartRateMin - 20, MockDataGenerator.thresholdData.heartRateMin, true);
        isAbnormal = true;
      } else {
        // 生成正常数据
        value = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.heartRateMin,
          MockDataGenerator.thresholdData.heartRateMax,
          true
        );
        isAbnormal = false;
      }

      const success = await vitalSignsRdbInstance.insertHeartRate({
        hospitalId: MockDataGenerator.hospitalId,
        value: value,
        measureTime: time,
        isAbnormal: isAbnormal
      });

      if (success) {
        await MockDataGenerator.createAlarmIfNeeded('heartRate', value, time, isAbnormal);
      } else {
        console.error(`插入心率数据失败: ${value}次/分, ${time}`);
      }
    }
    console.info('心率数据生成完成');
  }

  // 生成血氧数据
  private static async generateBloodOxygenData() {
    if (!MockDataGenerator.thresholdData) return;

    const times = MockDataGenerator.generateTimeSequence(12);
    console.info(`开始生成血氧数据，住院号: ${MockDataGenerator.hospitalId}`);

    for (const time of times) {
      const shouldBeAbnormal = Math.random() < 0.2;
      let value: number;
      let isAbnormal: boolean;

      if (shouldBeAbnormal) {
        // 生成异常数据（血氧只考虑低于下限的情况）
        value = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.bloodOxygenMin - 10,
          MockDataGenerator.thresholdData.bloodOxygenMin,
          true
        );
        isAbnormal = true;
      } else {
        // 生成正常数据
        value = MockDataGenerator.getRandomNumber(
          MockDataGenerator.thresholdData.bloodOxygenMin,
          MockDataGenerator.thresholdData.bloodOxygenMax,
          true
        );
        isAbnormal = false;
      }

      const success = await vitalSignsRdbInstance.insertBloodOxygen({
        hospitalId: MockDataGenerator.hospitalId,
        value: value,
        measureTime: time,
        isAbnormal: isAbnormal
      });

      if (success) {
        await MockDataGenerator.createAlarmIfNeeded('bloodOxygen', value, time, isAbnormal);
      } else {
        console.error(`插入血氧数据失败: ${value}%, ${time}`);
      }
    }
    console.info('血氧数据生成完成');
  }

  // 生成所有模拟数据
  public static async generateAllMockData(context: common.Context): Promise<void> {
    try {
      console.info(`开始生成所有模拟数据，住院号: ${MockDataGenerator.hospitalId}`);

      // 确保数据库已初始化并获取阈值设置
      const initSuccess = await MockDataGenerator.initializeDatabase(context);
      if (!initSuccess) {
        throw new Error('初始化失败');
      }

      await MockDataGenerator.generateTemperatureData();
      await MockDataGenerator.generateBloodPressureData();
      await MockDataGenerator.generateHeartRateData();
      await MockDataGenerator.generateBloodOxygenData();
      console.info(`所有模拟数据生成完成，住院号: ${MockDataGenerator.hospitalId}`);
    } catch (error) {
      console.error('生成模拟数据失败:', error);

    }
  }
} 