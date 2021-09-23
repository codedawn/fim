import 'package:azlistview/azlistview.dart';
import 'package:dio/dio.dart';
import 'package:fim/utils.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'chat.dart';
import 'copy_custom_pop_up_menu.dart';
import 'entity/contactInfo.dart';
import 'entity/contact_data.dart';
import 'entity/user.dart';
import 'extensions.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactController>(
        init: Get.find<ContactController>(),
        builder: (_) => Scaffold(
              body: SmartRefresher(

              controller: _.refreshController,

                header: ClassicHeader(
                  refreshingText: "刷新中",
                  completeText: "刷新完成",
                  idleText: "下拉刷新",
                  releaseText: "放开刷新",
                  failedText: "刷新失败",
                  refreshStyle: RefreshStyle.Follow,
                ),
                onRefresh: (){
                  _.updateContactList();
                  _.refreshController.refreshCompleted();
                },
              child: AzListView(
                data: _.contactInfoList,
                itemCount: _.contactInfoList.length,
                itemBuilder: (BuildContext context, int index) {
                  ContactInfo model = _.contactInfoList[index];

                  return Utils.getWeChatListItem(
                    context,
                    model,
                    defHeaderBgColor: Color(0xFFE5E5E5),
                  );
                },
                physics: BouncingScrollPhysics(),
                susItemBuilder: (BuildContext context, int index) {
                  ContactInfo model = _.contactInfoList[index];
                  if ('↑' == model.getSuspensionTag()) {
                    return Container();
                  }
                  return Utils.getSusItem(context, model.getSuspensionTag());
                },
                indexBarData: ['↑', '☆', ...kIndexBarData],
                indexBarOptions: IndexBarOptions(
                  needRebuild: true,
                  ignoreDragCancel: true,
                  downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
                  downItemDecoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                  indexHintWidth: 120 / 2,
                  indexHintHeight: 100 / 2,
                  indexHintDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Utils.getImgPath('ic_index_bar_bubble_gray')),
                      fit: BoxFit.contain,
                    ),
                  ),
                  indexHintAlignment: Alignment.centerRight,
                  indexHintChildAlignment: Alignment(-0.25, 0.0),
                  indexHintOffset: Offset(-20, 0),
                ),
              ),),
              appBar: FiveCMAppbar(
                context,
                title: "联系人",
                right: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // assetImage('ic_search',
                    //         width: 24.h, height: 24.h, color: Color(0xFF333333))
                    //     .intoPadding(
                    //       padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    //     )
                    //     .intoGesture(
                    //       onTap: () => {},
                    //     ),
                    buildPop(context: context, ctrl: _._popupCtrl),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),
            ));
  }
}

class ContactController extends GetxController {
  final _popupCtrl = CustomPopupMenuController();
  List<ContactInfo> contactInfoList = [];
  List<ContactInfo> topList = [];

  List<ContactWrapper> contactList=Get.find();

  Dio dio = Get.find();

  User user=Get.find();

  RefreshController refreshController = RefreshController();

  static ContactController get to =>Get.find();

  ContactController(){
    updateContact();
  }
  void updateContact(){
    topList.add(ContactInfo(
        name: '新的朋友',
        tagIndex: '↑',
        bgColor: Colors.orange,
        iconData: Icons.person_add));
    topList.add(ContactInfo(
        name: '群聊',
        tagIndex: '↑',
        bgColor: Colors.green,
        iconData: Icons.people));
    topList.add(ContactInfo(
        name: '标签',
        tagIndex: '↑',
        bgColor: Colors.blue,
        iconData: Icons.local_offer));
    updateContactList();
  }
  Future<void> updateContactList() async {
    var conResponse=await dio.get("/getContact/${user.uid}");
    var c=ContactData.fromJson(conResponse.data["data"]);
    contactList.clear();
    contactInfoList.clear();
    contactList.addAll(c.contactList as List<ContactWrapper>);

    contactList.forEach((v) {
      contactInfoList.add(ContactInfo(contact: v.contact,name:v.contact!.name!,img: v.contact!.avatar));
    });

    _handleList(contactInfoList);
  }

  void _handleList(List<ContactInfo> list) {
    // if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(contactInfoList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(contactInfoList);

    // add topList.
    contactInfoList.insertAll(0, topList);
    update();
  }

  Future<void> addConversation(contactUid) async {
    var addResp=await dio.get("/addPConversation?uid=${user.uid}&contactUid=${contactUid}");

  }
  void toChatPage(contact){
    Get.delete<Contact?>(tag: "currentContact");
    Get.put<Contact?>(contact,
        tag: "currentContact");
    Get.to(() => ChatPage());
  }
}
