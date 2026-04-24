/**
 * 主桌面页面 - 相亲相爱桌面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Contact, ContactActionType } from '../models/Contact';
import { AppShortcut } from '../models/AppShortcut';
import { AppSettings, FONT_SIZE_PRESETS, FontSizeLevel } from '../models/Settings';
import { StorageUtil } from '../utils/StorageUtil';
import { AppLauncherUtil } from '../utils/AppLauncherUtil';

interface ContactAction {
  type: ContactActionType;
  icon: ResourceStr;
  label: string;
}

@Entry
@Component
export struct Index {
  @State contacts: Contact[] = [];
  @State appShortcuts: AppShortcut[] = [];
  @State settings: AppSettings = new AppSettings();
  @State showContactDialog: boolean = false;
  @State selectedContact: Contact | null = null;
  @State showSettingsDialog: boolean = false;
  @State fontSizeConfig: Record<string, number> = { "fontSize": 22, "iconSize": 80 };

  private contactActions: ContactAction[] = [
    { type: ContactActionType.PHONE, icon: '�打电话', label: '拨打电话' },
    { type: ContactActionType.WECHAT_CALL, icon: '', label: '微信通话' },
    { type: ContactActionType.WECHAT_VIDEO, icon: '', label: '微信视频' }
  ];

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    AppLauncherUtil.init(context);
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
      "fontSize": config.fontSize,
      "iconSize": config.iconSize
    } as Record<string, number>;
  }

  // 点击联系人 - 语音播报 + 弹出操作
  onContactTap(contact: Contact): void {
    // 语音播报姓名
    if (this.settings.voiceEnabled) {
      AppLauncherUtil.speak(contact.name, this.settings.voiceSpeed);
    }
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

  // 退出桌面
  async exitDesktop(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      context.terminateSelf();
    } catch (e) {
      console.error(`Failed to exit: ${JSON.stringify(e)}`);
    }
  }

  build() {
    Stack() {
      Column() {
        // 标题区
        Column() {
          Text('相亲相爱桌面')
            .fontSize(this.fontSizeConfig.fontSize + 8)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text('长按联系人可快速呼叫')
            .fontSize(this.fontSizeConfig.fontSize - 4)
            .fontColor('#999999')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 24, bottom: 20 })
        .alignItems(HorizontalAlign.Center)

        // 联系人网格
        this.buildContactGrid()

        // 应用快捷方式
        this.buildAppGrid()

        Blank()

        // 设置按钮
        Button('设置')
          .fontSize(this.fontSizeConfig.fontSize)
          .fontColor('#FFFFFF')
          .backgroundColor('#409EFF')
          .borderRadius(24)
          .width(200)
          .height(50)
          .onClick(() => {
            this.showSettingsDialog = true;
          })
          .margin({ bottom: 32 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F2F4F7')

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
      Column() {
        Text('暂无联系人')
          .fontSize(this.fontSizeConfig.fontSize + 2)
          .fontColor('#999999')
        Text('请在设置中添加')
          .fontSize(this.fontSizeConfig.fontSize - 2)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 60 })
    } else {
      Grid() {
        ForEach(this.contacts, (contact: Contact) => {
          GridItem() {
            Column() {
              // 头像
              if (contact.photoUri) {
                Image(contact.photoUri)
                  .width(this.fontSizeConfig.iconSize)
                  .height(this.fontSizeConfig.iconSize)
                  .borderRadius(this.fontSizeConfig.iconSize / 2)
                  .objectFit(ImageFit.Cover)
                  .border({ width: 3, color: '#409EFF' })
              } else {
                Column() {
                  Text(contact.name.charAt(0))
                    .fontSize(this.fontSizeConfig.iconSize * 0.38)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .width(this.fontSizeConfig.iconSize)
                .height(this.fontSizeConfig.iconSize)
                .borderRadius(this.fontSizeConfig.iconSize / 2)
                .backgroundColor('#409EFF')
                .justifyContent(FlexAlign.Center)
              }

              Text(contact.name)
                .fontSize(this.fontSizeConfig.fontSize)
                .fontColor('#1A1A1A')
                .margin({ top: 10 })
                .maxLines(1)
            }
            .width('100%')
            .onClick(() => this.onContactTap(contact))
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(16)
      .rowsGap(24)
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
  }

  @Builder
  buildAppGrid() {
    const enabledApps = this.appShortcuts.filter(a => a.enabled);
    if (enabledApps.length === 0) {
      Blank()
    } else {
      Column() {
        Text('快捷应用')
          .fontSize(this.fontSizeConfig.fontSize - 2)
          .fontColor('#999999')
          .width('100%')
          .padding({ left: 24, right: 24, top: 16, bottom: 10 })

        Grid() {
          ForEach(enabledApps, (app: AppShortcut) => {
            GridItem() {
              Column() {
                Column() {
                  Text(app.appName.charAt(0))
                    .fontSize(this.fontSizeConfig.iconSize * 0.28)
                    .fontColor('#FFFFFF')
                }
                .width(this.fontSizeConfig.iconSize * 0.55)
                .height(this.fontSizeConfig.iconSize * 0.55)
                .borderRadius(14)
                .backgroundColor('#67C23A')
                .justifyContent(FlexAlign.Center)

                Text(app.appName)
                  .fontSize(this.fontSizeConfig.fontSize - 4)
                  .fontColor('#1A1A1A')
                  .margin({ top: 8 })
                  .maxLines(1)
              }
              .width('100%')
              .onClick(() => this.onAppTap(app))
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(16)
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
    }
  }

  @Builder
  ContactActionDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.45)')
        .onClick(() => {
          this.showContactDialog = false;
          this.selectedContact = null;
        })

      // 弹窗内容
      Column() {
        // 头部
        Row() {
          Text(this.selectedContact?.name ?? '')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')

          Blank()

          Text('x')
            .fontSize(22)
            .fontColor('#C0C4CC')
            .onClick(() => {
              this.showContactDialog = false;
              this.selectedContact = null;
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 16 })

        Divider().color('#EBEEF5').margin({ left: 24, right: 24 })

        // 头像
        if (this.selectedContact?.photoUri) {
          Image(this.selectedContact.photoUri)
            .width(72)
            .height(72)
            .borderRadius(36)
            .border({ width: 2, color: '#409EFF' })
            .margin({ top: 16 })
        } else {
          Column() {
            Text(this.selectedContact?.name?.charAt(0) ?? '')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#409EFF')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 16 })
        }

        Text(this.selectedContact?.phone ?? '')
          .fontSize(14)
          .fontColor('#909399')
          .margin({ top: 8 })

        // 操作按钮
        Column({ space: 10 }) {
          ForEach(this.contactActions, (action: ContactAction) => {
            Button(action.label)
              .width('85%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#409EFF')
              .borderRadius(24)
              .onClick(() => this.doContactAction(action.type))
          })
        }
        .margin({ top: 20 })

        // 取消
        Button('取消')
          .width('85%')
          .height(44)
          .fontSize(15)
          .fontColor('#606266')
          .backgroundColor('#F2F4F7')
          .borderRadius(22)
          .margin({ top: 10, bottom: 24 })
          .onClick(() => {
            this.showContactDialog = false;
            this.selectedContact = null;
          })
      }
      .width('78%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: '18%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 } as Position)
  }

  @Builder
  SettingsDialog() {
    Column() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.45)')
        .onClick(() => {
          this.showSettingsDialog = false;
        })

      // 设置面板
      Column() {
        // 标题
        Row() {
          Text('设置')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')

          Blank()

          Text('x')
            .fontSize(22)
            .fontColor('#C0C4CC')
            .onClick(() => {
              this.showSettingsDialog = false;
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 16 })

        Divider().color('#EBEEF5').margin({ left: 24, right: 24 })

        // 设置项列表
        Column() {
          this.SettingItem('联系人管理', 'ContactManage')
          Divider().color('#F2F4F7').margin({ left: 24, right: 24 })

          this.SettingItem('应用管理', 'AppManage')
          Divider().color('#F2F4F7').margin({ left: 24, right: 24 })

          this.SettingItem('语音设置', 'VoiceSetting')
          Divider().color('#F2F4F7').margin({ left: 24, right: 24 })

          this.SettingItem('字体大小', 'FontSizeSetting')
        }
        .width('100%')
        .margin({ top: 8 })

        Blank()

        // 退出桌面
        Button('退出桌面')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#F56C6C')
          .backgroundColor('#FEF0F0')
          .borderRadius(0)
          .onClick(() => this.exitDesktop())
      }
      .width('100%')
      .height(340)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 } as Position)
  }

  @Builder
  SettingItem(label: string, pageName: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#303133')

      Blank()

      Text('>')
        .fontSize(16)
        .fontColor('#C0C4CC')
    }
    .width('100%')
    .height(54)
    .padding({ left: 24, right: 24 })
    .onClick(() => {
      this.showSettingsDialog = false;
      router.pushUrl({ url: `pages/${pageName}` });
    })
  }
}
