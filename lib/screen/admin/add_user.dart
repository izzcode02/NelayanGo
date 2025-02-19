import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String icNo = '';
  String phoneNo = '';
  String status = 'Active';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Unfocuser(
        child: Form(
          key: _formKey,
          child: Container(
            child: textFormUser(),
          ),
        ),
      ),
    );
  }

  Widget textFormUser() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(76, 30, 76, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add User',
            style: textInter800S24B,
          ),
          Gap(20),
          Text(
            'Fullname',
            style: textInter800S20,
          ),
          Gap(10),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Enter your fullname",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter a valid name";
              }
              return null;
            },
            onSaved: (value) => name = value!,
          ),
          Gap(10),
          Text(
            'NRIC Number',
            style: textInter800S20,
          ),
          Gap(10),
          TextFormField(
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
                return "Please enter a valid NRIC No";
              }
              return null;
            },
            onSaved: (value) => icNo = value!,
          ),
          Gap(10),
          Text(
            'Phone Number',
            style: textInter800S20,
          ),
          Gap(10),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Please enter your phone number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter a valid phone number";
              }
              return null;
            },
            onSaved: (value) => phoneNo = value!,
          ),
          Gap(10),
          Text(
            'Status',
            style: textInter800S20,
          ),
          Gap(10),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: "Status",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            value: status,
            items: [
              DropdownMenuItem(
                child: Text("Active"),
                value: 'Active',
              ),
              DropdownMenuItem(
                child: Text("Inactive"),
                value: 'Inactive',
              ),
            ],
            onChanged: (value) {
              setState(() {
                status = value!;
              });
            },
          ),
          Gap(20),
          Divider(
            thickness: 2,
            color: Colors.black,
          ),
          Gap(20),
          Text(
            'Email',
            style: textInter800S20,
          ),
          Gap(10),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Please enter your email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter a valid email";
              }
              return null;
            },
            onSaved: (value) => email = value!,
          ),
          Gap(10),
          Text(
            'Password',
            style: textInter800S20,
          ),
          Gap(10),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Please enter your password (at least - 6)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter a valid password";
              }
              return null;
            },
            onSaved: (value) => password = value!,
          ),
          Gap(40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    cNavigate.goToDashboard(context);
                  });
                },
                style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.green),
                  backgroundColor: MaterialStatePropertyAll(Colors.white),
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
                    _formKey.currentState!.save();
                    // Perform some action with the form data here
                    await auth.createUser(
                        email, password, name, icNo, phoneNo, status, context);
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
