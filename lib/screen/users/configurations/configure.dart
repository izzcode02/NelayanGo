import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/screen/printer/printsummary.dart';
import 'package:nelayanpos/screen/users/configurations/test_receipt.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/custom_dialogbox.dart';
import 'package:nelayanpos/widget/drawer.dart';
import 'package:nelayanpos/widget/item_box.dart';
import 'package:nelayanpos/widget/listtile_box.dart';
import 'package:nelayanpos/widget/loading.dart';
import 'package:nelayanpos/widget/user_appbar.dart';

class Configure extends StatefulWidget {
  const Configure({super.key});

  @override
  State<Configure> createState() => _ConfigureState();
}

class _ConfigureState extends State<Configure> {
  bool connected = false;
  String connectedDevice = '';
  List availableBluetoothDevices = [];

  bool _isLoading = false;

  Future<void> getBluetooth() async {
    List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    try {
      String? result = await BluetoothThermalPrinter.connect(mac);
      print("state connected $result");
      if (result == "true") {
        setState(() {
          connected = true;
          connectedDevice = mac;
        });
      } else {
        setState(() {
          connected = true;
          connectedDevice = mac;
        });
        print("connection failed: $result");
      }
    } catch (e) {
      setState(() {
        connected = false;
        connectedDevice = '';
      });
      print("connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: UserAppBar(),
        drawer: UserDrawer(),
        body: ListView(
          padding: EdgeInsets.fromLTRB(150, 50, 150, 50),
          children: [
            Text(
              'CONFIGURATION',
              style: textInter800S24B,
            ),
            Gap(20),
            ItemBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(30),
                  Text(
                    'User Info',
                    style: textInter700S15G,
                  ),
                  Gap(15),
                  ListTileBoxExpanded(
                      title: Text('User Information '),
                      subtitle: Text('All data about current user listed'),
                      icon: Icon(Icons.people_alt_outlined)),
                  Gap(15),
                  Text(
                    'Printing',
                    style: textInter700S15G,
                  ),
                  Gap(15),
                  ListTileBox(
                    onTap: () async {
                      await getBluetooth();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: 'Receipt Printers',
                            description: 'Choose a supported printer',
                            icon: Icons.info,
                            buttonClose: 'Close',
                            buttonOK: null,
                            color: Colors.green,
                            children: [
                              for (String device in availableBluetoothDevices)
                                ListTile(
                                  title: Text(
                                      device.split('#')[0]), // extract the name
                                  subtitle: Text(
                                      connectedDevice == device.split('#')[1]
                                          ? 'Printer connected'
                                          : 'Not connected'),
                                  onTap: () async {
                                    String mac = device.split('#')[1];
                                    print(mac); // extract the MAC address
                                    // await setConnect(mac);
                                    await setConnect(mac);
                                    Navigator.pop(context);
                                  },
                                )
                            ],
                          );
                        },
                      );
                    },
                    title: Text('Select receipt printer'),
                    subtitle: Text(
                        'Choose the supported printer(for device with printer)'),
                    icon: Icon(Icons.print_outlined),
                    trailing: SizedBox.shrink(),
                  ),
                  ListTileBox(
                    onTap: () async {
                      await printTestTicket();
                    },
                    title: Text('Test Printer'),
                    subtitle:
                        Text('Print a sample receipt(for device with printer)'),
                    icon: Icon(Icons.receipt_long_outlined),
                    trailing: SizedBox.shrink(),
                  ),
                  Gap(30),
                  Text(
                    'Account Setting',
                    style: textInter700S15G,
                  ),
                  Gap(30),
                  ListTileBox(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: 'Log out',
                            description: 'Are you sure want to log out',
                            icon: Icons.question_mark_outlined,
                            buttonClose: 'Close',
                            buttonOK: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var result =
                                          await auth.UserAttendance(false).then(
                                        (value) async =>
                                            await printSummary().then(
                                          (value) async =>
                                              await auth.signOut(context),
                                        ),
                                      );
                                      if (result != null || result == null) {
                                        if (!mounted) return;
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              child: _isLoading
                                  ? Transform.scale(scale:0.5,child: Loading())
                                  : Text('OK', style: textInter700S15G),
                            ),
                            color: Colors.green,
                            children: [],
                          );
                        },
                      );
                    },
                    title: Text('Log out'),
                    subtitle: Text('Log out from the current user'),
                    icon: Icon(Icons.logout_outlined),
                    trailing: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> printSummary() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int>? bytes = await PrintSummary.getSummary();
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

  static Future<void> printTestTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await PrintReceipt.getTestTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }
}
