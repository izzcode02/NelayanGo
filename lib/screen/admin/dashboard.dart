import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/model/DashboardItem.dart';
import 'package:nelayanpos/screen/admin/add_item.dart';
import 'package:nelayanpos/screen/admin/add_user.dart';
import 'package:nelayanpos/screen/admin/items.dart';
import 'package:nelayanpos/screen/admin/user_account.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/admin_button.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<IconLabelButton> buttons = [];

  Widget? content;

  @override
  void initState() {
    super.initState();
    buttons = [
      IconLabelButton(
        image: Image(image: AssetImage('assets/icons/UserAcc.png')),
        label: "User Account List",
        onTap: () {
          setState(() {
            content = const UserAccountScreen();
          });
        },
      ),
      IconLabelButton(
        image: Image(image: AssetImage('assets/icons/AddUser.png')),
        label: "Add User",
        onTap: () {
          setState(() {
            content = AddUserScreen();
          });
        },
      ),
      IconLabelButton(
        image: Image(image: AssetImage('assets/icons/ItemList.png')),
        label: "Item List",
        onTap: () {
          setState(() {
            content = const ItemScreen();
          });
        },
      ),
      IconLabelButton(
        image: Image(image: AssetImage('assets/icons/AddItem.png')),
        label: "Add Item",
        onTap: () {
          setState(() {
            content = AddItemScreen();
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: content ?? Padding(
      padding: const EdgeInsets.fromLTRB(64, 30, 64, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Administrator', style: textInter800S24),
          Gap(20),
          Text('Welcome to Nelayan GO Administration', style: textInter800S24),
          Gap(20),
          Expanded(
            child: GridView.count(
              childAspectRatio: 3.0,
              mainAxisSpacing: 70.0,
              crossAxisSpacing: 30.0,
              crossAxisCount: 2,
              children: buttons.map((button) {
                return MyButton(
                  onTap: button.onTap,
                  title: button.label,
                  image: button.image,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    )
    );
  }
}
