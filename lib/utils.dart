import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fim/app.dart';
import 'package:fim/contact.dart';
import 'package:fim/conversation.dart';
import 'package:fim/entity/flutter_method.dart';
import 'package:fim/entity/message.dart';
import 'package:fim/entity/personal_message.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

import 'entity/contactInfo.dart';
import 'login.dart';
import 'new_contact.dart';
class NativeUtils {
  static const String NATIVE_CHANNEL_NAME =
      "com.codedawn.flutter.native"; //给native发消息，此处应和客户端名称保持一致
  //channel_name每一个通信通道的唯一标识，在整个项目内唯一！！！
  static const _channel = const MethodChannel(NATIVE_CHANNEL_NAME);

  ///
  /// @Params:
  /// @Desc: 获取native的数据
  ///
  static getNativeData(key, [dynamic arguments]) async {
    try {
      String resultValue = await _channel.invokeMethod(key, arguments);
      return resultValue;
    } on PlatformException catch (e) {
      print(e.toString());
      return "";
    }
  }

  ///
  /// @Params:
  /// @Desc: 获取native的数据
  ///
  static callAndroid(key, [dynamic arguments]) async {
    try {
      var resultValue = await _channel.invokeMethod(key, arguments);
      return resultValue;
    } on PlatformException catch (e) {
      print(e.toString());
      return {"success":false};
    }
  }

  static registerMethod() {
    //接收处理原生消息
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case FlutterMethod.MESSAGE:
          var msg=PGMessage.fromJson(Map.from(call.arguments));
          var message;
          if(msg.messageType=="textMessage"){
            message=Message(MessageType.TEXT_MESSAGE,msg);
          }else{
            message=Message(MessageType.IMAGE_MESSAGE,msg);
          }
          if(message.msg.isGroup==false){
            AppController.to.addMessage(msg.fromId!, message);
            print("flutter收到$msg");
          }else{
            AppController.to.addGroupMessage(msg.toId!, message);
            print("flutter收到$msg");
          }
          return true;
        case FlutterMethod.KICKOUT_MESSAGE:
          EasyLoading.showInfo('被服务器踢出!');
          AppController.to.clear();
          Get.offAll(()=>Login());
          return true;
        default:
          throw MissingPluginException();
      }
    });

  }
}


Widget assetImage(String res,
    {double? width, double? height, BoxFit? fit, Color? color}) {
  return Image.asset(
    imageResStr(res),
    width: width,
    height: height,
    fit: fit,
    color: color,
  );
}

String imageResStr(var name) => "assets/images/$name.webp";

class Utils {



  static String getImgPath(String name, {String format: 'png'}) {
    return 'assets/images/$name.$format';
  }

  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Widget getSusItem(BuildContext context, String tag,
      {double susHeight = 40}) {
    if (tag == '★') {
      tag = '★ 热门城市';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 16.0),
      color: Color(0xFFF3F4F5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$tag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF666666),
        ),
      ),
    );
  }



  static Widget getWeChatListItem(
      BuildContext context,
      ContactInfo model, {
        double susHeight = 40,
        Color? defHeaderBgColor,
      }) {
    return getWeChatItem(context, model, defHeaderBgColor: defHeaderBgColor);
//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      children: <Widget>[
//        Offstage(
//          offstage: !(model.isShowSuspension == true),
//          child: getSusItem(context, model.getSuspensionTag(),
//              susHeight: susHeight),
//        ),
//        getWeChatItem(context, model, defHeaderBgColor: defHeaderBgColor),
//      ],
//    );
  }

  static Widget getWeChatItem(
      BuildContext context,
      ContactInfo model, {
        Color? defHeaderBgColor,
      }) {
    DecorationImage? image;
//    if (model.img != null && model.img.isNotEmpty) {
//      image = DecorationImage(
//        image: CachedNetworkImageProvider(model.img),
//        fit: BoxFit.contain,
//      );
//    }
    return Container(
      decoration: BoxDecoration(
        color: model.tagIndex=='↑'?Color(0xFFFFFFFF):Color(0xFFFAFAFA),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4.0),
            color: model.bgColor ?? defHeaderBgColor,
            image: model.contact!=null? DecorationImage(
                image:Image(
                  image: CachedNetworkImageProvider(
                      model.contact!.avatar!),
                  height: 36,
                  width: 36,
                ).image,
                fit: BoxFit.fill):image,
          ),
          child: model.iconData == null
              ? null
              : Icon(
            model.iconData,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(model.name),
        onTap: () {
          if(model.tagIndex=='↑'&&model.name=="新的朋友"&&model.contact==null){
            Get.to(()=>NewContactPage());
          }else if(model.contact!=null){
            ContactController.to.addConversation(model.contact!.uid);
            AppController.to.updateConversation();
            ContactController.to.toChatPage(model.contact);
          }

        },
      ),
    );
  }
}
