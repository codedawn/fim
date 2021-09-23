import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:common_utils/common_utils.dart';

import 'entity/add_contact.dart';
import 'entity/contact_data.dart';
import 'entity/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddContactPage extends StatelessWidget {
  const AddContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddContactController>(
        init: AddContactController(),
        builder: (_) => Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 225, 226, 230),
                              width: 0.33),
                          color: Color.fromARGB(255, 239, 240, 244),
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        autofocus: false,
                        onChanged: (value) {},
                        onSubmitted: (value) {
                          _.search(value);
                        },
                        controller: _.textEditingController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF333333),
                            ),
                            suffixIcon: Offstage(
                              offstage: _.textEditingController.text.isEmpty,
                              child: InkWell(
                                onTap: () {
                                  _.textEditingController.clear();
                                  _.search('');
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: '搜索账号或名字',
                            hintStyle: TextStyle(color: Color(0xFF999999))),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: _.dataList.length,
                          itemBuilder: (BuildContext, int index) {
                            var item = _.dataList[index];
                            var t = "添加";
                            if (item.flag == 1) {
                              t="已经发送";
                            }
                            if (item.flag == 2) {
                              t="已经添加";
                            }
                            return ListTile(
                              leading: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: Image(
                                          image: CachedNetworkImageProvider(
                                              "https://img.ivsky.com/img/tupian/t/201402/18/pikachu.jpg"),
                                          height: 42,
                                          width: 42,
                                        ).image,
                                        fit: BoxFit.fill)),
                              ),
                              title: Text("${item.contact.name}"),
                              subtitle: Text('${item.contact.account}'),
                              trailing: item.flag==0?InkWell(

                                child: Container(
                                    height: 20.h,
                                    width: 75.w,
                                    alignment: Alignment(0, 0),
                                    child: Text(t,
                                        key: ValueKey(index))),
                                onTap: () {
                                  item.flag=1;
                                  _.add(item.contact.uid!);
                                },
                              ):Container(
                                  height: 20.h,
                                  width: 75.w,
                                  alignment: Alignment(0, 0),
                                  child: Text(t,
                                      key: ValueKey(index))),
                            );
                          }),
                    )
                  ],
                ),
              ),
            ));
  }
}

class AddContactController extends GetxController {
  List<AddContactInfo> dataList = [];

  TextEditingController textEditingController = new TextEditingController();

  Dio dio = Get.find();
  User user = Get.find();

  Future<void> search(String text) async {
    dataList.clear();
    if (ObjectUtil.isEmpty(text)) {
    } else {
      var resp = await dio.get("/searchContact?info=${text}");
      var list = resp.data["data"]["contactList"];
      list.forEach((v) {
        dataList.add(AddContactInfo(0, Contact.fromJson(v)));
      });
    }
    update();
  }

  Future<void> add(int contactUid) async {
    var resp = await dio.get("/addNewContact?uid=${user.uid}&contactUid=$contactUid");
    update();

  }
}
