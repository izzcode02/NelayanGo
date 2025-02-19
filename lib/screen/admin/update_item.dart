import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/admin_appbar.dart';

class UpdateItemScreen extends StatefulWidget {
  const UpdateItemScreen({super.key, required this.itemId});
  final String itemId;

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _controllerName = TextEditingController();
  final _controllerPrice = TextEditingController();
  String _selectedCategory = 'Ticket';
  String _selectedColor = 'Pink';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchItemData();
  }

  // Retrieve the item data from Firestore
  Future<void> _fetchItemData() async {
    DocumentSnapshot itemSnapshot = await auth.fetchItemData(widget.itemId);
    if (itemSnapshot.exists) {
      final itemData = itemSnapshot.data() as Map<String, dynamic>;
      _controllerName.text = itemData['name'];
      _controllerPrice.text = itemData['price'].toString();
      _selectedCategory = itemData['color'];

      if (itemData['category'] != null) {
        _selectedCategory = itemData['category'];
      }

      if (itemData['color'] != null) {
        _selectedColor = itemData['color'];
      }

      print(itemData);
    } else {
      print('Document does not exist on the database');
    }
  }

  // Update the item document in Firestore
  Future<void> _updateItem() async {
    final Map<String, dynamic> data = {
      'name': _controllerName.text,
      'price': double.parse(_controllerPrice.text),
      'category': _selectedCategory,
      'color': _selectedColor,
    };

    try {
      await auth.updateItem(widget.itemId, data);
      print('Item updated successfully!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item updated sucessfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pushNamed(context, '/admin/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something wrong, Please Try Again Later. $e'),
        backgroundColor: Colors.red,
      ));
      print('Error updating item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Unfocuser(
      child: Form(
        key: _formKey,
        child: Container(
          child: updateItemForm(),
        ),
      ),
    );
  }

  Widget updateItemForm() {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(76, 30, 76, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Item',
                style: textInter800S20,
              ),
              Gap(30),
              Text(
                'Item Name',
                style: textInter800S20,
              ),
              Gap(20),
              TextFormField(
                controller: _controllerName,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Enter item name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value!.isEmpty || value == null) {
                    return "Please enter a valid item name";
                  }
                  return null;
                },
              ),
              Gap(20),
              Text(
                'Price',
                style: textInter800S20,
              ),
              Gap(20),
              TextFormField(
                controller: _controllerPrice,
                decoration: InputDecoration(
                  labelText: "Enter item price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty || value == null) {
                    return "Please enter a valid price";
                  }
                  return null;
                },
              ),
              Gap(20),
              Text(
                'Category',
                style: textInter800S20,
              ),
              Gap(20),
              DropdownButtonFormField(
                value: _selectedCategory,
                items: [
                  DropdownMenuItem(value: 'Ticket', child: Text('Ticket')),
                  DropdownMenuItem(value: 'Others', child: Text('Others')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value.toString();
                  });
                },
              ),
              Gap(20),
              Text(
                'Color Button',
                style: textInter800S20,
              ),
              Gap(20),
              DropdownButtonFormField(
                value: _selectedColor,
                items: [
                  DropdownMenuItem(value: 'Pink', child: Text('Pink')),
                  DropdownMenuItem(value: 'Yellow', child: Text('Yellow')),
                  DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                  DropdownMenuItem(value: 'Green', child: Text('Green')),
                  DropdownMenuItem(value: 'Orange', child: Text('Orange')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value.toString();
                  });
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _updateItem();
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
    );
  }
}
