import { socket } from '@kit.NetworkKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';

interface BloodPressure {
  systolic: number;
  diastolic: number;
}

interface VitalSigns {
  temperature: number;
  bloodPressure: BloodPressure;
  heartRate: number;
  bloodOxygen: number;
}

interface DeviceData {
  deviceId: string;
  timestamp: string;
  vitalSigns: VitalSigns;
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

interface MessageData {
  timestamp: string;
  content: string;
  rawData?: string;
  isError?: boolean;
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

/**
 * TCP服务器实例
 */
let tcpServer: socket.TCPSocketServer;

class SocketInfo {
  message: ArrayBuffer = new ArrayBuffer(1);
  remoteInfo: socket.SocketRemoteInfo = {} as socket.SocketRemoteInfo;
}

@Entry
@Component
struct Index {
  @State showDatas: MessageData[] = [] //用于接收客服端发送的消息
  @State serverLocalIp: string = '127.0.0.1'
  @State serverPort: number = 8000
  @State serverData: string = ''
  @State connectState: boolean = false
  @State connectionStatus: string = '未连接'
  private tcpSocketConnection ?: socket.TCPSocketConnection
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    // 创建新的TCP服务器实例
    try {
      tcpServer = socket.constructTCPSocketServerInstance();
      console.info('TCP页面创建，初始化TCP服务器实例');
    } catch (error) {
      console.error('创建TCP服务器实例失败:', error);
      promptAction.showToast({ message: '创建服务器实例失败' });
    }
  }

  aboutToDisappear() {
    console.info('TCP页面即将销毁，清理资源');
    this.stopListening();
  }

  async stopListening() {
    try {
      // 清理客户端连接
      if (this.tcpSocketConnection) {
        // 移除客户端连接的所有监听器
        this.tcpSocketConnection.off('message');
        this.tcpSocketConnection.off('close');
        this.tcpSocketConnection.close();
        this.tcpSocketConnection = undefined;
        console.info('客户端连接清理完成');
      }

      // 移除服务器的所有监听器
      if (tcpServer) {
        tcpServer.off('connect');
        tcpServer.off('error');
        console.info('TCP服务器监听器移除成功');
      }

      // 重置状态
      this.connectState = false;
      this.connectionStatus = '未连接';

      // 重新创建服务器实例
      tcpServer = socket.constructTCPSocketServerInstance();
      promptAction.showToast({ message: '已停止监听' });
    } catch (error) {
      console.error('停止监听失败:', error);
      promptAction.showToast({ message: '停止监听失败: ' + error.message });
    }
  }

  // 验证生命体征数据
  validateVitalSigns(data: DeviceData): ValidationResult {
    try {
      // 验证必填字段
      if (!data.deviceId) {
        return { code: ErrorCode.INVALID_FORMAT, message: '缺少设备ID' };
      }

      if (!data.timestamp) {
        return { code: ErrorCode.INVALID_TIMESTAMP, message: '缺少时间戳' };
      }

      // 验证基本结构
      if (!data.vitalSigns) {
        return { code: ErrorCode.INVALID_FORMAT, message: '缺少生命体征数据' };
      }

      const vitalSigns = data.vitalSigns;

      // 验证体温（如果有值）
      if (vitalSigns.temperature !== undefined && vitalSigns.temperature !== null && vitalSigns.temperature < 0) {
        return {
          code: ErrorCode.INVALID_TEMPERATURE,
          message: `体温不能为负值: ${vitalSigns.temperature}℃`
        };
      }

      // 验证血压（如果有值）
      if (vitalSigns.bloodPressure) {
        if (vitalSigns.bloodPressure.systolic !== undefined && vitalSigns.bloodPressure.systolic !== null && vitalSigns.bloodPressure.systolic < 0) {
          return {
            code: ErrorCode.INVALID_BLOOD_PRESSURE,
            message: `收缩压不能为负值: ${vitalSigns.bloodPressure.systolic} mmHg`
          };
        }
        if (vitalSigns.bloodPressure.diastolic !== undefined && vitalSigns.bloodPressure.diastolic !== null && vitalSigns.bloodPressure.diastolic < 0) {
          return {
            code: ErrorCode.INVALID_BLOOD_PRESSURE,
            message: `舒张压不能为负值: ${vitalSigns.bloodPressure.diastolic} mmHg`
          };
        }
      }

      // 验证心率（如果有值）
      if (vitalSigns.heartRate !== undefined && vitalSigns.heartRate !== null && vitalSigns.heartRate < 0) {
        return {
          code: ErrorCode.INVALID_HEART_RATE,
          message: `心率不能为负值: ${vitalSigns.heartRate} 次/分`
        };
      }

      // 验证血氧（如果有值）
      if (vitalSigns.bloodOxygen !== undefined && vitalSigns.bloodOxygen !== null && vitalSigns.bloodOxygen < 0) {
        return {
          code: ErrorCode.INVALID_BLOOD_OXYGEN,
          message: `血氧不能为负值: ${vitalSigns.bloodOxygen}%`
        };
      }

      return { code: ErrorCode.SUCCESS, message: '数据格式正确' };
    } catch (error) {
      return { code: ErrorCode.INVALID_FORMAT, message: '数据格式错误: ' + error.message };
    }
  }

  showRawData(rawData: string) {
    AlertDialog.show({
      title: '原始数据',
      message: rawData,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: '关闭',
        action: () => {
          console.info('Close dialog');
        }
      }
    });
  }

  // 将字节数组转换为字符串
  byteArrayToString(buffer: ArrayBuffer): string {
    const dataView = new DataView(buffer);
    const decoder = new Uint8Array(buffer);
    let result = '';
    for (let i = 0; i < decoder.length; i++) {
      result += String.fromCharCode(decoder[i]);
    }
    try {
      // 尝试解码 UTF-8
      return decodeURIComponent(escape(result));
    } catch (error) {
      console.error('UTF-8解码失败，返回原始字符串:', error);
      return result;
    }
  }

  async listenServer(serverIp: string, serverPort: number) {
    // 先停止之前的监听
    await this.stopListening();

    let ipAddress: socket.NetAddress = {
      address: serverIp,
      port: serverPort
    };

    try {
      await tcpServer.listen(ipAddress);
      console.info('===listen success===');
      this.connectionStatus = '等待连接...';

      // 监听连接事件
      tcpServer.on('connect', (tcpConnection: socket.TCPSocketConnection) => {
        console.info("===connect success====");
        this.connectState = true;
        this.connectionStatus = '已连接';
        this.tcpSocketConnection = tcpConnection;

        // 监听消息
        tcpConnection.on('message', (data: SocketInfo) => {
          console.info("====receive message====");
          const messageData = this.byteArrayToString(data.message);
          console.info('收到原始消息:', messageData);

          try {
            const deviceData: DeviceData = JSON.parse(messageData);
            console.info('解析JSON成功:', JSON.stringify(deviceData));

            // 验证数据
            const validationResult = this.validateVitalSigns(deviceData);

            // 构建显示消息
            const formattedMessage = `
              设备ID: ${deviceData.deviceId}
              时间: ${deviceData.timestamp}
              体温: ${deviceData.vitalSigns.temperature ?? 0}℃
              血压: ${deviceData.vitalSigns.bloodPressure?.systolic ?? 0}/${deviceData.vitalSigns.bloodPressure?.diastolic ?? 0} mmHg
              心率: ${deviceData.vitalSigns.heartRate ?? 0} 次/分
              血氧: ${deviceData.vitalSigns.bloodOxygen ?? 0}%
              验证结果: [${validationResult.code}] ${validationResult.message}`;

            this.showDatas.push({
              timestamp: systemDateTime.getTime().toString(),
              content: formattedMessage,
              rawData: messageData,
              isError: validationResult.code !== ErrorCode.SUCCESS
            });

            // 如果数据异常，发送错误信息回客户端
            if (validationResult.code !== ErrorCode.SUCCESS) {
              const errorResponse: ErrorResponse = {
                code: validationResult.code,
                message: validationResult.message,
                timestamp: new Date().toISOString()
              };
              let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
              tcpSendOptions.data = JSON.stringify(errorResponse);
              this.tcpSocketConnection?.send(tcpSendOptions).then(() => {
                console.info('错误响应发送成功');
              }).catch((err:Error) => {
                console.error('错误响应发送失败:', err);
              });
            }
          } catch (error) {
            console.error('解析数据失败:', error);
            const correctFormat: DeviceData = {
              deviceId: "TEST001",
              timestamp: "2024-01-18 15:30:00",
              vitalSigns: {
                temperature: 0,
                bloodPressure: {
                  systolic: 0,
                  diastolic: 0
                },
                heartRate: 0,
                bloodOxygen: 0
              }
            };

            const errorMessage = `数据格式错误。正确的格式应为：\n${JSON.stringify(correctFormat, null, 2)}`;

            this.showDatas.push({
              timestamp: systemDateTime.getTime().toString(),
              content: errorMessage,
              rawData: messageData,
              isError: true
            });

            // 发送错误响应给客户端
            if (this.tcpSocketConnection) {
              const errorResponse: ErrorResponse = {
                code: ErrorCode.INVALID_FORMAT,
                message: errorMessage,
                timestamp: new Date().toISOString()
              };
              let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
              tcpSendOptions.data = JSON.stringify(errorResponse);
              this.tcpSocketConnection.send(tcpSendOptions).then(() => {
                console.info('格式错误响应发送成功');
              }).catch((err:Error) => {
                console.error('格式错误响应发送失败:', err);
              });
            }
          }
        });

        // 监听关闭事件
        tcpConnection.on('close', () => {
          console.info("===断开连接===");
          this.connectState = false;
          this.connectionStatus = '未连接';
          this.tcpSocketConnection = undefined;
        });
      });

      // 监听错误事件
      tcpServer.on('error', (err: BusinessError) => {
        console.error('服务器错误:', err);
        this.connectionStatus = '服务器错误';
        promptAction.showToast({ message: '服务器错误: ' + err.message });
      });

    } catch (err) {
      console.error('监听失败:', err);
      this.connectionStatus = '监听失败';
      promptAction.showToast({ message: '监听失败: ' + err.message });
    }
  }

  async sendData(message: string) {
    if (this.connectState && message.trim()) {
      let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
      tcpSendOptions.data = message;
      this.tcpSocketConnection?.send(tcpSendOptions).then(() => {
        console.info('===send success===');
        this.showDatas.push({
          timestamp: systemDateTime.getTime().toString(),
          content: '发送: ' + message,
          rawData: message
        });
        this.serverData = ''; // 清空输入框
      }).catch((err:Error) => {
        console.error('发送失败:', err);
        promptAction.showToast({ message: '发送失败' });
      });
    }
  }

  build() {
    Column({ space: 10 }) {
      // 顶部标题栏
      Row() {
        Text('TCP服务端')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Row() {
          Text('•')
            .fontSize(24)
            .fontColor(this.connectState ? '#00FF00' : '#FF0000')
            .margin({ left: 10, right: 5 })

          Text(this.connectionStatus)
            .fontSize(16)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .height(50)
      .backgroundColor('#007DFF')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 连接设置区域
      Column({ space: 8 }) {
        Row({ space: 5 }) {
          Text('服务端IP:')
            .width(110)
            .fontSize(16)
            .textAlign(TextAlign.End)

          TextInput({ placeholder: this.serverLocalIp })
            .fontSize(16)
            .width('60%')
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .onChange((value) => {
              this.serverLocalIp = value;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 5 }) {
          Text('服务端端口:')
            .width(110)
            .fontSize(16)
            .textAlign(TextAlign.End)

          TextInput({ placeholder: this.serverPort.toString() })
            .fontSize(16)
            .width('60%')
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value) => {
              this.serverPort = parseInt(value);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .padding({ top: 10, bottom: 10 })

      // 操作按钮区域
      Row() {
        Row({ space: 16 }) {
          Button(this.connectState ? '停止监听' : '启动监听')
            .fontSize(16)
            .width(100)
            .height(40)
            .backgroundColor(this.connectState ? '#FF4D4D' : '#007DFF')
            .onClick(() => {
              if (!this.connectState) {
                this.listenServer(this.serverLocalIp, this.serverPort);
              } else {
                this.stopListening();
              }
            })

          Button('清空消息')
            .fontSize(16)
            .width(100)
            .height(40)
            .backgroundColor('#666666')
            .onClick(() => {
              this.showDatas = [];
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 10 })
      .justifyContent(FlexAlign.Center)

      // 消息输入和发送区域
      Row({ space: 10 }) {
        TextInput({ placeholder: '请输入消息', text: this.serverData })
          .fontSize(16)
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .enabled(this.connectState) // 禁用输入框当未连接时
          .onChange((value) => {
            this.serverData = value;
          })

        Button('发送')
          .fontSize(16)
          .width(80)
          .height(40)
          .backgroundColor(this.connectState ? '#007DFF' : '#999999')
          .enabled(this.connectState)
          .onClick(() => {
            if (this.connectState && this.tcpSocketConnection) {
              this.sendData(this.serverData);
            } else {
              promptAction.showToast({ message: '未连接服务器' });
            }
          })
      }
      .width('90%')
      .margin({ bottom: 10 })

      // 消息显示区域
      List({ space: 8, scroller: this.scroller }) {
        ForEach(this.showDatas, (item: MessageData) => {
          ListItem() {
            Column() {
              Text(item.content)
                .fontSize(16)
                .width('100%')
                .backgroundColor(item.isError ? '#FFF0F0' : (item.content.includes('验证结果: [0]') ? '#F0FFE6' : '#f5f5f5'))
                .borderRadius(8)
                .padding(10)
                .margin({ bottom: 4 })

              Row() {
                Text(item.timestamp)
                  .fontSize(12)
                  .fontColor('#666666')

                Button('查看原始数据')
                  .fontSize(12)
                  .height(24)
                  .backgroundColor('#007DFF')
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.showRawData(item.rawData || '');
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
          }
        })
      }
      .width('95%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}