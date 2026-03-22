/**
 * TCP数据库 (tcp.db)
 *
 * 表名：TCP_MESSAGE_TABLE
 * 用途：存储TCP消息记录
 * 字段说明：
 * - id: INTEGER PRIMARY KEY AUTOINCREMENT  // 自增主键
 * - clientId: TEXT NOT NULL                // 客户端ID
 * - messageType: TEXT NOT NULL             // 消息类型(data/error)
 * - content: TEXT NOT NULL                 // 消息内容
 * - timestamp: TEXT NOT NULL               // 消息时间戳
 */

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

// 数据库配置接口
interface StoreConfig {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
}

// TCP消息数据接口
export interface TCPMessageData {
  id?: number;
  clientId: string;
  messageType: string;
  content: string;
  timestamp: string;
}

export class TcpRdb {
  private static instance: TcpRdb;
  private static rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  static getInstance(): TcpRdb {
    if (!TcpRdb.instance) {
      TcpRdb.instance = new TcpRdb();
    }
    return TcpRdb.instance;
  }

  async initDb(context: common.Context) {
    const STORE_CONFIG: StoreConfig = {
      name: 'tcp.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    const SQL_CREATE_TABLE = `
      CREATE TABLE IF NOT EXISTS TCP_MESSAGE_TABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId TEXT NOT NULL,
        messageType TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )`;

    try {
      TcpRdb.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await TcpRdb.rdbStore.executeSql(SQL_CREATE_TABLE);
      console.info('TCP数据库初始化成功');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('TCP数据库初始化失败:', errorMessage);
      TcpRdb.rdbStore = null;
      throw new Error(`TCP数据库初始化失败: ${errorMessage}`);
    }
  }

  private createValuesBucket(message: TCPMessageData): relationalStore.ValuesBucket {
    return {
      clientId: message.clientId,
      messageType: message.messageType,
      content: message.content,
      timestamp: message.timestamp
    };
  }

  private extractMessageFromResultSet(resultSet: relationalStore.ResultSet): TCPMessageData {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      clientId: resultSet.getString(resultSet.getColumnIndex('clientId')),
      messageType: resultSet.getString(resultSet.getColumnIndex('messageType')),
      content: resultSet.getString(resultSet.getColumnIndex('content')),
      timestamp: resultSet.getString(resultSet.getColumnIndex('timestamp'))
    };
  }

  async insertMessage(message: TCPMessageData): Promise<boolean> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return false;
    }

    try {
      const valuesBucket = this.createValuesBucket(message);
      const ret = await TcpRdb.rdbStore.insert('TCP_MESSAGE_TABLE', valuesBucket);
      console.info('插入TCP消息成功:', message.clientId);
      return ret !== -1;
    } catch (error) {
      console.error('插入TCP消息失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async getMessagesByClientId(clientId: string): Promise<TCPMessageData[]> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates('TCP_MESSAGE_TABLE');
      predicates.equalTo('clientId', clientId);
      predicates.orderByDesc('timestamp');

      const resultSet = await TcpRdb.rdbStore.query(predicates);
      const messages: TCPMessageData[] = [];

      while (resultSet.goToNextRow()) {
        messages.push(this.extractMessageFromResultSet(resultSet));
      }
      resultSet.close();

      console.info(`获取客户端[${clientId}]的消息记录, 共${messages.length}条`);
      return messages;
    } catch (error) {
      console.error('查询TCP消息失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }

  async deleteMessagesByClientId(clientId: string): Promise<boolean> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('TCP_MESSAGE_TABLE');
      predicates.equalTo('clientId', clientId);
      const rows = await TcpRdb.rdbStore.delete(predicates);
      console.info(`删除客户端[${clientId}]的消息记录成功，影响行数: ${rows}`);
      return rows > 0;
    } catch (error) {
      console.error('删除TCP消息失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async clearAllMessages(): Promise<boolean> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('TCP_MESSAGE_TABLE');
      const rows = await TcpRdb.rdbStore.delete(predicates);
      console.info(`清空所有TCP消息记录成功，影响行数: ${rows}`);
      return true;
    } catch (error) {
      console.error('清空TCP消息失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  async getAllMessages(): Promise<TCPMessageData[]> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates('TCP_MESSAGE_TABLE');
      predicates.orderByDesc('timestamp');

      const resultSet = await TcpRdb.rdbStore.query(predicates);
      const messages: TCPMessageData[] = [];

      while (resultSet.goToNextRow()) {
        messages.push(this.extractMessageFromResultSet(resultSet));
      }
      resultSet.close();

      console.info(`获取所有TCP消息记录, 共${messages.length}条`);
      return messages;
    } catch (error) {
      console.error('查询TCP消息失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }

  async getLatestMessages(limit: number = 100): Promise<TCPMessageData[]> {
    if (!TcpRdb.rdbStore) {
      console.error('TCP数据库未初始化');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates('TCP_MESSAGE_TABLE');
      predicates.orderByDesc('timestamp');
      predicates.limitAs(limit);

      const resultSet = await TcpRdb.rdbStore.query(predicates);
      const messages: TCPMessageData[] = [];

      while (resultSet.goToNextRow()) {
        messages.push(this.extractMessageFromResultSet(resultSet));
      }
      resultSet.close();

      console.info(`获取最新TCP消息记录, 共${messages.length}条`);
      return messages;
    } catch (error) {
      console.error('查询TCP消息失败:', error instanceof Error ? error.message : String(error));
      return [];
    }
  }
}

export default TcpRdb.getInstance();