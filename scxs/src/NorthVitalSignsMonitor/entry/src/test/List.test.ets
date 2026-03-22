import { socket } from '@kit.NetworkKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';

/**
 * 2.创建 TCPSocketServer
 * 创建一个 TCPSocketServer 连接，返回一个 TCPSocketServer 对象。
 */
let tcpServer: socket.TCPSocketServer = socket.constructTCPSocketServerInstance();

class SocketInfo {
  message: ArrayBuffer = new ArrayBuffer(1);
  remoteInfo: socket.SocketRemoteInfo = {} as socket.SocketRemoteInfo;
}

@Entry
@Component
struct Index {
  @State showDatas: string[] = [] //用于接收客服端发送的消息
  @State serverLocalIp: string = '127.0.0.1'
  @State serverPort: number = 8000
  @State serverData:string = '待发送消息'
  private connectState: boolean = false
  private tcpSocketConnection ?: socket.TCPSocketConnection

  async listenServer(serverIp: string, serverPort: number) {
    let ipAddress: socket.NetAddress = {
      address: serverIp,
      port: serverPort,
    }
    // 绑定IP:Port、监听并启动服务，接收客户端的连接请求
    tcpServer.listen(ipAddress).then(() => {
      console.info('===listen success===');
      tcpServer.on("connect", (tcpConnection: socket.TCPSocketConnection) => {
        console.info("===connect success====")
        this.connectState = true
        this.tcpSocketConnection = tcpConnection

        tcpConnection.on("message", (data: SocketInfo) => {
          console.info("====receive message====")
          let buffer = data.message;
          let dataView = new DataView(buffer);
          let messageData = "";
          for (let i = 0; i < dataView.byteLength; ++i) {
            messageData += String.fromCharCode(dataView.getUint8(i));
          }
          this.showDatas.push(systemDateTime.getTime().toString() + ': ' + messageData)
        });
        // 订阅TCPSocketConnection相关的事件
        tcpConnection.on("close", () => {
          console.info("===断开连接===");
        });
      })
    }).catch((err: BusinessError) => {
      console.info('listen fail');
    });}

  async sendData(message: string) {
    if (this.connectState) { //连接成功才可发送数据
      // 服务端给连接的客户端发送信息
      let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
      tcpSendOptions.data = message
      this.tcpSocketConnection?.send(tcpSendOptions).then(() => {
        console.info('===send success===');
        this.showDatas.push(systemDateTime.getTime().toString() + ': ' + tcpSendOptions.data)
      })
    }
  }

  build() {
    Column({ space: 5 }) {
      Text('TCP的服务端实现')
        .fontSize(30)

      Row({ space: 5 }) {
        Text('服务端ip:')
          .width(110)
          .fontSize(20)
          .textAlign(TextAlign.End)

        TextInput({ placeholder: this.serverLocalIp })
          .fontSize(20)
          .width('60%')
          .onChange((value) => {
            this.serverLocalIp = value
          })
      }

      Row({ space: 5 }) {
        Text('服务端port:')
          .width(110)
          .fontSize(20)
          .textAlign(TextAlign.End)
        TextInput({ placeholder: this.serverPort.toString() })
          .fontSize(20)
          .width('60%')
          .type(InputType.Number)
          .onChange((value) => {
            this.serverPort = parseInt(value)
          })
      }

      Button('启动监听')
        .fontSize(25)
        .onClick(() => {
          this.listenServer(this.serverLocalIp, this.serverPort)
        })
      TextInput({ placeholder: this.serverData })
        .fontSize(20)
        .width('90%')
        .height(50)
        .onChange((value) => {
          this.serverData = value
        })
      Button('发送消息')
        .fontSize(25)
        .onClick(()=>{
          this.sendData(this.serverData)
        })

      List(){
        ListItem(){
          Text('接收到的消息：')
        }
        ForEach(this.showDatas, (item: string) => {
          ListItem(){
            Text(item)
              .fontSize(20)
          }
        })
      }.width('95%')
      .layoutWeight(1)
    }
  }
}