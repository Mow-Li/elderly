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

    // 获取已保存的快捷方式
    this.enabledApps = await StorageUtil.getAppShortcuts();

    // 获取已安装应用
    this.installedApps = await AppLauncherUtil.getInstalledApps();

    this.isLoading = false;
  }

  // 检查应用是否已启用
  isAppEnabled(bundleName: string): boolean {
    return this.enabledApps.some(a => a.bundleName === bundleName && a.enabled);
  }

  // 获取应用的位置
  getAppPosition(bundleName: string): number {
    const app = this.enabledApps.find(a => a.bundleName === bundleName);
    return app?.position ?? -1;
  }

  // 切换应用启用状态
  async toggleApp(app: InstalledAppInfo): Promise<void> {
    const isEnabled = this.isAppEnabled(app.bundleName);
    const enabledCount = this.enabledApps.filter(a => a.enabled).length;

    if (isEnabled) {
      // 禁用
      const index = this.enabledApps.findIndex(a => a.bundleName === app.bundleName);
      if (index !== -1) {
        this.enabledApps[index].enabled = false;
      }
    } else {
      // 启用（检查数量限制）
      if (enabledCount >= this.MAX_ENABLED) {
        promptAction.showToast({ message: `最多只能启用${this.MAX_ENABLED}个应用` });
        return;
      }

      // 检查是否已存在
      let existing = this.enabledApps.find(a => a.bundleName === app.bundleName);
      if (existing) {
        existing.enabled = true;
        existing.position = enabledCount;
      } else {
        // 新建快捷方式
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
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor('#333333')
            .onClick(() => router.back())

          Text('应用管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 10 })

          Blank()

          Text(`已选 ${this.enabledApps.filter(a => a.enabled).length}/${this.MAX_ENABLED}`)
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(60)
        .padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')

        Text('选择要在桌面上显示的应用（最多6个）')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .padding({ left: 20, top: 15, bottom: 10 })

        // 应用列表
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#FF9800')

            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 10 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.installedApps, (app: InstalledAppInfo) => {
              ListItem() {
                Row() {
                  // 应用图标
                  if (app.icon) {
                    Image(app.icon)
                      .width(45)
                      .height(45)
                      .borderRadius(10)
                      .objectFit(ImageFit.Cover)
                  } else {
                    Text(app.appName.charAt(0))
                      .fontSize(20)
                      .fontColor('#FFFFFF')
                      .width(45)
                      .height(45)
                      .borderRadius(10)
                      .backgroundColor('#4CAF50')
                      .textAlign(TextAlign.Center)
                  }

                  // 应用信息
                  Column() {
                    Text(app.appName)
                      .fontSize(16)
                      .fontColor('#333333')

                    Text(app.bundleName)
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 3 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                  .layoutWeight(1)

                  // 开关
                  Toggle({ type: ToggleType.Switch, isOn: this.isAppEnabled(app.bundleName) })
                    .selectedColor('#FF9800')
                    .onChange((isOn: boolean) => {
                      this.toggleApp(app);
                    })
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor('#FFFFFF')
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .divider({ strokeWidth: 1, color: '#E0E0E0' })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
