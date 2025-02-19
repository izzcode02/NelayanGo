import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key, required this.uid});
  final String uid;

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _noKpController = TextEditingController();
  final _noHpController = TextEditingController();
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    _fetchItemData();
  }

  Future<void> _fetchItemData() async {
    // get the current email of the user from Firebase Auth
    // fetch the user data from Firestore and populate the form
    await FirebaseFirestore.instance
        .collection('userData')
        .doc(widget.uid)
        .get()
        .then(
      (documentSnapshot) {
        if (documentSnapshot.exists) {
          // set the form fields to the values fetched from Firestore
          final data = documentSnapshot.data() as Map<String, dynamic>;
          _nameController.text = data['name'];
          _noKpController.text = data['icNo'];
          _noHpController.text = data['phoneNo'];
          _selectedStatus = data['status'];
        }
      },
    );
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        // get the updated form data
        final updatedName = _nameController.text.trim();
        final updatedNoKp = _noKpController.text.trim();
        final updatedNoHp = _noHpController.text.trim();
        final updatedStatus = _selectedStatus;

        // update the user data in Firestore
        await FirebaseFirestore.instance
            .collection('userData')
            .doc(widget.uid)
            .update({
          'name': updatedName,
          'icNo': updatedNoKp,
          'phoneNo': updatedNoHp,
          'status': updatedStatus,
        });

        // show a success snackbar if everything is updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User data updated successfully.'),
              backgroundColor: Colors.green),
        );
        cNavigate.goToDashboard(context);
      }
    } catch (error) {
      // show an error snackbar if the data update fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'An error occurred while updating user data: ${error.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Unfocuser(
      child: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(76, 30, 76, 70),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Update Name',
                    style: textInter800S20,
                  ),
                  Gap(30),
                  Text(
                    'Full Name',
                    style: textInter800S20,
                  ),
                  Gap(20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Enter your fullname",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'NRIC Number',
                    style: textInter800S20,
                  ),
                  Gap(20),
                  TextFormField(
                    controller: _noKpController,
                    decoration: InputDecoration(
                      labelText: "Please Enter Your NRIC Number(without '-')",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a your NRIC No";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Phone Number',
                    style: textInter800S20,
                  ),
                  Gap(20),
                  TextFormField(
                    controller: _noHpController,
                    decoration: InputDecoration(
                      labelText: "Please enter your phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Status',
                    style: textInter800S20,
                  ),
                  Gap(20),
                  DropdownButtonFormField(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: "Please select status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value.toString();
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          cNavigate.goToDashboard(context);
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white),
                        ),
                        child: Text(
                          "Back",
                          style: textInter700S15G,
                        ),
                      ),
                      Gap(20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _submitForm();
                          }
                        },
                        child: Text("Submit"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
