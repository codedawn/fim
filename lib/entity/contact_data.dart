import 'package:azlistview/azlistview.dart';

///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class Contact {
/*
{
  "uid": 7,
  "name": "ret",
  "account": "1234",
  "password": null
}
*/

  int? uid;
  String? name;
  String? account;
  String? password;
  String? avatar;

  Contact({
    this.uid,
    this.name,
    this.account,
    this.password,
    this.avatar
  });
  Contact.fromJson(Map<String, dynamic> json) {
    uid = json["uid"]?.toInt();
    name = json["name"]?.toString();
    account = json["account"]?.toString();
    password = json["password"]?.toString();
    avatar = json["avatar"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["uid"] = uid;
    data["name"] = name;
    data["account"] = account;
    data["password"] = password;
    data["avatar"] = avatar;
    return data;
  }
}

class ContactWrapper extends ISuspensionBean{
/*
{
  "coid": 1,
  "contact": {
    "uid": 7,
    "name": "ret",
    "account": "1234",
    "password": null
  }
}
*/

  int? coid;
  Contact? contact;

  ContactWrapper({
    this.coid,
    this.contact,
  });
  ContactWrapper.fromJson(Map<String, dynamic> json) {
    coid = json["coid"]?.toInt();
    contact = (json["contact"] != null) ? Contact.fromJson(json["contact"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["coid"] = coid;
    if (contact != null) {
      data["contact"] = contact!.toJson();
    }
    return data;
  }

  @override
  String getSuspensionTag() {
    return "A";
  }
}

class ContactData {
/*
{
  "contactList": [
    {
      "coid": 1,
      "contact": {
        "uid": 7,
        "name": "ret",
        "account": "1234",
        "password": null
      }
    }
  ]
}
*/

  List<ContactWrapper?>? contactList;

  ContactData({
    this.contactList,
  });
  ContactData.fromJson(Map<String, dynamic> json) {
    if (json["contactList"] != null) {
      final v = json["contactList"];
      final arr0 = <ContactWrapper>[];
      v.forEach((v) {
        arr0.add(ContactWrapper.fromJson(v));
      });
      contactList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (contactList != null) {
      final v = contactList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["contactList"] = arr0;
    }
    return data;
  }
}
