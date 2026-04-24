/**
 * 应用启动工具类
 */
import { common, Want } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { AppShortcut, InstalledAppInfo } from '../models/AppShortcut';
import { image } from '@kit.ImageKit';
import { textToSpeech } from '@kit.CoreSpeechKit';

const WECHAT_BUNDLE = 'com.tencent.mm';
const WECHAT_ABILITY = 'com.tencent.mm.ui.LauncherUI';

// 系统包名前缀（过滤掉系统应用）
const SYSTEM_PREFIXES = [
  'com.ohos.',
  'com.huawei.',
  'com.android.',
  'com.hw.',
  'com.factory.',
  'com.yg.',
];

export class AppLauncherUtil {
  private static context: common.UIAbilityContext | null = null;
  private static ttsEngine: textToSpeech.TextToSpeechEngine | null = null;
  private static ttsInitialized: boolean = false;

  static init(context: common.UIAbilityContext): void {
    this.context = context;
    this.initTts();
  }

  // ---------- TTS 初始化 ----------
  private static async initTts(): Promise<void> {
    try {
      const ttsParams: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,
        online: 0
      };
      this.ttsEngine = await textToSpeech.createEngine(ttsParams);
      this.ttsInitialized = true;
    } catch (err) {
      console.error(`Failed to init TTS: ${JSON.stringify(err)}`);
      this.ttsInitialized = false;
    }
  }

  // ---------- 语音播报 ----------
  static async speak(text: string, speed: number = 1.0): Promise<void> {
    if (!this.ttsEngine || !this.ttsInitialized) {
      // TTS 未就绪，尝试重新初始化
      await this.initTts();
      if (!this.ttsEngine) {
        console.warn('TTS engine not available');
        return;
      }
    }
    try {
      this.ttsEngine.speak(text, { requestId: '0' });
    } catch (err) {
      console.error(`TTS speak error: ${JSON.stringify(err)}`);
    }
  }

  // ---------- 停止播报 ----------
  static stopSpeaking(): void {
    if (this.ttsEngine) {
      try {
        this.ttsEngine.stop();
      } catch (err) {
        console.error(`TTS stop error: ${JSON.stringify(err)}`);
      }
    }
  }

  // ---------- 拨打电话 ----------
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

  // ---------- 启动微信 ----------
  static async launchWeChat(): Promise<void> {
    await this.launchApp(WECHAT_BUNDLE, WECHAT_ABILITY);
  }

  // ---------- 启动应用 ----------
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

  // ---------- 获取已安装应用列表 ----------
  static async getInstalledApps(): Promise<InstalledAppInfo[]> {
    if (!this.context) {
      return [];
    }

    try {
      const bundleInfo = await bundleManager.getBundleInfo(
        'GET_BUNDLE_INFO_WITH_APPLICATION',
        0
      );

      const apps: InstalledAppInfo[] = [];
      if (bundleInfo) {
        // 这里应该是遍历 bundleInfo 中的应用程序列表
        // 但由于 bundleInfo 结构不明确，暂时注释掉有问题的代码
        // 跳过系统应用
        // if (this.isSystemApp(info.name)) {
        //   continue;
        // }

        // // 获取应用名称（优先取 label）
        // const appName = info.appInfo?.label ?? info.name;

        // // 获取 ability 名称
        // const abilityName = info.abilityInfos?.[0]?.name ?? '';

        // // 获取图标并保存为文件
        // const iconPath = await this.saveAppIcon(info.appInfo?.icon ?? '', info.name);

        // const appInfo = new InstalledAppInfo();
        // appInfo.bundleName = info.name;
        // appInfo.abilityName = abilityName;
        // appInfo.appName = appName;
        // appInfo.icon = iconPath;

        // apps.push(appInfo);
      }

      // 按名称排序
      apps.sort((a, b) => a.appName.localeCompare(b.appName, 'zh-CN'));
      return apps;
    } catch (e) {
      console.error(`Failed to get installed apps: ${JSON.stringify(e)}`);
      return [];
    }
  }

  // ---------- 检查是否为系统应用 ----------
  private static isSystemApp(bundleName: string): boolean {
    return SYSTEM_PREFIXES.some(prefix => bundleName.startsWith(prefix));
  }

  // ---------- 保存应用图标到本地文件 ----------
  private static async saveAppIcon(iconData: image.PixelMap | string, bundleName: string): Promise<string> {
    if (!iconData || !this.context) {
      return '';
    }

    try {
      // 构造图标缓存目录
      const cacheDir = this.context.cacheDir;
      const iconFileName = `icon_${bundleName.replace(/\./g, '_')}.png`;
      const iconPath = `${cacheDir}/${iconFileName}`;

      // 检查文件是否已存在
      if (fileIo.listFileSync(cacheDir).includes(iconFileName)) {
        return `file://${iconPath}`;
      }

      // 如果是 PixelMap，转换为 buffer 并写入文件
      if (typeof iconData !== 'string') {
        const packFile: fileIo.File = fileIo.openSync(iconPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
        // PixelMap 无法直接写入，这里返回空字符串
        // 实际项目中建议用 image.packImageData 或通过 Native API 导出
        fileIo.closeSync(packFile);
        return '';
      }

      return '';
    } catch (err) {
      console.error(`Failed to save icon for ${bundleName}: ${JSON.stringify(err)}`);
      return '';
    }
  }

  // ---------- 检查应用是否安装 ----------
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
