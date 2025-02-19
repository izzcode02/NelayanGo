import 'package:flutter/material.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';

class BackButtonB extends StatefulWidget {
  const BackButtonB({
    super.key,
  });
  @override
  State<BackButtonB> createState() => _BackButtonBState();
}

class _BackButtonBState extends State<BackButtonB> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStatePropertyAll(Colors.green),
        backgroundColor: MaterialStatePropertyAll(Colors.white),
      ),
      onPressed: (() {
        cNavigate.goToDashboard(context);
      }),
      child: Text(
        'Back',
        style: textInter700S15G,
      ),
    );
  }
}
