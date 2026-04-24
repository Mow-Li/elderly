/**
 * 语音设置页面
 */
import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { AppSettings } from '../models/Settings';
import { StorageUtil } from '../utils/StorageUtil';
import { AppLauncherUtil } from '../utils/AppLauncherUtil';

@Entry
@Component
export struct VoiceSetting {
  @State settings: AppSettings = new AppSettings();

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    AppLauncherUtil.init(context);
    this.settings = await StorageUtil.getSettings();
  }

  async onToggleVoice(enabled: boolean): Promise<void> {
    this.settings.voiceEnabled = enabled;
    await StorageUtil.saveSettings(this.settings);
  }

  async onSpeechRateChange(rate: number): Promise<void> {
    this.settings.voiceSpeed = rate;
    await StorageUtil.saveSettings(this.settings);
  }

  // 试听语音
  onPreview(): void {
    AppLauncherUtil.speak('这是语音播报试听', this.settings.voiceSpeed);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(22)
          .fontColor('#303133')
          .onClick(() => router.back())

        Text('语音设置')
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
        // 语音开关
        Row() {
          Column() {
            Text('语音播报')
              .fontSize(16)
              .fontColor('#303133')

            Text('点击联系人时播报姓名')
              .fontSize(13)
              .fontColor('#909399')
              .margin({ top: 4 })
          }

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.settings.voiceEnabled })
            .selectedColor('#409EFF')
            .onChange((isOn: boolean) => {
              this.onToggleVoice(isOn);
            })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 语速调节
        Column() {
          Row() {
            Text('语速调节')
              .fontSize(16)
              .fontColor('#303133')

            Blank()

            Text(`${this.settings.voiceSpeed.toFixed(1)}x`)
              .fontSize(14)
              .fontColor('#909399')
          }

          Row() {
            Text('慢')
              .fontSize(12)
              .fontColor('#C0C4CC')

            Slider({
              value: this.settings.voiceSpeed * 100,
              min: 50,
              max: 200,
              step: 10,
              style: SliderStyle.OutSet
            })
              .width('70%')
              .blockColor('#409EFF')
              .trackColor('#E6E8EB')
              .selectedColor('#409EFF')
              .onChange((value: number) => {
                this.onSpeechRateChange(value / 100);
              })

            Text('快')
              .fontSize(12)
              .fontColor('#C0C4CC')
          }
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 12 })

        // 试听按钮
        Button('试听语音')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#409EFF')
          .borderRadius(24)
          .margin({ top: 24 })
          .onClick(() => this.onPreview())
      }
      .width('92%')
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
