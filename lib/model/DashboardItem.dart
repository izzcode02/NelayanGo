import 'package:flutter/material.dart';

class IconLabelButton {
  final Image image;
  final String label;
  final VoidCallback onTap;

   IconLabelButton({
    required this.image,
    required this.label,
    required this.onTap,
  });
}
