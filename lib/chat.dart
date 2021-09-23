
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:fim/app.dart';
import 'package:fim/entity/android_method.dart';
import 'package:fim/entity/contact_data.dart';
import 'package:fim/entity/message.dart';
import 'package:fim/entity/personal_conversations.dart';
import 'package:fim/entity/personal_message.dart';
import 'package:fim/entity/user.dart';
import 'package:fim/qr.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'chat_msg_view.dart';
import 'utils.dart';
import 'extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
        init: ChatController(),
        builder: (_) => Scaffold(
              appBar: FiveCMAppbar(
                context,
                title: "${_.contact!.name}",
                right: assetImage('ic_more', width: 28.h)
                    .intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        height: double.infinity)
                    .intoGesture(onTap: () {
                  // Get.to(()=>QRPage());
                }),
                back: true,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: GetBuilder<AppController>(
                      // id: "chat",
                      builder: (i) => SmartRefresher(
                        controller: _.refreshController,
                        enablePullDown: false,
                        reverse: true,
                        onLoading: () {
                          _.getMoreMessage();
                          _.refreshController.loadComplete();
                        },
                        footer: CustomFooter(
                          loadStyle: LoadStyle.ShowAlways,
                          builder: (context, mode) {
                            if (mode == LoadStatus.loading) {
                              return Container(
                                height: 60.0,
                                child: Container(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            } else
                              return Container();
                          },
                        ),
                        enablePullUp: true,
                        child: ListView.builder(
                            reverse: true,
                            // shrinkWrap: true,
                            controller: _.autoScrollController,
                            padding: EdgeInsets.only(left: 22.w, right: 22.w),
                            itemCount: i.messageMap[_.contact!.uid]!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: _.autoScrollController,
                                  index: index,
                                  child: ChatMsgView(
                                          i.messageMap[_.contact!.uid]![index],
                                          false)
                                      .intoContainer(
                                    padding: EdgeInsets.only(
                                        top: 10.h, bottom: 10.h),
                                  ));
                            }),
                      ),
                    ),
                  ),
                  ChatInputView()
                ],
              ),
            ));
  }
}

class ChatController extends GetxController {
  Contact? contact = Get.find(tag: "currentContact");
  AutoScrollController autoScrollController = Get.put(AutoScrollController());
  AppController appController = Get.find();
  RefreshController refreshController = RefreshController();
  User user = Get.find();
  Dio dio = Get.find();

  ChatController() {
    // autoScrollController.scrollToIndex(list!.length-1,preferPosition: AutoScrollPosition.end);
    autoScrollController.scrollToIndex(0,
        preferPosition: AutoScrollPosition.end);
  }

  Future<void> getMoreMessage() async {
    var l = appController.messageMap[contact!.uid];
    var perMsgResponse = await dio.get(
        "/getMorePersonalMessage?fromId=${user.uid}&toId=${contact!.uid}&timestamp=${l!.length > 0 ? l.last.msg.timestamp : DateTime.now().millisecondsSinceEpoch}");
    final v = perMsgResponse.data["data"]["morePersonalMessageList"];
    final arr0 = <Message>[];
    if (v == null) return;
    v.forEach((v) {
      arr0.add(Message(MessageType.TEXT_MESSAGE, PGMessage.fromJson(v)));
    });
    appController.messageMap[contact!.uid]!.addAll(arr0);
    update();
  }
}

class ChatInputView extends StatelessWidget {
  const ChatInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatInputViewController>(
        init: ChatInputViewController(),
        builder: (_) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F2FF),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000).withOpacity(0.12),
                      offset: Offset(0, -1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    assetImage('ic_speak').intoGesture(
                      onTap: () {},
                    ),
                    ExtendedTextField(
                      controller: _.textEditingController,
                      autofocus: false,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (value) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 3),
                      ),
                    )
                        .intoContainer(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 3.w, right: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                        )
                        .intoExpanded(),
                    assetImage(_.visible == false ? 'ic_add_blue' : 'ic_add')
                        .intoGesture(
                      onTap: () {
                        _.setVisible();
                      },
                    ),
                    Container(
                      width: 43.w,
                      height: 30.h,
                      margin: EdgeInsets.only(left: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF1B72EC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "发送",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                    ).intoGesture(onTap: () {
                      _.send();
                    }),
                  ],
                ),
              ),
              Container(
                  height: _.visible == true ? 100.h : 0,
                  child: Visibility(
                      visible: _.visible,
                      child: Row(
                        children: [
                          Spacer(),
                          Icon(Icons.image).intoGesture(onTap: () async {
                            final pickedFile = await ImagePicker()
                                .getImage(source: ImageSource.gallery);
                            if(pickedFile==null)return;
                            var url=await _.uploadImage(File(pickedFile.path));
                            _.sendImage(url);
                          }),
                          Spacer(),
                        ],
                      )))
            ],
          );
        });
  }
}

class ChatInputViewController extends GetxController {
  Contact? contact = Get.find(tag: "currentContact");

  TextEditingController textEditingController = TextEditingController();
  User user = Get.find();
  AppController appController = Get.find();

  AutoScrollController autoScrollController = Get.find();

  bool visible = false;

  Dio dio=Get.find();

  void setVisible() {
    this.visible = !visible;
    update();
  }

  Future<String?> uploadImage(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response = await dio.post("/file/upload", data: formData);
    if(response.data["succeed"]==true){
      return response.data['data']["url"];
    }else{
      return null;
    }
  }

  Future<void> sendImage(url) async {
    if(url==null)return;
    var result = await NativeUtils.callAndroid(
        AndroidMethod.SEND_IMAGE_MESSAGE,
        Map.from({
          "url": url,
          "toId": contact!.uid.toString(),
          "fromId": user.uid.toString(),
          "isGroup": false,
        }));

    var message = Message(
        MessageType.IMAGE_MESSAGE,
        PGMessage(
            mid: int.parse(result["perId"]),
            fromId: user.uid,
            toId: contact!.uid,
            url: url,
            timestamp: result["timestamp"],
            messageType: "imageMessage",
            isGroup: false));
    appController.addMessage(contact!.uid!, message);
    if (result["success"] == true) {
      Get.snackbar("发送成功", url);
      setVisible();
      // var list=appController.messageMap[contact!.account];
      autoScrollController.scrollToIndex(0,
          preferPosition: AutoScrollPosition.begin);
    }

  }

  void send() async {
    var text = textEditingController.text;

    textEditingController.clear();
    // Get.snackbar("发送", text);
    var result = await NativeUtils.callAndroid(
        AndroidMethod.SEND_TEXT_MESSAGE,
        Map.from({
          "message": text,
          "toId": contact!.uid.toString(),
          "fromId": user.uid.toString(),
          "isGroup": false,
        }));
    var message = Message(
        MessageType.TEXT_MESSAGE,
        PGMessage(
            mid: int.parse(result["perId"]),
            fromId: user.uid,
            toId: contact!.uid,
            content: text,
            timestamp: result["timestamp"],
            messageType: "textMessage",
            isGroup: false));
    appController.addMessage(contact!.uid!, message);
    if (result["success"] == true) {
      Get.snackbar("发送成功", text);
      // var list=appController.messageMap[contact!.account];
      autoScrollController.scrollToIndex(0,
          preferPosition: AutoScrollPosition.begin);
    }
  }
}
