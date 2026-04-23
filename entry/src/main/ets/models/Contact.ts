/**
 * 联系人数据模型
 */
export class Contact {
  id: string;
  name: string;
  photoUri: string;
  phone: string;
  wechatId: string;
  position: number;

  constructor() {
    this.id = '';
    this.name = '';
    this.photoUri = '';
    this.phone = '';
    this.wechatId = '';
    this.position = 0;
  }

  static fromJson(json: Record<string => Object>): Contact {
    const contact = new Contact();
    contact.id = json['id'] as string ?? '';
    contact.name = json['name'] as string ?? '';
    contact.photoUri = json['photoUri'] as string ?? '';
    contact.phone = json['phone'] as string ?? '';
    contact.wechatId = json['wechatId'] as string ?? '';
    contact.position = json['position'] as number ?? 0;
    return contact;
  }

  toJson(): Record<string => Object> {
    return {
      id: this.id,
      name: this.name,
      photoUri: this.photoUri,
      phone: this.phone,
      wechatId: this.wechatId,
      position: this.position
    };
  }
}

/**
 * 联系人操作类型
 */
export enum ContactActionType {
  PHONE = 'phone',
  WECHAT_CALL = 'wechat_call',
  WECHAT_VIDEO = 'wechat_video'
}
