import 'package:fim/chat_group_layout.dart';
import 'package:fim/entity/message.dart';

import 'chat_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMsgView extends StatelessWidget {
  const ChatMsgView(this.message,this.isGroup,{Key? key, }) : super(key: key);

  final Message message;
  final bool isGroup;


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatMsgViewController>(
        init: ChatMsgViewController(),
        builder: (_) {
          return _.buildChatLayout(isGroup, message);
        });
  }
}

class ChatMsgViewController extends GetxController {

    Widget buildChatLayout(bool isGroup,Message message){
      if(!isGroup){
        return  ChatSingleLayout(message);
      }else{
        return  ChatGroupLayout(message);
      }
    }
}
