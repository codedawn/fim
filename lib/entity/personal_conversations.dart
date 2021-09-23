import 'package:fim/conversation.dart';
import 'package:fim/entity/contact_data.dart';



class PersonalConversation extends Conversation{
/*
{
  "cid": 1,
  "contact": {
    "uid": 7,
    "name": "ret",
    "account": "1234",
    "password": null
  }
}
*/

  int? cid;
  Contact? contact;

  PersonalConversation({
    this.cid,
    this.contact,
  });
  PersonalConversation.fromJson(Map<String, dynamic> json) {
    cid = json["cid"]?.toInt();
    contact = (json["contact"] != null) ? Contact.fromJson(json["contact"]) : null;
    type=ConversationType.PERSONAL;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["cid"] = cid;
    if (contact != null) {
      data["contact"] = contact!.toJson();
    }
    return data;
  }
}

class PersonalConversationData {
/*
{
  "personalConversations": [
    {
      "cid": 1,
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

  List<PersonalConversation?>? personalConversations;

  PersonalConversationData({
    this.personalConversations,
  });
  PersonalConversationData.fromJson(Map<String, dynamic> json) {
    if (json["personalConversations"] != null) {
      final v = json["personalConversations"];
      final arr0 = <PersonalConversation>[];
      v.forEach((v) {
        arr0.add(PersonalConversation.fromJson(v));
      });
      personalConversations = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (personalConversations != null) {
      final v = personalConversations;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["personalConversations"] = arr0;
    }
    return data;
  }
}
