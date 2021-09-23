import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fim/entity/contact_data.dart';
import 'package:fim/image_view.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:octo_image/octo_image.dart';
import 'chat_avatar_view.dart';
import 'entity/message.dart';
import 'entity/personal_conversations.dart';
import 'entity/user.dart';
import 'extensions.dart';

class ChatSingleLayout extends StatelessWidget with layout{
  const ChatSingleLayout(this.message,{Key? key}) : super(key: key);

  final Message message;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatSingleLayoutController>(
        init: ChatSingleLayoutController(),
        builder: (_) {
          return Row(
            mainAxisAlignment:
                _.user.uid!=message.msg.fromId ? MainAxisAlignment.start : MainAxisAlignment.end,//当前用户是消息的发送者就在左边
            children: [
              buildAvatar(
                _.contact!.avatar,
                _.user.uid!=message.msg.fromId,//当前用户不是消息的发送者，就显示为对方发送
                onTap: () {},
                onLongPress: () {},
              ),
              buildSendFailView(
                false,
                fail: false,
              ),
              Bubble(
                margin: BubbleEdges.only(
                  left: true ? 4.w : 0,
                  right: false ? 0 : 4.w,
                ),
                // alignment: Alignment.topRight,
                nip: _.user.uid!=message.msg.fromId?BubbleNip.leftCenter:BubbleNip.rightCenter,
                color: Color.fromRGBO(225, 255, 199, 1.0),
                child: InkWell(
                  child: buildContent(message),
                  onTap: () => {},
                ),
              ),
              buildAvatar(
                _.user.avatar,
                (_.user.uid==message.msg.fromId),//当前用户是消息的发送者，就显示为当前用户发送
                onTap: () {},
                onLongPress: () {},
              ),
            ],
          );
        });
  }


}

class ChatSingleLayoutController extends GetxController {
  Contact? contact = Get.find(tag: "currentContact");
  User user=Get.find();
}

class layout{
  Widget buildContent(Message message){
    if(message.messageType==MessageType.TEXT_MESSAGE){
      return buildText(message);
    }else if(message.messageType==MessageType.IMAGE_MESSAGE){
      return buildImage(message);
    }
    return Container();
  }
  Widget buildImage(Message message){
    return OctoImage(
      image: CachedNetworkImageProvider(message.msg.url,maxWidth: 120.w.toInt(),),
      progressIndicatorBuilder: OctoProgressIndicator.circularProgressIndicator(),
    ).intoGesture(onTap: (){
      Get.to(()=>ImageViewPage(url: message.msg.url,));
    });
  }
  Widget buildText(Message message) => Container(
    constraints: BoxConstraints(
      maxWidth: 0.5.sw,
    ),
    child: Text(
      message.msg.content,
      textAlign: true ? TextAlign.left : TextAlign.right,
      softWrap: true,
      style: TextStyle(
        color: Color(0xFF333333),
        fontSize: 16.sp,
      ),
    ),
  );


  Widget buildAvatar(
      String? url,
      bool show, {
        final Function()? onTap,
        final Function()? onLongPress,
      }) =>
      ChatAvatarView(
        url: url,
        visible: show,
        onTap: onTap,
        onLongPress: onLongPress,
      );

  Widget buildSendFailView(bool show, {bool fail = false}) => Visibility(
    visible: show && fail,
    child: assetImage('ic_msg_error'),
  );
}