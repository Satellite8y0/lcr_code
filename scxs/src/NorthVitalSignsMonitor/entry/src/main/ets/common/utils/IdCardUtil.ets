// 导出 IdCardUtil 类作为兼容性类
export class IdCardUtil {
  /**
   * 从身份证号获取年龄
   * @param idCard 身份证号
   * @returns 年龄
   */
  static getAge(idCard: string): number {
    return ValidationUtil.getAge(idCard);
  }

  /**
   * 从身份证号获取性别
   * @param idCard 身份证号
   * @returns 性别（'男' 或 '女'）
   */
  static getGender(idCard: string): string {
    return ValidationUtil.getGender(idCard);
  }

  /**
   * 从身份证号获取出生日期
   * @param idCard 身份证号
   * @returns 格式化的出生日期字符串
   */
  static getBirthDate(idCard: string): string {
    return ValidationUtil.getBirthDate(idCard);
  }

  /**
   * 验证身份证号是否合法
   * @param idCard 身份证号
   * @returns 是否合法
   */
  static isValid(idCard: string): boolean {
    return ValidationUtil.isValidIdCard(idCard);
  }
}

// 验证工具类，包含所有实际实现
export class ValidationUtil {
  /**
   * 验证身份证号是否合法
   * @param idCard 身份证号
   * @returns 是否合法
   */
  static isValidIdCard(idCard: string): boolean {
    if (!idCard || idCard.length !== 18) {
      return false;
    }
    // 简单的格式验证
    const pattern = /^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/;
    return pattern.test(idCard);
  }

  /**
   * 验证手机号是否合法
   * @param phone 手机号
   * @returns 是否合法
   */
  static isValidPhone(phone: string): boolean {
    if (!phone || phone.length !== 11) {
      return false;
    }
    // 中国大陆手机号验证规则：
    // 1. 以1开头
    // 2. 第二位可以是3-9
    // 3. 后面9位是0-9的数字
    const pattern = /^1[3-9]\d{9}$/;
    return pattern.test(phone);
  }

  /**
   * 从身份证号获取年龄
   * @param idCard 身份证号
   * @returns 年龄
   */
  static getAge(idCard: string): number {
    if (!idCard || idCard.length !== 18) {
      return 0;
    }
    const birthYear = parseInt(idCard.substring(6, 10));
    const birthMonth = parseInt(idCard.substring(10, 12));
    const birthDay = parseInt(idCard.substring(12, 14));

    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;
    const currentDay = now.getDate();

    let age = currentYear - birthYear;
    if (currentMonth < birthMonth || (currentMonth === birthMonth && currentDay < birthDay)) {
      age--;
    }
    return age;
  }

  /**
   * 从身份证号获取性别
   * @param idCard 身份证号
   * @returns 性别（'男' 或 '女'）
   */
  static getGender(idCard: string): string {
    if (!idCard || idCard.length !== 18) {
      return '未知';
    }
    return parseInt(idCard.charAt(16)) % 2 === 0 ? '女' : '男';
  }

  /**
   * 从身份证号获取出生日期
   * @param idCard 身份证号
   * @returns 格式化的出生日期字符串
   */
  static getBirthDate(idCard: string): string {
    if (!idCard || idCard.length !== 18) {
      return '未知';
    }
    const year = idCard.substring(6, 10);
    const month = idCard.substring(10, 12);
    const day = idCard.substring(12, 14);
    return `${year}年${month}月${day}日`;
  }
} 