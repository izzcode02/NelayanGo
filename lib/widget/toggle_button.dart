import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final String leftLabel;
  final String rightLabel;

  const ToggleButton({
    Key? key,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
    required this.leftLabel,
    required this.rightLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onLeftTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLeftSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                leftLabel,
                style: TextStyle(
                  color: isLeftSelected ? Colors.blue : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            onTap: onRightTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLeftSelected ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                rightLabel,
                style: TextStyle(
                  color: isLeftSelected ? Colors.white : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
