# 生命体征监测系统

## 项目概述
生命体征监测系统是一个基于HarmonyOS的医疗监护应用，用于实时监测和记录患者的生命体征数据，包括体温、血压、心率和血氧等指标。系统支持设备管理、数据采集、阈值设置、告警提醒等功能，为医护人员提供便捷的患者监护工具。

## 开发环境
- DevEco Studio 4.1.0 Release
- HarmonyOS SDK API 11
- Node.js 18.0.0+
- ohpm 1.0.0+

## 安装说明
1. 克隆项目到本地
2. 打开终端，进入项目目录
3. 执行以下命令安装依赖：
```bash
ohpm install
```
4. 使用DevEco Studio打开项目
5. 构建并运行项目

## 数据库设计

### 1. 告警数据库 (alarm.db)
```sql
CREATE TABLE alarm_table (
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
```

### 2. 设备数据库 (DeviceDB.db)
```sql
CREATE TABLE DEVICE_TABLE (
  deviceId TEXT PRIMARY KEY,
  deviceName TEXT NOT NULL,
  batteryLevel INTEGER NOT NULL,
  status TEXT NOT NULL,
  isBound INTEGER NOT NULL,
  lastUpdateTime TEXT NOT NULL,
  hospitalId TEXT
)
```

### 3. 就诊记录数据库 (PatientDB.db)
```sql
CREATE TABLE VISIT_RECORDS (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hospitalId TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  idCard TEXT NOT NULL,
  deviceId TEXT,
  diagnosis TEXT,
  createTime TEXT NOT NULL,
  remark TEXT
)
```

### 4. TCP消息数据库 (tcp.db)
```sql
CREATE TABLE TCP_MESSAGE_TABLE (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  clientId TEXT NOT NULL,
  messageType TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TEXT NOT NULL
)
```

### 5. 阈值数据库 (threshold.db)
```sql
CREATE TABLE THRESHOLD_TABLE (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hospitalId TEXT NOT NULL,
  temperatureMin REAL NOT NULL,
  temperatureMax REAL NOT NULL,
  systolicPressureMin INTEGER NOT NULL,
  systolicPressureMax INTEGER NOT NULL,
  diastolicPressureMin INTEGER NOT NULL,
  diastolicPressureMax INTEGER NOT NULL,
  heartRateMin INTEGER NOT NULL,
  heartRateMax INTEGER NOT NULL,
  bloodOxygenMin INTEGER NOT NULL,
  bloodOxygenMax INTEGER NOT NULL,
  updateTime TEXT NOT NULL,
  isDefault INTEGER DEFAULT 0,
  UNIQUE(hospitalId)
)
```

## 界面设计

### 1. 登录界面 (LoginPage)
- 手势密码解锁
- 默认Z字形密码图案
- 支持振动反馈

### 2. 主界面 (Index)
- 底部导航栏
  - 就诊管理
  - 告警管理
  - 个人中心

### 3. 就诊管理 (PatientPage)
- 患者列表
- 新增就诊记录
- 绑定监护设备
- 查看生命体征数据

### 4. 告警管理 (AlarmPage)
- 实时告警列表
- 告警处理
- 告警延迟
- 历史告警查询

### 5. 设备管理 (DeviceBindPage)
- 设备扫描
- 设备绑定
- 设备状态监控
- 电池电量显示

### 6. 数据详情 (PatientDetailDataPage)
- 生命体征数据展示
- 数据趋势图
- 异常数据标记
- 参考范围显示

## 功能特点

### 1. 实时监测
- TCP通信实时接收设备数据
- 自动数据解析和存储
- 实时阈值判断
- 异常数据告警

### 2. 告警管理
- 多级告警策略
- 声光振动提醒
- 告警处理记录
- 延迟提醒功能

### 3. 数据管理
- 历史数据查询
- 数据导出功能
- 趋势图分析
- 异常数据标记

### 4. 设备管理
- 自动设备发现
- 设备绑定解绑
- 设备状态监控
- 电池状态显示

### 5. 系统设置
- 阈值个性化配置
- 告警方式设置
- 手势密码修改
- 系统日志查看

## 安全特性
- 手势密码保护
- 数据加密存储
- 设备认证机制
- 操作日志记录

## 性能优化
- 数据库索引优化
- 异步数据处理
- 内存缓存管理
- UI渲染优化

## 注意事项
1. 首次使用需要配置默认阈值
2. 设备绑定前确保TCP服务正常运行
3. 定期检查系统日志
4. 及时处理告警信息
5. 确保网络连接稳定

## 资源文件
项目包含以下资源文件：
- 图标资源（SVG格式）
- 背景图片
- 启动图标
- 系统配置文件

## 技术支持
如有问题请联系技术支持团队：
- Email: support@example.com
- Tel: 400-xxx-xxxx

## 版权信息
© 2025 生命体征监测系统团队，保留所有权利。 