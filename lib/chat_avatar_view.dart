import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatAvatarView extends StatelessWidget {
  const ChatAvatarView({
    Key? key,
    this.visible = true,
    this.size,
    this.onTap,
    this.url,
    this.onLongPress,
  }) : super(key: key);
  final bool visible;
  final double? size;
  final Function()? onTap;
  final Function()? onLongPress;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        height: 36,
        width: 36,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: null == url || url!.isEmpty
              ? Container(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: (size ?? 36) - 10,
                  ),
                  width: size ?? 36,
                  height: size ?? 36,
                  color: Colors.grey[400],
                )
              : Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4.0),
                image: DecorationImage(
                    image: Image(
                      image: CachedNetworkImageProvider(
                          url!),
                      height: 36,
                      width: 36,
                    ).image,
                    fit: BoxFit.fill)),

              ),
        ),
      ),
    );
  }
}
