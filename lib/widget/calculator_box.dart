import 'package:flutter/material.dart';

class CalculatorBox extends StatefulWidget {
  const CalculatorBox({super.key, required this.child});
  final Widget child;
  @override
  State<CalculatorBox> createState() => _CalculatorBoxState();
}

class _CalculatorBoxState extends State<CalculatorBox> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 37, 10),
        child: Container(
          height: 755,
          width: 596,
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
          child: SingleChildScrollView(child: widget.child),
        ),
      ),
    );
  }
}
