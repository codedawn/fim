import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'entity/add_contact.dart';
import 'entity/contact_data.dart';
import 'entity/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewContactPage extends StatelessWidget {
  const NewContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewContactController>(
        init: NewContactController(),
        builder: (_) => Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _.dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item = _.dataList[index];
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 75.w,
                                height: 30.h,
                                child: item.flag==0?RaisedButton(
                                  onPressed: () {
                                    item.flag=1;
                                    _.agree(item.nid,item.contact.uid!);

                                  },
                                  child: Text("同意"),
                                  color: Colors.blue,
                                ):Container(),
                              ),
                              Padding(
                                //左边添加8像素补白
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  width: 75.w,
                                  height: 30.h,
                                  child: item.flag==0?RaisedButton(
                                    onPressed: () {
                                      item.flag=2;
                                      _.reject(item.nid);

                                    },
                                    child: Text("拒绝"),
                                    color: Colors.blue,
                                  ):Container(),
                                ),
                              ),
                              Visibility(child: Text(item.flag==1?"已经同意":"已经拒绝"),visible: item.flag!=0,)
                            ],
                          ),
                        );
                        ;
                      },
                    ),
                  )
                ],
              ),
              appBar: FiveCMAppbar(
                context,
                title: "好友请求",
                back: true,
              ),
            ));
  }
}

class NewContactController extends GetxController {
  List<NewContactInfo> dataList = [];

  TextEditingController textEditingController = new TextEditingController();

  Dio dio = Get.find();
  User user = Get.find();

  NewContactController() {
    getNewContact();
  }

  Future<void> getNewContact() async {
    var resp = await dio.get("/getNewContact/${user.uid}");
    var list = resp.data["data"]["newContactList"];
    list.forEach((v) {
      dataList.add(NewContactInfo(0,v["nid"], Contact.fromJson(v["contact"])));
    });
    update();
  }

  Future<void> agree(int nid,int contactUid) async {
    var resp = await dio.get("/agreeContact?uid=${user.uid}&contactUid=$contactUid&nid=$nid");
    update();
  }

  Future<void> reject(int nid) async {
    var resp = await dio.get("/rejectContact?nid=$nid");
    update();
  }
}
