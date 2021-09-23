// widget 扩展
import 'package:flutter/material.dart';

extension WidgetExt on Widget {
  //
  GestureDetector intoGesture({
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return GestureDetector(
      child: this,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent,
    );
  }

  Container intoContainer({
    //复制Container构造函数的所有参数（除了child字段）
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
  }) {
    return Container(
      key: key,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      child: this,
    );
  }

  Expanded intoExpanded({int flex = 1}) {
    return Expanded(child: this, flex: flex);
  }

  Padding intoPadding({required EdgeInsetsGeometry padding}) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}