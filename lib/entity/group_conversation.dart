import 'package:fim/conversation.dart';
import 'package:fim/entity/contact_data.dart';



class Group {
/*
{
  "gid": 1,
  "groupName": "急急急",
  "createTime": 1631154887138,
  "ownerId": 1,
  "groupMember": [
    {
      "uid": 1,
      "name": "ltm",
      "account": "123",
      "password": null,
      "avatar": "https://edu-codedawn.oss-cn-shenzhen.aliyuncs.com/images/2021/09/08/16311019919296332.jpg"
    }
  ]
}
*/

  int? gid;
  String? groupName;
  int? createTime;
  int? ownerId;
  List<Contact?>? groupMember;

  Group({
    this.gid,
    this.groupName,
    this.createTime,
    this.ownerId,
    this.groupMember,
  });
  Group.fromJson(Map<String, dynamic> json) {
    gid = json["gid"]?.toInt();
    groupName = json["groupName"]?.toString();
    createTime = json["createTime"]?.toInt();
    ownerId = json["ownerId"]?.toInt();
    if (json["groupMember"] != null) {
      final v = json["groupMember"];
      final arr0 = <Contact>[];
      v.forEach((v) {
        arr0.add(Contact.fromJson(v));
      });
      groupMember = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["gid"] = gid;
    data["groupName"] = groupName;
    data["createTime"] = createTime;
    data["ownerId"] = ownerId;
    if (groupMember != null) {
      final v = groupMember;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["groupMember"] = arr0;
    }
    return data;
  }
}

class GroupConversation extends Conversation{
/*
{
  "cid": 1,
  "group": {
    "gid": 1,
    "groupName": "急急急",
    "createTime": 1631154887138,
    "ownerId": 1,
    "groupMember": [
      {
        "uid": 1,
        "name": "ltm",
        "account": "123",
        "password": null,
        "avatar": "https://edu-codedawn.oss-cn-shenzhen.aliyuncs.com/images/2021/09/08/16311019919296332.jpg"
      }
    ]
  }
}
*/

  int? cid;
  Group? group;

  GroupConversation({
    this.cid,
    this.group,
  });
  GroupConversation.fromJson(Map<String, dynamic> json) {
    cid = json["cid"]?.toInt();
    group = (json["group"] != null) ? Group.fromJson(json["group"]) : null;
    type=ConversationType.GROUP;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["cid"] = cid;
    if (group != null) {
      data["group"] = group!.toJson();
    }
    return data;
  }
}
