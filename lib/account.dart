import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fim/utils.dart';
import 'package:fim/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'extensions.dart';

import 'app.dart';
import 'entity/android_method.dart';
import 'entity/user.dart';
import 'login.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountController>(
        init: AccountController(),
        builder: (_) => Scaffold(
              appBar: FiveCMAppbar(context, title: "我的"),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Header(
                        url:
                            _.user.avatar,
                        name: "${_.user.name}",
                        account: "账号：${_.user.account}",
                        suffix: _Suffix(
                          text: '',
                        )),
                    // SizedBox(
                    //   height: 24.h,
                    // ),
                    Divider(
                      thickness: 5,
                    ),

                    _SettingItem(
                      iconData: Icons.notifications,
                      iconColor: Colors.blue,
                      title: '消息中心',
                      suffix: _NotificationsText(
                        text: '2',
                      ),
                    ),
                    // Divider(),
                    // SizedBox(
                    //   height: 12.h,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    // ),
                    Divider(),
                    _SettingItem(
                      iconData: Icons.add_a_photo_rounded,
                      iconColor: Colors.grey,
                      title: '修改头像',
                      suffix: _Suffix(
                        text: '',
                      ),
                      onTap: () {
                        Get.to(() => PickAvatarPage());
                        // Get.snackbar("title", "message");
                      },
                    ),
                    Divider(),
                    _SettingItem(
                      iconData: Icons.settings,
                      iconColor: Colors.grey,
                      title: '设置',
                      suffix: _Suffix(
                        text: '',
                      ),
                    ),

                    SizedBox(
                      height: 30.h,
                    ),
                    FlatButton(
                      child: Text('注销'),
                      color: Colors.blueGrey[200],
                      onPressed: () {
                        _.logout();
                      },
                    )
                  ],
                ),
              ),
            ));
  }
}

class AccountController extends GetxController {
  User user = Get.find();
  AppController appController = Get.find();


  AccountController();
  // AccountController(){
  //   print("update account");
  //   update();
  // }

  Future<void> logout() async {
    EasyLoading.show();
    var result = await NativeUtils.callAndroid(AndroidMethod.SEND_DIS_AUTH);

    if (result["success"] == true) {
      // EasyLoading.showSuccess('注销成功!');
      EasyLoading.dismiss();
      appController.clear();
      Get.offAll(() => Login());
    } else {
      EasyLoading.showError('注销失败!');
    }
  }
}

class PickAvatarPage extends StatelessWidget {
  const PickAvatarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PickAvatarController>(
        init: PickAvatarController(),
        builder: (_) {
          return Container(
            color: Colors.black,
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: _._sample == null
                ? _._buildOpeningImage()
                : _._buildCroppingImage(),
          );
        });
  }
}

class PickAvatarController extends GetxController {

  final cropKey = GlobalKey<CropState>();
  File? _file;
  File? _sample;
  File? _lastCropped;

  PickAvatarController();

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(_sample!, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  '裁剪',
                  style: Theme.of(Get.context!)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.white),
                ),
                onPressed: () => _cropImage(),
              ),
              _buildOpenImage(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOpenImage() {
    return TextButton(
      child: Text(
        '选择图片',
        style: Theme.of(Get.context!)
            .textTheme
            .button!
            .copyWith(color: Colors.white),
      ),
      onPressed: () => _openImage(),
    );
  }

  Future<void> _openImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(pickedFile!.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: Get.context!.size!.longestSide.ceil(),
    );

    _sample?.delete();
    _file?.delete();

    _sample = sample;
    _file = file;
    update();
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file!,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;
    Get.delete<File>(tag: "image");
    Get.put<File>(_lastCropped!, tag: "image");
    // user.avatar=file.uri.toString();
    // Get.back();
    Get.off(() => ShowImage());
    debugPrint('$file');
  }
}

class ShowImage extends StatelessWidget {
  const ShowImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowImageController>(
        init: ShowImageController(),
        builder: (_) => Scaffold(body: Container(
            child: Column(
              children: [
                Expanded(child: Image.file(_.file)),
                RaisedButton(
                    onPressed: () async {
                      var url=await _.uploadImage(_.file);
                      if(url!=null){
                        _.user.avatar=url;
                        EasyLoading.showInfo("修改头像成功！");
                        Get.back();
                      }
                    },
                    child: Text("确定")),
                // SizedBox(width: 100,height: 30,child:  ),)
              ],
            )),));
  }
}

class ShowImageController extends GetxController {
  File file = Get.find(tag: "image");
  Dio dio = Get.find();
  User user = Get.find();

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
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    Key? key,
    this.iconData,
    this.iconColor,
    this.onTap,
    required this.title,
    required this.suffix,
  }) : super(key: key);

  final IconData? iconData;
  final Color? iconColor;
  final String? title;
  final Widget suffix;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 30,
          ),
          Icon(
            iconData,
            color: iconColor,
          ),
          SizedBox(
            width: 30,
          ),
          Expanded(
            child: Text('$title'),
          ),
          suffix,
          SizedBox(
            width: 15,
          ),
        ],
      ).intoGesture(onTap: onTap),
    );
  }
}

class _Suffix extends StatelessWidget {
  final String? text;

  const _Suffix({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$text',
      style: TextStyle(color: Colors.grey.withOpacity(.5)),
    );
  }
}

class _NotificationsText extends StatelessWidget {
  final String? text;

  const _NotificationsText({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: Colors.red),
      child: Text(
        '$text',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(
      {Key? key, this.url, this.account, this.name, required this.suffix})
      : super(key: key);

  final String? url;
  final String? name;
  final String? account;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 60,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 15,
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4.0),
                image: DecorationImage(
                    image: Image(
                      image: CachedNetworkImageProvider(url!),
                      height: 36,
                      width: 36,
                    ).image,
                    fit: BoxFit.fill)),
          ),
          SizedBox(
            width: 30,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name',
                  style: TextStyle(fontSize: 20),
                ),
                Text('$account'),
              ],
            ),
          ),
          suffix,
          SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }
}
