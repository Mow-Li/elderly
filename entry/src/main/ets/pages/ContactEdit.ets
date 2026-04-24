/**
 * 联系人编辑页面 - 添加/编辑联系人
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { photoViewPicker } from '@kit.MediaLibraryKit';
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

    // 获取路由参数
    const params = router.getParams() as EditParams | null;
    if (params && params.contact) {
      // 编辑模式：复制传入的联系人数据
      this.isEditMode = true;
      this.contact.id = params.contact.id;
      this.contact.name = params.contact.name;
      this.contact.photoUri = params.contact.photoUri;
      this.contact.phone = params.contact.phone;
      this.contact.wechatId = params.contact.wechatId;
      this.contact.position = params.contact.position;
    } else {
      // 添加模式：生成新ID
      this.isEditMode = false;
      this.contact = new Contact();
      this.contact.id = Date.now().toString();
    }
  }

  // 选择照片
  async onSelectPhoto(): Promise<void> {
    try {
      const photoPicker = new photoViewPicker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: photoViewPicker.PhotoViewMIMETypes.IMAGE_TYPE,
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

  // 保存联系人
  async onSave(): Promise<void> {
    // 表单校验
    if (!this.contact.name || this.contact.name.trim() === '') {
      promptAction.showToast({ message: '请输入姓名' });
      return;
    }
    if (!this.contact.phone || this.contact.phone.trim() === '') {
      promptAction.showToast({ message: '请输入电话号码' });
      return;
    }

    // 电话号码格式简单校验（至少7位）
    const phone = this.contact.phone.trim();
    if (phone.length < 7) {
      promptAction.showToast({ message: '电话号码格式不正确' });
      return;
    }

    this.isSaving = true;

    try {
      // 修正空白字符
      this.contact.name = this.contact.name.trim();
      this.contact.phone = this.contact.phone.trim();
      this.contact.wechatId = this.contact.wechatId?.trim() ?? '';

      // 获取现有联系人列表
      const contacts = await StorageUtil.getContacts();

      if (this.isEditMode) {
        // 编辑模式：更新现有联系人
        const index = contacts.findIndex(c => c.id === this.contact.id);
        if (index !== -1) {
          contacts[index] = this.contact;
        }
      } else {
        // 添加模式：追加到列表末尾
        this.contact.position = contacts.length;
        contacts.push(this.contact);
      }

      await StorageUtil.saveContacts(contacts);
      promptAction.showToast({
        message: this.isEditMode ? '修改成功' : '添加成功'
      });

      // 返回上一页
      router.back();
    } catch (err) {
      console.error(`Failed to save contact: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isSaving = false;
    }
  }

  // 返回（未保存时提示）
  async onBack(): Promise<void> {
    const hasContent = this.contact.name || this.contact.phone || this.contact.photoUri;
    if (hasContent) {
      // 有内容，提示是否放弃
      router.back();
    } else {
      router.back();
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => this.onBack())

        Text(this.isEditMode ? '编辑联系人' : '添加联系人')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 10 })

        Blank()

        Text('保存')
          .fontSize(16)
          .fontColor('#FF9800')
          .onClick(() => this.onSave())
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: { bottom: '#E0E0E0' } })

      ScrollView() {
        Column() {
          // 头像选择
          Column() {
            if (this.contact.photoUri) {
              Image(this.contact.photoUri)
                .width(100)
                .height(100)
                .borderRadius(50)
                .border({ width: 3, color: '#FF9800' })
                .objectFit(ImageFit.Cover)
                .onClick(() => this.onSelectPhoto())
            } else {
              Column() {
                Text('📷')
                  .fontSize(40)
                  .fontColor('#CCCCCC')
                Text('点击选择照片')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
              .width(100)
              .height(100)
              .borderRadius(50)
              .backgroundColor('#F0F0F0')
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.onSelectPhoto())
            }

            Text('点击头像更换照片')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding({ top: 30, bottom: 30 })
          .justifyContent(FlexAlign.Center)

          // 表单区域
          Column() {
            // 姓名
            Column() {
              Text('姓名 *')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')

              TextInput({ text: this.contact.name, placeholder: '请输入联系人姓名' })
                .fontSize(18)
                .height(50)
                .width('100%')
                .backgroundColor('#F5F5F5')
                .borderRadius(12)
                .margin({ top: 8 })
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.contact.name = value;
                })
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 电话号码
            Column() {
              Text('电话号码 *')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')

              TextInput({ text: this.contact.phone, placeholder: '请输入手机号码' })
                .fontSize(18)
                .height(50)
                .width('100%')
                .type(InputType.PhoneNumber)
                .backgroundColor('#F5F5F5')
                .borderRadius(12)
                .margin({ top: 8 })
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.contact.phone = value;
                })
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 微信ID
            Column() {
              Text('微信ID（选填）')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')

              TextInput({ text: this.contact.wechatId, placeholder: '用于微信语音/视频通话' })
                .fontSize(18)
                .height(50)
                .width('100%')
                .backgroundColor('#F5F5F5')
                .borderRadius(12)
                .margin({ top: 8 })
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.contact.wechatId = value;
                })
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 提示说明
            Column() {
              Row() {
                Text('💡')
                  .fontSize(14)
                  .margin({ right: 8 })
                Text('带 * 的为必填项')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 10 })
            }
            .width('100%')
          }
          .width('90%')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
