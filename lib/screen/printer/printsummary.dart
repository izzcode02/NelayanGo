import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
import 'package:intl/intl.dart';
import 'package:nelayanpos/model/Summary.dart';
import 'package:nelayanpos/services/firestoreclient.dart';

class PrintSummary {
  //GET SUMMARY
  static Future<Summary?> createSummary() async {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    // Create summary ID
    String summaryId = FirestoreClient.summaryRef.doc().id;

    if (user != null) {
      final userDataDoc = await FirestoreClient.userDataRef.doc(user.uid).get();
      if (userDataDoc.exists) {
        final name = userDataDoc.get('name');

        // Generate receiptId
        String receiptId = FirestoreClient.receiptRef.doc().id;

        //Get document data
        final QuerySnapshot attendanceSnapshot = await FirestoreClient
            .attendance
            .where('uid', isEqualTo: user.uid)
            .orderBy('login_time', descending: true)
            .get();

        //Get login_time and logout_time
        if (attendanceSnapshot.docs.isNotEmpty) {
          final latestAttendance = attendanceSnapshot.docs.first;
          final loginTime = latestAttendance.get('login_time') as Timestamp;
          final logoutTime =
              latestAttendance.get('logout_time') as Timestamp? ??
                  Timestamp.now();

          // Get the receipts that fall between loginTime and logoutTime
          final QuerySnapshot receiptSnapshot = await FirestoreClient.receiptRef
              .where('created_at',
                  isGreaterThanOrEqualTo: loginTime,
                  isLessThanOrEqualTo: logoutTime)
              .get();

          //Retrieve and Get total quantity by each category in items array,map in firestore collection named 'receipts in one day
          Map<String, int> categoryQuantityMap = {};
          Map<String, Map<String, dynamic>> categoryNameMap = {};
          int totalTicketSold = 0;
          receiptSnapshot.docs.forEach((doc) {
            List<dynamic> items = doc.get('items');
            items.forEach((item) {
              String category = item['category'];
              int quantity = item['quantity'];
              double price = item['price'];

              categoryQuantityMap.update(category, (value) => value + quantity,
                  ifAbsent: () => quantity);

              Map<String, dynamic> nameQuantityMap =
                  categoryNameMap.putIfAbsent(category, () => {});
              String name = item['name'];
              Map<String, dynamic> itemInfo = nameQuantityMap.putIfAbsent(
                  name, () => {'quantity': 0, 'price': price});
              itemInfo['quantity'] += quantity;
              totalTicketSold += quantity;
            });
          });

          // Add the login and logout timestamps to the "summary" collection
          final summary = Summary(
            summaryId: summaryId,
            uid: user.uid,
            name: name,
            loginTime: loginTime,
            logoutTime: logoutTime,
            createdAt: DateTime.now(),
            categoryQuantityMap: categoryQuantityMap,
            categoryNameMap: categoryNameMap,
            totalTicketSold: totalTicketSold,
          );

          // Create new summary document in Firestore
          await FirestoreClient.summaryRef.doc(summaryId).set(summary.toMap());

          // Update the attendance record with the logout_time value
          final attendanceDocRef =
              FirestoreClient.attendance.doc(latestAttendance.id);
          await attendanceDocRef.update({'logout_time': DateTime.now()});

          // Return the created summary
          return summary;
        }
      } else {
        return null;
      }
    }
  }

  //PRINTING TICKET
  static Future<List<int>> getSummary() async {
    try {
      final Summary? summary = await createSummary();

      List<int> bytes = [];
      CapabilityProfile profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      // Load the image from assets
      final ByteData data =
          await rootBundle.load('assets/icons/receiptheader.png');
      final Uint8List imageData = data.buffer.asUint8List();
      final Img.Image? image = Img.decodeImage(imageData);

      // Print the image
      bytes += generator.image(image!);

      // Print the divider
      bytes += generator.hr();

      bytes += generator.text("Muzium Nelayan \nTanjung Balau",
          styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));

      bytes += generator.text(
          "Kompleks Pelancongan Tanjung Balau,\n 81930 Kota Tinggi, Johor",
          styles: PosStyles(align: PosAlign.center));
      bytes += generator.text('Tel: +6078843100',
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);

      if (summary != null) {
        //dateTime format
        DateTime dateTimeString = summary.createdAt;
        String summaryDateTime =
            DateFormat('yyyy-MM-dd HH:mm').format(dateTimeString);
        final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

        bytes += generator.text('Date Time : ${summaryDateTime}',
            styles: PosStyles(align: PosAlign.center), linesAfter: 1);

        bytes += generator.text(
            "Start shift : ${dateFormatter.format(summary.loginTime.toDate())}",
            styles: PosStyles(
              align: PosAlign.center,
            ),
            linesAfter: 1);

        bytes += generator.text(
            "End shift : ${dateFormatter.format(summary.logoutTime.toDate())}",
            styles: PosStyles(
              align: PosAlign.center,
            ),
            linesAfter: 1);

        bytes += generator.text("Staff : ${summary.name}",
            styles: PosStyles(
              align: PosAlign.center,
            ),
            linesAfter: 1);

        bytes += generator.text(
            "Total ticket sales : ${summary.totalTicketSold.toString()}",
            styles: PosStyles(
              align: PosAlign.center,
            ),
            linesAfter: 1);

        bytes += generator.hr();

        bytes += generator.text("SALES SUMMARY",
            styles: PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
            linesAfter: 1);

        bytes += generator.hr();

        bytes += generator.row([
          PosColumn(
              text: 'No',
              width: 1,
              styles: PosStyles(align: PosAlign.left, bold: true)),
          PosColumn(
              text: 'Item',
              width: 6,
              styles: PosStyles(align: PosAlign.left, bold: true)),
          PosColumn(
              text: 'Price',
              width: 3,
              styles: PosStyles(align: PosAlign.right, bold: true)),
          PosColumn(
              text: 'Qty',
              width: 2,
              styles: PosStyles(align: PosAlign.right, bold: true)),
        ]);

        // Display item name, price, and quantity
        int counter = 1;
        double totalSales = 0;
        Map<String, Map<String, dynamic>> categoryNameMap =
            summary.categoryNameMap;
        categoryNameMap.forEach((category, namePriceQuantityMap) {
          namePriceQuantityMap.forEach((name, priceQuantity) {
            double price = priceQuantity['price'];
            int quantity = priceQuantity['quantity'];

            bytes += generator.row([
              PosColumn(
                text: '$counter',
                width: 1,
                styles: PosStyles(align: PosAlign.left),
              ),
              PosColumn(
                text: name,
                width: 6,
                styles: PosStyles(align: PosAlign.left),
              ),
              PosColumn(
                text: '${price.toStringAsFixed(2)}',
                width: 3,
                styles: PosStyles(align: PosAlign.right),
              ),
              PosColumn(
                text: '$quantity',
                width: 2,
                styles: PosStyles(align: PosAlign.right),
              )
            ]);

            totalSales += price * quantity;
            counter++;
          });
        });

        bytes += generator.hr();

        // Print the total sales
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 6,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'Total Sales:',
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true),
          ),
          PosColumn(
            text: '${totalSales.toStringAsFixed(2)}',
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true),
          ),
          PosColumn(
            text: '${summary.totalTicketSold.toString()}',
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true),
          )
        ]);

        bytes += generator.hr();

        // ticket.feed(2);
        bytes += generator.text('Thank you, Please Come Again',
            styles: PosStyles(align: PosAlign.center, bold: true));

        bytes += generator.text('"Hargai Warisan Nelayan"',
            styles: PosStyles(align: PosAlign.center, bold: true));

        bytes += generator.cut();
      } else {
        // Handle the case where summary is null
        bytes += generator.cut();
      }

      return bytes;
    } catch (e) {
      rethrow;
    }
  }
}
