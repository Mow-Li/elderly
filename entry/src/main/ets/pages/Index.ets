/**
 * 主桌面页面 - 相亲相爱桌面
 */
import { common, Want } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Contact, ContactActionType } from '../models/Contact';
import { AppShortcut } from '../models/AppShortcut';
import { AppSettings, FONT_SIZE_PRESETS, FontSizeLevel } from '../models/Settings';
import { StorageUtil } from '../utils/StorageUtil';
import { AppLauncherUtil } from '../utils/AppLauncherUtil';

interface ContactAction {
  type: ContactActionType;
  icon: string;
  label: string;
}

@Component
export struct Index {
  @State contacts: Contact[] = [];
  @State appShortcuts: AppShortcut[] = [];
  @State settings: AppSettings = new AppSettings();
  @State showContactDialog: boolean = false;
  @State selectedContact: Contact | null = null;
  @State showSettingsDialog: boolean = false;
  @State fontSizeConfig: Record<string, number> = { fontSize: 22, iconSize: 80 };

  private contactActions: ContactAction[] = [
    { type: ContactActionType.PHONE, icon: '📞', label: '打电话' },
    { type: ContactActionType.WECHAT_CALL, icon: '💬', label: '微信电话' },
    { type: ContactActionType.WECHAT_VIDEO, icon: '📹', label: '微信视频' }
  ];

  async aboutToAppear(): Promise<void> {
    // 初始化
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    AppLauncherUtil.init(context);

    // 加载数据
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.contacts = await StorageUtil.getContacts();
    this.appShortcuts = await StorageUtil.getAppShortcuts();
    this.settings = await StorageUtil.getSettings();
    this.updateFontSize();
  }

  updateFontSize(): void {
    const config = FONT_SIZE_PRESETS[this.settings.fontSize];
    this.fontSizeConfig = {
      fontSize: config.fontSize,
      iconSize: config.iconSize
    };
  }

  // 点击联系人
  onContactTap(contact: Contact): void {
    this.selectedContact = contact;
    this.showContactDialog = true;
  }

  // 执行联系人操作
  async doContactAction(actionType: ContactActionType): Promise<void> {
    if (!this.selectedContact) {
      return;
    }

    switch (actionType) {
      case ContactActionType.PHONE:
        if (this.selectedContact.phone) {
          await AppLauncherUtil.makeCall(this.selectedContact.phone);
        }
        break;
      case ContactActionType.WECHAT_CALL:
      case ContactActionType.WECHAT_VIDEO:
        await AppLauncherUtil.launchWeChat();
        break;
    }

    this.showContactDialog = false;
    this.selectedContact = null;
  }

  // 点击应用
  async onAppTap(app: AppShortcut): Promise<void> {
    await AppLauncherUtil.launchApp(app.bundleName, app.abilityName);
  }

  // 点击设置
  onSettingsClick(): void {
    this.showSettingsDialog = true;
  }

  // 退出桌面
  async exitDesktop(): Promise<void> {
    // 关闭当前 Ability，让系统回到默认桌面
    try {
      const context = getContext(this) as common.UIAbilityContext;
      context.terminateSelf();
    } catch (e) {
      console.error(`Failed to exit: ${JSON.stringify(e)}`);
    }
  }

  // 跳转到页面
  pushToPage(pageName: string): void {
    this.showSettingsDialog = false;
    router.pushUrl({ url: `pages/${pageName}` });
  }

  build() {
    Stack() {
      Column() {
        // 标题
        Text('相亲相爱桌面')
          .fontSize(this.fontSizeConfig.fontSize + 6)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 30, bottom: 20 })

        // 联系人网格
        this.buildContactGrid()

        // 应用快捷方式
        this.buildAppGrid()

        Blank()

        // 设置按钮
        Button('⚙️ 设置')
          .fontSize(this.fontSizeConfig.fontSize)
          .backgroundColor('#FF9800')
          .borderRadius(25)
          .padding({ left: 40, right: 40, top: 12, bottom: 12 })
          .onClick(() => this.onSettingsClick())
          .margin({ bottom: 30 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 联系人操作弹窗
      if (this.showContactDialog && this.selectedContact) {
        this.ContactActionDialog()
      }

      // 设置弹窗
      if (this.showSettingsDialog) {
        this.SettingsDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildContactGrid() {
    if (this.contacts.length === 0) {
      Text('点击下方"设置"添加联系人')
        .fontSize(this.fontSizeConfig.fontSize)
        .fontColor('#999999')
        .margin({ top: 40 })
    } else {
      Grid() {
        ForEach(this.contacts, (contact: Contact, index: number) => {
          GridItem() {
            Column() {
              if (contact.photoUri) {
                Image(contact.photoUri)
                  .width(this.fontSizeConfig.iconSize)
                  .height(this.fontSizeConfig.iconSize)
                  .borderRadius(this.fontSizeConfig.iconSize / 2)
                  .objectFit(ImageFit.Cover)
                  .border({ width: 3, color: '#FF9800' })
              } else {
                Text(contact.name.charAt(0))
                  .fontSize(this.fontSizeConfig.iconSize * 0.4)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width(this.fontSizeConfig.iconSize)
                  .height(this.fontSizeConfig.iconSize)
                  .borderRadius(this.fontSizeConfig.iconSize / 2)
                  .backgroundColor('#FF9800')
                  .textAlign(TextAlign.Center)
              }

              Text(contact.name)
                .fontSize(this.fontSizeConfig.fontSize)
                .fontColor('#333333')
                .margin({ top: 8 })
                .maxLines(1)
            }
            .onClick(() => this.onContactTap(contact))
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(15)
      .rowsGap(20)
      .width('90%')
      .height('40%')
      .margin({ left: '5%', right: '5%' })
    }
  }

  @Builder
  buildAppGrid() {
    Column() {
      if (this.appShortcuts.filter(a => a.enabled).length > 0) {
        Grid() {
          ForEach(this.appShortcuts.filter(a => a.enabled), (app: AppShortcut) => {
            GridItem() {
              Column() {
                if (app.iconUri) {
                  Image(app.iconUri)
                    .width(this.fontSizeConfig.iconSize * 0.6)
                    .height(this.fontSizeConfig.iconSize * 0.6)
                    .borderRadius(12)
                    .objectFit(ImageFit.Cover)
                } else {
                  Text(app.appName.charAt(0))
                    .fontSize(this.fontSizeConfig.iconSize * 0.3)
                    .fontColor('#FFFFFF')
                    .width(this.fontSizeConfig.iconSize * 0.6)
                    .height(this.fontSizeConfig.iconSize * 0.6)
                    .borderRadius(12)
                    .backgroundColor('#4CAF50')
                    .textAlign(TextAlign.Center)
                }

                Text(app.appName)
                  .fontSize(this.fontSizeConfig.fontSize - 4)
                  .fontColor('#333333')
                  .margin({ top: 6 })
                  .maxLines(1)
              }
              .onClick(() => this.onAppTap(app))
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width('90%')
        .padding(10)
      }
    }
    .width('100%')
    .margin({ top: 20 })
  }

  @Builder
  ContactActionDialog() {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showContactDialog = false;
          this.selectedContact = null;
        })

      // 弹窗内容
      Column() {
        // 头像
        if (this.selectedContact?.photoUri) {
          Image(this.selectedContact.photoUri)
            .width(80)
            .height(80)
            .borderRadius(40)
            .border({ width: 3, color: '#FF9800' })
            .margin({ top: 20 })
        }

        Text(this.selectedContact?.name ?? '')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 10 })

        // 操作按钮
        Column({ space: 12 }) {
          ForEach(this.contactActions, (action: ContactAction) => {
            Button(`${action.icon} ${action.label}`)
              .width('80%')
              .height(50)
              .fontSize(18)
              .backgroundColor('#FFFFFF')
              .fontColor('#333333')
              .borderRadius(25)
              .border({ width: 1, color: '#E0E0E0' })
              .onClick(() => this.doContactAction(action.type))
          })
        }
        .margin({ top: 25 })

        // 取消
        Button('取消')
          .width('80%')
          .height(45)
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(22)
          .margin({ top: 20, bottom: 25 })
          .onClick(() => {
            this.showContactDialog = false;
            this.selectedContact = null;
          })
      }
      .width('85%')
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .margin({ top: '15%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  SettingsDialog() {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showSettingsDialog = false;
        })

      // 设置面板
      Column() {
        // 标题
        Row() {
          Text('设置')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text('×')
            .fontSize(28)
            .fontColor('#999999')
            .onClick(() => {
              this.showSettingsDialog = false;
            })
        }
        .width('100%')
        .padding(20)
        .borderBottom({ width: 1, color: '#E0E0E0' })

        // 设置项
        Column() {
          this.SettingItem('👨 联系人管理', () => this.pushToPage('ContactManage'))
          Divider().color('#E0E0E0').margin({ left: 20, right: 20 })

          this.SettingItem('📱 应用管理', () => this.pushToPage('AppManage'))
          Divider().color('#E0E0E0').margin({ left: 20, right: 20 })

          this.SettingItem('🔊 语音设置', () => this.pushToPage('VoiceSetting'))
          Divider().color('#E0E0E0').margin({ left: 20, right: 20 })

          this.SettingItem('📏 字体大小', () => this.pushToPage('FontSizeSetting'))
        }
        .margin({ top: 10 })

        Blank()

        // 退出桌面
        Button('🚪 退出桌面')
          .width('100%')
          .height(55)
          .fontSize(18)
          .backgroundColor('#F5F5F5')
          .fontColor('#FF5722')
          .borderRadius(0)
          .onClick(() => this.exitDesktop())
      }
      .width('90%')
      .height(380)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .margin({ top: '20%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  SettingItem(label: string, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(18)
        .fontColor('#333333')

      Blank()

      Text('>')
        .fontSize(18)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height(55)
    .padding({ left: 20, right: 20 })
    .onClick(onClick)
  }
}
