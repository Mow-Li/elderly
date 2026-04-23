/**
 * 数据存储工具类
 */
import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import { Contact } from '../models/Contact';
import { AppShortcut } from '../models/AppShortcut';
import { AppSettings } from '../models/Settings';

const STORE_NAME = 'elderly_desktop_store';

const KEYS = {
  CONTACTS: 'contacts',
  APP_SHORTCUTS: 'app_shortcuts',
  SETTINGS: 'app_settings'
} as const;

export class StorageUtil {
  private static prefs: preferences.Preferences | null = null;

  /**
   * 初始化
   */
  static async init(context: common.UIAbilityContext): Promise<void> {
    if (!this.prefs) {
      this.prefs = await preferences.getPreferences(context, STORE_NAME);
    }
  }

  /**
   * 保存联系人列表
   */
  static async saveContacts(contacts: Contact[]): Promise<void> {
    if (!this.prefs) {
      return;
    }
    const json = JSON.stringify(contacts.map(c => c.toJson()));
    await this.prefs.put(KEYS.CONTACTS, json);
    await this.prefs.flush();
  }

  /**
   * 获取联系人列表
   */
  static async getContacts(): Promise<Contact[]> {
    if (!this.prefs) {
      return [];
    }
    const json = await this.prefs.get(KEYS.CONTACTS, '[]') as string;
    const arr = JSON.parse(json) as Record<string, Object>[];
    return arr.map(item => Contact.fromJson(item));
  }

  /**
   * 保存应用快捷方式
   */
  static async saveAppShortcuts(shortcuts: AppShortcut[]): Promise<void> {
    if (!this.prefs) {
      return;
    }
    const json = JSON.stringify(shortcuts.map(s => s.toJson()));
    await this.prefs.put(KEYS.APP_SHORTCUTS, json);
    await this.prefs.flush();
  }

  /**
   * 获取应用快捷方式
   */
  static async getAppShortcuts(): Promise<AppShortcut[]> {
    if (!this.prefs) {
      return [];
    }
    const json = await this.prefs.get(KEYS.APP_SHORTCUTS, '[]') as string;
    const arr = JSON.parse(json) as Record<string, Object>[];
    return arr.map(item => AppShortcut.fromJson(item));
  }

  /**
   * 保存设置
   */
  static async saveSettings(settings: AppSettings): Promise<void> {
    if (!this.prefs) {
      return;
    }
    const json = JSON.stringify(settings.toJson());
    await this.prefs.put(KEYS.SETTINGS, json);
    await this.prefs.flush();
  }

  /**
   * 获取设置
   */
  static async getSettings(): Promise<AppSettings> {
    if (!this.prefs) {
      return new AppSettings();
    }
    const json = await this.prefs.get(KEYS.SETTINGS, '{}') as string;
    const obj = JSON.parse(json) as Record<string, Object>;
    return AppSettings.fromJson(obj);
  }
}
