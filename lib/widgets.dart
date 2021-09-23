import 'package:fim/add_contact.dart';
import 'package:fim/app.dart';
import 'package:fim/create_group.dart';
import 'package:fim/qr_reader.dart';
import 'package:fim/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'copy_custom_pop_up_menu.dart';
import 'extensions.dart';
AppBar appbar(
    BuildContext context, {
      dynamic data,
      bool back = true,
      Widget? left,
      Widget? center,
      Widget? right,
      Color? backgroundColor,
      Color? backBtnColor,
      Function()? onBack,
    }) {
  return AppBar(
    // shadowColor: Color(0xFF000000).withOpacity(0.3),
    // elevation: 4,
    titleSpacing: 0,
    backgroundColor: backgroundColor ?? Colors.blue,
    toolbarHeight: 50.h,
    leading: null,
    automaticallyImplyLeading: false,
    title: Container(
      height: 50.h,
      child: Stack(
        children: [
          Visibility(
            visible: back,
            child: assetImage('ic_back',
                width: 12.w, height: 21.h, color: backBtnColor)
                .intoContainer(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 22.w),
            )
                .intoGesture(
              onTap: onBack ?? () => Navigator.pop(context, data),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: left,
          ),
          Align(
            alignment: Alignment.center,
            child: center,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: right,
          )
        ],
      ),
      // padding: EdgeInsets.symmetric(horizontal: 22.w),
    ),
  );
}

AppBar FiveCMAppbar(
    BuildContext context, {
      String? title,
      Widget? right,
      Function()? onBack,
      Color? backgroundColor,
      Color? backBtnColor,
      bool back=false,
    }) =>
    appbar(
      context,
      back: back,
      right: right,
      onBack: onBack,
      backgroundColor: backgroundColor,
      backBtnColor: backBtnColor,
      center: Text(
        title ?? "没有标题页面",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 19.sp,
          color: Color(0xFF151010),
          // fontWeight: FontWeight.w600,
        ),
      ),
    );

Widget buildPop({
  required BuildContext context,
  CustomPopupMenuController? ctrl,
}) =>
    CopyCustomPopupMenu(
      controller: ctrl,
      barrierColor: Colors.transparent,
      arrowColor: Color(0xFF1B72EC),
      verticalMargin: 0,
      // horizontalMargin: 0,
      child: assetImage(
        'ic_add',
        width: 24.h,
        height: 24.h,
        color: Color(0xFF333333),
      ).intoPadding(
        padding: EdgeInsets.only(right: 10.w, left: 10.w),
      ),
      menuBuilder: () => _buildPopBgView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPopItemView(
              iconWidget: assetImage(
                'ic_add_friend',
                width: 18.w,
                height: 18.h,
              ),
              text: "添加好友",
              onTap: () {
                ctrl?.hideMenu();
                Get.to(()=>AddContactPage());
              },
            ),
            _buildPopItemView(
              iconWidget: assetImage(
                'ic_group_chat3',
                width: 18.w,
                height: 18.h,
              ),
              text: "创建群聊",
              onTap: () {
                ctrl?.hideMenu();
                  Get.to(()=>CreateGroupPage());

              },
            ),
            _buildPopItemView(
              iconWidget: assetImage(
                'ic_group_chat2',
                width: 18.w,
                height: 18.h,
              ),
              text: "添加群聊",
              onTap: () {

              },
            ),
            _buildPopItemView(
              iconWidget: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 18.w,
              ),
              text: "扫一扫",
              onTap: () async {
                ctrl?.hideMenu();
                var result=await Get.to(()=>QRReaderPage());
                if(result!=null&&result!=''){
                  AppController.to.joinGroup(result);
                }
              },
            ),
          ],
        ),
      ),
      pressType: PressType.singleClick,
    );

Widget _buildPopBgView({Widget? child}) => Container(
  child: child,
  padding: EdgeInsets.symmetric(vertical: 4.h),
  decoration: BoxDecoration(
    color: Color(0xFF1B72EC),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF000000).withOpacity(0.5),
        offset: Offset(0, 2.h),
        blurRadius: 6,
        spreadRadius: 0,
      )
    ],
  ),
);



Widget _buildPopItemView(
    {required Widget iconWidget,
      required String text,
      Function()? onTap}) =>
    GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 35.h,
        // width: 140.w,
        // color: Colors.black,
        constraints: BoxConstraints(
          minWidth:
          170.w ,
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            SizedBox(
              width: 14.w,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
