/**
 * 应用管理页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { AppShortcut, InstalledAppInfo } from '../models/AppShortcut';
import { StorageUtil } from '../utils/StorageUtil';
import { AppLauncherUtil } from '../utils/AppLauncherUtil';

@Entry
@Component
export struct AppManage {
  @State installedApps: InstalledAppInfo[] = [];
  @State enabledApps: AppShortcut[] = [];
  @State isLoading: boolean = true;

  private readonly MAX_ENABLED = 6;

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    AppLauncherUtil.init(context);
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;

    this.enabledApps = await StorageUtil.getAppShortcuts();
    this.installedApps = await AppLauncherUtil.getInstalledApps();

    this.isLoading = false;
  }

  isAppEnabled(bundleName: string): boolean {
    return this.enabledApps.some(a => a.bundleName === bundleName && a.enabled);
  }

  async toggleApp(app: InstalledAppInfo): Promise<void> {
    const isEnabled = this.isAppEnabled(app.bundleName);
    const enabledCount = this.enabledApps.filter(a => a.enabled).length;

    if (isEnabled) {
      const index = this.enabledApps.findIndex(a => a.bundleName === app.bundleName);
      if (index !== -1) {
        this.enabledApps[index].enabled = false;
      }
    } else {
      if (enabledCount >= this.MAX_ENABLED) {
        promptAction.showToast({ message: `最多只能启用${this.MAX_ENABLED}个应用` });
        return;
      }

      let existing = this.enabledApps.find(a => a.bundleName === app.bundleName);
      if (existing) {
        existing.enabled = true;
        existing.position = enabledCount;
      } else {
        const shortcut = new AppShortcut();
        shortcut.bundleName = app.bundleName;
        shortcut.abilityName = app.abilityName;
        shortcut.appName = app.appName;
        shortcut.iconUri = app.icon;
        shortcut.enabled = true;
        shortcut.position = enabledCount;
        this.enabledApps.push(shortcut);
      }
    }

    await StorageUtil.saveAppShortcuts(this.enabledApps);
    // 刷新列表以更新 Switch 状态
    this.enabledApps = await StorageUtil.getAppShortcuts();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(22)
          .fontColor('#303133')
          .onClick(() => router.back())

        Text('应用管理')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: { bottom: '#F2F4F7' } })

      // 状态栏
      Row() {
        Text(`已选 ${this.enabledApps.filter(a => a.enabled).length}/${this.MAX_ENABLED} 个应用`)
          .fontSize(13)
          .fontColor('#909399')
      }
      .width('100%')
      .padding({ left: 20, top: 12, bottom: 12 })
      .backgroundColor('#F2F4F7')

      // 应用列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#409EFF')

          Text('加载中...')
            .fontSize(14)
            .fontColor('#909399')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.installedApps.length === 0) {
        Column() {
          Text('暂无可用应用')
            .fontSize(15)
            .fontColor('#909399')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.installedApps, (app: InstalledAppInfo) => {
            ListItem() {
              Row() {
                // 应用图标占位
                Column() {
                  Text(app.appName.charAt(0))
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }
                .width(42)
                .height(42)
                .borderRadius(10)
                .backgroundColor('#67C23A')
                .justifyContent(FlexAlign.Center)

                // 应用信息
                Column() {
                  Text(app.appName)
                    .fontSize(15)
                    .fontColor('#1A1A1A')

                  Text(app.bundleName)
                    .fontSize(11)
                    .fontColor('#C0C4CC')
                    .margin({ top: 3 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)

                // 开关
                Toggle({ type: ToggleType.Switch, isOn: this.isAppEnabled(app.bundleName) })
                  .selectedColor('#409EFF')
                  .onChange((isOn: boolean) => {
                    this.toggleApp(app);
                  })
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F2F4F7')
        .divider({ strokeWidth: 1, color: '#F2F4F7' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
