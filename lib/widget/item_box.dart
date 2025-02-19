import 'package:flutter/material.dart';

class ItemBox extends StatefulWidget {
  const ItemBox({super.key, required this.child});
  final Widget child;
  @override
  State<ItemBox> createState() => _ItemBoxState();
}

class _ItemBoxState extends State<ItemBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 14, 14, 10),
      child: Container(
        //height: 755,
        width: 673,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 9, 19, 18),
          child: widget.child,
        ),
      ),
    );
  }
}
