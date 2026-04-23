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
      const bundleInfos = await bundleManager.getAllBundleInfo(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
        0
      );

      const apps: InstalledAppInfo[] = [];
      for (const info of bundleInfos) {
        // 过滤系统应用
        if (info.name.startsWith('com.ohos.') ||
            info.name.startsWith('com.huawei.') ||
            info.name.startsWith('com.android.')) {
          continue;
        }

        const appInfo = new InstalledAppInfo();
        appInfo.bundleName = info.name;
        appInfo.appName = info.appInfo?.label ?? info.name;
        appInfo.icon = info.appInfo?.icon ?? '';
        appInfo.abilityName = info.abilityInfos?.[0]?.name ?? '';

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
