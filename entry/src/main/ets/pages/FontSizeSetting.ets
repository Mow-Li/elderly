/**
 * 字体大小设置页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { AppSettings, FONT_SIZE_PRESETS, FontSizeLevel, FontSizeConfig } from '../models/Settings';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
export struct FontSizeSetting {
  @State settings: AppSettings = new AppSettings();

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    this.settings = await StorageUtil.getSettings();
  }

  async onSelectFontSize(level: FontSizeLevel): Promise<void> {
    this.settings.fontSize = level;
    await StorageUtil.saveSettings(this.settings);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => router.back())

        Text('字体大小')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 10 })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 预览
      Column() {
        Text('预览效果')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 15 })

        Column() {
          Text('儿子')
            .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
            .fontColor('#333333')

          Text('女儿')
            .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
            .fontColor('#333333')
            .margin({ top: 10 })

          Text('老伴')
            .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
            .fontColor('#333333')
            .margin({ top: 10 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
      }
      .width('90%')
      .margin({ top: 25 })

      // 选项列表
      Column() {
        ForEach(FONT_SIZE_PRESETS, (config: FontSizeConfig) => {
          Row() {
            Text(config.label)
              .fontSize(config.fontSize)
              .fontColor('#333333')
              .width(60)

            Text('Aa')
              .fontSize(config.fontSize)
              .fontColor('#333333')

            Blank()

            if (this.settings.fontSize === config.level) {
              Text('✓')
                .fontSize(20)
                .fontColor('#FF9800')
            }
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .onClick(() => this.onSelectFontSize(config.level))

          if (config.level !== FontSizeLevel.EXTRA_EXTRA_LARGE) {
            Divider()
              .color('#E0E0E0')
              .margin({ left: 20, right: 20 })
          }
        })
      }
      .width('90%')
      .margin({ top: 25 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
