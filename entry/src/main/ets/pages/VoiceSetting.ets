/**
 * 语音设置页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { AppSettings } from '../models/Settings';
import { StorageUtil } from '../utils/StorageUtil';

@Component
export struct VoiceSetting {
  @State settings: AppSettings = new AppSettings();

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
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

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => router.back())

        Text('语音设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 10 })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      Column() {
        // 语音开关
        Row() {
          Column() {
            Text('语音播报')
              .fontSize(18)
              .fontColor('#333333')

            Text('点击联系人时播报姓名')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 4 })
          }

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.settings.voiceEnabled })
            .selectedColor('#FF9800')
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
              .fontSize(18)
              .fontColor('#333333')

            Blank()

            Text(`${this.settings.voiceSpeed.toFixed(1)}x`)
              .fontSize(14)
              .fontColor('#999999')
          }

          Row() {
            Text('慢')
              .fontSize(12)
              .fontColor('#999999')

            Slider({
              value: this.settings.voiceSpeed * 100,
              min: 50,
              max: 200,
              step: 10,
              style: SliderStyle.OutSet
            })
              .width('70%')
              .blockColor('#FF9800')
              .trackColor('#E0E0E0')
              .selectedColor('#FF9800')
              .onChange((value: number) => {
                this.onSpeechRateChange(value / 100);
              })

            Text('快')
              .fontSize(12)
              .fontColor('#999999')
          }
          .margin({ top: 15 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 15 })

        // 试听按钮
        Button('试听语音')
          .width('100%')
          .height(50)
          .fontSize(18)
          .backgroundColor('#FF9800')
          .fontColor('#FFFFFF')
          .borderRadius(25)
          .margin({ top: 30 })
          .onClick(() => {
            // TODO: 实现语音试听
            promptAction.showToast({ message: '语音试听功能待实现' });
          })
      }
      .width('90%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
