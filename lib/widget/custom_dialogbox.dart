import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/utils/text_style.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, description, buttonClose;
  final Widget? buttonOK;
  final IconData icon;
  final List<Widget> children;
  final Color color;

  CustomDialogBox(
      {super.key,
      required this.title,
      required this.description,
      required this.children,
      required this.icon,
      required this.buttonOK,
      required this.buttonClose, required this.color});

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 350,
          padding: EdgeInsets.only(
            left: 6,
            top: 16,
            right: 16,
            bottom: 16,
          ),
          margin: EdgeInsets.only(top: 66),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: textInter800S24,
              ),
              Gap(5),
              Text(widget.description),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children,
              ),
              Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: widget.buttonOK,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      widget.buttonClose,
                      style: textInter700S15G,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: widget.color,
            radius: 30,
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
