import 'package:fim/widgets.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPage extends StatelessWidget {
  const QRPage(this.data,{Key? key}) : super(key: key);
  final data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FiveCMAppbar(context,title: "扫码加群",back: true),
      body: Center(
        child: Column(
          children: [
            Text("群号：${data}"),
            QrImage(
              data: data.toString(),
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
          ],
        ),
      ),
    );
  }
}
