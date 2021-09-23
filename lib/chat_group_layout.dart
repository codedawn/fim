import 'package:bubble/bubble.dart';
import 'package:fim/chat_single_layout.dart';
import 'package:fim/entity/contact_data.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_avatar_view.dart';
import 'entity/group_conversation.dart';
import 'entity/message.dart';
import 'entity/personal_conversations.dart';
import 'entity/user.dart';

class ChatGroupLayout extends StatelessWidget with layout{
  const ChatGroupLayout(this.message, {Key? key}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatGroupLayoutController>(
        init: ChatGroupLayoutController(),
        builder: (_) {
          final l = _.group!.groupMember;
          Contact? contact;
          for (var i in l!) {
            if (i!.uid == message.msg.fromId) {
              contact = i;
            }
          }
          return Row(
            mainAxisAlignment: _.user.uid != message.msg.fromId
                ? MainAxisAlignment.start
                : MainAxisAlignment.end, //当前用户是消息的发送者就在左边
            children: [
              buildAvatar(
                contact!.avatar,
                _.user.uid != message.msg.fromId, //当前用户不是消息的发送者，就显示为对方发送
                onTap: () {},
                onLongPress: () {},
              ),
              buildSendFailView(
                false,
                fail: false,
              ),
              Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: _.user.uid != message.msg.fromId
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 11.w,
                      ),
                      Text(
                        "${contact.name}",
                      ),SizedBox(
                        width: 11.w,
                      ),
                    ],
                  ),
                  // Align(child: ,alignment: Alignment.center,),
                  Bubble(
                    margin: BubbleEdges.only(
                      left: true ? 4.w : 0,
                      right: false ? 0 : 4.w,
                    ),
                    // alignment: Alignment.topRight,
                    nip: _.user.uid != message.msg.fromId
                        ? BubbleNip.leftCenter
                        : BubbleNip.rightCenter,
                    color: Color.fromRGBO(225, 255, 199, 1.0),
                    child: InkWell(
                      child: buildContent(message),
                      onTap: () => {},
                    ),
                  )
                ],
              ),
              buildAvatar(
                _.user.avatar,
                (_.user.uid == message.msg.fromId), //当前用户是消息的发送者，就显示为当前用户发送
                onTap: () {},
                onLongPress: () {},
              ),
            ],
          );
        });
  }


}

class ChatGroupLayoutController extends GetxController {
  Group? group = Get.find(tag: "currentGroup");
  User user = Get.find();
}
