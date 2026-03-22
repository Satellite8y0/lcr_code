import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export class PasswordUtil {
  private static instance: PasswordUtil;
  private readonly PREFERENCES_NAME = 'password_store';
  private readonly PASSWORD_KEY = 'pattern_password';
  private preferences: preferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): PasswordUtil {
    if (!PasswordUtil.instance) {
      PasswordUtil.instance = new PasswordUtil();
    }
    return PasswordUtil.instance;
  }

  public async init(context: common.Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.PREFERENCES_NAME);
    } catch (error) {
      console.error(`初始化密码存储失败: ${error}`);
    }
  }

  public async setPassword(password: number[]): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      await this.preferences.put(this.PASSWORD_KEY, password.toString());
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error(`保存密码失败: ${error}`);
      return false;
    }
  }

  public async getPassword(): Promise<number[] | null> {
    if (!this.preferences) {
      return null;
    }

    try {
      const passwordStr = await this.preferences.get(this.PASSWORD_KEY, '') as string;
      if (!passwordStr) {
        return null;
      }
      return passwordStr.split(',').map(num => parseInt(num));
    } catch (error) {
      console.error(`获取密码失败: ${error}`);
      return null;
    }
  }

  public async hasPassword(): Promise<boolean> {
    const password = await this.getPassword();
    return password !== null;
  }
} 