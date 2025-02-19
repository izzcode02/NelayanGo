import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nelayanpos/model/SummaryList.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/custom_dialogbox.dart';
import 'package:nelayanpos/widget/drawer.dart';
import 'package:nelayanpos/widget/loading.dart';
import 'package:nelayanpos/widget/user_appbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? selectedDate;
  List<SummaryList> summaries = [];

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void _showDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      if (selectedStartDate == null) {
        selectedStartDate = date;
        _startDateController.text = DateFormat('EEEE, d/M/y').format(date);
      } else if (selectedEndDate == null) {
        if (date.isBefore(selectedStartDate!)) {
          setState(() {
            _startDateController.clear();
            _endDateController.clear();

            selectedStartDate = null;
            selectedEndDate = null;
          });
        } else {
          selectedEndDate = date;
          _endDateController.text = DateFormat('EEEE, d/M/y').format(date);
        }
      } else {
        // Both start and end dates have been selected
        // Reset the selection and start over
        selectedStartDate = date;
        selectedEndDate = null;
        _startDateController.text = DateFormat('EEEE, d/M/y').format(date);
        _endDateController.text = '';
      }
    }
    print(selectedStartDate);
    print(selectedEndDate);
    print(selectedDate);
  }

  void _clearDateController() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();

      selectedStartDate = null;
      selectedEndDate = null;
    });
  }

  Stream<List<SummaryList>> retrieveSummary() {
    StreamController<List<SummaryList>> controller =
        StreamController<List<SummaryList>>();

    FirebaseFirestore.instance
        .collection('summary')
        .where('created_at',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(selectedStartDate ?? DateTime.now()))
        .where('created_at',
            isLessThanOrEqualTo:
                Timestamp.fromDate(selectedEndDate ?? DateTime.now()))
        .snapshots()
        .map((snapshot) {
      List<SummaryList> summaries = [];
      snapshot.docs.forEach((doc) {
        SummaryList summary =
            SummaryList.fromMap(doc.data() as Map<String, dynamic>);
        summaries.add(summary);
      });
      return summaries;
    }).listen((data) {
      controller.add(data);
    });

    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: UserAppBar(),
        drawer: UserDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(150, 50, 150, 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUMMARY SALE',
                      style: textInter800S24B,
                    ),
                    Gap(10),
                    ElevatedButton.icon(
                      onPressed:
                          selectedStartDate == null || selectedEndDate == null
                              ? null
                              : () async {
                                  final pdf = await generateSummarySalesPdf();
                                  await savePdfToDisk(pdf, DateTime.now());
                                },
                      icon: Icon(Icons.share),
                      label: Text('Share'),
                    )
                  ],
                ),
              ),
              _dateList(),
              Gap(20),
              _summarySales(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 1025,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: 300,
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _showDatePicker();
                      },
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: 300,
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _showDatePicker();
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await retrieveSummary();
                  setState(() {});
                },
                style: ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(224, 58)),
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text('Search'),
              ),
              Gap(5),
              ElevatedButton.icon(
                  onPressed: _clearDateController,
                  icon: Icon(Icons.delete),
                  label: Text('Clear'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red))),
            ],
          ),
        ),
      ],
    );
  }

  //show the TABLE for summarySales
  Widget _summarySales() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(10),
          Card(
            child: StreamBuilder<List<SummaryList>>(
              stream: retrieveSummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loading();
                }
                if (!snapshot.hasData) {
                  return Text('No data available');
                }
                List<SummaryList> summaries = snapshot.data!;

                // Retrieve all categories from the first summary and iterate over them to generate DataColumn based on how many categories exist
                List<DataColumn> categoryColumns;

                if (summaries.isNotEmpty) {
                  categoryColumns = summaries.first.categoryNameMap.keys
                      .map((category) => DataColumn(label: Text(category)))
                      .toList();
                  print('print column $categoryColumns');
                } else {
                  categoryColumns = [DataColumn(label: Text('Ticket'))];
                  print(categoryColumns);
                  print(summaries.length);
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey[300]),
                    headingRowHeight: 53,
                    dataRowHeight: 150,
                    dividerThickness: 2,
                    columns: [
                      DataColumn(label: Text('Staff')),
                      DataColumn(label: Text('Login Time')),
                      DataColumn(label: Text('Logout Time')),

                      // Generate Column with named based on types of category in firebase field Map<String, int> categoryNameMap
                      // Retrieve type all category on each document in summary collection and iterate to generate DataColumn based how many category has.
                      // Add the list of category columns to the DataTable
                      ...categoryColumns,
                      //--------------------------------------

                      DataColumn(label: Text('Ticket Sold')),

                      // Calculate Total Sales from categoryNameMap (TotalSales = price x quantity)
                      DataColumn(label: Text('Total Sales')),
                    ],
                    rows: summaries
                        .where((summary) => summary.categoryNameMap.isNotEmpty)
                        .map((summary) => DataRow(cells: [
                              DataCell(Text(summary.name)),
                              DataCell(
                                Text(DateFormat('EEEE, d/M/y, hh:mm a')
                                    .format(summary.loginTime.toDate())),
                              ),
                              DataCell(
                                Text(DateFormat('EEEE, d/M/y, hh:mm a')
                                    .format(summary.logoutTime.toDate())),
                              ),
                              // Generate cells for each category with their corresponding quantity
                              // ...summary.categoryNameMap.values
                              //     .map((category) => DataCell(Text(category
                              //         .toString()
                              //         .replaceAll('{', ' ')
                              //         .replaceAll('},', '\n')
                              //         .replaceAll('}', ''))))
                              //     .toList(),
                              ...summary.categoryNameMap.keys
                                  .map(
                                    (category) => summary.categoryNameMap
                                            .containsKey(category)
                                        ? DataCell(
                                            Text(summary
                                                .categoryNameMap[category]
                                                .toString()
                                                .replaceAll('{', ' ')
                                                .replaceAll('},', '\n')
                                                .replaceAll('}', '')),
                                          )
                                        : DataCell(Text('0')),
                                  )
                                  .toList(),
                              //--------------------------------------

                              summary.totalTicketSold != 0
                                  ? DataCell(Text('${summary.totalTicketSold}'))
                                  : DataCell(Text('0')),

                              // Generate cell for total sales
                              DataCell(
                                  Text('\RM${calculateTotalSales(summary)}')),
                            ]))
                        .toList(),
                  ),
                );
              },
            ),
          ),
          Gap(10),
        ],
      ),
    );
  }

  // Helper function to calculate the total sales for a given summary
  String calculateTotalSales(SummaryList summary) {
    double totalSales = 0;
    summary.categoryNameMap.forEach((category, productMap) {
      productMap.forEach((name, priceQuantity) {
        num price = priceQuantity['price'];
        num quantity = priceQuantity['quantity'] ?? 0.0;
        totalSales += price * quantity;
      });
      print(category);
    });
    return totalSales.toStringAsFixed(2);
  }

  String calculateTotalAllSales(List<SummaryList> summaries) {
    double totalAllSales = 0;
    for (var summary in summaries) {
      double totalSales = double.parse(calculateTotalSales(summary));
      totalAllSales += totalSales;
    }
    return totalAllSales.toStringAsFixed(2);
  }

  String calculateTotalAllTicketSold(List<SummaryList> summaries) {
    int totalAllTicketSold = 0;
    for (var summary in summaries) {
      totalAllTicketSold += summary.totalTicketSold;
    }
    return totalAllTicketSold.toString();
  }

  Future<Uint8List> generateSummarySalesPdf() async {
    // Retrieve summary data
    List<SummaryList> summaries = await retrieveSummary().first;

    // Calculate total sales
    String totalAllSales = calculateTotalAllSales(summaries);

    // Calculate total ticket sold
    String totalAllTicketSold = calculateTotalAllTicketSold(summaries);

    // Create PDF document
    final pdf = pw.Document();

    //image
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/icons/receiptheader1.png'))
          .buffer
          .asUint8List(),
    );

    // Set maximum number of rows per page
    final int rowsPerPage = 7;

    // Add content to the PDF document
    List<List<dynamic>> tableData = [];

    for (SummaryList summary in summaries) {
      if (summary.categoryNameMap.isNotEmpty) {
        List<List<dynamic>> data = summary.categoryNameMap.values
            .map((category) => category
                .toString()
                .replaceAll('{', ' ')
                .replaceAll('},', '\n')
                .replaceAll('}', ''))
            .toList()
            .map((categoryName) => [
                  summary.name,
                  DateFormat('EEEE, d/M/y, hh:mm a')
                      .format(summary.loginTime.toDate()),
                  DateFormat('EEEE, d/M/y, hh:mm a')
                      .format(summary.logoutTime.toDate()),
                  categoryName,
                  summary.totalTicketSold.toString(),
                  '\RM${calculateTotalSales(summary)}',
                ])
            .toList();
        tableData.addAll(data);
      }
    }

    List<List<List<dynamic>>> pagesData = [];
    for (int i = 0; i < tableData.length; i += rowsPerPage) {
      List<List<dynamic>> pageData = tableData.sublist(
          i,
          i + rowsPerPage > tableData.length
              ? tableData.length
              : i + rowsPerPage);
      pagesData.add(pageData);
    }

    for (int i = 0; i < pagesData.length; i++) {
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(logo),
                pw.Center(child: pw.Divider()),
                pw.Text('Muzium Nelayan Tanjung Balau'),
                pw.Text('Kompleks Pelancongan Tanjung Balau,'),
                pw.Text('81930 Kota Tinggi, Johor'),
                pw.Text('Tel: +6078843100'),
                pw.Center(child: pw.Divider()),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Table Summary',
                  style: pw.TextStyle(
                    decoration: pw.TextDecoration.underline,
                    decorationThickness: 1.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  child: pw.Table.fromTextArray(
                    headerAlignment: pw.Alignment.centerLeft,
                    data: [
                      // Generate header row
                      [
                        'Staff',
                        'Login Time',
                        'Logout Time',
                        'Ticket',
                        'Ticket Sold',
                        'Total Sales',
                      ],
                      // Generate data rows
                      ...pagesData[i],
                    ],
                    cellAlignment: pw.Alignment.centerLeft,
                    cellStyle: pw.TextStyle(fontSize: 6),
                    cellPadding: const pw.EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total All Ticket : $totalAllTicketSold',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total All Sales : \RM$totalAllSales',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Page ${i + 1} of ${pagesData.length}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    final Uint8List pdfBytes = await pdf.save();
    return pdfBytes;
  }

  Future<void> savePdfToDisk(Uint8List pdfBytes, DateTime dateTime) async {
    try {
      // Check storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        // Request storage permission
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // Show snackbar telling the user that storage permission is needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage permission is needed to save the PDF'),
            ),
          );
          return;
        }
      }

      // Get Downloads directory path
      final downloadDir = await getExternalStorageDirectory();
      final downloadFilePath = '${downloadDir?.path}/Summary - $dateTime.pdf';

      // Save PDF to disk
      final file = File(downloadFilePath);
      await file.writeAsBytes(pdfBytes);

      // Open the downloaded PDF file
      OpenFilex.open(downloadFilePath);
    } catch (e) {
      print(e);
    }
  }
}
