import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';

// ignore: must_be_immutable
class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  Widget? titleWidget;
  Widget? trailingWidget;
  IconButton? icon;
  MainAxisAlignment? mainAxisAlignment;

  CustomAppbar({
    super.key,
    this.titleWidget,
    this.trailingWidget,
    this.icon,
    this.mainAxisAlignment,
  });
  @override
  _CustomAppbarState createState() => _CustomAppbarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(65); // Adjust the height as needed
}

class _CustomAppbarState extends State<CustomAppbar> {
  late Size mq = MediaQuery.of(context).size;
  String? selectedMenu;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        elevation: 2,
        child: ClipPath(
          clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: GalleryThemeData.colorScheme.primary,
            ),
            padding: EdgeInsets.only(
              left: mq.width * 0.02,
              right: mq.width * 0.04,
              top: mq.width * 0.05,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) widget.icon!,
                Expanded(child: widget.titleWidget ?? const SizedBox.shrink()),
                if (widget.trailingWidget != null)
                  SizedBox(
                    height: 70,
                    child: Center(child: widget.trailingWidget!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
