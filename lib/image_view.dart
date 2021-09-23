import 'package:cached_network_image/cached_network_image.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage({Key? key, this.url}) : super(key: key);

  final url;

  @override
  Widget build(BuildContext context) {
    // return Scaffold(body: ,appBar: FiveCMAppbar(context,title: "查看图片",back: true),);
    return Container(child: PhotoView(
      imageProvider: CachedNetworkImageProvider(url),
      onTapUp: (BuildContext context,
          TapUpDetails details,
          PhotoViewControllerValue controllerValue,){
        Get.back();
      },
    ),);
  }
}
