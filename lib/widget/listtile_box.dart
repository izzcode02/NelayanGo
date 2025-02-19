import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/services/firestoreclient.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/custom_dialogbox.dart';
import 'package:nelayanpos/widget/loading.dart';

class ListTileBox extends StatefulWidget {
  const ListTileBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.icon,
    required this.trailing,
  });

  final Widget title;
  final Widget subtitle;
  final Widget icon;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  State<ListTileBox> createState() => _ListTileBoxState();
}

class _ListTileBoxState extends State<ListTileBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
        leading: widget.icon,
        title: widget.title,
        subtitle: widget.subtitle,
        onTap: widget.onTap,
        trailing: widget.trailing,
      ),
    );
  }
}

class ListTileBoxExpanded extends StatefulWidget {
  const ListTileBoxExpanded({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final Widget title;
  final Widget subtitle;
  final Widget icon;

  @override
  State<ListTileBoxExpanded> createState() => _ListTileBoxExpandedState();
}

class _ListTileBoxExpandedState extends State<ListTileBoxExpanded> {
  bool _isExpanded = false;

  Future<Map<String, dynamic>> getUser() async {
    final _auth = FirebaseAuth.instance;

    final User? user = _auth.currentUser;
    if (user != null) {
      final userDataDoc = await FirestoreClient.userDataRef.doc(user.uid).get();
      if (userDataDoc.exists) {
        final name = userDataDoc.get('name');
        final email = userDataDoc.get('email');
        final icNo = userDataDoc.get('icNo');
        final phoneNo = userDataDoc.get('phoneNo');
        return {'name': name, 'email': email, 'icNo': icNo, 'phoneNo': phoneNo};
      }
    }
    return {'name': 'null', 'email': '', 'icNo': '', 'phoneNo': ''};
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: widget.title,
        subtitle: widget.subtitle,
        leading: widget.icon,
        onExpansionChanged: (bool value) {
          setState(() {
            _isExpanded = value;
          });
        },
        initiallyExpanded: _isExpanded,
        expandedAlignment: Alignment.centerLeft,
        children: <Widget>[
          FutureBuilder(
            future: getUser(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(70, 0, 0, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Gap(5),
                      Text('Name: ${snapshot.data!['name']}'),
                      Gap(5),
                      Text('IC Number: ${snapshot.data!['icNo']}'),
                      Gap(5),
                      Text('Email: ${snapshot.data!['email']}'),
                      Gap(5),
                      Text('Phone Number: ${snapshot.data!['phoneNo']}'),
                      Gap(10),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogBox(
                                  title: 'Confirm?',
                                  description:
                                      'This cannot be UNDONE! Are you sure?',
                                  icon: Icons.warning,
                                  buttonClose: 'Close',
                                  buttonOK: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.red)),
                                    onPressed: () async {
                                      await auth.deleteUser(context);
                                      Center(
                                        child: Container(
                                          child: Text(
                                            'user deleted, redirected to login screen....',
                                            style: textInter700S15W,
                                          ),
                                        ),
                                      );
                                      cNavigate.goToLogin(context);
                                    },
                                    child: Text('OK', style: textInter700S15W),
                                  ),
                                  color: Colors.red,
                                  children: [],
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red),
                          ),
                          child: Text('DELETE USER'))
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Loading();
              }
            },
          ),
        ],
      ),
    );
  }
}
