// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/utils/text_style.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Image image;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: TextButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              image,
              const Gap(25),
              Text(title, style: textInter800S24B),
            ],
          ),
        ),
      ),
    );
  }
}
