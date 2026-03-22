import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';

// 定义远程信息接口
export interface RemoteInfo {
  address: string;
  family: string;
  port: number;
  size?: number;
}

// 定义消息数据接口
interface TcpMessage {
  message: ArrayBuffer;
  remoteInfo: RemoteInfo;
}

// 定义TCP事件监听器接口
export interface TCPEventListener {
  onMessage?(message: ArrayBuffer, remoteInfo: RemoteInfo): void;
  onConnect?(): void;
  onDisconnect?(): void;
  onError?(error: BusinessError): void;
}

class TcpManager {
  private static instance: TcpManager | null = null;
  private tcpServer: socket.TCPSocketServer | null = null;
  private tcpConnection: socket.TCPSocketConnection | null = null;
  private listeners: Set<TCPEventListener> = new Set();
  private isConnected: boolean = false;
  private context: common.UIAbilityContext | null = null;

  private constructor() {
    // 私有构造函数，防止外部直接实例化
  }

  public static getInstance(): TcpManager {
    if (!TcpManager.instance) {
      TcpManager.instance = new TcpManager();
    }
    return TcpManager.instance;
  }

  public setContext(context: common.UIAbilityContext) {
    this.context = context;
  }

  public initialize() {
    try {
      if (!this.tcpServer) {
        this.tcpServer = socket.constructTCPSocketServerInstance();
        console.info('TCP管理器初始化成功');
      }
    } catch (error) {
      console.error('TCP管理器初始化失败:', error);
      this.notifyError(error);
    }
  }

  public async startServer(address: string, port: number) {
    if (!this.tcpServer) {
      this.initialize();
    }

    try {
      await this.tcpServer?.listen({ address, port });
      console.info('TCP服务器启动成功');

      this.tcpServer?.on('connect', (connection: socket.TCPSocketConnection) => {
        console.info('TCP客户端连接成功');
        this.tcpConnection = connection;
        this.isConnected = true;
        this.setupConnectionListeners(connection);
        this.notifyConnect();
      });

      this.tcpServer?.on('error', (error: BusinessError) => {
        console.error('TCP服务器错误:', error);
        this.notifyError(error);
      });

    } catch (error) {
      console.error('TCP服务器启动失败:', error);
      this.notifyError(error);
    }
  }

  private setupConnectionListeners(connection: socket.TCPSocketConnection) {
    connection.on('message', (data: TcpMessage) => {
      console.info('收到TCP消息');
      this.notifyMessage(data.message, data.remoteInfo);
    });

    connection.on('close', () => {
      console.info('TCP连接关闭');
      this.isConnected = false;
      this.tcpConnection = null;
      this.notifyDisconnect();
    });
  }

  public async sendMessage(data: string) {
    if (!this.isConnected || !this.tcpConnection) {
      console.error('TCP未连接，无法发送消息');
      return;
    }

    try {
      await this.tcpConnection.send({ data });
      console.info('TCP消息发送成功');
    } catch (error) {
      console.error('TCP消息发送失败:', error);
      this.notifyError(error);
    }
  }

  public addListener(listener: TCPEventListener) {
    this.listeners.add(listener);
  }

  public removeListener(listener: TCPEventListener) {
    this.listeners.delete(listener);
  }

  private notifyMessage(message: ArrayBuffer, remoteInfo: RemoteInfo) {
    this.listeners.forEach(listener => {
      if (listener.onMessage) {
        listener.onMessage(message, remoteInfo);
      }
    });
  }

  private notifyConnect() {
    this.listeners.forEach(listener => {
      if (listener.onConnect) {
        listener.onConnect();
      }
    });
  }

  private notifyDisconnect() {
    this.listeners.forEach(listener => {
      if (listener.onDisconnect) {
        listener.onDisconnect();
      }
    });
  }

  private notifyError(error: BusinessError) {
    this.listeners.forEach(listener => {
      if (listener.onError) {
        listener.onError(error);
      }
    });
  }

  public isServerConnected(): boolean {
    return this.isConnected;
  }

  public async stopServer() {
    try {
      if (this.tcpConnection) {
        this.tcpConnection.off('message');
        this.tcpConnection.off('close');
        this.tcpConnection.close();
        this.tcpConnection = null;
      }

      if (this.tcpServer) {
        this.tcpServer.off('connect');
        this.tcpServer.off('error');
      }

      this.isConnected = false;
      console.info('TCP服务器已停止');
    } catch (error) {
      console.error('TCP服务器停止失败:', error);
      this.notifyError(error);
    }
  }

  public destroy() {
    this.stopServer();
    this.listeners.clear();
    this.tcpServer = null;
    TcpManager.instance = null;
    console.info('TCP管理器已销毁');
  }
}

export default TcpManager; 