import 'package:dio/dio.dart';
import 'package:fim/account.dart';
import 'package:fim/contact.dart';
import 'package:fim/conversation.dart';
import 'package:fim/entity/group_conversation.dart';
import 'package:fim/entity/personal_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart' hide FormData;
import 'entity/contact_data.dart';
import 'entity/message.dart';
import 'entity/personal_conversations.dart';
import 'entity/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(
        init: HomeController(),
        builder:(_) {return Center(
          child: Scaffold(
            // appBar: AppBar(
            //   title: Text("Five CM"),
            // ),
            body:PageView(
              controller: _.pageController,
              onPageChanged: (index){
                _.setIndex(index);
              },
              children: [
                _.conversationPage,
                _.contactPage,
                _.accountPage
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _.bottomBarIndex,
              onTap: (index){
              _.pageController.jumpToPage(index);
              // _.bottomBarIndex.value=index;
              // _.setIndex(index);
              print(_.bottomBarIndex);

            },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home),label: "首页"),
                BottomNavigationBarItem(icon: Icon(Icons.contact_page),label: "联系人"),
                BottomNavigationBarItem(icon: Icon(Icons.perm_identity),label: "账号"),
              ],
            ),
          ),
        );},
    );
  }
}
class HomeController extends GetxController{
//底部导航栏索引
  var bottomBarIndex = 0;
  final  pageController=PageController(initialPage: 0);

  final conversationPage=ConversationPage();
  final contactPage=ContactPage();
  final accountPage=AccountPage();

  void setIndex(index){
    bottomBarIndex=index;
    update();
  }

}

class AppController extends GetxController {

  //会话
  final conversationList=Get.put(<Conversation>[]);

  final messageMap=Get.put(Map<int,List<Message>>(),tag: "messageMap");

  final groupMessageMap=Get.put(Map<int,List<Message>>(),tag: "groupMessageMap");

  final contactList=Get.put(<ContactWrapper>[]);

  static AppController get to =>Get.find();

  User user=Get.find();
  Dio dio = Get.find();


  AppController()  {
   init();
  }

  void clear(){
    Get.delete<AppController>();
    Get.delete<List<Conversation>>();
    Get.delete<List<ContactWrapper>>();
    Get.delete<Map<String,List<Message>>>(tag: "messageMap");
    Get.delete<Map<String,List<Message>>>(tag: "groupMessageMap");
  }

  Future<void> init() async {

    Get.put(ContactController());

    updateConversation();

    // update(["conversation"]);
    // update();
  }

  Future<void> updateConversation() async {
    //获取聊天会话
    var perConResponse=await dio.get("/pconversation/${user.uid}");
    if(perConResponse.data["succeed"]==false)return;
    var p=PersonalConversationData.fromJson(perConResponse.data["data"]);

    var groConResponse=await dio.get("/getGroupConversation?uid=${user.uid}");
    if(groConResponse.data["succeed"]==false)return;
    final groupConversationList=<GroupConversation>[];
    if(groConResponse.data["data"]["groupConversationList"]!=null){
      final g=groConResponse.data["data"]["groupConversationList"];
      g.forEach((v){
        groupConversationList.add(GroupConversation.fromJson(v));
      });
    }

    conversationList.clear();
    messageMap.clear();
    groupMessageMap.clear();
    conversationList.addAll(p.personalConversations as List<Conversation>);
    conversationList.addAll(groupConversationList);
    for(var i in p.personalConversations!){
      // FormData formData = FormData.fromMap({"fromId": user.uid, "toId": i!.contact!.uid});
      //获取聊天消息
      var perMsgResponse=await dio.get("/getPersonalMessage?fromId=${user.uid}&toId=${i!.contact!.uid}");
      final v = perMsgResponse.data["data"]["personalMessageList"];
      final arr0 = <Message>[];
      v.forEach((v) {
        var p= PGMessage.fromJson(v);
        Message? m;
        if(p.messageType=='textMessage'){
          m=Message(MessageType.TEXT_MESSAGE,p);
        }else if(p.messageType=='imageMessage'){
          m=Message(MessageType.IMAGE_MESSAGE,p);
        }
        arr0.add(m!);
      });
      messageMap.putIfAbsent(i.contact!.uid!, () => arr0);
    }

    for(var i in groupConversationList){
      //获取群聊天消息
      var groupMsgResponse=await dio.get("/getGroupMessage?fromId=${user.uid}&toId=${i.group!.gid}");
      final v = groupMsgResponse.data["data"]["groupMessageList"];
      final arr0 = <Message>[];
      v.forEach((v) {
        var p= PGMessage.fromJson(v);
        Message? m;
        if(p.messageType=='textMessage'){
          m=Message(MessageType.TEXT_MESSAGE,p);
        }else if(p.messageType=='imageMessage'){
          m=Message(MessageType.IMAGE_MESSAGE,p);
        }
        arr0.add(m!);
      });
      groupMessageMap.putIfAbsent(i.group!.gid!, () => arr0);
    }
    update();
  }

  void addMessage(int contactId,Message message) {
    List<Message> messageList=messageMap.putIfAbsent(contactId, () => <Message>[]);
    // messageList.add(message);
    messageList.insert(0,message);
    Get.snackbar("收到来自${message.msg.fromId}的消息", message.msg.messageType);
    update();
    // update(["conversation","chat"]);

  }

  void addGroupMessage(int contactId,Message message) {
    List<Message> messageList=groupMessageMap.putIfAbsent(contactId, () => <Message>[]);
    // messageList.add(message);
    messageList.insert(0,message);
    Get.snackbar("收到来自${message.msg.fromId}的消息", message.msg.messageType);
    update();
    // update(["conversation","chat"]);

  }


  Future<void> joinGroup(gid) async {
    var jResponse=await dio.get("/joinGroup?gid=${gid}&uid=${user.uid}");
    if(jResponse.data["succeed"]==true){
      EasyLoading.showInfo("加入群号：${gid}，成功");
    }else{
      EasyLoading.showError("加入群号：${gid}，失败");
    }
  }



}
