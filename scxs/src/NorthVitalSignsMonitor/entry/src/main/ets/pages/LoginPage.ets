import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import vibrator from '@ohos.vibrator';
import { BusinessError } from '@ohos.base';
import { PasswordUtil } from '../common/utils/PasswordUtil';
import common from '@ohos.app.ability.common';

/**
 * 登录页面组件
 * 功能：
 * 1. 提供手势密码解锁界面
 * 2. 支持密码验证和错误提示
 * 3. 提供振动反馈
 * 4. 自动初始化默认密码
 * 
 * 状态管理：
 * - message: 提示信息文本
 * - passwords: 第一次输入的密码数组
 * - patternLockController: 手势密码控制器
 * - defaultPattern: 默认密码（Z形图案）
 */
@Entry
@Component
struct LoginPage {
  @State message: string = '请绘制解锁图案'; // 当前显示的提示信息
  @State passwords: number[] = []; // 第一次输入的密码数组
  private patternLockController: PatternLockController = new PatternLockController(); // 手势密码控制器
  private defaultPattern: number[] = [0,1,2,4,6,7,8]; // Z形默认密码（从0开始编号）

  /**
   * 组件初始化
   * 执行操作：
   * 1. 初始化密码存储工具
   * 2. 检查是否存在存储的密码，如果没有则设置默认密码
   * 3. 重置手势密码状态
   */
  async aboutToAppear() {
    // 初始化密码存储
    const context = getContext(this) as common.Context;
    const passwordUtil = PasswordUtil.getInstance();
    await passwordUtil.init(context);

    // 如果没有存储的密码，设置默认密码
    const hasPassword = await passwordUtil.hasPassword();
    if (!hasPassword) {
      await passwordUtil.setPassword(this.defaultPattern);
    }

    // 页面创建时清空状态
    this.resetPatternLock();
  }

  /**
   * 构建页面UI
   * 包含以下部分：
   * 1. 顶部标题
   * 2. 提示文本
   * 3. 手势密码区域
   *    - 支持密码输入
   *    - 提供视觉反馈
   *    - 处理密码验证
   */
  build() {
    Column() {
      // 顶部标题
      Text('手势密码解锁')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 20 })
        .fontColor('#333333')

      // 提示文本
      Text(this.message)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ bottom: 40 })
        .textAlign(TextAlign.Center)

      // 手势密码区域
      PatternLock(this.patternLockController)
        .sideLength(300) // 设置手势密码区域边长
        .circleRadius(12) // 设置圆点半径
        .pathStrokeWidth(8) // 设置连线宽度
        .activeColor('#4CAF50') // 设置激活状态颜色
        .selectedColor('#4CAF50') // 设置选中状态颜色
        .pathColor('#4CAF50') // 设置连线颜色
        .backgroundColor('#F5F5F5') // 设置背景颜色
        .autoReset(true) // 启用自动重置
        .activateCircleStyle({
          color: '#81C784', // 设置激活圆点颜色
          enableWaveEffect: true // 启用波纹效果
        })
        .onDotConnect((index: number) => {
          // 连接圆点时触发振动
          console.info("onDotConnect index: " + index);
          this.startVibrator();
        })
        .onPatternComplete(async (input: Array<number>) => {
          // 输入的密码长度小于4时，提示重新输入
          if (!input || input.length < 4) {
            this.message = '至少连接4个点，请重新输入';
            this.startVibrator(2); // 错误时振动两次
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG);
            setTimeout(() => {
              this.patternLockController.reset();
            }, 1000);
            return;
          }

          // 获取存储的密码进行验证
          const passwordUtil = PasswordUtil.getInstance();
          const storedPassword = await passwordUtil.getPassword();
          if (!storedPassword) {
            promptAction.showToast({ message: '系统错误：未找到密码配置' });
            return;
          }

          // 验证密码
          if (input.toString() === storedPassword.toString()) {
            this.message = '密码正确';
            this.startVibrator(); // 正确时振动一次
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT);
            setTimeout(() => {
              router.pushUrl({ url: 'pages/Index' }); // 密码正确后跳转到首页
            }, 500);
          } else {
            this.message = '密码错误，请重新输入';
            this.startVibrator(2); // 错误时振动两次
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG);
            setTimeout(() => {
              this.patternLockController.reset();
            }, 1000);
          }
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: 20 })
  }

  /**
   * 页面显示时执行
   * 重置手势密码状态
   */
  onPageShow() {
    this.resetPatternLock();
  }

  /**
   * 重置手势密码状态
   * 执行操作：
   * 1. 清空密码数组
   * 2. 重置提示信息
   * 3. 重置手势密码控制器
   */
  private resetPatternLock() {
    this.passwords = [];
    this.message = '请绘制解锁图案';
    this.patternLockController.reset();
  }

  /**
   * 启动振动反馈
   * 功能：
   * 1. 提供触觉反馈
   * 2. 支持自定义振动次数
   * 3. 错误处理
   * 
   * @param vibratorCount 振动次数，默认为1次
   */
  startVibrator(vibratorCount?: number) {
    try {
      vibrator.startVibration({
        type: 'preset', // 使用预设振动效果
        effectId: 'haptic.clock.timer', // 使用时钟计时器振动效果
        count: vibratorCount && vibratorCount > 1 ? vibratorCount : 1 // 设置振动次数
      }, {
        usage: 'unknown' // 振动用途
      }, (error: BusinessError) => {
        if (error) {
          console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        } else {
          console.info(`Success to start vibration.`);
        }
      })
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${error.code}, message: ${error.message}`);
    }
  }
}