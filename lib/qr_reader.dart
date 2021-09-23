import 'package:fim/qrcode_reader_view.dart';
import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:get/get.dart';
class QRReaderPage extends StatelessWidget {
  const QRReaderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrcodeReaderView(
        // key: _key,
        onScan: onScan,
        headerWidget: FiveCMAppbar(
          context,
          backgroundColor: Colors.black.withOpacity(0.5),
          backBtnColor: Colors.white,
          back: true,
          title: ""
        ),
        helpWidget: Text(''),
      ),
    );
  }

  Future onScan(String data) async {
    // Navigator.pop(context, data);
//    _key.currentState.startScan();
    print('-------------scan result:$data');
    if (data.isEmpty) {
      Get.snackbar("没有二维码", "图片中识别不到二维码");
    } else {
       // Get.snackbar("title", "${data}");
       Get.back(result: data);
    }
  }
}
