import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/utils/clock.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/username.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  AdminAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();
}

class _AdminAppBarState extends State<AdminAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 3,
        title: Container(
            height: 100,
            width: 100,
            child: Image.asset('assets/icons/logo.png')),
        actions: <Widget>[
          ClockWidget(style: textInter700S12B, username: Username(name: 'Administrator', style: textInter700S15O500),),
          Gap(10),
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.green,
            onPressed: () async {
              auth.signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
