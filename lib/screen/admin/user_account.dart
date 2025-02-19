import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/model/Staff.dart';
import 'package:nelayanpos/screen/admin/add_user.dart';
import 'package:nelayanpos/screen/admin/update_user.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/backbutton.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  Widget? contentUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: contentUser ??
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 70, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    userAccountTitle(),
                    const Gap(10),
                    userAccountTable(),
                  ],
                ),
              ),
            ));
  }

  Widget userAccountTitle() {
    return Card(
      child: Container(
        width: 986,
        height: 62,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButtonB(),
              const Text(
                'User Account List',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    contentUser = const AddUserScreen();
                  });
                },
                style: ElevatedButton.styleFrom(
                    elevation: 12.0,
                    textStyle: textInter700S15W),
                child: const Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userAccountTable() {
    return StreamBuilder<List<Staff>>(
      stream: auth.getStaffData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final staffList = snapshot.data;
          print(staffList);
          return Container(
            width: 1100,
            child: Card(
                child: DataTable(
              headingRowColor: MaterialStatePropertyAll(Colors.grey[300]),
              headingRowHeight: 93,
              dataRowHeight: 66,
              dividerThickness: 2,
              columns: const [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('No.Kp')),
                DataColumn(label: Text('No.Hp')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: staffList?.map((staff) {
                    return DataRow(cells: [
                      DataCell(Text(staff.email)),
                      DataCell(Text(staff.name)),
                      DataCell(Text(staff.icNo)),
                      DataCell(Text(staff.phoneNo)),
                      DataCell(
                        Container(
                          width: 103,
                          height: 32,
                          decoration: BoxDecoration(
                            color: staff.status == 'Inactive'
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              staff.status,
                              style: textInter700S15W,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  contentUser =
                                      UpdateUserScreen(uid: staff.uid);
                                });
                              },
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.blue)),
                              child: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList() ??
                  [],
            )),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
