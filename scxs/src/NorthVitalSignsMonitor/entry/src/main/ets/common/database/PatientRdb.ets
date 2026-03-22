/**
 * 就诊记录数据库 (PatientDB.db)
 *
 * 表名：VISIT_RECORDS
 * 用途：存储患者就诊记录信息
 *
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - hospitalId: TEXT NOT NULL UNIQUE       // 住院号(YYMMDDNNNN格式)
 * - name: TEXT NOT NULL                    // 患者姓名
 * - phone: TEXT NOT NULL                   // 联系电话
 * - idCard: TEXT NOT NULL                  // 身份证号
 * - deviceId: TEXT                         // 绑定的设备ID
 * - diagnosis: TEXT                        // 诊断结果
 * - createTime: TEXT NOT NULL              // 创建时间
 * - remark: TEXT                           // 备注信息
 *
 * 主要功能：
 * 1. 管理患者就诊记录
 * 2. 跟踪设备绑定状态
 * 3. 记录诊断结果
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

// 定义患者数据接口
export interface PatientData {
  id: number;
  name: string;
  phone: string;
  idCard: string;
  createTime: string;
  remark: string;
  isBound: boolean;
}

// 定义就诊记录数据接口
export interface VisitRecord {
  id?: number;
  hospitalId: string;  // 住院号 YYMMDDNNNN，在添加记录时自动生成
  name: string;
  phone: string;
  idCard: string;
  deviceId: string;   // 绑定设备ID
  diagnosis: string;  // 诊断结果
  createTime: string;
  remark: string;
}

interface GeneratedTypeLiteralInterface_1 {
  hospitalId: string;
}

class PatientRdb {
  private static instance: PatientRdb;
  private rdbStore: relationalStore.RdbStore | undefined;
  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'PatientDB.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  private readonly SQL_CREATE_PATIENT_TABLE: string = 'CREATE TABLE IF NOT EXISTS VISIT_RECORDS' +
    '(id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'hospitalId TEXT NOT NULL UNIQUE, ' +
    'name TEXT NOT NULL, ' +
    'phone TEXT NOT NULL, ' +
    'idCard TEXT NOT NULL, ' +
    'deviceId TEXT, ' +
    'diagnosis TEXT, ' +
    'createTime TEXT NOT NULL, ' +
    'remark TEXT)';

  private constructor() {}

  public static getInstance(): PatientRdb {
    if (!PatientRdb.instance) {
      PatientRdb.instance = new PatientRdb();
    }
    return PatientRdb.instance;
  }

  private ensureStoreReady(): boolean {
    if (!this.rdbStore) {
      console.error('患者数据库未初始化');
      return false;
    }
    return true;
  }

  public async initRdbStore(context: common.Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);
      await this.rdbStore.executeSql(this.SQL_CREATE_PATIENT_TABLE);
      console.info('患者数据库初始化成功');
    } catch (err) {
      console.error(`患者数据库初始化异常: ${err}`);
      return;
    }
  }

  private async generateHospitalId(): Promise<string | undefined> {
    if (!this.rdbStore) {
      return undefined;
    }

    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const baseId = `${year}${month}${day}`;

    const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
    predicates.like('hospitalId', `${baseId}%`);
    predicates.orderByDesc('hospitalId');

    try {
      const result = await this.rdbStore.query(predicates, ['hospitalId']);
      let sequence = '0001';
      if (result && result.rowCount > 0) {
        result.goToFirstRow();
        const latestId = result.getString(result.getColumnIndex('hospitalId'));
        sequence = (parseInt(latestId.slice(-4)) + 1).toString().padStart(4, '0');
      }
      result?.close();
      return `${baseId}${sequence}`;
    } catch (err) {
      console.error(`生成住院号失败: ${err}`);
      return undefined;
    }
  }

  public async addVisitRecord(visit: VisitRecord): Promise<boolean> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return false;
    }

    try {
      const hospitalId = await this.generateHospitalId();
      if (!hospitalId) {
        return false;
      }

      const valueBucket: relationalStore.ValuesBucket = {
        hospitalId: hospitalId,
        name: visit.name,
        phone: visit.phone,
        idCard: visit.idCard,
        deviceId: visit.deviceId || '',
        diagnosis: visit.diagnosis || '',
        createTime: visit.createTime,
        remark: visit.remark || ''
      };

      const rowId = await this.rdbStore.insert('VISIT_RECORDS', valueBucket);
      console.info(`添加就诊记录成功，rowId: ${rowId}`);
      return true;
    } catch (err) {
      console.error(`添加就诊记录异常: ${err}`);
      return false;
    }
  }

  public async updateVisitRecord(visit: VisitRecord): Promise<boolean> {
    if (!this.ensureStoreReady() || !visit.id || !this.rdbStore) {
      return false;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        name: visit.name,
        phone: visit.phone,
        idCard: visit.idCard,
        deviceId: visit.deviceId || '',
        diagnosis: visit.diagnosis || '',
        createTime: visit.createTime,
        remark: visit.remark || ''
      };

      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('id', visit.id);

      const rows = await this.rdbStore.update(valueBucket, predicates);
      console.info(`更新就诊记录成功，影响行数: ${rows}`);
      return rows > 0;
    } catch (err) {
      console.error(`更新就诊记录异常: ${err}`);
      return false;
    }
  }

  public async deleteVisitRecord(id: number): Promise<boolean> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('id', id);

      const rows = await this.rdbStore.delete(predicates);
      console.info(`删除就诊记录成功，影响行数: ${rows}`);
      return rows > 0;
    } catch (err) {
      console.error(`删除就诊记录异常: ${err}`);
      return false;
    }
  }

  public async getAllVisitRecords(): Promise<VisitRecord[]> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.orderByDesc('id');

      const resultSet = await this.rdbStore.query(predicates, ['id', 'hospitalId', 'name', 'phone', 'idCard', 'deviceId', 'diagnosis', 'createTime', 'remark']);
      const visits: VisitRecord[] = [];

      while (resultSet.goToNextRow()) {
        visits.push({
          id: resultSet.getDouble(resultSet.getColumnIndex('id')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          phone: resultSet.getString(resultSet.getColumnIndex('phone')),
          idCard: resultSet.getString(resultSet.getColumnIndex('idCard')),
          deviceId: resultSet.getString(resultSet.getColumnIndex('deviceId')),
          diagnosis: resultSet.getString(resultSet.getColumnIndex('diagnosis')),
          createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
          remark: resultSet.getString(resultSet.getColumnIndex('remark'))
        });
      }
      resultSet.close();
      return visits;
    } catch (err) {
      console.error(`查询就诊记录异常: ${err}`);
      return [];
    }
  }

  /**
   * 通过住院号创建或更新就诊记录
   * @param visit 就诊记录
   * @returns 是否成功
   */
  public async createOrUpdateVisitByHospitalId(visitRecord: VisitRecord): Promise<boolean> {
    if (!this.rdbStore || !visitRecord.hospitalId) {
      return false;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        hospitalId: visitRecord.hospitalId,
        name: visitRecord.name,
        phone: visitRecord.phone,
        idCard: visitRecord.idCard,
        deviceId: visitRecord.deviceId || '',
        diagnosis: visitRecord.diagnosis || '',
        createTime: visitRecord.createTime,
        remark: visitRecord.remark || ''
      };

      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('hospitalId', visitRecord.hospitalId);

      const updateResult = await this.rdbStore.update(valueBucket, predicates);
      if (updateResult === 0) {
        // If update fails (no record found), insert new record
        const insertResult = await this.rdbStore.insert('VISIT_RECORDS', valueBucket);
        return insertResult !== -1;
      }
      return updateResult > 0;
    } catch (error) {
      console.error('更新就诊记录失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async hasActiveVisit(idCard: string): Promise<boolean> {
    if (!this.rdbStore) {
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('idCard', idCard)
        .and()
        .notEqualTo('deviceId', '')
        .and()
        .equalTo('diagnosis', ''); // 未完成就诊的记录

      const resultSet = await this.rdbStore.query(predicates);
      return resultSet.rowCount > 0;
    } catch (error) {
      console.error('查询活跃就诊记录失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async completeVisit(hospitalId: string): Promise<boolean> {
    if (!this.rdbStore) {
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('hospitalId', hospitalId);

      const valueBucket: relationalStore.ValuesBucket = {
        diagnosis: '已完成就诊',
        deviceId: ''  // 解除设备绑定
      };

      const rows = await this.rdbStore.update(valueBucket, predicates);
      return rows > 0;
    } catch (error) {
      console.error('完成就诊记录失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async getVisitByHospitalId(hospitalId: string): Promise<VisitRecord | null> {
    if (!this.rdbStore) {
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('VISIT_RECORDS');
      predicates.equalTo('hospitalId', hospitalId);

      const resultSet = await this.rdbStore.query(predicates);
      if (resultSet.rowCount === 0) {
        return null;
      }

      resultSet.goToFirstRow();
      const visit: VisitRecord = {
        id: resultSet.getDouble(resultSet.getColumnIndex('id')),
        hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        phone: resultSet.getString(resultSet.getColumnIndex('phone')),
        idCard: resultSet.getString(resultSet.getColumnIndex('idCard')),
        deviceId: resultSet.getString(resultSet.getColumnIndex('deviceId')),
        diagnosis: resultSet.getString(resultSet.getColumnIndex('diagnosis')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
        remark: resultSet.getString(resultSet.getColumnIndex('remark'))
      };
      resultSet.close();
      return visit;
    } catch (error) {
      console.error('查询就诊记录失败:', error instanceof Error ? error.message : String(error));
      return null;
    }
  }
}

export default PatientRdb.getInstance();