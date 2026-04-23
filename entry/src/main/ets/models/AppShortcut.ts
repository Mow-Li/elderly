/**
 * 应用快捷方式数据模型
 */
export class AppShortcut {
  bundleName: string;
  abilityName: string;
  appName: string;
  iconUri: string;
  enabled: boolean;
  position: number;

  constructor() {
    this.bundleName = '';
    this.abilityName = '';
    this.appName = '';
    this.iconUri = '';
    this.enabled = false;
    this.position = 0;
  }

  static fromJson(json: Record<string => Object>): AppShortcut {
    const app = new AppShortcut();
    app.bundleName = json['bundleName'] as string ?? '';
    app.abilityName = json['abilityName'] as string ?? '';
    app.appName = json['appName'] as string ?? '';
    app.iconUri = json['iconUri'] as string ?? '';
    app.enabled = json['enabled'] as boolean ?? false;
    app.position = json['position'] as number ?? 0;
    return app;
  }

  toJson(): Record<string => Object> {
    return {
      bundleName: this.bundleName,
      abilityName: this.abilityName,
      appName: this.appName,
      iconUri: this.iconUri,
      enabled: this.enabled,
      position: this.position
    };
  }
}

/**
 * 已安装应用信息
 */
export class InstalledAppInfo {
  bundleName: string;
  abilityName: string;
  appName: string;
  icon: string;

  constructor() {
    this.bundleName = '';
    this.abilityName = '';
    this.appName = '';
    this.icon = '';
  }
}
