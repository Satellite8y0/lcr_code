import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { socket } from '@kit.NetworkKit';
import { DeviceRdb } from '../common/database/DeviceRdb';
import { AlarmRdb } from '../common/database/AlarmRdb';
import { VitalSignsRdb } from '../common/database/VitalSignsRdb';
import PatientRdb from '../common/database/PatientRdb';
import ThresholdRdb, { ThresholdData } from '../common/database/ThresholdRdb';
import TcpRdb, { TCPMessageData } from '../common/database/TcpRdb';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import notification from '@ohos.notification';
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
const TCP_PORT = 8000;

// Define event handling classes
class TCPAddress {
  address: string;
  port: number;
  family: number;

  constructor(address: string, port: number, family: number = 1) {
    this.address = address;
    this.port = port;
    this.family = family;
  }
}

class TCPMessage {
  message: ArrayBuffer;
  constructor(message: ArrayBuffer) {
    this.message = message;
  }
}

class TCPEvent {
  detail: TCPMessage;
  constructor(detail: TCPMessage) {
    this.detail = detail;
  }
}

class EventCallback {
  callback: (event: TCPEvent) => void;
  constructor(callback: (event: TCPEvent) => void) {
    this.callback = callback;
  }
}

class MessageData {
  message: ArrayBuffer;
  constructor(message: ArrayBuffer) {
    this.message = message;
  }
}

class CustomEventHub {
  private listeners: Map<string, Set<EventCallback>>;

  constructor() {
    this.listeners = new Map<string, Set<EventCallback>>();
  }

  addEventListener(type: string, callback: (event: TCPEvent) => void): void {
    if (!this.listeners.has(type)) {
      this.listeners.set(type, new Set<EventCallback>());
    }
    this.listeners.get(type)?.add(new EventCallback(callback));
  }

  removeEventListener(type: string, callback: (event: TCPEvent) => void): void {
    const listeners = this.listeners.get(type);
    if (listeners) {
      for (const eventCallback of listeners) {
        if (eventCallback.callback === callback) {
          listeners.delete(eventCallback);
          break;
        }
      }
    }
  }

  emit(type: string, detail: TCPMessage): void {
    const event = new TCPEvent(detail);
    this.listeners.get(type)?.forEach(eventCallback => {
      eventCallback.callback(event);
    });
  }
}

// 全局TCP服务器实例和状态
export class GlobalTCPServer {
  private static instance: GlobalTCPServer;
  private tcpServer: socket.TCPSocketServer;
  private tcpConnection: socket.TCPSocketConnection | null = null;
  private isListening: boolean = false;
  private static eventListeners: Set<(status: boolean) => void> = new Set();
  private static onlineDevices: Set<string> = new Set();
  private static preferencesInstance: preferences.Preferences | null = null;

  private constructor() {
    this.tcpServer = socket.constructTCPSocketServerInstance();
  }

  public static getInstance(): GlobalTCPServer {
    if (!GlobalTCPServer.instance) {
      GlobalTCPServer.instance = new GlobalTCPServer();
    }
    return GlobalTCPServer.instance;
  }

  public static async initPreferences(context: Context): Promise<void> {
    try {
      GlobalTCPServer.preferencesInstance = await preferences.getPreferences(context, 'tcp_server');
      await GlobalTCPServer.preferencesInstance.put('port_in_use', false);
      await GlobalTCPServer.preferencesInstance.flush();
      console.info('TCP服务器首选项初始化成功');
    } catch (error) {
      console.error('TCP服务器首选项初始化失败:', error);
    }
  }

  public static async isPortInUse(): Promise<boolean> {
    if (GlobalTCPServer.preferencesInstance) {
      try {
        return await GlobalTCPServer.preferencesInstance.get('port_in_use', false) as boolean;
      } catch (error) {
        console.error('获取端口状态失败:', error);
        return false;
      }
    }
    return false;
  }

  private static async updateOnlineDeviceCount(): Promise<void> {
    if (GlobalTCPServer.preferencesInstance) {
      try {
        await GlobalTCPServer.preferencesInstance.put('online_devices', GlobalTCPServer.onlineDevices.size);
        await GlobalTCPServer.preferencesInstance.flush();
        console.info('更新在线设备数:', GlobalTCPServer.onlineDevices.size);
      } catch (error) {
        console.error('更新在线设备数失败:', error);
      }
    }
  }

  public static async getOnlineDeviceCount(): Promise<number> {
    if (GlobalTCPServer.preferencesInstance) {
      try {
        return await GlobalTCPServer.preferencesInstance.get('online_devices', 0) as number;
      } catch (error) {
        console.error('获取在线设备数失败:', error);
        return 0;
      }
    }
    return 0;
  }

  private static async addOnlineDevice(clientId: string): Promise<void> {
    GlobalTCPServer.onlineDevices.add(clientId);
    await GlobalTCPServer.updateOnlineDeviceCount();
  }

  private static async removeOnlineDevice(clientId: string): Promise<void> {
    GlobalTCPServer.onlineDevices.delete(clientId);
    await GlobalTCPServer.updateOnlineDeviceCount();
  }

  public addStatusListener(listener: (status: boolean) => void): void {
    GlobalTCPServer.eventListeners.add(listener);
    listener(this.isListening);
  }

  public removeStatusListener(listener: (status: boolean) => void): void {
    GlobalTCPServer.eventListeners.delete(listener);
  }

  private notifyStatusChange(status: boolean): void {
    this.isListening = status;
    GlobalTCPServer.eventListeners.forEach(listener => listener(status));
  }

  private async updatePortStatus(inUse: boolean): Promise<void> {
    if (GlobalTCPServer.preferencesInstance) {
      try {
        await GlobalTCPServer.preferencesInstance.put('port_in_use', inUse);
        await GlobalTCPServer.preferencesInstance.flush();
        console.info('更新端口状态:', inUse);
      } catch (error) {
        console.error('更新端口状态失败:', error);
      }
    }
  }

  public async startListening(): Promise<void> {
    if (this.isListening) {
      console.info('TCP服务器已经在监听中');
      return;
    }

    try {
      const ipAddress = new TCPAddress('0.0.0.0', TCP_PORT);
      await this.tcpServer.listen(ipAddress);
      console.info('TCP服务器启动成功，监听地址:', ipAddress.address, '端口:', ipAddress.port);

      this.tcpServer.on('connect', (connection: socket.TCPSocketConnection) => {
        console.info('TCP客户端连接成功');
        this.tcpConnection = connection;
        this.isListening = true;
        this.updatePortStatus(true);
        this.notifyStatusChange(true);

        // 为新连接生成一个临时ID
        const tempClientId = `CLIENT_${Date.now()}`;
        GlobalTCPServer.addOnlineDevice(tempClientId);

        connection.on('message', (data: MessageData) => {
          // 将 ArrayBuffer 转换为 Uint8Array
          const bytes = new Uint8Array(data.message);

          // 打印字节数组
          console.info('收到客户端消息(字节):', Array.from(bytes));

          // 打印十六进制表示
          console.info('收到客户端消息(十六进制):', Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join(' '));

          // 尝试将字节转换为字符串（假设是ASCII或UTF-8编码）
          let str = '';
          for (let i = 0; i < bytes.length; i++) {
            str += String.fromCharCode(bytes[i]);
          }
          console.info('收到客户端消息(字符串):', str);

          const tcpMessage = new TCPMessage(data.message);
          (globalThis.eventHub as CustomEventHub)?.emit('tcp-message', tcpMessage);
        });

        connection.on('close', async () => {
          console.info('TCP客户端连接断开');
          await GlobalTCPServer.removeOnlineDevice(tempClientId);
          this.tcpConnection = null;
          this.isListening = false;
          this.updatePortStatus(false);
          this.notifyStatusChange(false);
        });
      });

      this.tcpServer.on('error', (err: Error) => {
        console.error('TCP服务器错误:', err);
        this.isListening = false;
        this.updatePortStatus(false);
        this.notifyStatusChange(false);
      });

    } catch (error) {
      console.error('TCP服务器启动失败:', error);
      this.isListening = false;
      this.updatePortStatus(false);
      this.notifyStatusChange(false);
    }
  }

  public async stopListening(): Promise<void> {
    try {
      if (this.tcpConnection) {
        this.tcpConnection.off('message');
        this.tcpConnection.off('close');
        this.tcpConnection.close();
        this.tcpConnection = null;
      }

      this.tcpServer.off('connect');
      this.tcpServer.off('error');
      this.tcpServer = socket.constructTCPSocketServerInstance();

      this.isListening = false;
      await this.updatePortStatus(false);
      this.notifyStatusChange(false);
      console.info('TCP服务器已停止');
    } catch (error) {
      console.error('停止TCP服务器失败:', error);
    }
  }

  public getTcpConnection(): socket.TCPSocketConnection | null {
    return this.tcpConnection;
  }

  public isServerListening(): boolean {
    return this.isListening;
  }
}

// 数据接口定义
interface VitalSigns {
  temperature?: number;
  bloodPressure?: BloodPressure;
  heartRate?: number;
  bloodOxygen?: number;
}

interface BloodPressure {
  systolic: number;
  diastolic: number;
}

interface DeviceData {
  deviceId: string;
  timestamp: string;
  vitalSigns: VitalSigns;
}

// 错误码定义
enum ErrorCode {
  SUCCESS = 0,
  INVALID_TEMPERATURE = 1001,
  INVALID_BLOOD_PRESSURE = 1002,
  INVALID_HEART_RATE = 1003,
  INVALID_BLOOD_OXYGEN = 1004,
  INVALID_FORMAT = 1005,
  INVALID_TIMESTAMP = 1006
}

interface ValidationResult {
  code: ErrorCode;
  message: string;
}

interface ErrorResponse {
  code: ErrorCode;
  message: string;
  timestamp: string;
}

// 添加接口定义
interface ParsedData {
  deviceId: string;
  mac: string;
  macAddress: string;
  deviceMac: string;
  hwAddress: string;
}

// 定义通知内容类型
interface NotificationBasicContent {
  title: string;
  text: string;
  additionalText?: string;
}

interface NotificationContent {
  notificationContentType: notificationManager.ContentType;
  normal: NotificationBasicContent;
}

interface NotificationRequestData {
  id: number;
  content: NotificationContent;
}

// 消息队列类
class MessageQueue {
  private messages: ArrayBuffer[] = [];
  private isProcessing: boolean = false;

  async enqueue(message: ArrayBuffer): Promise<void> {
    this.messages.push(message);
    if (!this.isProcessing) {
      await this.processMessages();
    }
  }

  private async processMessages(): Promise<void> {
    this.isProcessing = true;
    while (this.messages.length > 0) {
      const message = this.messages.shift();
      if (message) {
        await this.processMessage(message);
      }
    }
    this.isProcessing = false;
  }

  private async processMessage(message: ArrayBuffer): Promise<void> {
    // 获取当前时间戳，用于错误消息
    const currentTimestamp = new Date().toISOString();

    try {
      // 将ArrayBuffer转换为字符串
      const bytes = new Uint8Array(message);
      let jsonString = '';
      for (let i = 0; i < bytes.length; i++) {
        jsonString += String.fromCharCode(bytes[i]);
      }
      console.info('处理消息:', jsonString);

      // 尝试解析JSON数据以获取设备ID
      let clientId: string;
      try {
        const parsedData: Record<string, string> = JSON.parse(jsonString);
        clientId = this.getClientId(parsedData, jsonString);
      } catch {
        clientId = this.extractMacFromRawData(jsonString) || this.generateTempId(jsonString);
      }

      // 解析JSON数据
      let data: DeviceData;
      try {
        data = JSON.parse(jsonString) as DeviceData;
      } catch (err) {
        await TcpRdb.insertMessage({
          clientId: clientId,
          messageType: 'error',
          content: JSON.stringify({
            error: `消息解析失败: ${err instanceof Error ? err.message : String(err)}`,
            rawData: jsonString
          }),
          timestamp: currentTimestamp // 使用当前时间戳
        });
        console.error('JSON解析失败:', err);
        return;
      }

      // 验证数据格式
      const validationResult = this.validateVitalSigns(data);
      if (validationResult.code !== ErrorCode.SUCCESS) {
        await TcpRdb.insertMessage({
          clientId: clientId,
          messageType: 'error',
          content: JSON.stringify({
            error: validationResult.message,
            rawData: jsonString
          }),
          timestamp: currentTimestamp // 使用当前时间戳
        });
        console.error('数据验证失败:', validationResult.message);
        return;
      }

      await this.handleDeviceData(data);

      // 记录成功消息到TCP数据库
      await TcpRdb.insertMessage({
        clientId: clientId,
        messageType: 'data',
        content: jsonString,
        timestamp: data.timestamp || currentTimestamp // 优先使用数据中的时间戳，如果没有则使用当前时间戳
      });

    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : String(err);
      const rawData = Array.from(new Uint8Array(message))
        .map(byte => String.fromCharCode(byte))
        .join('');

      const clientId = this.extractMacFromRawData(rawData) || this.generateTempId(rawData);

      await TcpRdb.insertMessage({
        clientId: clientId,
        messageType: 'error',
        content: JSON.stringify({
          error: `消息处理失败: ${errorMessage}`,
          rawData: rawData
        }),
        timestamp: currentTimestamp // 使用当前时间戳
      });
      console.error('处理消息失败:', errorMessage);
    }
  }

  // 获取客户端ID
  private getClientId(data: Record<string, string>, rawData: string): string {
    // 首先检查deviceId
    if (data.deviceId) {
      return data.deviceId;
    }

    // 然后检查各种MAC地址字段
    if (data.mac && this.isValidMacAddress(data.mac)) {
      return data.mac;
    }
    if (data.macAddress && this.isValidMacAddress(data.macAddress)) {
      return data.macAddress;
    }
    if (data.deviceMac && this.isValidMacAddress(data.deviceMac)) {
      return data.deviceMac;
    }
    if (data.hwAddress && this.isValidMacAddress(data.hwAddress)) {
      return data.hwAddress;
    }

    // 尝试从原始数据中提取MAC地址
    const extractedMac = this.extractMacFromRawData(rawData);
    if (extractedMac) {
      return extractedMac;
    }

    // 最后生成临时ID
    return this.generateTempId(rawData);
  }

  // 从原始数据中提取MAC地址
  private extractMacFromRawData(rawData: string): string | null {
    // MAC地址的正则表达式模式
    const macPattern = /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/;
    const match = rawData.match(macPattern);
    return match ? match[0] : null;
  }

  // 验证MAC地址格式
  private isValidMacAddress(mac: string): boolean {
    const macPattern = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
    return macPattern.test(mac);
  }

  // 生成临时ID（基于数据内容的哈希）
  private generateTempId(data: string): string {
    let hash = 0;
    for (let i = 0; i < data.length; i++) {
      const char = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return `TEMP_${Math.abs(hash).toString(16).padStart(8, '0')}`;
  }

  private validateVitalSigns(data: DeviceData): ValidationResult {
    try {
      if (!data.deviceId) {
        return { code: ErrorCode.INVALID_FORMAT, message: '缺少设备ID' };
      }

      // 如果没有时间戳，直接使用当前时间
      if (!data.timestamp) {
        data.timestamp = new Date().toISOString();
      }

      // 如果有时间戳，直接使用当前时间
      if (data.timestamp) {
        data.timestamp = new Date().toISOString();
      }

      if (!data.vitalSigns) {
        return { code: ErrorCode.INVALID_FORMAT, message: '缺少生命体征数据' };
      }

      const vitalSigns = data.vitalSigns;

      if (vitalSigns.temperature !== undefined) {
        if (vitalSigns.temperature < 0) {
          return {
            code: ErrorCode.INVALID_TEMPERATURE,
            message: `体温不能为负值: ${vitalSigns.temperature}℃`
          };
        }
        if (vitalSigns.temperature > 50) {
          return {
            code: ErrorCode.INVALID_TEMPERATURE,
            message: `体温值异常: ${vitalSigns.temperature}℃，超出合理范围(0-50℃)`
          };
        }
      }

      if (vitalSigns.bloodPressure) {
        if (vitalSigns.bloodPressure.systolic !== undefined) {
          if (vitalSigns.bloodPressure.systolic < 0) {
            return {
              code: ErrorCode.INVALID_BLOOD_PRESSURE,
              message: `收缩压不能为负值: ${vitalSigns.bloodPressure.systolic} mmHg`
            };
          }
          if (vitalSigns.bloodPressure.systolic > 300) {
            return {
              code: ErrorCode.INVALID_BLOOD_PRESSURE,
              message: `收缩压值异常: ${vitalSigns.bloodPressure.systolic} mmHg，超出合理范围(0-300mmHg)`
            };
          }
        }
        if (vitalSigns.bloodPressure.diastolic !== undefined) {
          if (vitalSigns.bloodPressure.diastolic < 0) {
            return {
              code: ErrorCode.INVALID_BLOOD_PRESSURE,
              message: `舒张压不能为负值: ${vitalSigns.bloodPressure.diastolic} mmHg`
            };
          }
          if (vitalSigns.bloodPressure.diastolic > 200) {
            return {
              code: ErrorCode.INVALID_BLOOD_PRESSURE,
              message: `舒张压值异常: ${vitalSigns.bloodPressure.diastolic} mmHg，超出合理范围(0-200mmHg)`
            };
          }
        }
      }

      if (vitalSigns.heartRate !== undefined) {
        if (vitalSigns.heartRate < 0) {
          return {
            code: ErrorCode.INVALID_HEART_RATE,
            message: `心率不能为负值: ${vitalSigns.heartRate} 次/分`
          };
        }
        if (vitalSigns.heartRate > 300) {
          return {
            code: ErrorCode.INVALID_HEART_RATE,
            message: `心率值异常: ${vitalSigns.heartRate} 次/分，超出合理范围(0-300次/分)`
          };
        }
      }

      if (vitalSigns.bloodOxygen !== undefined) {
        if (vitalSigns.bloodOxygen < 0) {
          return {
            code: ErrorCode.INVALID_BLOOD_OXYGEN,
            message: `血氧不能为负值: ${vitalSigns.bloodOxygen}%`
          };
        }
        if (vitalSigns.bloodOxygen > 100) {
          return {
            code: ErrorCode.INVALID_BLOOD_OXYGEN,
            message: `血氧值异常: ${vitalSigns.bloodOxygen}%，超出合理范围(0-100%)`
          };
        }
      }

      return { code: ErrorCode.SUCCESS, message: '数据格式正确' };
    } catch (err) {
      return { code: ErrorCode.INVALID_FORMAT, message: '数据格式错误: ' + err.message };
    }
  }

  private async checkAndCreateAlarms(data: DeviceData, hospitalId: string, patientName: string, threshold: ThresholdData): Promise<void> {
    const vitalSigns = data.vitalSigns;

    // 检查体温
    if (vitalSigns.temperature !== undefined) {
      if (vitalSigns.temperature < threshold.temperatureMin || vitalSigns.temperature > threshold.temperatureMax) {
        await AlarmRdb.createAlarmFromAbnormalData(
          hospitalId,
          patientName,
          'temperature',
          vitalSigns.temperature,
          data.timestamp
        );
        await this.sendAlarmNotification('体温', patientName, vitalSigns.temperature, '°C', Date.now());
      }
    }

    // 检查血压
    if (vitalSigns.bloodPressure) {
      if (vitalSigns.bloodPressure.systolic < threshold.systolicPressureMin ||
        vitalSigns.bloodPressure.systolic > threshold.systolicPressureMax ||
        vitalSigns.bloodPressure.diastolic < threshold.diastolicPressureMin ||
        vitalSigns.bloodPressure.diastolic > threshold.diastolicPressureMax) {
        await AlarmRdb.createAlarmFromAbnormalData(
          hospitalId,
          patientName,
          'bloodPressure',
          vitalSigns.bloodPressure.systolic,
          data.timestamp
        );
        await this.sendAlarmNotification('血压', patientName,
          `${vitalSigns.bloodPressure.systolic}/${vitalSigns.bloodPressure.diastolic}`,
          'mmHg', Date.now());
      }
    }

    // 检查心率
    if (vitalSigns.heartRate !== undefined) {
      if (vitalSigns.heartRate < threshold.heartRateMin || vitalSigns.heartRate > threshold.heartRateMax) {
        await AlarmRdb.createAlarmFromAbnormalData(
          hospitalId,
          patientName,
          'heartRate',
          vitalSigns.heartRate,
          data.timestamp
        );
        await this.sendAlarmNotification('心率', patientName, vitalSigns.heartRate, '次/分', Date.now());
      }
    }

    // 检查血氧
    if (vitalSigns.bloodOxygen !== undefined) {
      if (vitalSigns.bloodOxygen < threshold.bloodOxygenMin || vitalSigns.bloodOxygen > threshold.bloodOxygenMax) {
        await AlarmRdb.createAlarmFromAbnormalData(
          hospitalId,
          patientName,
          'bloodOxygen',
          vitalSigns.bloodOxygen,
          data.timestamp
        );
        await this.sendAlarmNotification('血氧', patientName, vitalSigns.bloodOxygen, '%', Date.now());
      }
    }
  }

  private async sendAlarmNotification(type: string, patientName: string, value: number | string, unit: string, alarmId: number): Promise<void> {
    try {
      // 创建通知请求
      const request: NotificationRequestData = {
        id: alarmId,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `${type}异常告警`,
            text: `患者${patientName}的${type}异常：${value}${unit}`,
            additionalText: new Date().toLocaleTimeString()
          }
        }
      };

      // 发送通知
      let publishCallback = (err: BusinessError): void => {
        if (err) {
          console.error(`发送告警通知失败: ${err.code}, ${err.message}`);
        } else {
          console.info('告警通知发送成功');
        }
      }

      notification.publish(request, publishCallback);
    } catch (error) {
      console.error('发送告警通知失败:', error);
    }
  }

  private async saveVitalSigns(data: DeviceData, hospitalId: string): Promise<void> {
    const vitalSigns = data.vitalSigns;
    const vitalSignsRdb = VitalSignsRdb.getInstance();

    // 保存体温数据
    if (vitalSigns.temperature !== undefined) {
      await vitalSignsRdb.insertTemperature({
        hospitalId: hospitalId,
        value: vitalSigns.temperature,
        measureTime: data.timestamp,
        isAbnormal: false
      });
    }

    // 保存血压数据
    if (vitalSigns.bloodPressure) {
      await vitalSignsRdb.insertBloodPressure({
        hospitalId: hospitalId,
        systolic: vitalSigns.bloodPressure.systolic,
        diastolic: vitalSigns.bloodPressure.diastolic,
        measureTime: data.timestamp,
        isAbnormal: false
      });
    }

    // 保存心率数据
    if (vitalSigns.heartRate !== undefined) {
      await vitalSignsRdb.insertHeartRate({
        hospitalId: hospitalId,
        value: vitalSigns.heartRate,
        measureTime: data.timestamp,
        isAbnormal: false
      });
    }

    // 保存血氧数据
    if (vitalSigns.bloodOxygen !== undefined) {
      await vitalSignsRdb.insertBloodOxygen({
        hospitalId: hospitalId,
        value: vitalSigns.bloodOxygen,
        measureTime: data.timestamp,
        isAbnormal: false
      });
    }
  }

  private async handleDeviceData(data: DeviceData): Promise<void> {
    try {
      console.info('开始处理设备数据:', JSON.stringify(data));

      // 1. 通过设备ID查找住院号
      const device = await DeviceRdb.getInstance().getDeviceById(data.deviceId);
      if (!device || !device.hospitalId) {
        console.error('未找到设备或设备未绑定患者:', data.deviceId);
        return;
      }

      const hospitalId = device.hospitalId;
      console.info('找到对应的住院号:', hospitalId);

      // 2. 获取患者信息
      const patient = await PatientRdb.getVisitByHospitalId(hospitalId);
      if (!patient) {
        console.error('未找到患者信息:', hospitalId);
        return;
      }

      // 3. 获取阈值设置
      const threshold = await ThresholdRdb.getThresholdByHospitalId(hospitalId);
      if (!threshold) {
        console.error('未找到阈值设置:', hospitalId);
        return;
      }

      // 4. 检查并创建告警
      await this.checkAndCreateAlarms(data, hospitalId, patient.name, threshold);

      // 5. 保存生命体征数据
      await this.saveVitalSigns(data, hospitalId);

      console.info('设备数据处理完成');
    } catch (err) {
      console.error('处理设备数据失败:', err);
    }
  }
}

export default class EntryAbility extends UIAbility {
  private messageQueue: MessageQueue = new MessageQueue();

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化全局事件总线
    globalThis.eventHub = new CustomEventHub();

    // 初始化数据库
    await this.initializeDatabases();

    // 初始化TCP服务器首选项
    await GlobalTCPServer.initPreferences(this.context);

    // 启动TCP服务器
    await GlobalTCPServer.getInstance().startListening();

    // 添加消息处理监听器
    (globalThis.eventHub as CustomEventHub).addEventListener('tcp-message', async (event: TCPEvent) => {
      await this.messageQueue.enqueue(event.detail.message);
    });
  }

  onDestroy() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    // 停止TCP服务器
    GlobalTCPServer.getInstance().stopListening();
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/LoginPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private async initializeDatabases() {
    try {
      console.info('开始初始化数据库...');

      await DeviceRdb.getInstance().initDb(this.context);
      console.info('设备数据库初始化完成');

      await ThresholdRdb.initDb(this.context);
      console.info('阈值数据库初始化完成');

      await AlarmRdb.initDb(this.context);
      console.info('告警数据库初始化完成');

      await VitalSignsRdb.getInstance().initDb(this.context);
      console.info('生命体征数据库初始化完成');

      await PatientRdb.initRdbStore(this.context);
      console.info('患者数据库初始化完成');

      await TcpRdb.initDb(this.context);
      console.info('TCP消息数据库初始化完成');

      console.info('所有数据库初始化完成');
    } catch (error) {
      console.error('数据库初始化失败:', error);
    }
  }
}