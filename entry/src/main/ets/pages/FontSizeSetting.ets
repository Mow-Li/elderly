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
          .fontSize(22)
          .fontColor('#303133')
          .onClick(() => router.back())

        Text('字体大小')
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

      Column() {
        // 预览卡片
        Column() {
          Text('当前预览')
            .fontSize(12)
            .fontColor('#C0C4CC')
            .width('100%')
            .margin({ bottom: 12 })

          Column() {
            Text('儿子')
              .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
              .fontColor('#1A1A1A')

            Text('女儿')
              .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
              .fontColor('#1A1A1A')
              .margin({ top: 10 })

            Text('老伴')
              .fontSize(FONT_SIZE_PRESETS[this.settings.fontSize].fontSize)
              .fontColor('#1A1A1A')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F5F7FA')
          .borderRadius(10)
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 选项列表
        Column() {
          ForEach(FONT_SIZE_PRESETS, (config: FontSizeConfig) => {
            Column() {
              Row() {
                Text(config.label)
                  .fontSize(config.fontSize)
                  .fontColor(this.settings.fontSize === config.level ? '#409EFF' : '#1A1A1A')
                  .width(50)

                Text('示例文本')
                  .fontSize(config.fontSize * 0.75)
                  .fontColor(this.settings.fontSize === config.level ? '#409EFF' : '#909399')

                Blank()

                if (this.settings.fontSize === config.level) {
                  Text('checked')
                    .fontSize(14)
                    .fontColor('#409EFF')
                }
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
              .onClick(() => this.onSelectFontSize(config.level))
            }
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      }
      .width('92%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
