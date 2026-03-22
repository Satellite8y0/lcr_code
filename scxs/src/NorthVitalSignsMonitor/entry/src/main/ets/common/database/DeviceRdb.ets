/**
 * 设备数据库 (DeviceDB.db)
 *
 * 表名：DEVICE_TABLE
 * 用途：存储所有设备的基本信息和状态
 *
 * 字段说明：
 * - deviceId: TEXT PRIMARY KEY    // 设备唯一标识
 * - deviceName: TEXT NOT NULL     // 设备名称
 * - batteryLevel: INTEGER         // 电池电量(0-100)
 * - status: TEXT                  // 设备状态(IDLE-空闲, IN_USE-使用中, OFFLINE-离线)
 * - isBound: INTEGER             // 是否已绑定(0-未绑定, 1-已绑定)
 * - lastUpdateTime: TEXT         // 最后更新时间
 * - hospitalId: TEXT             // 关联的住院号(可选)
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

// 设备数据接口
export interface DeviceData {
  deviceId: string;
  deviceName: string;
  batteryLevel: number;
  status: 'IDLE' | 'IN_USE' | 'OFFLINE';
  isBound: boolean;
  lastUpdateTime: string;
  hospitalId?: string;  // 添加可选的住院号字段
}

export class DeviceRdb {
  private static instance: DeviceRdb;
  private rdbStore: relationalStore.RdbStore | undefined;
  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'DeviceDB.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  private readonly SQL_CREATE_DEVICE_TABLE: string = 'CREATE TABLE IF NOT EXISTS DEVICE_TABLE ' +
    '(deviceId TEXT PRIMARY KEY, ' +
    'deviceName TEXT NOT NULL, ' +
    'batteryLevel INTEGER NOT NULL, ' +
    'status TEXT NOT NULL, ' +
    'isBound INTEGER NOT NULL, ' +
    'lastUpdateTime TEXT NOT NULL)';

  private readonly SQL_ALTER_ADD_HOSPITAL_ID: string = 'ALTER TABLE DEVICE_TABLE ADD COLUMN hospitalId TEXT';

  private constructor() {}

  public static getInstance(): DeviceRdb {
    if (!DeviceRdb.instance) {
      DeviceRdb.instance = new DeviceRdb();
    }
    return DeviceRdb.instance;
  }

  public async initDb(context: common.Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);

      // 首先创建基本表结构
      await this.rdbStore.executeSql(this.SQL_CREATE_DEVICE_TABLE);

      try {
        // 尝试添加 hospitalId 列
        await this.rdbStore.executeSql(this.SQL_ALTER_ADD_HOSPITAL_ID);
        console.info('设备表添加 hospitalId 字段成功');
      } catch (alterError) {
        // 如果列已存在，SQLite 会抛出错误，这是预期的行为
        console.info('hospitalId 字段可能已存在:', alterError instanceof Error ? alterError.message : String(alterError));
      }

      console.info('设备数据库初始化成功');
    } catch (err) {
      console.error(`设备数据库初始化异常: ${err}`);
    }
  }

  private ensureStoreReady(): boolean {
    if (!this.rdbStore) {
      console.error('设备数据库未初始化');
      return false;
    }
    return true;
  }

  public async getDeviceById(deviceId: string): Promise<DeviceData | undefined> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return undefined;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('DEVICE_TABLE');
      predicates.equalTo('deviceId', deviceId);

      const resultSet = await this.rdbStore.query(predicates, ['deviceId', 'deviceName', 'batteryLevel', 'status', 'isBound', 'lastUpdateTime', 'hospitalId']);
      if (!resultSet || resultSet.rowCount === 0) {
        resultSet?.close();
        return undefined;
      }

      resultSet.goToFirstRow();
      const device: DeviceData = {
        deviceId: resultSet.getString(resultSet.getColumnIndex('deviceId')),
        deviceName: resultSet.getString(resultSet.getColumnIndex('deviceName')),
        batteryLevel: resultSet.getLong(resultSet.getColumnIndex('batteryLevel')),
        status: resultSet.getString(resultSet.getColumnIndex('status')) as 'IDLE' | 'IN_USE' | 'OFFLINE',
        isBound: resultSet.getLong(resultSet.getColumnIndex('isBound')) === 1,
        lastUpdateTime: resultSet.getString(resultSet.getColumnIndex('lastUpdateTime')),
        hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId'))  // 获取住院号
      };
      resultSet.close();
      return device;
    } catch (err) {
      console.error(`查询设备失败: ${err}`);
      return undefined;
    }
  }

  public async getAllDevices(): Promise<DeviceData[]> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates('DEVICE_TABLE');
      const resultSet = await this.rdbStore.query(predicates, ['deviceId', 'deviceName', 'batteryLevel', 'status', 'isBound', 'lastUpdateTime', 'hospitalId']);
      const devices: DeviceData[] = [];

      while (resultSet.goToNextRow()) {
        devices.push({
          deviceId: resultSet.getString(resultSet.getColumnIndex('deviceId')),
          deviceName: resultSet.getString(resultSet.getColumnIndex('deviceName')),
          batteryLevel: resultSet.getLong(resultSet.getColumnIndex('batteryLevel')),
          status: resultSet.getString(resultSet.getColumnIndex('status')) as 'IDLE' | 'IN_USE' | 'OFFLINE',
          isBound: resultSet.getLong(resultSet.getColumnIndex('isBound')) === 1,
          lastUpdateTime: resultSet.getString(resultSet.getColumnIndex('lastUpdateTime')),
          hospitalId: resultSet.getString(resultSet.getColumnIndex('hospitalId'))
        });
      }
      resultSet.close();
      return devices;
    } catch (err) {
      console.error(`查询设备列表失败: ${err}`);
      return [];
    }
  }

  public async upsertDevice(device: DeviceData): Promise<boolean> {
    if (!this.ensureStoreReady() || !this.rdbStore) {
      return false;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        batteryLevel: device.batteryLevel,
        status: device.status,
        isBound: device.isBound ? 1 : 0,
        lastUpdateTime: device.lastUpdateTime,
        hospitalId: device.hospitalId ?? null  // 使用空值合并运算符，确保 undefined 会被转换为 null
      };

      const predicates = new relationalStore.RdbPredicates('DEVICE_TABLE');
      predicates.equalTo('deviceId', device.deviceId);

      const updateResult = await this.rdbStore.update(valueBucket, predicates);
      if (updateResult === 0) {
        // 如果更新失败（没有找到记录），则插入新记录
        await this.rdbStore.insert('DEVICE_TABLE', valueBucket);
      }
      return true;
    } catch (err) {
      console.error(`更新设备失败: ${err}`);
      return false;
    }
  }

  // 删除设备
  async deleteDevice(deviceId: string): Promise<boolean> {
    if (!this.ensureStoreReady()) {
      return false;
    }

    const predicates = new relationalStore.RdbPredicates('DEVICE_TABLE');
    predicates.equalTo('deviceId', deviceId);

    return new Promise((resolve) => {
      try {
        const store = this.rdbStore;
        if (store) {
          store.delete(predicates, (err, rows) => {
            if (err) {
              console.error(`删除设备失败: ${err.code}, ${err.message}`);
              resolve(false);
              return;
            }
            resolve(rows > 0);
          });
        } else {
          resolve(false);
        }
      } catch (err) {
        console.error(`删除设备异常: ${err}`);
        resolve(false);
      }
    });
  }
}

// 导出单例实例
export const deviceRdbInstance = DeviceRdb.getInstance();