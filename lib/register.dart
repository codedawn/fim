import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fim/app.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
        init: RegisterController(),
        builder: (_) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                new Container(
                    padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                    child: new Text(
                      '注册',
                      style: TextStyle(
                          color: Color.fromARGB(255, 53, 53, 53),
                          fontSize: 50.0),
                    )),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    key: _.registerKey,
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
                            validator: (v) => _.accValidator(v),
                            onChanged: (v) {
                              _.validateAccount(v);
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
                            validator: (v) => _.pwdValidator(v),
                            onSaved: (value) {
                              _.setPassword(value!);
                            },
                          ),
                        ),
                        new Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Color.fromARGB(255, 240, 240, 240),
                            width: 1.0,
                          ))),
                          child: new TextFormField(
                            decoration: new InputDecoration(
                              labelText: '请输入用户名',
                              labelStyle: new TextStyle(
                                  fontSize: 15.0,
                                  color: Color.fromARGB(255, 93, 93, 93)),
                              border: InputBorder.none,
                              // suffixIcon: new IconButton(
                              //   icon: new Icon(
                              //     Icons.close,
                              //     color: Color.fromARGB(255, 126, 126, 126),
                              //   ),
                              //   onPressed: () {
                              //     var accountForm = _.accountKey.currentState;
                              //     accountForm!.reset();
                              //   },
                              // ),
                            ),
                            keyboardType: TextInputType.text,
                            onSaved: (value) {
                              _.setName(value!);
                            },
                            validator: (v) => _.nameValidator(v),
                          ),
                        ),
                        new Container(
                          height: 45.0,
                          margin: EdgeInsets.only(top: 40.0),
                          child: new SizedBox.expand(
                            child: new RaisedButton(
                              onPressed: () {
                                //读取当前的Form状态
                                var registerForm = _.registerKey.currentState;
                                //验证Form表单
                                if (registerForm!.validate()) {
                                  registerForm.save();
                                  _.register();
                                }
                              },
                              color: Color.fromARGB(255, 61, 203, 128),
                              child: new Text(
                                '注册',
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
                                child: Text(
                                  '返回登录',
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      color: Color.fromARGB(255, 53, 53, 53)),
                                ),
                                onTap: () {
                                  Get.back();
                                },
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

class RegisterController extends GetxController {
  GlobalKey<FormState> registerKey = new GlobalKey<FormState>();
  GlobalKey<FormFieldState> accountKey = new GlobalKey<FormFieldState>();

  String account = "";

  String password = "";

  String name = "";

  bool isShowPassWord = false;

  bool permit = true;

  void setAccount(String v) {
    account = v;
    update();
  }

  void setName(String v) {
    name = v;
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

  accValidator(v) {
    if (v!.length == 0) {
      return '请输入帐号';
    }
    if (permit == false) {
      return '账号已经存在';
    } else {
      return null;
    }
  }

  nameValidator(v) {
    if (v!.length == 0) {
      return '请输入用户名';
    }
  }

  pwdValidator(v) {
    if (v!.length == 0) {
      return '请输入密码';
    }
  }

  Future<void> register() async {
    Dio dio = Get.find();

    FormData formData = FormData.fromMap(
        {"account": account, "password": password, "name": name});
    var response = await dio.post("/register", data: formData);

    if (response.data["succeed"] == true) {
      Get.defaultDialog(
          title: "注册成功", onConfirm: () => Get.back(), middleText: "您可以返回登录");
    } else {
      Get.defaultDialog(
          title: "注册失败",
          onConfirm: () => Get.back(),
          middleText: "${response.data["message"]}");
    }
  }

  void validateAccount(v) async {
    print("validateAccount");

    Dio dio = Get.find();

    var response = await dio.get("/validateAccount?account=$v");

    if (response.data["succeed"] == true) {
      permit = true;
    } else {
      permit = false;
    }
    accountKey.currentState!.validate();
  }

  abb() {
    return null;
  }
}
