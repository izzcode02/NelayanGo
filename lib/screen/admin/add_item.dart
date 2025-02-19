import 'dart:io';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  double? price;
  File? _image;
  String? category;
  String? color;

  void _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        String? imageUrl = await auth.uploadImage(_image!);

        if (imageUrl != null) {
          var result =
              auth.createItem(name!, price!, category!, imageUrl, color!);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Item created sucessfully'),
            backgroundColor: Colors.green,
          ));
          print(result);
        } else {
          // Handle the case where imageUrl is null
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please Insert Image'),
            backgroundColor: Colors.red,
          ));
        }
        cNavigate.goToDashboard(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something Wrong. Please Try Again'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      XFile? pickedFile =
          (await ImagePicker().pickImage(source: ImageSource.gallery));

      // Set the image file
      setState(() {
        _image = File(pickedFile!.path);
      });
    } catch (e) {
      print(e);
    }
    // Allow the user to select an image from the gallery
  }

  @override
  Widget build(BuildContext context) {
    return Unfocuser(
      child: Form(
        key: _formKey,
        child: Container(
          child: textFormItem(),
        ),
      ),
    );
  }

  Widget textFormItem() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(76, 30, 76, 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Item',
              style: textInter800S20,
            ),
            Gap(30),
            Text(
              'Item Name',
              style: textInter800S20,
            ),
            Gap(20),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Enter item name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a valid item name";
                }
                return null;
              },
              onSaved: (value) => name = value!,
            ),
            Gap(20),
            Text(
              'Price',
              style: textInter800S20,
            ),
            Gap(20),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Enter item price",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a valid price";
                }
                return null;
              },
              onSaved: (value) => price = double.parse(value!),
            ),
            Gap(20),
            Text(
              'Image',
              style: textInter800S20,
            ),
            Gap(20),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: Text('Select Image'),
            ),
            _image != null ? Image.file(_image!) : Container(),
            Gap(20),
            Text(
              'Category',
              style: textInter800S20,
            ),
            Gap(20),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Please select category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: category,
              items: [
                DropdownMenuItem(value: 'Ticket', child: Text('Ticket')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
              onSaved: (value) {
                category = value;
              },
            ),
            Gap(20),
            Text(
              'Color',
              style: textInter800S20,
            ),
            Gap(20),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Please select color button',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: color,
              items: [
                DropdownMenuItem(value: 'Pink', child: Text('Pink')),
                DropdownMenuItem(value: 'Yellow', child: Text('Yellow')),
                DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                DropdownMenuItem(value: 'Green', child: Text('Green')),
                DropdownMenuItem(value: 'Orange', child: Text('Orange')),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  color = value;
                });
              },
              onSaved: (value) {
                color = value;
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    cNavigate.goToDashboard(context);
                  },
                  style: ButtonStyle(
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
                  onPressed: _submitForm,
                  child: Text("Submit"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
