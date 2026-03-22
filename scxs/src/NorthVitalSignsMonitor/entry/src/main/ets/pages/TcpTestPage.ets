import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import { GlobalTCPServer } from '../entryability/EntryAbility';
import { router } from '@kit.ArkUI';
import TcpRdb, { TCPMessageData } from '../common/database/TcpRdb';
import preferences from '@ohos.data.preferences';

// 基础接口定义
interface SocketRemoteInfo {
  address: string;
  family: string;
  port: number;
  size?: number;
}

interface TCPSendOptions {
  data: string;
}

// 消息队列接口定义
interface MessageQueue {
  messages: ArrayBuffer[];
  isProcessing: boolean;
}

const QUEUE_PROCESS_INTERVAL = 100; // 队列处理间隔（毫秒）
const MAX_QUEUE_SIZE = 1000; // 最大队列长度

@Observed
class MessageItem {
  id?: number;
  clientId: string;
  messageType: string;
  content: string;
  timestamp: string;

  constructor(data: TCPMessageData) {
    this.id = data.id;
    this.clientId = data.clientId;
    this.messageType = data.messageType;
    this.content = data.content;
    this.timestamp = data.timestamp;
  }
}

@Entry
@Component
struct Index {
  @State showDatas: TCPMessageData[] = [] // 直接使用数据库消息类型
  @State serverLocalIp: string = '127.0.0.1'
  @State serverPort: number = 8000
  @State serverData: string = ''
  @State connectState: boolean = false
  @State connectionStatus: string = '未连接'
  @State queueStatus: string = '队列: 0/1000'
  private scroller: Scroller = new Scroller()
  private tcpSocketConnection?: socket.TCPSocketConnection
  private tcpServer: socket.TCPSocketServer = socket.constructTCPSocketServerInstance()
  private refreshTimer: number = -1
  private readonly REFRESH_INTERVAL: number = 3000 // 3秒刷新一次

  // 消息队列
  private messageQueue: MessageQueue = {
    messages: [],
    isProcessing: false
  }
  private queueTimer: number = -1

  async aboutToAppear(): Promise<void> {
    // 检查端口是否在使用
    const isPortInUse: boolean = await GlobalTCPServer.isPortInUse();
    if (isPortInUse) {
      this.connectionStatus = '端口已在使用';
      this.connectState = true;
      // 启动定时刷新
      this.startRefreshTimer();
    }
  }

  aboutToDisappear(): void {
    this.stopQueueProcessor();
    this.stopListening();
    this.stopRefreshTimer();
  }

  // 启动队列处理器
  private startQueueProcessor() {
    if (this.queueTimer === -1) {
      this.queueTimer = setInterval(() => {
        this.processNextMessage();
      }, QUEUE_PROCESS_INTERVAL);
      console.info('消息队列处理器已启动');
    }
  }

  // 停止队列处理器
  private stopQueueProcessor() {
    if (this.queueTimer !== -1) {
      clearInterval(this.queueTimer);
      this.queueTimer = -1;
      console.info('消息队列处理器已停止');
    }
  }

  // 消息入队
  private enqueueMessage(message: ArrayBuffer) {
    if (this.messageQueue.messages.length >= MAX_QUEUE_SIZE) {
      console.warn('队列已满，丢弃最早的消息');
      this.messageQueue.messages.shift();
    }
    this.messageQueue.messages.push(message);
    this.queueStatus = `队列: ${this.messageQueue.messages.length}/${MAX_QUEUE_SIZE}`;
    console.info(`消息已入队，当前队列长度: ${this.messageQueue.messages.length}`);
  }

  // 处理消息
  private async processNextMessage() {
    if (this.messageQueue.isProcessing || this.messageQueue.messages.length === 0) {
      return;
    }

    try {
      this.messageQueue.isProcessing = true;
      const message = this.messageQueue.messages.shift();
      this.queueStatus = `队列: ${this.messageQueue.messages.length}/${MAX_QUEUE_SIZE}`;

      if (message) {
        // 将ArrayBuffer转换为字符串
        const bytes = new Uint8Array(message);
        let str = '';
        for (let i = 0; i < bytes.length; i++) {
          str += String.fromCharCode(bytes[i]);
        }

        console.info('TCP测试页面收到消息:', str);
      }
    } catch (error) {
      console.error('处理消息时出错:', error);
    } finally {
      this.messageQueue.isProcessing = false;
    }
  }

  async listenServer(serverIp: string, serverPort: number) {
    try {
      await this.tcpServer.listen({
        address: serverIp,
        port: serverPort
      });

      console.info('TCP服务器启动成功');
      this.connectionStatus = '等待连接...';

      this.tcpServer.on('connect', (connection: socket.TCPSocketConnection) => {
        console.info('TCP客户端连接成功');
        this.connectState = true;
        this.connectionStatus = '已连接';
        this.tcpSocketConnection = connection;

        connection.on('close', () => {
          console.info('TCP客户端连接断开');
          this.connectState = false;
          this.connectionStatus = '未连接';
          this.tcpSocketConnection = undefined;
        });
      });

    } catch (err) {
      console.error('监听失败:', err);
      this.connectionStatus = '监听失败';
      promptAction.showToast({ message: '监听失败: ' + err.message });
    }
  }

  async stopListening() {
    try {
      if (this.tcpSocketConnection) {
        this.tcpSocketConnection.off('message');
        this.tcpSocketConnection.off('close');
        this.tcpSocketConnection.close();
        this.tcpSocketConnection = undefined;
      }

      this.tcpServer.off('connect');
      this.tcpServer = socket.constructTCPSocketServerInstance();

      this.connectState = false;
      this.connectionStatus = '未连接';
      // promptAction.showToast({ message: '已停止监听' });
    } catch (error) {
      console.error('停止监听失败:', error);
      promptAction.showToast({ message: '停止监听失败: ' + error.message });
    }
  }

  // 启动定时刷新
  private startRefreshTimer(): void {
    if (this.refreshTimer === -1) {
      // 立即执行一次
      void this.refreshMessages();
      // 设置定时器
      this.refreshTimer = setInterval(() => {
        void this.refreshMessages();
      }, this.REFRESH_INTERVAL);
      console.info('消息刷新定时器已启动');
    }
  }

  // 停止定时刷新
  private stopRefreshTimer(): void {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
      console.info('消息刷新定时器已停止');
    }
  }

  // 格式化显示内容
  private formatContent(item: TCPMessageData): string {
    if (!item.content) {
      return '';
    }
    try {
      // 尝试解析JSON
      const content: object = JSON.parse(item.content);
      return JSON.stringify(content, null, 2);
    } catch {
      // 如果不是JSON格式，直接返回原始内容
      return item.content;
    }
  }

  // 获取消息背景色
  private getMessageBackground(item: TCPMessageData): string {
    return item.messageType === 'error' ? '#FFF1F0' : '#f5f5f5';
  }

  // 获取消息文本颜色
  private getMessageColor(item: TCPMessageData): string {
    return item.messageType === 'error' ? '#FF4D4F' : '#000000';
  }

  // 刷新消息列表
  private async refreshMessages(): Promise<void> {
    try {
      // 获取连接设备数
      const onlineDevices: number = await GlobalTCPServer.getOnlineDeviceCount();
      console.info('当前连接设备数:', onlineDevices);

      // 更新队列状态
      this.queueStatus = `队列: ${onlineDevices}/1000`;

      // 从数据库获取最新消息
      this.showDatas = await TcpRdb.getLatestMessages(100);
      console.info('获取到消息数量:', this.showDatas.length);

      // 更新连接状态
      if (onlineDevices === 0) {
        this.connectState = false;
        this.connectionStatus = '未连接';
      } else {
        this.connectState = true;
        this.connectionStatus = '已连接';
      }
    } catch (error) {
      console.error('刷新消息失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width(24)
            .height(24)
            .margin({ right: 16 })
            .onClick(() => {
              router.back();
            })
          Text('TCP测试')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#007DFF')
      .alignItems(VerticalAlign.Center)

      // 状态显示
      Row() {
        Column() {
          Text('连接状态')
            .fontSize(14)
            .fontColor('#666666')
          Text(this.connectionStatus)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.connectState ? '#00CC00' : '#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('队列状态')
            .fontSize(14)
            .fontColor('#666666')
          Text(this.queueStatus)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('90%')
      .padding(16)
      .margin({ top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      .borderRadius(8)

      // 连接设置
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

      // 操作按钮
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
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 10 })
      .justifyContent(FlexAlign.Center)

      // 消息显示区域
      List({ space: 8, scroller: this.scroller }) {
        ForEach(this.showDatas, (item: TCPMessageData) => {
          ListItem() {
            Column() {
              Text(this.formatContent(item))
                .fontSize(16)
                .width('100%')
                .backgroundColor(this.getMessageBackground(item))
                .fontColor(this.getMessageColor(item))
                .borderRadius(8)
                .padding(10)
                .margin({ bottom: 4 })
                .fontFamily('monospace')

              Row() {
                Text(`客户端: ${item.clientId}`)
                  .fontSize(12)
                  .fontColor('#666666')
                Text(`类型: ${item.messageType}`)
                  .fontSize(12)
                  .fontColor(item.messageType === 'error' ? '#FF4D4F' : '#666666')
                  .margin({ left: 8 })
                Text(new Date(item.timestamp).toLocaleString())
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 8 })
              }
            }
            .width('100%')
          }
        }, (item: TCPMessageData): string => item.id ? item.id.toString() : item.timestamp)
      }
      .width('95%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(10)
    }
    .width('100%')
    .height('100%')
  }
}