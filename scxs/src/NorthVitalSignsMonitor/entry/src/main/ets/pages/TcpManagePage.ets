import router from '@ohos.router';
import TcpRdb, { TCPMessageData } from '../common/database/TcpRdb';
import promptAction from '@ohos.promptAction';
import { GlobalTCPServer } from '../entryability/EntryAbility';

// 统计数据接口
@Observed
class StatisticsData {
  totalMessages: number = 0;
  errorMessages: number = 0;
  onlineDevices: number = 0;
}

// 消息详情类
@Observed
class MessageDetail {
  error?: string = '';
  rawData?: string = '';
}

// 对话框选项类
class DialogButtonInfo {
  value: string;
  action: () => void;

  constructor(value: string, action: () => void) {
    this.value = value;
    this.action = action;
  }
}

class DialogOffsetInfo {
  dx: number;
  dy: number;

  constructor(dx: number, dy: number) {
    this.dx = dx;
    this.dy = dy;
  }
}

class DialogOptionsInfo {
  title: string;
  message: string;
  alignment: DialogAlignment;
  offset: DialogOffsetInfo;
  primaryButton: DialogButtonInfo;

  constructor(
    title: string,
    message: string,
    alignment: DialogAlignment,
    offset: DialogOffsetInfo,
    primaryButton: DialogButtonInfo
  ) {
    this.title = title;
    this.message = message;
    this.alignment = alignment;
    this.offset = offset;
    this.primaryButton = primaryButton;
  }
}

interface ErrorMessage {
  error?: string;
  message?: string;
}

@CustomDialog
struct MessageListDialog {
  @State messages: TCPMessageData[] = [];
  @State clientId: string = '';
  controller: CustomDialogController;
  onRefresh?: () => void;

  formatTime(timestamp: string): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`;
  }

  async clearMessages() {
    try {
      await TcpRdb.deleteMessagesByClientId(this.clientId);
      promptAction.showToast({ message: '清除成功' });
      if (this.onRefresh) {
        this.onRefresh();
      }
      this.controller.close();
    } catch (error) {
      promptAction.showToast({ message: '清除失败' });
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('消息记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('清除记录')
          .fontSize(14)
          .fontColor('#FF4D4F')
          .backgroundColor('#FFF1F0')
          .onClick(() => this.clearMessages())
        Button('关闭')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor(Color.Transparent)
          .margin({ left: 12 })
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      if (this.messages.length === 0) {
        Text('暂无消息记录')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 40 })
      } else {
        List({ space: 12 }) {
          ForEach(this.messages, (message: TCPMessageData) => {
            ListItem() {
              Column() {
                Row() {
                  Text(message.messageType === 'data' ? '数据消息' : '错误消息')
                    .fontSize(14)
                    .fontColor(message.messageType === 'data' ? '#007DFF' : '#FF4D4F')
                    .backgroundColor(message.messageType === 'data' ? '#F0F7FF' : '#FFF1F0')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)

                  Text(this.formatTime(message.timestamp))
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ left: 8 })
                }
                .width('100%')

                Text(message.content)
                  .fontSize(16)
                  .margin({ top: 8 })
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(2)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.controller.close();
                messageDetailDialog.show(message);
              })
            }
          }, (item: TCPMessageData) => item.id?.toString() || item.timestamp)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 24, right: 24 })
      }
    }
    .width('100%')
    .height('80%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

@CustomDialog
struct MessageDetailDialog {
  @State message: TCPMessageData = {} as TCPMessageData;
  controller: CustomDialogController;

  formatTime(timestamp: string): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`;
  }

  private getErrorMessage(content: string): string {
    try {
      const jsonContent: string = content;
      const parsed: ErrorMessage = JSON.parse(jsonContent) as ErrorMessage;
      return parsed.error || parsed.message || '未知错误';
    } catch {
      return content;
    }
  }

  build() {
    Column() {
      Row() {
        Text('消息详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('关闭')
          .backgroundColor(Color.Transparent)
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16, left: 24, right: 24 })

      Column() {
        // 消息类型
        Row() {
          Text('消息类型：')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.message.messageType === 'data' ? '数据消息' : '错误消息')
            .fontSize(16)
            .fontColor(this.message.messageType === 'data' ? '#007DFF' : '#FF4D4F')
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 时间
        Row() {
          Text('时间：')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.formatTime(this.message.timestamp))
            .fontSize(16)
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 错误信息（如果是错误消息）
        if (this.message.messageType === 'error') {
          Text('错误信息：')
            .fontSize(16)
            .fontColor('#666666')
            .width('100%')

          Text(this.getErrorMessage(this.message.content))
            .fontSize(16)
            .fontColor('#FF4D4F')
            .width('100%')
            .margin({ bottom: 12 })
        }

        // 原始数据
        Text('原始数据：')
          .fontSize(16)
          .fontColor('#666666')
          .width('100%')
        Text(this.message.content)
          .fontSize(16)
          .width('100%')
          .fontFamily('monospace')
          .backgroundColor('#F5F5F5')
          .padding(12)
          .borderRadius(8)
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}

class MessageDialogManager {
  private static instance: MessageDialogManager;
  private messageListDialog: CustomDialogController | null = null;
  private messageDetailDialog: CustomDialogController | null = null;

  private constructor() {}

  static getInstance(): MessageDialogManager {
    if (!MessageDialogManager.instance) {
      MessageDialogManager.instance = new MessageDialogManager();
    }
    return MessageDialogManager.instance;
  }

  showMessageList(messages: TCPMessageData[], clientId: string, onRefresh?: () => void) {
    if (this.messageListDialog) {
      this.messageListDialog.close();
    }
    this.messageListDialog = new CustomDialogController({
      builder: MessageListDialog({
        messages: messages,
        clientId: clientId,
        onRefresh: onRefresh,
        controller: undefined
      }),
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: 0 },
      customStyle: true
    });
    this.messageListDialog.open();
  }

  show(message: TCPMessageData) {
    if (this.messageDetailDialog) {
      this.messageDetailDialog.close();
    }
    this.messageDetailDialog = new CustomDialogController({
      builder: MessageDetailDialog({
        message: message,
        controller: undefined
      }),
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: 0 },
      customStyle: true
    });
    this.messageDetailDialog.open();
  }
}

const messageDetailDialog = MessageDialogManager.getInstance();

@Entry
@Component
struct TcpManagePage {
  @State statistics: StatisticsData = new StatisticsData();
  @State clientIds: string[] = [];
  private refreshTimer: number = 0;

  async aboutToAppear() {
    await this.loadData();
    // 每3秒刷新一次数据
    this.refreshTimer = setInterval(async () => {
      await this.loadData();
    }, 3000);
  }

  aboutToDisappear() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
  }

  async loadData() {
    try {
      // 获取所有消息
      const messages = await TcpRdb.getAllMessages();
      console.info('获取所有TCP消息记录, 共' + messages.length + '条');

      // 获取在线设备数
      const onlineDevices = await GlobalTCPServer.getOnlineDeviceCount();

      // 统计数据
      const errorMessages = messages.filter(msg => msg.messageType === 'error').length;
      this.statistics = {
        totalMessages: messages.length,
        errorMessages: errorMessages,
        onlineDevices: onlineDevices
      };

      // 获取唯一的客户端ID列表
      const uniqueClientIds = new Set(messages.map(msg => msg.clientId));
      this.clientIds = Array.from(uniqueClientIds);
    } catch (error) {
      console.error('加载TCP管理数据失败:', error);
    }
  }

  formatTime(timestamp: string): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`;
  }

  showMessageDetail(message: TCPMessageData) {
    let content = '';
    if (message.messageType === 'error') {
      try {
        const errorData: ErrorMessage = JSON.parse(message.content);
        content = `错误信息：${errorData.error || errorData.message || '未知错误'}\n\n`;
      } catch {
        content = `错误信息：${message.content}\n\n`;
      }
    }
    content += `原始数据：${message.content}`;

    promptAction.showDialog({
      title: '消息详情',
      message: content,
      buttons: [
        {
          text: '关闭',
          color: '#666666'
        }
      ]
    });
  }

  async showMessageList(clientId: string) {
    try {
      const messages = await TcpRdb.getMessagesByClientId(clientId);
      console.info('获取客户端[' + clientId + ']的消息记录, 共' + messages.length + '条');

      if (messages.length === 0) {
        promptAction.showToast({ message: '暂无消息记录' });
        return;
      }

      let content = messages.map(msg => {
        const time = this.formatTime(msg.timestamp);
        const type = msg.messageType === 'data' ? '数据消息' : '错误消息';
        return `[${time}] ${type}\n${msg.content}\n`;
      }).join('\n');

      promptAction.showDialog({
        title: '消息记录',
        message: content,
        buttons: [
          {
            text: '清除记录',
            color: '#FF4D4F'
          },
          {
            text: '关闭',
            color: '#666666'
          }
        ]
      }).then((result) => {
        if (result.index === 0) {
          TcpRdb.deleteMessagesByClientId(clientId).then(() => {
            promptAction.showToast({ message: '清除成功' });
            this.loadData();
          }).catch(() => {
            promptAction.showToast({ message: '清除失败' });
          });
        }
      }).catch((err: Error) => {
        console.error('显示对话框失败:', err);
      });
    } catch (error) {
      console.error('获取消息记录失败:', error);
      promptAction.showToast({ message: '获取消息记录失败' });
    }
  }

  @Builder
  StatisticsCard() {
    Column() {
      Text('消息统计')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        Column() {
          Text('总消息数')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.statistics.totalMessages.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height(40)
          .color('#EEEEEE')

        Column() {
          Text('错误消息')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.statistics.errorMessages.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height(40)
          .color('#EEEEEE')

        Column() {
          Text('在线设备')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.statistics.onlineDevices.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  @Builder
  ClientsList() {
    Column() {
      Text('客户端列表')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.clientIds.length === 0) {
        Text('暂无客户端记录')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 20 })
      } else {
        List() {
          ForEach(this.clientIds, (clientId: string) => {
            ListItem() {
              Row() {
                Column() {
                  Text(clientId)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Image($r('app.media.ic_record'))
                  .width(24)
                  .height(24)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.showMessageList(clientId);
              })
            }
          }, (item: string) => item)
        }
        .divider({ strokeWidth: 1, color: '#EEEEEE' })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
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
          Text('TCP管理')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }

        Image($r('app.media.ic_test'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => {
            router.pushUrl({ url: 'pages/TcpTestPage' });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#007DFF')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)

      // 内容区域
      Scroll() {
        Column({ space: 16 }) {
          this.StatisticsCard()
          this.ClientsList()
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}