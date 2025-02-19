import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nelayanpos/services/firestoreclient.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/username.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key, required this.style, required this.username});

  final TextStyle style;
  final Widget username;

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream<DateTime>.periodic(Duration(seconds: 1), (_) => DateTime.now());
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Gap(5),
        widget.username,
        StreamBuilder<DateTime>(
          stream: _clockStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Text(
                    DateFormat('EEE, MMM d, y').format(snapshot.data!),
                    style: widget.style,
                  ),
                  Text(
                    DateFormat('h:mm:ss a').format(snapshot.data!),
                    style: widget.style,
                  ),
                ],
              );
            } else {
              return Text('Loading...');
            }
          },
        ),
      ],
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
        setState(() {});
      } else {}
    }
  }
}
