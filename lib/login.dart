import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fim/app.dart';
import 'package:fim/contact.dart';
import 'package:fim/conversation.dart';
import 'package:fim/entity/android_method.dart';
import 'package:fim/entity/user.dart';
import 'package:fim/register.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;

import 'entity/message.dart';
import 'entity/personal_conversations.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.threeBounce
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 60.0
      ..radius = 5.0
      ..backgroundColor = Color.fromRGBO(0, 186, 155,1)
      ..indicatorColor = Colors.white
      ..textColor = Colors.black
      ..userInteractions = false
      ..dismissOnTap = false;
    return GetBuilder<LoginController>(
        init: LoginController(),
        initState: (GetBuilderState<LoginController> state){
          Get.put(User(1,"","","",""));
        },
        builder: (_) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                new Container(
                    padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                    child: new Text(
                      '登录',
                      style: TextStyle(
                          color: Color.fromARGB(255, 53, 53, 53),
                          fontSize: 50.0),
                    )),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    key: _.loginKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Color.fromARGB(255, 240, 240, 240),
                            width: 1.0,
                          ))),
                          child: new TextFormField(
                            key: _.accountKey,
                            decoration: new InputDecoration(
                              labelText: '请输入账号',
                              labelStyle: new TextStyle(
                                  fontSize: 15.0,
                                  color: Color.fromARGB(255, 93, 93, 93)),
                              border: InputBorder.none,
                              suffixIcon: new IconButton(
                                icon: new Icon(
                                  Icons.close,
                                  color: Color.fromARGB(255, 126, 126, 126),
                                ),
                                onPressed: () {
                                  var accountForm = _.accountKey.currentState;
                                  accountForm!.reset();
                                },
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            onSaved: (value) {
                              _.setAccount(value!);
                            },
                            validator: (account) {
                              if (account!.length == 0) {
                                return '请输入帐号';
                              }
                            },
                            onFieldSubmitted: (v) {
                              var accountForm = _.accountKey.currentState;
                              accountForm!.validate();
                            },
                          ),
                        ),
                        new Container(
                          decoration: new BoxDecoration(
                              border: new Border(
                                  bottom: BorderSide(
                                      color: Color.fromARGB(255, 240, 240, 240),
                                      width: 1.0))),
                          child: new TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: new InputDecoration(
                                labelText: '请输入密码',
                                labelStyle: new TextStyle(
                                    fontSize: 15.0,
                                    color: Color.fromARGB(255, 93, 93, 93)),
                                border: InputBorder.none,
                                suffixIcon: new IconButton(
                                  icon: new Icon(
                                    _.isShowPassWord
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color.fromARGB(255, 126, 126, 126),
                                  ),
                                  onPressed: () {
                                    _.setShowPwd(!_.isShowPassWord);
                                  },
                                )),
                            obscureText: !_.isShowPassWord,
                            validator: (password) {
                              if (password!.length == 0) {
                                return '请输入密码';
                              }
                            },
                            onSaved: (value) {
                              _.setPassword(value!);
                            },
                          ),
                        ),
                        new Container(
                          height: 45.0,
                          margin: EdgeInsets.only(top: 40.0),
                          child: new SizedBox.expand(
                            child: new RaisedButton(
                              onPressed: () {
                                //读取当前的Form状态
                                var loginForm = _.loginKey.currentState;
                                //验证Form表单
                                if (loginForm!.validate()) {
                                  loginForm.save();
                                  _.login();
                                }
                              },
                              color: Color.fromARGB(255, 61, 203, 128),
                              child: new Text(
                                '登录',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(45.0)),
                            ),
                          ),
                        ),
                        new Container(
                          margin: EdgeInsets.only(top: 30.0),
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Container(
                                  child: GestureDetector(
                                onTap: () {
                                  Get.to(() => Register());
                                },
                                child: Text(
                                  '注册账号',
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      color: Color.fromARGB(255, 53, 53, 53)),
                                ),
                              )),
                              Text(
                                '忘记密码？',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Color.fromARGB(255, 53, 53, 53)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

class LoginController extends GetxController {
  GlobalKey<FormState> loginKey = new GlobalKey<FormState>();
  GlobalKey<FormFieldState> accountKey = new GlobalKey<FormFieldState>();
  Dio dio = Get.find();
  String account = "";

  String password = "";

  bool isShowPassWord = false;

  void setAccount(String v) {
    account = v;
    update();
  }

  void setPassword(String v) {
    password = v;
    update();
  }

  void setShowPwd(bool v) {
    isShowPassWord = v;
    update();
  }

  Future<void> login() async {


    EasyLoading.show();
    FormData formData =
        FormData.fromMap({"account": account, "password": password});
    var response;
    try {
      response = await dio.post("/login", data: formData);
    } catch (e) {
      EasyLoading.dismiss();
    }

    if (response.data["succeed"] == true) {
      User user = Get.find();
      user.uid=response.data["data"]["user"]["uid"];
      user.account=response.data["data"]["user"]["account"];
      user.name=response.data["data"]["user"]["name"];
      user.avatar=response.data["data"]["user"]["avatar"];
      user.token=response.data["data"]["token"];
      var result = await NativeUtils.callAndroid(AndroidMethod.SEND_LOGIN,
          Map.from({"id": user.uid.toString(), "token": user.token}));
      if (result["success"] == true) {
        EasyLoading.showSuccess('登录成功!',duration: Duration(milliseconds: 200));

        Get.offAll(() => HomePage(),
            binding:
            BindingsBuilder(() => {Get.put<AppController>(AppController())}));
      }else{
        EasyLoading.showError('vital-im认证失败');
      }

    } else {
      EasyLoading.showError('${response.data["message"]}');

    }
  }
}
