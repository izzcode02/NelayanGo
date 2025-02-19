import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nelayanpos/screen/admin/dashboard.dart';
import 'package:nelayanpos/screen/admin/items.dart';
import 'package:nelayanpos/screen/admin/user_account.dart';
import 'package:nelayanpos/widget/admin_appbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Widget content = Dashboard();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 7, 99, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 157,
                    width: 282,
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/header.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        content = Dashboard();
                      });
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 7, 99, 30),
                      child: Row(
                        children: const [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                              child: (Icon(
                                Icons.dashboard,
                                color: Colors.white,
                              ))),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                            child: Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        content = UserAccountScreen();
                      });
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 7, 99, 30),
                      child: Row(
                        children: const [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                              child: (Icon(
                                Icons.supervisor_account,
                                color: Colors.white,
                              ))),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                            child: Text(
                              'User Accounts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        content = ItemScreen();
                      });
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 7, 99, 30),
                      child: Container(
                        child: Row(
                          children: const [
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                                child: (Icon(
                                  Icons.checklist,
                                  color: Colors.white,
                                ))),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
                              child: Text(
                                'Items',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Scaffold(
              appBar: AdminAppBar(),
              body: Container(child: content),
            ),
          )
        ],
      ),
    );
  }
}
