
import 'contact_data.dart';

class AddContactInfo{
  int flag;//0是可以添加，1是已经发送添加请求，2是已经是好友
  Contact contact;

  AddContactInfo(this.flag, this.contact);
}


class NewContactInfo{
  int flag;//1是已经同意，2是已经拒绝，0是未操作
  int nid;
  Contact contact;

  NewContactInfo(this.flag,this.nid, this.contact);
}