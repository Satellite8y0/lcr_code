/**
 * 阈值数据库 (threshold.db)
 *
 * 表名：THRESHOLD_TABLE
 * 用途：存储生命体征监测的阈值设置
 *
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL UNIQUE       // 住院号，用于关联就诊记录
 * - temperatureMin: REAL NOT NULL          // 体温下限(℃)
 * - temperatureMax: REAL NOT NULL          // 体温上限(℃)
 * - systolicPressureMin: INTEGER NOT NULL  // 收缩压下限(mmHg)
 * - systolicPressureMax: INTEGER NOT NULL  // 收缩压上限(mmHg)
 * - diastolicPressureMin: INTEGER NOT NULL // 舒张压下限(mmHg)
 * - diastolicPressureMax: INTEGER NOT NULL // 舒张压上限(mmHg)
 * - heartRateMin: INTEGER NOT NULL         // 心率下限(次/分)
 * - heartRateMax: INTEGER NOT NULL         // 心率上限(次/分)
 * - bloodOxygenMin: INTEGER NOT NULL       // 血氧下限(%)
 * - bloodOxygenMax: INTEGER NOT NULL       // 血氧上限(%)
 * - updateTime: TEXT NOT NULL              // 更新时间
 * - isDefault: INTEGER DEFAULT 0           // 是否为默认阈值(0-否, 1-是)
 *
 * 主要功能：
 * 1. 维护每个患者的生命体征监测阈值
 * 2. 提供默认阈值设置
 * 3. 支持阈值的个性化调整
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

// 数据库配置接口
interface StoreConfig {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
}

// 阈值数据接口
export interface ThresholdData {
  id?: number;
  hospitalId: string;  // 住院号，用于关联就诊记录
  temperatureMin: number;
  temperatureMax: number;
  systolicPressureMin: number;
  systolicPressureMax: number;
  diastolicPressureMin: number;
  diastolicPressureMax: number;
  heartRateMin: number;
  heartRateMax: number;
  bloodOxygenMin: number;
  bloodOxygenMax: number;
  updateTime: string;
  isDefault?: boolean;  // 是否为默认阈值
}

export class ThresholdRdb {
  private static instance: ThresholdRdb;
  private static rdbStore: relationalStore.RdbStore | null = null;  // 改为静态成员

  private constructor() {}

  static getInstance(): ThresholdRdb {
    if (!ThresholdRdb.instance) {
      ThresholdRdb.instance = new ThresholdRdb();
    }
    return ThresholdRdb.instance;
  }

  async initDb(context: common.Context) {
    const STORE_CONFIG: StoreConfig = {
      name: 'threshold.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    const SQL_CREATE_TABLE = `
      CREATE TABLE IF NOT EXISTS THRESHOLD_TABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospitalId TEXT NOT NULL,
        temperatureMin REAL NOT NULL,
        temperatureMax REAL NOT NULL,
        systolicPressureMin INTEGER NOT NULL,
        systolicPressureMax INTEGER NOT NULL,
        diastolicPressureMin INTEGER NOT NULL,
        diastolicPressureMax INTEGER NOT NULL,
        heartRateMin INTEGER NOT NULL,
        heartRateMax INTEGER NOT NULL,
        bloodOxygenMin INTEGER NOT NULL,
        bloodOxygenMax INTEGER NOT NULL,
        updateTime TEXT NOT NULL,
        isDefault INTEGER DEFAULT 0,
        UNIQUE(hospitalId)
      )`;

    try {
      ThresholdRdb.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await ThresholdRdb.rdbStore.executeSql(SQL_CREATE_TABLE);
      await this.ensureDefaultThresholdExists();
      console.info('阈值数据库初始化成功');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('阈值数据库初始化失败:', errorMessage);
      ThresholdRdb.rdbStore = null;
      throw new Error(`阈值数据库初始化失败: ${errorMessage}`);
    }
  }

  private async ensureDefaultThresholdExists() {
    if (!ThresholdRdb.rdbStore) return;

    try {
      const defaultThreshold = await this.getDefaultThreshold();
      if (!defaultThreshold) {
        // 设置统一的默认阈值
        const defaultValues: ThresholdData = {
          hospitalId: 'default',
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
          updateTime: new Date().toISOString(),
          isDefault: true
        };
        await this.insertThreshold(defaultValues);
      }
    } catch (error) {
      console.error('创建默认阈值失败:', error);
    }
  }

  async getDefaultThreshold(): Promise<ThresholdData | null> {
    if (!ThresholdRdb.rdbStore) return null;

    try {
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('isDefault', 1);
      const resultSet = await ThresholdRdb.rdbStore.query(predicates);

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        return this.extractThresholdFromResultSet(resultSet);
      }
    } catch (error) {
      console.error('获取默认阈值失败:', error);
    }
    return null;
  }

  async getThresholdByHospitalId(hospitalId: string): Promise<ThresholdData | null> {
    if (!ThresholdRdb.rdbStore) return null;

    try {
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const resultSet = await ThresholdRdb.rdbStore.query(predicates);

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        const threshold = this.extractThresholdFromResultSet(resultSet);
        console.info(`获取到患者[${hospitalId}]的阈值设置:`, JSON.stringify(threshold));
        return threshold;
      } else {
        // 如果没有找到特定的阈值，返回默认阈值
        const defaultThreshold = await this.getDefaultThreshold();
        if (defaultThreshold) {
          console.info(`未找到患者[${hospitalId}]的阈值设置，使用默认阈值:`, JSON.stringify(defaultThreshold));
          // 创建一个新的阈值记录，基于默认值
          const newThreshold: ThresholdData = {
            hospitalId: hospitalId,
            temperatureMin: defaultThreshold.temperatureMin,
            temperatureMax: defaultThreshold.temperatureMax,
            systolicPressureMin: defaultThreshold.systolicPressureMin,
            systolicPressureMax: defaultThreshold.systolicPressureMax,
            diastolicPressureMin: defaultThreshold.diastolicPressureMin,
            diastolicPressureMax: defaultThreshold.diastolicPressureMax,
            heartRateMin: defaultThreshold.heartRateMin,
            heartRateMax: defaultThreshold.heartRateMax,
            bloodOxygenMin: defaultThreshold.bloodOxygenMin,
            bloodOxygenMax: defaultThreshold.bloodOxygenMax,
            updateTime: new Date().toISOString(),
            isDefault: false
          };
          await this.insertThreshold(newThreshold);
          return newThreshold;
        }
      }
    } catch (error) {
      console.error('获取阈值失败:', error);
    }
    return null;
  }

  async updateDefaultThreshold(threshold: ThresholdData): Promise<boolean> {
    if (!ThresholdRdb.rdbStore) return false;

    try {
      const updatedThreshold: ThresholdData = {
        hospitalId: 'default',
        temperatureMin: threshold.temperatureMin,
        temperatureMax: threshold.temperatureMax,
        systolicPressureMin: threshold.systolicPressureMin,
        systolicPressureMax: threshold.systolicPressureMax,
        diastolicPressureMin: threshold.diastolicPressureMin,
        diastolicPressureMax: threshold.diastolicPressureMax,
        heartRateMin: threshold.heartRateMin,
        heartRateMax: threshold.heartRateMax,
        bloodOxygenMin: threshold.bloodOxygenMin,
        bloodOxygenMax: threshold.bloodOxygenMax,
        updateTime: threshold.updateTime,
        isDefault: true
      };

      const valuesBucket = this.createValuesBucket(updatedThreshold);
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('isDefault', 1);

      const rows = await ThresholdRdb.rdbStore.update(valuesBucket, predicates);
      return rows > 0;
    } catch (error) {
      console.error('更新默认阈值失败:', error);
      return false;
    }
  }

  private createValuesBucket(threshold: ThresholdData): relationalStore.ValuesBucket {
    const valuesBucket: relationalStore.ValuesBucket = {
      hospitalId: threshold.hospitalId,
      temperatureMin: threshold.temperatureMin,
      temperatureMax: threshold.temperatureMax,
      systolicPressureMin: threshold.systolicPressureMin,
      systolicPressureMax: threshold.systolicPressureMax,
      diastolicPressureMin: threshold.diastolicPressureMin,
      diastolicPressureMax: threshold.diastolicPressureMax,
      heartRateMin: threshold.heartRateMin,
      heartRateMax: threshold.heartRateMax,
      bloodOxygenMin: threshold.bloodOxygenMin,
      bloodOxygenMax: threshold.bloodOxygenMax,
      updateTime: threshold.updateTime,
      isDefault: threshold.isDefault ? 1 : 0
    };
    return valuesBucket;
  }

  private extractThresholdFromResultSet(resultSet: relationalStore.ResultSet): ThresholdData {
    const threshold: ThresholdData = {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
      temperatureMin: resultSet.getDouble(resultSet.getColumnIndex('temperatureMin')),
      temperatureMax: resultSet.getDouble(resultSet.getColumnIndex('temperatureMax')),
      systolicPressureMin: resultSet.getLong(resultSet.getColumnIndex('systolicPressureMin')),
      systolicPressureMax: resultSet.getLong(resultSet.getColumnIndex('systolicPressureMax')),
      diastolicPressureMin: resultSet.getLong(resultSet.getColumnIndex('diastolicPressureMin')),
      diastolicPressureMax: resultSet.getLong(resultSet.getColumnIndex('diastolicPressureMax')),
      heartRateMin: resultSet.getLong(resultSet.getColumnIndex('heartRateMin')),
      heartRateMax: resultSet.getLong(resultSet.getColumnIndex('heartRateMax')),
      bloodOxygenMin: resultSet.getLong(resultSet.getColumnIndex('bloodOxygenMin')),
      bloodOxygenMax: resultSet.getLong(resultSet.getColumnIndex('bloodOxygenMax')),
      updateTime: resultSet.getString(resultSet.getColumnIndex('updateTime')),
      isDefault: resultSet.getLong(resultSet.getColumnIndex('isDefault')) === 1
    };
    return threshold;
  }

  async insertThreshold(threshold: ThresholdData): Promise<boolean> {
    if (!ThresholdRdb.rdbStore) return false;

    try {
      const valuesBucket = this.createValuesBucket(threshold);

      // 先尝试更新
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('hospitalId', threshold.hospitalId);

      const updateRows = await ThresholdRdb.rdbStore.update(valuesBucket, predicates);
      if (updateRows > 0) {
        return true; // 更新成功
      }

      // 如果更新失败（没有找到记录），则插入新记录
      const insertRows = await ThresholdRdb.rdbStore.insert('THRESHOLD_TABLE', valuesBucket);
      return insertRows !== -1;
    } catch (error) {
      console.error('插入或更新阈值失败:', error);
      return false;
    }
  }

  async updateThreshold(threshold: ThresholdData): Promise<boolean> {
    if (!ThresholdRdb.rdbStore || !threshold.hospitalId) return false;

    try {
      const valuesBucket = this.createValuesBucket(threshold);
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('hospitalId', threshold.hospitalId);

      const rows = await ThresholdRdb.rdbStore.update(valuesBucket, predicates);
      return rows > 0;
    } catch (error) {
      console.error('更新阈值失败:', error);
      return false;
    }
  }

  async deleteThresholdByHospitalId(hospitalId: string): Promise<void> {
    if (!ThresholdRdb.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      const predicates = new relationalStore.RdbPredicates('THRESHOLD_TABLE');
      predicates.equalTo('hospitalId', hospitalId);
      const count = await ThresholdRdb.rdbStore.delete(predicates);
      console.info(`删除阈值数据成功，影响行数: ${count}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error(`删除阈值数据失败: ${errorMessage}`);
      throw new Error(`删除阈值数据失败: ${errorMessage}`);
    }
  }
}

export default ThresholdRdb.getInstance();