// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:nelayanpos/utils/text_style.dart';

class Username extends StatefulWidget {
  const Username({
    Key? key,
    required this.name, required this.style,
  }) : super(key: key);

  final String name;
  final TextStyle style;
  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.name,
      style: widget.style,
    );
  }
}
