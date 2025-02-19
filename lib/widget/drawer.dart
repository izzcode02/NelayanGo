import 'package:flutter/material.dart';
import 'package:nelayanpos/utils/text_style.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.green[50],
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'Nelayan POS App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/header.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.green),
            title: Text(
              'Home',
              style: textInter700S15B,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/users/home');
              // navigate to home page
            },
          ),
          ListTile(
            leading: Icon(Icons.list, color: Colors.green),
            title: Text(
              'Summary',
              style: textInter700S15B,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/users/summary');
              // navigate to profile page
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.green),
            title: Text(
              'Configuration',
              style: textInter700S15B,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/users/configure');
              // navigate to profile page
            },
          ),
          Divider(
            thickness: 1,
          ),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'Hak Cipta Terpelihara Muzium Nelayan | 2023',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
