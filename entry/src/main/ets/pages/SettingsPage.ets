/**
 * 设置主页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

interface SettingsItem {
  label: string;
  pageName: string;
  desc?: string;
}

@Entry
@Component
export struct SettingsPage {
  @State showExitConfirm: boolean = false;

  private settingsItems: SettingsItem[] = [
    { label: '联系人管理', pageName: 'ContactManage', desc: '添加、编辑、删除联系人' },
    { label: '应用管理', pageName: 'AppManage', desc: '管理桌面快捷应用' },
    { label: '语音设置', pageName: 'VoiceSetting', desc: '语音播报开关及语速' },
    { label: '字体大小', pageName: 'FontSizeSetting', desc: '调整界面字体大小' }
  ];

  confirmExit(): void {
    this.showExitConfirm = false;
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
        // 标题栏
        Row() {
          Text('<')
            .fontSize(22)
            .fontColor('#303133')
            .onClick(() => router.back())

          Text('设置')
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

        // 设置项列表
        Column() {
          ForEach(this.settingsItems, (item: SettingsItem, index: number) => {
            Column() {
              Row() {
                Column() {
                  Text(item.label)
                    .fontSize(16)
                    .fontColor('#303133')

                  Text(item.desc ?? '')
                    .fontSize(12)
                    .fontColor('#C0C4CC')
                    .margin({ top: 3 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor('#C0C4CC')
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .onClick(() => {
                router.pushUrl({ url: `pages/${item.pageName}` });
              })

              if (index < this.settingsItems.length - 1) {
                Divider()
                  .color('#F2F4F7')
                  .margin({ left: 20, right: 20 })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
          })
        }
        .width('100%')
        .margin({ top: 12 })

        Blank()

        // 退出桌面
        Button('退出桌面')
          .width('92%')
          .height(50)
          .fontSize(16)
          .fontColor('#F56C6C')
          .backgroundColor('#FEF0F0')
          .borderRadius(12)
          .margin({ bottom: 32 })
          .onClick(() => {
            this.showExitConfirm = true;
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F2F4F7')

      // 退出确认弹窗
      if (this.showExitConfirm) {
        this.ExitConfirmDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ExitConfirmDialog() {
    Stack({ alignContent: Alignment.Center }) {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showExitConfirm = false;
        })

      // 确认卡片（居中）
      Column() {
        Text('退出桌面')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Text('退出后将返回系统桌面')
          .fontSize(14)
          .fontColor('#909399')
          .margin({ top: 8 })

        Row({ space: 16 }) {
          Button('取消')
            .width('46%')
            .height(44)
            .fontSize(15)
            .fontColor('#606266')
            .backgroundColor('#F2F4F7')
            .borderRadius(22)
            .onClick(() => {
              this.showExitConfirm = false;
            })

          Button('确认退出')
            .width('46%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#F56C6C')
            .borderRadius(22)
            .onClick(() => {
              this.confirmExit();
            })
        }
        .margin({ top: 24 })
      }
      .width('72%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding(24)
    }
    .width('100%')
    .height('100%')
  }
}
