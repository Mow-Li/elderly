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

  onAddContact(): void {
    router.pushUrl({ url: 'pages/ContactEdit' });
  }

  onEditContact(contact: Contact): void {
    router.pushUrl({
      url: 'pages/ContactEdit',
      params: { contact: contact }
    });
  }

  async onDeleteContact(contact: Contact): Promise<void> {
    const index = this.contacts.findIndex(c => c.id === contact.id);
    if (index !== -1) {
      this.contacts.splice(index, 1);
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
          .fontSize(22)
          .fontColor('#303133')
          .onClick(() => router.back())

        Text('联系人管理')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 8 })

        Blank()

        Text('添加')
          .fontSize(15)
          .fontColor('#409EFF')
          .onClick(() => this.onAddContact())
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: { bottom: '#F2F4F7' } })

      if (this.contacts.length === 0) {
        Column() {
          Text('暂无联系人')
            .fontSize(16)
            .fontColor('#909399')
            .margin({ top: 100 })

          Button('添加联系人')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#409EFF')
            .borderRadius(20)
            .padding({ left: 28, right: 28, top: 10, bottom: 10 })
            .margin({ top: 16 })
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
                    .width(52)
                    .height(52)
                    .borderRadius(26)
                    .objectFit(ImageFit.Cover)
                    .border({ width: 2, color: '#409EFF' })
                } else {
                  Column() {
                    Text(contact.name.charAt(0))
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                  }
                  .width(52)
                  .height(52)
                  .borderRadius(26)
                  .backgroundColor('#409EFF')
                  .justifyContent(FlexAlign.Center)
                }

                // 信息
                Column() {
                  Text(contact.name)
                    .fontSize(16)
                    .fontColor('#1A1A1A')

                  Text(contact.phone)
                    .fontSize(13)
                    .fontColor('#909399')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 14 })
                .layoutWeight(1)

                // 操作按钮
                Row({ space: 10 }) {
                  Button('编辑')
                    .fontSize(13)
                    .fontColor('#409EFF')
                    .backgroundColor('#EBF5FF')
                    .borderRadius(14)
                    .height(30)
                    .padding({ left: 14, right: 14 })
                    .onClick(() => this.onEditContact(contact))

                  Button('删除')
                    .fontSize(13)
                    .fontColor('#F56C6C')
                    .backgroundColor('#FEF0F0')
                    .borderRadius(14)
                    .height(30)
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
        .backgroundColor('#F2F4F7')
        .divider({ strokeWidth: 1, color: '#F2F4F7' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
