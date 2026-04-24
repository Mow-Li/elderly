/**
 * 应用启动工具类
 */
import { common, Want } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppShortcut, InstalledAppInfo } from '../models/AppShortcut';

const WECHAT_BUNDLE = 'com.tencent.mm';

export class AppLauncherUtil {
  private static context: common.UIAbilityContext | null = null;

  static init(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 拨打电话
   */
  static async makeCall(phoneNumber: string): Promise<void> {
    if (!this.context) {
      return;
    }
    const want: Want = {
      action: 'ohos.want.action.dial',
      uri: `tel:${phoneNumber}`
    };
    try {
      await this.context.startAbility(want);
    } catch (e) {
      console.error(`Failed to make call: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 启动微信
   */
  static async launchWeChat(): Promise<void> {
    await this.launchApp(WECHAT_BUNDLE, 'com.tencent.mm.ui.LauncherUI');
  }

  /**
   * 启动应用
   */
  static async launchApp(bundleName: string, abilityName: string): Promise<void> {
    if (!this.context) {
      return;
    }
    const want: Want = {
      bundleName: bundleName,
      abilityName: abilityName
    };
    try {
      await this.context.startAbility(want);
    } catch (e) {
      console.error(`Failed to launch app: ${JSON.stringify(e)}`);
    }
  }
  /**
   * 获取已安装应用列表
   */
  static async getInstalledApps(): Promise<InstalledAppInfo[]> {
    if (!this.context) {
      return [];
    }
    try {
      // 暂时返回空列表，待后续实现完整的应用列表获取逻辑
      const apps: InstalledAppInfo[] = [];
      
      // 添加一些常用应用作为示例
      const sampleApps = [
        { bundleName: 'com.tencent.mm', appName: '微信', icon: '' },
        { bundleName: 'com.tencent.mobileqq', appName: 'QQ', icon: '' },
        { bundleName: 'com.alibaba.android.rimet', appName: '钉钉', icon: '' }
      ];
      
      for (const app of sampleApps) {
        const appInfo = new InstalledAppInfo();
        appInfo.bundleName = app.bundleName;
        appInfo.appName = app.appName;
        appInfo.icon = app.icon;
        appInfo.abilityName = '';
        apps.push(appInfo);
      }

      return apps;
    } catch (e) {
      console.error(`Failed to get installed apps: ${JSON.stringify(e)}`);
      return [];
    }
  }

  /**
   * 检查应用是否安装
   */
  static async isAppInstalled(bundleName: string): Promise<boolean> {
    try {
      await bundleManager.getBundleInfo(
        bundleName,
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT
      );
      return true;
    } catch {
      return false;
    }
  }
}
