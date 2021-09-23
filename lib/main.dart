import 'package:dio/dio.dart';
import 'package:fim/account.dart';
import 'package:fim/app.dart';
import 'package:fim/chat.dart';
import 'package:fim/contact.dart';
import 'package:fim/conversation.dart';
import 'package:fim/entity/message.dart';
import 'package:fim/entity/personal_conversations.dart';
import 'package:fim/entity/user.dart';
import 'package:fim/login.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';

import 'entity/android_method.dart';

void main() {
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // NativeUtils.registerMethod();
    //dio
    Dio dio=Get.put(Dio(BaseOptions(baseUrl: "http://192.168.1.104:8080")));
    //添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          options.headers.putIfAbsent("token", () {
            User user=Get.find();
            var token=user.token;
            if(token!=null){
              options.headers.putIfAbsent("id", () => user.uid);
              return token;
            }else{
              return '';
            }
          });
          return handler.next(options); //continue
          // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
          // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
          //
          // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
          // 这样请求将被中止并触发异常，上层catchError会被调用。
        },
        onResponse:(response,handler) async {
          print(response);
          if(response.data is Map &&response.data["code"]==420){
            EasyLoading.showInfo('登录过期');
            // handler.reject(DioError(requestOptions: RequestOptions(path: '')));
            AppController appController = Get.find();
            appController.clear();
            var result = await NativeUtils.callAndroid(AndroidMethod.SEND_DIS_AUTH);
            if (result["success"] == true) {
              Get.offAll(() => Login());
            }
          }
          // Do something with response data
          return handler.next(response); // continue
          // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
          // 这样请求将被中止并触发异常，上层catchError会被调用。
        },
        onError: (DioError e, handler) {
          // Do something with response error
          return  handler.next(e);//continue
          // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
          // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
        }
    ));


  NativeUtils.registerMethod();
    // List<Conversation> conversation = Get.find();
    // var p = PCDataPersonalConversation(
    //     cid: 1,
    //     contact: PCDataPersonalConversationsContact(
    //         uid: 1, name: "carry", account: '21341', password: 'dwqdwq'));
    // conversation.add(p);
    // Get.delete<PCDataPersonalConversationsContact?>(tag: "currentContact");
    // Get.put<PCDataPersonalConversationsContact?>(p.contact,
    //     tag: "currentContact");
    return ScreenUtilInit(
        designSize: Size(375, 812),
        builder: () => GetMaterialApp(
              builder: EasyLoading.init(),
              home: Login(),
              // home: ContactPage(),
            )
    );
  }


}
