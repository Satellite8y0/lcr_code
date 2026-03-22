/**
 * 生命体征数据库 (vital_signs.db)
 *
 * 表名：TEMPERATURE_TABLE
 * 用途：存储体温数据
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL              // 住院号
 * - value: REAL NOT NULL                   // 体温值(℃)
 * - measureTime: TEXT NOT NULL             // 测量时间
 * - isAbnormal: INTEGER NOT NULL           // 是否异常(0-正常, 1-异常)
 *
 * 表名：BLOOD_PRESSURE_TABLE
 * 用途：存储血压数据
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL              // 住院号
 * - systolic: INTEGER NOT NULL             // 收缩压(mmHg)
 * - diastolic: INTEGER NOT NULL            // 舒张压(mmHg)
 * - measureTime: TEXT NOT NULL             // 测量时间
 * - isAbnormal: INTEGER NOT NULL           // 是否异常(0-正常, 1-异常)
 *
 * 表名：HEART_RATE_TABLE
 * 用途：存储心率数据
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL              // 住院号
 * - value: INTEGER NOT NULL                // 心率值(次/分)
 * - measureTime: TEXT NOT NULL             // 测量时间
 * - isAbnormal: INTEGER NOT NULL           // 是否异常(0-正常, 1-异常)
 *
 * 表名：BLOOD_OXYGEN_TABLE
 * 用途：存储血氧数据
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL              // 住院号
 * - value: INTEGER NOT NULL                // 血氧值(%)
 * - measureTime: TEXT NOT NULL             // 测量时间
 * - isAbnormal: INTEGER NOT NULL           // 是否异常(0-正常, 1-异常)
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

// 数据接口定义
export interface TemperatureData {
  id?: number;
  hospitalId: string;
  value: number;
  measureTime: string;
  isAbnormal: boolean;
}

export interface BloodPressureData {
  id?: number;
  hospitalId: string;
  systolic: number;
  diastolic: number;
  measureTime: string;
  isAbnormal: boolean;
}

export interface HeartRateData {
  id?: number;
  hospitalId: string;
  value: number;
  measureTime: string;
  isAbnormal: boolean;
}

export interface BloodOxygenData {
  id?: number;
  hospitalId: string;
  value: number;
  measureTime: string;
  isAbnormal: boolean;
}

export class VitalSignsRdb {
  private static instance: VitalSignsRdb;
  private rdbStore: relationalStore.RdbStore | null = null;

  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'vital_signs.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false
  };

  private readonly SQL_CREATE_TEMPERATURE_TABLE = `
    CREATE TABLE IF NOT EXISTS TEMPERATURE_TABLE (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hospitalId TEXT NOT NULL,
      value REAL NOT NULL,
      measureTime TEXT NOT NULL,
      isAbnormal INTEGER NOT NULL
    )`;

  private readonly SQL_CREATE_BLOOD_PRESSURE_TABLE = `
    CREATE TABLE IF NOT EXISTS BLOOD_PRESSURE_TABLE (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hospitalId TEXT NOT NULL,
      systolic INTEGER NOT NULL,
      diastolic INTEGER NOT NULL,
      measureTime TEXT NOT NULL,
      isAbnormal INTEGER NOT NULL
    )`;

  private readonly SQL_CREATE_HEART_RATE_TABLE = `
    CREATE TABLE IF NOT EXISTS HEART_RATE_TABLE (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hospitalId TEXT NOT NULL,
      value INTEGER NOT NULL,
      measureTime TEXT NOT NULL,
      isAbnormal INTEGER NOT NULL
    )`;

  private readonly SQL_CREATE_BLOOD_OXYGEN_TABLE = `
    CREATE TABLE IF NOT EXISTS BLOOD_OXYGEN_TABLE (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hospitalId TEXT NOT NULL,
      value INTEGER NOT NULL,
      measureTime TEXT NOT NULL,
      isAbnormal INTEGER NOT NULL
    )`;

  private constructor() {}

  static getInstance(): VitalSignsRdb {
    if (!VitalSignsRdb.instance) {
      VitalSignsRdb.instance = new VitalSignsRdb();
    }
    return VitalSignsRdb.instance;
  }

  async initDb(context: common.Context) {
    try {
      if (this.rdbStore) {
        console.info('数据库已经初始化');
        return;
      }

      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);
      // 创建所有表
      await this.rdbStore.executeSql(this.SQL_CREATE_TEMPERATURE_TABLE);
      await this.rdbStore.executeSql(this.SQL_CREATE_BLOOD_PRESSURE_TABLE);
      await this.rdbStore.executeSql(this.SQL_CREATE_HEART_RATE_TABLE);
      await this.rdbStore.executeSql(this.SQL_CREATE_BLOOD_OXYGEN_TABLE);
      console.info('生命体征数据库初始化成功');
    } catch (error) {
      console.error('生命体征数据库初始化失败:', error);
      this.rdbStore = null;
    }
  }

  // 体温相关操作
  async insertTemperature(data: TemperatureData): Promise<boolean> {
    if (!this.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        hospitalId: data.hospitalId,
        value: data.value,
        measureTime: data.measureTime,
        isAbnormal: data.isAbnormal ? 1 : 0
      };
      const ret = await this.rdbStore.insert('TEMPERATURE_TABLE', valuesBucket);
      if (ret === -1) {
        console.error('插入体温数据失败: 数据库操作返回-1');
        return false;
      }
      return true;
    } catch (error) {
      console.error('插入体温数据失败:', error);
      return false;
    }
  }

  async getTemperaturesByHospitalId(hospitalId: string): Promise<TemperatureData[]> {
    if (!this.rdbStore) return [];

    try {
      const predicates = new relationalStore.RdbPredicates('TEMPERATURE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      predicates.orderByDesc('measureTime');

      const resultSet = await this.rdbStore.query(predicates);
      const temperatures: TemperatureData[] = [];

      while (resultSet.goToNextRow()) {
        temperatures.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
          value: resultSet.getDouble(resultSet.getColumnIndex('value')),
          measureTime: resultSet.getString(resultSet.getColumnIndex('measureTime')),
          isAbnormal: resultSet.getLong(resultSet.getColumnIndex('isAbnormal')) === 1
        });
      }
      resultSet.close();
      return temperatures;
    } catch (error) {
      console.error('查询体温数据失败:', error);
      return [];
    }
  }

  // 血压相关操作
  async insertBloodPressure(data: BloodPressureData): Promise<boolean> {
    if (!this.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        hospitalId: data.hospitalId,
        systolic: data.systolic,
        diastolic: data.diastolic,
        measureTime: data.measureTime,
        isAbnormal: data.isAbnormal ? 1 : 0
      };
      const ret = await this.rdbStore.insert('BLOOD_PRESSURE_TABLE', valuesBucket);
      if (ret === -1) {
        console.error('插入血压数据失败: 数据库操作返回-1');
        return false;
      }
      return true;
    } catch (error) {
      console.error('插入血压数据失败:', error);
      return false;
    }
  }

  async getBloodPressuresByHospitalId(hospitalId: string): Promise<BloodPressureData[]> {
    if (!this.rdbStore) return [];

    try {
      const predicates = new relationalStore.RdbPredicates('BLOOD_PRESSURE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      predicates.orderByDesc('measureTime');

      const resultSet = await this.rdbStore.query(predicates);
      const bloodPressures: BloodPressureData[] = [];

      while (resultSet.goToNextRow()) {
        bloodPressures.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
          systolic: resultSet.getLong(resultSet.getColumnIndex('systolic')),
          diastolic: resultSet.getLong(resultSet.getColumnIndex('diastolic')),
          measureTime: resultSet.getString(resultSet.getColumnIndex('measureTime')),
          isAbnormal: resultSet.getLong(resultSet.getColumnIndex('isAbnormal')) === 1
        });
      }
      resultSet.close();
      return bloodPressures;
    } catch (error) {
      console.error('查询血压数据失败:', error);
      return [];
    }
  }

  // 心率相关操作
  async insertHeartRate(data: HeartRateData): Promise<boolean> {
    if (!this.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        hospitalId: data.hospitalId,
        value: data.value,
        measureTime: data.measureTime,
        isAbnormal: data.isAbnormal ? 1 : 0
      };
      const ret = await this.rdbStore.insert('HEART_RATE_TABLE', valuesBucket);
      if (ret === -1) {
        console.error('插入心率数据失败: 数据库操作返回-1');
        return false;
      }
      return true;
    } catch (error) {
      console.error('插入心率数据失败:', error);
      return false;
    }
  }

  async getHeartRatesByHospitalId(hospitalId: string): Promise<HeartRateData[]> {
    if (!this.rdbStore) return [];

    try {
      const predicates = new relationalStore.RdbPredicates('HEART_RATE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      predicates.orderByDesc('measureTime');

      const resultSet = await this.rdbStore.query(predicates);
      const heartRates: HeartRateData[] = [];

      while (resultSet.goToNextRow()) {
        heartRates.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
          value: resultSet.getLong(resultSet.getColumnIndex('value')),
          measureTime: resultSet.getString(resultSet.getColumnIndex('measureTime')),
          isAbnormal: resultSet.getLong(resultSet.getColumnIndex('isAbnormal')) === 1
        });
      }
      resultSet.close();
      return heartRates;
    } catch (error) {
      console.error('查询心率数据失败:', error);
      return [];
    }
  }

  // 血氧相关操作
  async insertBloodOxygen(data: BloodOxygenData): Promise<boolean> {
    if (!this.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const valuesBucket: relationalStore.ValuesBucket = {
        hospitalId: data.hospitalId,
        value: data.value,
        measureTime: data.measureTime,
        isAbnormal: data.isAbnormal ? 1 : 0
      };
      const ret = await this.rdbStore.insert('BLOOD_OXYGEN_TABLE', valuesBucket);
      if (ret === -1) {
        console.error('插入血氧数据失败: 数据库操作返回-1');
        return false;
      }
      return true;
    } catch (error) {
      console.error('插入血氧数据失败:', error);
      return false;
    }
  }

  async getBloodOxygensByHospitalId(hospitalId: string): Promise<BloodOxygenData[]> {
    if (!this.rdbStore) return [];

    try {
      const predicates = new relationalStore.RdbPredicates('BLOOD_OXYGEN_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      predicates.orderByDesc('measureTime');

      const resultSet = await this.rdbStore.query(predicates);
      const bloodOxygens: BloodOxygenData[] = [];

      while (resultSet.goToNextRow()) {
        bloodOxygens.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
          value: resultSet.getLong(resultSet.getColumnIndex('value')),
          measureTime: resultSet.getString(resultSet.getColumnIndex('measureTime')),
          isAbnormal: resultSet.getLong(resultSet.getColumnIndex('isAbnormal')) === 1
        });
      }
      resultSet.close();
      return bloodOxygens;
    } catch (error) {
      console.error('查询血氧数据失败:', error);
      return [];
    }
  }

  async deleteTemperaturesByHospitalId(hospitalId: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('TEMPERATURE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const count = await this.rdbStore?.delete(predicates);
      console.info(`删除体温数据成功，影响行数: ${count}`);
    } catch (error) {
      console.error(`删除体温数据失败: ${error}`);
    }
  }

  async deleteBloodPressuresByHospitalId(hospitalId: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('BLOOD_PRESSURE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const count = await this.rdbStore?.delete(predicates);
      console.info(`删除血压数据成功，影响行数: ${count}`);
    } catch (error) {
      console.error(`删除血压数据失败: ${error}`);

    }
  }

  async deleteHeartRatesByHospitalId(hospitalId: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('HEART_RATE_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const count = await this.rdbStore?.delete(predicates);
      console.info(`删除心率数据成功，影响行数: ${count}`);
    } catch (error) {
      console.error(`删除心率数据失败: ${error}`);

    }
  }

  async deleteBloodOxygensByHospitalId(hospitalId: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('BLOOD_OXYGEN_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const count = await this.rdbStore?.delete(predicates);
      console.info(`删除血氧数据成功，影响行数: ${count}`);
    } catch (error) {
      console.error(`删除血氧数据失败: ${error}`);

    }
  }
}

// 导出单例实例
export const vitalSignsRdbInstance = VitalSignsRdb.getInstance(); 