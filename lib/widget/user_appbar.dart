import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/services/firestoreclient.dart';
import 'package:nelayanpos/utils/clock.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/username.dart';

class UserAppBar extends StatefulWidget implements PreferredSizeWidget {
  UserAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  State<UserAppBar> createState() => _UserAppBarState();
}

class _UserAppBarState extends State<UserAppBar> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Container(
            height: 100,
            width: 100,
            child: Image.asset('assets/icons/logo white.png')),
        actions: <Widget>[
          ClockWidget(
            style: textInter700S12W,
            username: Username(name: _name, style: textInter700S15O500),
          ),
          Gap(10),
        ],
      ),
    );
  }

  Future<void> getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDataDoc = await FirestoreClient.userDataRef.doc(user.uid).get();
      if (userDataDoc.exists) {
        final name = userDataDoc.get('name');
        print('This is $name');
        if (!mounted) return;
        setState(
          () {
            _name = name;
          },
        );
      } else {
        _name = 'Administrator';
      }
    }
  }
}
