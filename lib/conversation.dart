import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:fim/app.dart';
import 'package:fim/chat.dart';
import 'package:fim/entity/contact_data.dart';
import 'package:fim/entity/group_conversation.dart';
import 'package:fim/entity/personal_conversations.dart';
import 'package:fim/group_chat.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'copy_custom_pop_up_menu.dart';
import 'extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'entity/message.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      init: ConversationController(),
      // id: "conversation",
      builder: (_) => Scaffold(
        appBar: FiveCMAppbar(context,
            title: "会话",
            right: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // assetImage('ic_search',
                //         width: 24.h, height: 24.h, color: Color(0xFF333333))
                //     .intoPadding(
                //       padding: EdgeInsets.only(left: 10.w, right: 10.w),
                //     )
                //     .intoGesture(
                //       onTap: () => {},
                //     ),
                buildPop(context: context, ctrl: _._popupCtrl),
                SizedBox(width: 12.w),
              ],
            )),
        body: GetBuilder<AppController>(
            builder: (i) => Column(
                  children: [
                    Expanded(
                        child: SmartRefresher(
                      controller: _.refreshController,
                      enablePullDown: true,
                      header: ClassicHeader(
                        refreshStyle: RefreshStyle.Follow,
                        refreshingText: "刷新中",
                        completeText: "刷新完成",
                        idleText: "下拉刷新",
                        releaseText: "放开刷新",
                        failedText: "刷新失败",
                      ),
                      onRefresh: () {
                        i.updateConversation();
                        _.refreshController.refreshCompleted();
                      },
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                            return _.buildConversation(context, index, i, _);
                        },
                        itemCount: i.conversationList.length,
                      ),
                    ))
                  ],
                )),
      ),
    );
  }
}

class ConversationController extends GetxController {
  final _popupCtrl = CustomPopupMenuController();

  RefreshController refreshController = RefreshController();

  void toChatPage(v) {
    if(v is Contact){
      Get.delete<Contact?>(tag: "currentContact");
      Get.put<Contact?>(v, tag: "currentContact");
      Get.to(() => ChatPage());
    }
    if(v is Group){
      Get.delete<Group?>(tag: "currentGroup");
      Get.put<Group?>(v, tag: "currentGroup");
      Get.to(() => GroupChatPage());
    }
  }

  Widget buildConversation(BuildContext context, int index, AppController i, ConversationController _){
    final c = i.conversationList[index];
    if (c.type == ConversationType.PERSONAL) {
      return buildPersonalConversation(context, index, i, _);
    }else{
       return buildGroupConversation(context, index, i, _);
    }
  }

  Widget buildPersonalConversation(BuildContext context, int index, AppController i, ConversationController _) {
    final c = i.conversationList[index];
    PersonalConversation? item;
    List<Message>? l;
    var content='';
    if (c.type == ConversationType.PERSONAL) {
      item = i.conversationList[index] as PersonalConversation;
      l = i.messageMap[item.contact!.uid];
      if(l!.length > 0){
        if(l.first.messageType==MessageType.TEXT_MESSAGE){
          content=l.first.msg.content;
        }else if(l.first.messageType==MessageType.IMAGE_MESSAGE){
          content="图片";
        }
      }
    }
    var pkey = GlobalKey<PopupMenuButtonState>();
    return ListTile(
        onTap: () {
          _.toChatPage(item!.contact);
        },
        onLongPress: () {
          pkey.currentState!.showButtonMenu();
        },
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4.0),
              image: DecorationImage(
                  image: Image(
                    image: CachedNetworkImageProvider(item!.contact!.avatar!),
                    height: 36,
                    width: 36,
                  ).image,
                  fit: BoxFit.fill)),
        ),
        title: Text("${item.contact!.name}"),
        subtitle: Text("$content"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "${formatDate(DateTime.fromMillisecondsSinceEpoch(l!.length > 0 ? l[0].msg.timestamp : 0, isUtc: true).add(new Duration(hours: 8)), [
                  mm,
                  '-',
                  dd,
                  ' ',
                  HH,
                  ':',
                  nn,
                  ':',
                  ss
                ])}"),
            PopupMenuButton<int>(
              iconSize: 15,
              key: pkey,
              onSelected: (value) {
                if (value == 0) {
                  Get.snackbar("", "删除会话${item!.cid}");
                }
              },
              itemBuilder: (context) {
                return <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text('删除会话'),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('置顶会话'),
                  ),
                ];
              },
            ),
          ],
        ));
  }

  Widget buildGroupConversation(BuildContext context, int index,AppController i, ConversationController _) {
    final c = i.conversationList[index];
    GroupConversation? item;
    List<Message>? l;
    var content='';
    if (c.type == ConversationType.GROUP) {
      item = i.conversationList[index] as GroupConversation;
      l = i.groupMessageMap[item.group!.gid];
      if(l!.length > 0){
        if(l.first.messageType==MessageType.TEXT_MESSAGE){
          content=l.first.msg.content;
        }else if(l.first.messageType==MessageType.IMAGE_MESSAGE){
          content="图片";
        }
      }
    }
    var pkey = GlobalKey<PopupMenuButtonState>();
    return ListTile(
        onTap: () {
          _.toChatPage(item!.group);
        },
        onLongPress: () {
          pkey.currentState!.showButtonMenu();
        },
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4.0),
              image: DecorationImage(
                  image: Image(
                    image: CachedNetworkImageProvider("https://edu-codedawn.oss-cn-shenzhen.aliyuncs.com/images/2021/09/08/16311019919296332.jpg"),
                    height: 36,
                    width: 36,
                  ).image,
                  fit: BoxFit.fill)),
        ),
        title: Text("${item!.group!.groupName}"),
        subtitle: Text('${content}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "${formatDate(DateTime.fromMillisecondsSinceEpoch(l!.length > 0 ? l[0].msg.timestamp : 0, isUtc: true).add(new Duration(hours: 8)), [
                  mm,
                  '-',
                  dd,
                  ' ',
                  HH,
                  ':',
                  nn,
                  ':',
                  ss
                ])}"),
            PopupMenuButton<int>(
              iconSize: 15,
              key: pkey,
              onSelected: (value) {
                if (value == 0) {
                  Get.snackbar("", "删除会话${item!.cid}");
                }
              },
              itemBuilder: (context) {
                return <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text('删除会话'),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('置顶会话'),
                  ),
                ];
              },
            ),
          ],
        ));
  }
}

class Conversation {
  ConversationType type = ConversationType.PERSONAL;

  Conversation();
}

enum ConversationType {
  PERSONAL,
  GROUP,
}
