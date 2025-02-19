import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/model/Item.dart';
import 'package:nelayanpos/screen/printer/printreceipt.dart';
import 'package:nelayanpos/services/firestoreclient.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/calculator_box.dart';
import 'package:nelayanpos/widget/custom_dialogbox.dart';
import 'package:nelayanpos/widget/drawer.dart';
import 'package:nelayanpos/widget/item_box.dart';
import 'package:nelayanpos/widget/loading.dart';
import 'package:nelayanpos/widget/user_appbar.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  double _totalPrice = 0.0;
  double amount = 0.0;
  double change = 0.0;
  final List<Item> _cartItems = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _changeController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _itemQuantityControllers = {};

  void submitPay(List<Item> cartItems) {
    double totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double change = double.tryParse(_changeController.text) ?? 0.0;
    final _auth = FirebaseAuth.instance;
    if (totalPrice > amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The amount paid is less than the total price.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment submitted.'),
          backgroundColor: Colors.green,
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: 'Print Receipt',
            description: '',
            icon: Icons.info,
            buttonClose: 'Close',
            buttonOK: TextButton(
              onPressed: () async {
                printTicket().then((value) => _clearCart());
                Navigator.of(context).pop();
              },
              child: Text('OK', style: textInter700S15G),
            ),
            color: Colors.green,
            children: [],
          );
        },
      );
    }
  }

  void _addToCart(Item item) {
    setState(() {
      final existingItemIndex =
          _cartItems.indexWhere((cartItem) => cartItem.itemId == item.itemId);
      if (existingItemIndex != -1) {
        // increase the quantity of the existing item
        final existingItem = _cartItems[existingItemIndex];
        existingItem.quantity++;
        _itemQuantityControllers[existingItem.itemId]!.text =
            existingItem.quantity.toString();
      } else {
        // add the item to the cart
        item.quantity = 1;
        _cartItems.add(item);
        _itemQuantityControllers[item.itemId] =
            TextEditingController(text: item.quantity.toString());
      }
      _totalPrice += item.price;
    });
    print(_cartItems);
    print(_totalPrice);
  }

  // Add a function to clear the cart and total price
  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalPrice = 0.0;
      amount = 0.0;
      _amountController.clear();
      _changeController.clear();
    });
    print(_cartItems);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth.snackbarUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: UserAppBar(),
      drawer: UserDrawer(),
      body: Row(
        children: [
          ItemBox(child: ItemGridList(context)),
          CalculatorBox(
            child: DataTableCalculator(context),
          ),
        ],
      ),
    );
  }

  Widget ItemGridList(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreClient.itemDataRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: Something went wrong, try again later'),
            );
          }
    
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          }
    
          List<Item> items = snapshot.data!.docs
              .map((DocumentSnapshot document) => Item.fromFirestore(document))
              .toList();
    
          Color _getColorFromString(String colorString) {
            switch (colorString) {
              case 'Pink':
                return Colors.pink;
              case 'Orange':
                return Colors.orange;
              case 'Green':
                return Colors.green;
              case 'Blue':
                return Colors.blue;
              case 'Yellow':
                return Colors.yellow;
              default:
                return Colors
                    .grey; // fallback color if the string is not recognized
            }
          }
    
          return GridView.count(
            mainAxisSpacing: 36.0,
            crossAxisSpacing: 39.0,
            crossAxisCount: 3,
            children: items.map((item) {
              Color buttonColor =
                  _getColorFromString(item.color); //color settings
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                child: Container(
                  width: 220,
                  height: 187,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: Text(item.name)),
                      Center(child: Text('RM ${item.price.toStringAsFixed(2)}')),
                    ],
                  ),
                ),
                onPressed: () {
                  // add the item to the cart or increase the quantity of the existing item
                  _addToCart(item);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget DataTableCalculator(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 61,
          padding: EdgeInsets.fromLTRB(0, 16, 0, 26),
          color: Colors.white,
          child: Text('CHECKOUT', style: textInter800S20),
        ),
        Container(
          width: 596,
          child: DataTable(
            dataRowHeight: 66,
            headingRowHeight: 42,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => Colors.grey),
            columns: [
              DataColumn(
                label: Text("Name"),
              ),
              DataColumn(
                label: Text("QTY"),
              ),
              DataColumn(
                label: Text("Price"),
              ),
            ],
            rows: _cartItems
                .map((cartItem) => DataRow(
                      cells: [
                        DataCell(Text(cartItem.name)),
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  _itemQuantityControllers[cartItem.itemId],
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  cartItem.quantity = int.tryParse(value) ?? 0;
                                  _totalPrice = _cartItems.fold(
                                      0.0,
                                      (sum, item) =>
                                          sum + (item.price * item.quantity));
                                });
                              },
                            ),
                          ),
                        ), // display the quantity
                        DataCell(
                            Text("RM ${cartItem.price.toStringAsFixed(2)}")),
                      ],
                    ))
                .toList(),
          ),
        ),
        Divider(
          thickness: 3,
        ),
        Container(
          height: 333,
          width: 596,
          padding: EdgeInsets.fromLTRB(26, 29, 18, 0),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Amount :", style: textInter800S20),
                      SizedBox(
                        width: 359,
                        height: 36,
                        child: TextFormField(
                          controller: _amountController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'RM0.00',
                            hintStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            amount = double.tryParse(value) ?? 0.0;
                            change = amount - _totalPrice;
                            setState(() {
                              _changeController.text =
                                  change.toStringAsFixed(2);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total :", style: textInter800S20),
                      SizedBox(
                        width: 359,
                        height: 36,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'RM${_totalPrice.toStringAsFixed(2)}',
                            hintStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(26),
                  Divider(
                    thickness: 3,
                    color: Colors.black,
                  ),
                  Gap(26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Change :", style: textInter800S20),
                      SizedBox(
                        width: 359,
                        height: 36,
                        child: TextFormField(
                          controller: _changeController,
                          textAlign: TextAlign.center,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'RM0.00',
                            hintStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Gap(31),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        child: Text(
                          "Cancel Order",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          _clearCart();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2.0, color: Colors.red),
                        ),
                      ),
                    ),
                    Gap(10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          submitPay(_cartItems);
                        },
                        child: Text("PAY"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await PrintReceipt.getTicket(_cartItems, amount);
      if (bytes != null) {
        final result = await BluetoothThermalPrinter.writeBytes(bytes);
        print("Print $result");
      } else {
        print('null');
      }
    } else {
      //Handle Not Connected Senario
      print('not connected');
    }
  }
}
