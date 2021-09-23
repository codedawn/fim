import 'package:dio/dio.dart';
import 'package:fim/entity/user.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(
        init: CreateGroupController(),
        builder: (_) => Scaffold(
              appBar: FiveCMAppbar(
                context,
                title: "创建群聊",
                back: true,
              ),
              body: Column(
                children: [
                  Center(
                      child: Text(
                    "群名称",
                    style: TextStyle(fontSize: 30.sp),
                  )),
                  SizedBox(
                    height: 30.h,
                  ),
                  Center(
                    child: Container(
                      height: 60.h,
                      width: 350.w,
                      child: TextField(
                        controller: _.editingController,
                        decoration: InputDecoration(
                          fillColor: Color(0x30cccccc),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00FF0000)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          hintText: '输入群聊名',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00000000)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100.h,
                  ),
                  Visibility(
                    visible: _.vis,
                    child: Container(
                      width: 150.w,
                      height: 40.h,
                      child: FlatButton(
                        child: Text('创建'),
                        color: Colors.blueGrey[200],
                        onPressed: () {
                          _.createGroup();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}

class CreateGroupController extends GetxController {
  TextEditingController editingController = TextEditingController();
  Dio dio=Get.find();
  bool vis = false;
  User user=Get.find();

  CreateGroupController() {
    editingController.addListener(() {
      editingController.text.length > 0 ? vis = true : vis = false;
      update();
    });
  }

  Future<void> createGroup() async {
    var createResponse=await dio.get("/createGroup?ownerId=${user.uid}&groupName=${editingController.text}");
    if (createResponse.data["succeed"] == true) {
      EasyLoading.showInfo("创建成功！");
      Get.back();
    }else{
      EasyLoading.showInfo("创建失败！");
    }
  }
}
