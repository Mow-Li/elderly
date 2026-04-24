/**
 * 联系人编辑页面 - 添加/编辑联系人
 */
import { common } from '@kit.AbilityKit';
import { router, promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Contact } from '../models/Contact';
import { StorageUtil } from '../utils/StorageUtil';

interface EditParams {
  contact?: Contact;
}

@Entry
@Component
export struct ContactEdit {
  @State contact: Contact = new Contact();
  @State isEditMode: boolean = false;
  @State isSaving: boolean = false;

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);

    const params = router.getParams() as EditParams | null;
    if (params && params.contact) {
      this.isEditMode = true;
      this.contact.id = params.contact.id;
      this.contact.name = params.contact.name;
      this.contact.photoUri = params.contact.photoUri;
      this.contact.phone = params.contact.phone;
      this.contact.wechatId = params.contact.wechatId;
      this.contact.position = params.contact.position;
    } else {
      this.isEditMode = false;
      this.contact = new Contact();
      this.contact.id = Date.now().toString();
    }
  }

  async onSelectPhoto(): Promise<void> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result.photoUris && result.photoUris.length > 0) {
        this.contact.photoUri = result.photoUris[0];
      }
    } catch (err) {
      console.error(`Failed to select photo: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '选择照片失败' });
    }
  }

  async onSave(): Promise<void> {
    if (!this.contact.name || this.contact.name.trim() === '') {
      promptAction.showToast({ message: '请输入姓名' });
      return;
    }
    if (!this.contact.phone || this.contact.phone.trim() === '') {
      promptAction.showToast({ message: '请输入电话号码' });
      return;
    }

    const phone = this.contact.phone.trim();
    if (phone.length < 7) {
      promptAction.showToast({ message: '电话号码格式不正确' });
      return;
    }

    this.isSaving = true;

    try {
      this.contact.name = this.contact.name.trim();
      this.contact.phone = this.contact.phone.trim();
      this.contact.wechatId = this.contact.wechatId?.trim() ?? '';

      const contacts = await StorageUtil.getContacts();

      if (this.isEditMode) {
        const index = contacts.findIndex(c => c.id === this.contact.id);
        if (index !== -1) {
          contacts[index] = this.contact;
        }
      } else {
        this.contact.position = contacts.length;
        contacts.push(this.contact);
      }

      await StorageUtil.saveContacts(contacts);
      promptAction.showToast({
        message: this.isEditMode ? '修改成功' : '添加成功'
      });
      router.back();
    } catch (err) {
      console.error(`Failed to save contact: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(22)
          .fontColor('#409EFF')
          .onClick(() => router.back())

        Text(this.isEditMode ? '编辑联系人' : '添加联系人')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 6 })

        Blank()

        Button('保存')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#409EFF')
          .borderRadius(16)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.onSave())
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: { bottom: '#F2F4F7' } })

      Scroll() {
        Column() {
          // 头像选择
          Column() {
            if (this.contact.photoUri) {
              Image(this.contact.photoUri)
                .width(96)
                .height(96)
                .borderRadius(48)
                .border({ width: 3, color: '#409EFF' })
                .objectFit(ImageFit.Cover)
                .onClick(() => this.onSelectPhoto())
            } else {
              Column() {
                Text('+')
                  .fontSize(36)
                  .fontColor('#C0C4CC')
              }
              .width(96)
              .height(96)
              .borderRadius(48)
              .backgroundColor('#F5F7FA')
              .border({ width: 2, color: '#DCDFE6', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.onSelectPhoto())
            }

            Text('点击更换头像')
              .fontSize(12)
              .fontColor('#C0C4CC')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding({ top: 32, bottom: 28 })
          .alignItems(HorizontalAlign.Center)

          // 表单卡片
          Column() {
            // 姓名
            Column() {
              Text('姓名')
                .fontSize(13)
                .fontColor('#909399')
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ text: this.contact.name, placeholder: '请输入联系人姓名' })
                .fontSize(16)
                .height(48)
                .width('100%')
                .backgroundColor('#F5F7FA')
                .borderRadius(8)
                .padding({ left: 14, right: 14 })
                .onChange((value: string) => {
                  this.contact.name = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 电话号码
            Column() {
              Text('电话号码')
                .fontSize(13)
                .fontColor('#909399')
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ text: this.contact.phone, placeholder: '请输入手机号码' })
                .fontSize(16)
                .height(48)
                .width('100%')
                .type(InputType.PhoneNumber)
                .backgroundColor('#F5F7FA')
                .borderRadius(8)
                .padding({ left: 14, right: 14 })
                .onChange((value: string) => {
                  this.contact.phone = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 微信ID
            Column() {
              Text('微信ID（选填）')
                .fontSize(13)
                .fontColor('#909399')
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ text: this.contact.wechatId, placeholder: '用于微信语音/视频通话' })
                .fontSize(16)
                .height(48)
                .width('100%')
                .backgroundColor('#F5F7FA')
                .borderRadius(8)
                .padding({ left: 14, right: 14 })
                .onChange((value: string) => {
                  this.contact.wechatId = value;
                })
            }
            .width('100%')
          }
          .width('90%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 提示
          Row() {
            Text('* 为必填项')
              .fontSize(12)
              .fontColor('#C0C4CC')
          }
          .width('90%')
          .margin({ top: 12 })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F2F4F7')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
