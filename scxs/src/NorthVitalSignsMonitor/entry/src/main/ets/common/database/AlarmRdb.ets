/**
 * 告警数据库 (alarm.db)
 *
 * 表名：ALARM_TABLE
 * 用途：存储生命体征监测的告警记录
 *
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL              // 住院号
 * - patientName: TEXT NOT NULL             // 患者姓名
 * - alarmType: TEXT NOT NULL               // 告警类型(temperature/bloodPressure/heartRate/bloodOxygen)
 * - alarmValue: REAL NOT NULL              // 告警值
 * - alarmTime: TEXT NOT NULL               // 告警时间
 * - status: INTEGER NOT NULL               // 告警状态(0-未处理, 1-已处理, 2-已延迟)
 * - delayTime: TEXT                        // 延迟提醒时间
 * - processTime: TEXT                      // 处理时间
 * - remark: TEXT                           // 备注
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

// 告警记录接口
export type AlarmType = 'temperature' | 'bloodPressure' | 'heartRate' | 'bloodOxygen';

export interface AlarmRecord {
  id?: number;
  hospitalId: string;
  patientName: string;
  alarmType: AlarmType;
  alarmValue: number;
  alarmTime: string;
  status: number;  // 0-未处理, 1-已处理, 2-已延迟
  delayTime?: string;
  processTime?: string;
  remark?: string;
}

export class AlarmRdb {
  private static rdbStore: relationalStore.RdbStore | null = null;
  private static readonly ALARM_TABLE = 'alarm_table';
  private static readonly CREATE_TABLE_SQL = `
    CREATE TABLE IF NOT EXISTS ${AlarmRdb.ALARM_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hospital_id TEXT NOT NULL,
      patient_name TEXT NOT NULL,
      alarm_type TEXT NOT NULL,
      alarm_value REAL NOT NULL,
      alarm_time TEXT NOT NULL,
      status INTEGER NOT NULL DEFAULT 0,
      delay_time TEXT,
      process_time TEXT,
      remarks TEXT
    )
  `;

  public static async initDb(context: common.Context): Promise<void> {
    try {
      console.info('开始初始化告警数据库...');
      const STORE_CONFIG: relationalStore.StoreConfig = {
        name: 'alarm.db',
        securityLevel: relationalStore.SecurityLevel.S1
      };

      // 获取数据库实例
      console.info('获取数据库实例...');
      AlarmRdb.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);

      // Create the table if not exists
      console.info('开始创建告警表（如果不存在）...');
      console.info('创建表SQL:', AlarmRdb.CREATE_TABLE_SQL);
      await AlarmRdb.rdbStore.executeSql(AlarmRdb.CREATE_TABLE_SQL);
      console.info('告警数据库初始化成功');

      // 验证表结构
      try {
        const resultSet = await AlarmRdb.rdbStore.query(new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE), ['1']);
        const columnNames = resultSet.columnNames;
        console.info('告警表结构验证 - 列名:', columnNames);
        resultSet.close();
      } catch (error) {
        console.error('验证表结构失败:', error instanceof Error ? error.message : String(error));
      }
    } catch (error) {
      console.error('告警数据库初始化失败:', error instanceof Error ? error.message : String(error));
      throw new Error('告警数据库初始化失败');
    }
  }

  private static createValuesBucket(alarm: AlarmRecord): relationalStore.ValuesBucket {
    const valuesBucket: relationalStore.ValuesBucket = {
      'hospital_id': alarm.hospitalId,
      'patient_name': alarm.patientName,
      'alarm_type': alarm.alarmType,
      'alarm_value': alarm.alarmValue,
      'alarm_time': alarm.alarmTime,
      'status': alarm.status
    };

    if (alarm.delayTime) {
      valuesBucket['delay_time'] = alarm.delayTime;
    }
    if (alarm.processTime) {
      valuesBucket['process_time'] = alarm.processTime;
    }
    if (alarm.remark) {
      valuesBucket['remarks'] = alarm.remark;
    }

    return valuesBucket;
  }

  public static async createAlarmFromAbnormalData(
    hospitalId: string,
    patientName: string,
    alarmType: AlarmType,
    alarmValue: number,
    alarmTime: string
  ): Promise<boolean> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const alarm: AlarmRecord = {
        hospitalId,
        patientName,
        alarmType,
        alarmValue,
        alarmTime,
        status: 0
      };

      console.info(`尝试创建告警记录: ${JSON.stringify(alarm)}`);
      const valuesBucket = AlarmRdb.createValuesBucket(alarm);
      console.info(`告警数据转换为ValuesBucket: ${JSON.stringify(valuesBucket)}`);

      const rowId = await AlarmRdb.rdbStore.insert(AlarmRdb.ALARM_TABLE, valuesBucket);
      console.info(`告警记录创建${rowId !== -1 ? '成功' : '失败'}, rowId: ${rowId}`);
      return rowId !== -1;
    } catch (error) {
      console.error('创建告警记录失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  public static async getUnprocessedAlarms(): Promise<AlarmRecord[]> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return [];
    }

    try {
      console.info('开始查询未处理的告警记录');
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('status', 0).or().equalTo('status', 2);
      predicates.orderByDesc('alarm_time');

      const resultSet = await AlarmRdb.rdbStore.query(predicates, ['*']);
      console.info(`查询结果集获取成功，开始解析数据`);

      const alarms: AlarmRecord[] = [];
      while (resultSet.goToNextRow()) {
        const alarm: AlarmRecord = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospital_id')),
          patientName: resultSet.getString(resultSet.getColumnIndex('patient_name')),
          alarmType: resultSet.getString(resultSet.getColumnIndex('alarm_type')) as AlarmType,
          alarmValue: resultSet.getDouble(resultSet.getColumnIndex('alarm_value')),
          alarmTime: resultSet.getString(resultSet.getColumnIndex('alarm_time')),
          status: resultSet.getLong(resultSet.getColumnIndex('status')),
          processTime: resultSet.getString(resultSet.getColumnIndex('process_time')),
          remark: resultSet.getString(resultSet.getColumnIndex('remarks'))
        };
        alarms.push(alarm);
      }
      resultSet.close();

      console.info(`查询到 ${alarms.length} 条未处理的告警记录`);
      console.info(`告警记录详情: ${JSON.stringify(alarms)}`);
      return alarms;
    } catch (error) {
      console.error('查询未处理告警失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }

  public static async getHistoryAlarms(startDate: string, endDate: string): Promise<AlarmRecord[]> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return [];
    }

    try {
      console.info('开始查询历史告警记录，时间范围:', startDate, '至', endDate);

      // 将本地时间转换为UTC时间进行查询
      const startUtc = new Date(startDate).toISOString();
      const endUtc = new Date(endDate).toISOString();
      console.info('转换为UTC时间范围:', startUtc, '至', endUtc);

      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.between('alarm_time', startUtc, endUtc);
      predicates.orderByDesc('alarm_time');

      const resultSet = await AlarmRdb.rdbStore.query(predicates, ['*']);
      console.info('查询结果集获取成功，开始解析数据');
      console.info('SQL查询条件:', `alarm_time BETWEEN '${startUtc}' AND '${endUtc}'`);

      const alarms: AlarmRecord[] = [];
      while (resultSet.goToNextRow()) {
        const alarm: AlarmRecord = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospital_id')),
          patientName: resultSet.getString(resultSet.getColumnIndex('patient_name')),
          alarmType: resultSet.getString(resultSet.getColumnIndex('alarm_type')) as AlarmType,
          alarmValue: resultSet.getDouble(resultSet.getColumnIndex('alarm_value')),
          alarmTime: resultSet.getString(resultSet.getColumnIndex('alarm_time')),
          status: resultSet.getLong(resultSet.getColumnIndex('status')),
          processTime: resultSet.getString(resultSet.getColumnIndex('process_time')),
          remark: resultSet.getString(resultSet.getColumnIndex('remarks'))
        };
        alarms.push(alarm);
      }
      resultSet.close();

      console.info(`查询到 ${alarms.length} 条历史告警记录`);
      if (alarms.length > 0) {
        console.info('第一条告警记录:', JSON.stringify(alarms[0]));
        console.info('末条告警记录:', JSON.stringify(alarms[alarms.length - 1]));
      }
      return alarms;
    } catch (error) {
      console.error('查询历史告警失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }

  public static async updateAlarmStatus(id: number, status: number, delayTime?: string): Promise<boolean> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('id', id);
      const valuesBucket: relationalStore.ValuesBucket = {
        'status': status
      };
      if (delayTime) {
        valuesBucket['delay_time'] = delayTime;
      }
      const rows = await AlarmRdb.rdbStore.update(valuesBucket, predicates);
      console.info(`更新告警状态成功，影响行数: ${rows}`);
      return rows > 0;
    } catch (error) {
      console.error('更新告警状态失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  public static async deleteAlarm(id: number): Promise<boolean> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('id', id);
      const rows = await AlarmRdb.rdbStore.delete(predicates);
      return rows > 0;
    } catch (error) {
      console.error('删除告警记录失败:', error);
      return false;
    }
  }

  static async deleteAlarmsByHospitalId(hospitalId: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('hospital_id', hospitalId);
      const count = await AlarmRdb.rdbStore?.delete(predicates);
      console.info(`删除告警数据成功，影响行数: ${count}`);
    } catch (error) {
      console.error(`删除告警数据失败: ${error}`);
    }
  }

  // 添加清理方法
  public static async cleanup(): Promise<void> {
    try {
      if (AlarmRdb.rdbStore !== null) {
        await AlarmRdb.rdbStore.close();
        AlarmRdb.rdbStore = null;
        console.info('告警数据库连接已关闭');
      }
    } catch (error) {
      console.error('关闭告警数据库失败:', error instanceof Error ? error.message : String(error));
    }
  }

  public static async getAllActiveAlarms(): Promise<AlarmRecord[]> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return [];
    }

    try {
      console.info('开始查询所有活动告警记录');
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('status', 0).or().equalTo('status', 2);
      predicates.orderByDesc('alarm_time');

      const resultSet = await AlarmRdb.rdbStore.query(predicates, ['*']);
      console.info(`查询结果集获取成功，开始解析数据`);

      const alarms: AlarmRecord[] = [];
      while (resultSet.goToNextRow()) {
        const alarm: AlarmRecord = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospital_id')),
          patientName: resultSet.getString(resultSet.getColumnIndex('patient_name')),
          alarmType: resultSet.getString(resultSet.getColumnIndex('alarm_type')) as AlarmType,
          alarmValue: resultSet.getDouble(resultSet.getColumnIndex('alarm_value')),
          alarmTime: resultSet.getString(resultSet.getColumnIndex('alarm_time')),
          status: resultSet.getLong(resultSet.getColumnIndex('status')),
          delayTime: resultSet.getString(resultSet.getColumnIndex('delay_time')),
          processTime: resultSet.getString(resultSet.getColumnIndex('process_time')),
          remark: resultSet.getString(resultSet.getColumnIndex('remarks'))
        };
        alarms.push(alarm);
      }
      resultSet.close();

      console.info(`查询到 ${alarms.length} 条活动告警记录`);
      console.info(`告警记录详情: ${JSON.stringify(alarms)}`);
      return alarms;
    } catch (error) {
      console.error('查询活动告警失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }

  public static async updateAlarmDelay(id: number, delayTime: string): Promise<boolean> {
    if (!AlarmRdb.rdbStore) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(AlarmRdb.ALARM_TABLE);
      predicates.equalTo('id', id);
      const valuesBucket: relationalStore.ValuesBucket = {
        'status': 2,  // 设置为已延迟状态
        'delay_time': delayTime
      };
      const rows = await AlarmRdb.rdbStore.update(valuesBucket, predicates);
      console.info(`更新告警延迟时间成功，影响行数: ${rows}`);
      return rows > 0;
    } catch (error) {
      console.error('更新告警延迟时间失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }
}