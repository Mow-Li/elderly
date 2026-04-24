/**
 * 联系人管理页面
 */
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Contact } from '../models/Contact';
import { StorageUtil } from '../utils/StorageUtil';
@Entry
@Component
export struct ContactManage {
  @State contacts: Contact[] = [];
  @State showEditDialog: boolean = false;
  @State editingContact: Contact = new Contact();
  @State isEditMode: boolean = false;

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await StorageUtil.init(context);
    await this.loadContacts();
  }

  async loadContacts(): Promise<void> {
    this.contacts = await StorageUtil.getContacts();
  }

  // 添加联系人
  onAddContact(): void {
    this.editingContact = new Contact();
    this.editingContact.id = Date.now().toString();
    this.editingContact.position = this.contacts.length;
    this.isEditMode = false;
    this.showEditDialog = true;
  }

  // 编辑联系人
  onEditContact(contact: Contact): void {
    this.editingContact = new Contact();
    this.editingContact.id = contact.id;
    this.editingContact.name = contact.name;
    this.editingContact.photoUri = contact.photoUri;
    this.editingContact.phone = contact.phone;
    this.editingContact.wechatId = contact.wechatId;
    this.editingContact.position = contact.position;
    this.isEditMode = true;
    this.showEditDialog = true;
  }

  // 删除联系人
  async onDeleteContact(contact: Contact): Promise<void> {
    const index = this.contacts.findIndex(c => c.id === contact.id);
    if (index !== -1) {
      this.contacts.splice(index, 1);
      // 重新排序位置
      this.contacts.forEach((c, i) => c.position = i);
      await StorageUtil.saveContacts(this.contacts);
    }
  }

  // 保存联系人
  async onSaveContact(): Promise<void> {
    if (!this.editingContact.name || !this.editingContact.phone) {
      return;
    }

    if (this.isEditMode) {
      const index = this.contacts.findIndex(c => c.id === this.editingContact.id);
      if (index !== -1) {
        this.contacts[index] = this.editingContact;
      }
    } else {
      this.contacts.push(this.editingContact);
    }

    await StorageUtil.saveContacts(this.contacts);
    this.showEditDialog = false;
    await this.loadContacts();
  }

  // 选择照片（待实现）
  onSelectPhoto(): void {
    // TODO: 实现照片选择
    promptAction.showToast({ message: '照片选择待实现' });
  }

  build() {
    Stack() {
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

        // 联系人列表
        if (this.contacts.length === 0) {
          Column() {
            Text('还没有联系人')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 100 })

            Button('添加联系人')
              .fontSize(16)
              .backgroundColor('#FF9800')
              .borderRadius(25)
              .padding({ left: 30, right: 30, top: 10, bottom: 10 })
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
                      .width(55)
                      .height(55)
                      .borderRadius(28)
                      .objectFit(ImageFit.Cover)
                  } else {
                    Text(contact.name.charAt(0))
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .width(55)
                      .height(55)
                      .borderRadius(28)
                      .backgroundColor('#FF9800')
                      .textAlign(TextAlign.Center)
                  }

                  // 信息
                  Column() {
                    Text(contact.name)
                      .fontSize(18)
                      .fontColor('#333333')

                    Text(contact.phone)
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 15 })
                  .layoutWeight(1)

                  // 操作
                  Row({ space: 15 }) {
                    Text('编辑')
                      .fontSize(14)
                      .fontColor('#FF9800')
                      .onClick(() => this.onEditContact(contact))

                    Text('删除')
                      .fontSize(14)
                      .fontColor('#FF5722')
                      .onClick(() => this.onDeleteContact(contact))
                  }
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor('#FFFFFF')
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .divider({ strokeWidth: 1, color: '#E0E0E0' })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 编辑弹窗
      if (this.showEditDialog) {
        this.EditDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  EditDialog() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showEditDialog = false;
        })

      Column() {
        Text(this.isEditMode ? '编辑联系人' : '添加联系人')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 20 })

        // 照片选择
        Column() {
          if (this.editingContact.photoUri) {
            Image(this.editingContact.photoUri)
              .width(90)
              .height(90)
              .borderRadius(45)
              .border({ width: 3, color: '#FF9800' })
              .onClick(() => this.onSelectPhoto())
          } else {
            Column() {
              Text('📷')
                .fontSize(36)
                .fontColor('#CCCCCC')
              Text('选择照片')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 6 })
            }
            .width(90)
            .height(90)
            .borderRadius(45)
            .backgroundColor('#F5F5F5')
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onSelectPhoto())
          }
        }
        .margin({ top: 20 })

        // 姓名输入
        Column() {
          Text('姓名')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')

          TextInput({ text: this.editingContact.name, placeholder: '请输入姓名' })
            .fontSize(16)
            .height(45)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ top: 6 })
            .onChange((value: string) => {
              this.editingContact.name = value;
            })
        }
        .width('85%')
        .margin({ top: 20 })

        // 电话输入
        Column() {
          Text('电话号码')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')

          TextInput({ text: this.editingContact.phone, placeholder: '请输入电话号码' })
            .fontSize(16)
            .height(45)
            .type(InputType.PhoneNumber)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ top: 6 })
            .onChange((value: string) => {
              this.editingContact.phone = value;
            })
        }
        .width('85%')
        .margin({ top: 15 })

        // 微信ID（可选）
        Column() {
          Text('微信ID（可选）')
            .fontSize(14)
            .fontColor('#999999')
            .width('100%')

          TextInput({ text: this.editingContact.wechatId, placeholder: '请输入微信ID' })
            .fontSize(16)
            .height(45)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ top: 6 })
            .onChange((value: string) => {
              this.editingContact.wechatId = value;
            })
        }
        .width('85%')
        .margin({ top: 15 })

        // 按钮
        Row({ space: 15 }) {
          Button('取消')
            .width('40%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .borderRadius(24)
            .onClick(() => {
              this.showEditDialog = false;
            })

          Button('保存')
            .width('40%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#FF9800')
            .fontColor('#FFFFFF')
            .borderRadius(24)
            .onClick(() => this.onSaveContact())
        }
        .margin({ top: 30, bottom: 25 })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .margin({ top: '10%' })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}
