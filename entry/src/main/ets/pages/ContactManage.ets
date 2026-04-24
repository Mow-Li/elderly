/**
 * 联系人管理页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { Contact } from '../models/Contact';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
export struct ContactManage {
  @State contacts: Contact[] = [];

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    await this.loadContacts();
  }

  async loadContacts(): Promise<void> {
    this.contacts = await StorageUtil.getContacts();
  }

  // 添加联系人 → 跳转到编辑页面
  onAddContact(): void {
    router.pushUrl({ url: 'pages/ContactEdit' });
  }

  // 编辑联系人 → 跳转到编辑页面（携带数据）
  onEditContact(contact: Contact): void {
    router.pushUrl({
      url: 'pages/ContactEdit',
      params: { contact: contact }
    });
  }

  // 删除联系人
  async onDeleteContact(contact: Contact): Promise<void> {
    const index = this.contacts.findIndex(c => c.id === contact.id);
    if (index !== -1) {
      this.contacts.splice(index, 1);
      // 重新排序位置
      this.contacts.forEach((c, i) => c.position = i);
      await StorageUtil.saveContacts(this.contacts);
      await this.loadContacts();
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => router.back())

        Text('联系人管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 10 })

        Blank()

        Text('添加')
          .fontSize(16)
          .fontColor('#FF9800')
          .onClick(() => this.onAddContact())
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: { bottom: '#E0E0E0' } })

      // 联系人列表
      if (this.contacts.length === 0) {
        Column() {
          Text('还没有联系人')
            .fontSize(18)
            .fontColor('#999999')
            .margin({ top: 100 })

          Button('添加联系人')
            .fontSize(16)
            .backgroundColor('#FF9800')
            .fontColor('#FFFFFF')
            .borderRadius(25)
            .padding({ left: 30, right: 30, top: 12, bottom: 12 })
            .margin({ top: 20 })
            .onClick(() => this.onAddContact())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.contacts, (contact: Contact) => {
            ListItem() {
              Row() {
                // 头像
                if (contact.photoUri) {
                  Image(contact.photoUri)
                    .width(60)
                    .height(60)
                    .borderRadius(30)
                    .objectFit(ImageFit.Cover)
                    .border({ width: 2, color: '#FF9800' })
                } else {
                  Text(contact.name.charAt(0))
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .width(60)
                    .height(60)
                    .borderRadius(30)
                    .backgroundColor('#FF9800')
                    .textAlign(TextAlign.Center)
                }

                // 信息
                Column() {
                  Text(contact.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')

                  Text(contact.phone)
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 15 })
                .layoutWeight(1)

                // 操作按钮
                Row({ space: 12 }) {
                  Button('编辑')
                    .fontSize(14)
                    .fontColor('#FF9800')
                    .backgroundColor('#FFF5EB')
                    .borderRadius(16)
                    .height(32)
                    .padding({ left: 14, right: 14 })
                    .onClick(() => this.onEditContact(contact))

                  Button('删除')
                    .fontSize(14)
                    .fontColor('#FF5722')
                    .backgroundColor('#FFF0EB')
                    .borderRadius(16)
                    .height(32)
                    .padding({ left: 14, right: 14 })
                    .onClick(() => this.onDeleteContact(contact))
                }
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
