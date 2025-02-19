import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
import 'package:intl/intl.dart';
import 'package:nelayanpos/model/Item.dart';
import 'package:nelayanpos/model/Receipt.dart';
import 'package:nelayanpos/services/firestoreclient.dart';

class PrintReceipt {
  static Future<Receipt?> createReceipt(List<Item> cartItems) async {
    try {
      //Get current user
      User? user = FirebaseAuth.instance.currentUser;

      //Get user uid
      if (user != null) {
        final userDataDoc =
            await FirestoreClient.userDataRef.doc(user.uid).get();
        if (userDataDoc.exists) {
          final name = userDataDoc.get('name');
          print('This is $name');

          // Generate receiptId
          String receiptId = FirestoreClient.receiptRef.doc().id;

          // Get current DateTime
          final created_at = Timestamp.now();

          // Create new Receipt object
          final receipt = Receipt(
            receiptId: receiptId,
            uid: user.uid,
            name: name,
            created_at: created_at,
            items: cartItems,
          );

          // Create new receipt document in Firestore
          await FirestoreClient.receiptRef.doc(receiptId).set(receipt.toMap());

          // Return the created receipt
          return receipt;
        }
      }
    } catch (error) {
      print(error);
    }

    // Return null if receipt creation fails
    return null;
  }

  static Future<List<int>> getTicket(List<Item> cartItems, amount) async {
    try {
      final Receipt? receipt = await createReceipt(cartItems);
      List<int> bytes = [];
      CapabilityProfile profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      //dateTime format
      DateTime dateTimeString = receipt!.created_at.toDate();
      String receiptDateTime =
          DateFormat('yyyy-MM-dd HH:mm').format(dateTimeString);

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
      bytes += generator.text('Tel : +6078843100',
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);

      bytes += generator.text('Date Time : ${receiptDateTime}',
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);

      bytes += generator.text("Receipt ID : ${receipt.receiptId}",
          styles: PosStyles(
            align: PosAlign.center,
          ),
          linesAfter: 1);

      bytes += generator.text("Staff : ${receipt.name}",
          styles: PosStyles(
            align: PosAlign.center,
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
            width: 5,
            styles: PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: 'Price',
            width: 2,
            styles: PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(
            text: 'Qty',
            width: 2,
            styles: PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(
            text: 'Total',
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);

      // Loop through cart items and add a new row for each item
      int counter = 1;
      double totalAmount = 0.0;
      for (Item item in cartItems) {
        double itemTotal = item.quantity * item.price;
        totalAmount += itemTotal;

        bytes += generator.row([
          PosColumn(text: counter.toString(), width: 1),
          PosColumn(
              text: item.name,
              width: 5,
              styles: PosStyles(
                align: PosAlign.left,
              )),
          PosColumn(
              text: item.price.toStringAsFixed(2),
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              )),
          PosColumn(
              text: item.quantity.toString(),
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: itemTotal.toStringAsFixed(2),
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        counter++;
      }

      bytes += generator.hr();

      bytes += generator.row([
        PosColumn(
            text: 'TOTAL',
            width: 6,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
        PosColumn(
            text: totalAmount.toStringAsFixed(2),
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            )),
      ]);

      bytes += generator.hr(ch: '=', linesAfter: 1);

      if (amount > totalAmount) {
        double change = amount - totalAmount;
        bytes += generator.row([
          PosColumn(
              text: 'AMOUNT PAID',
              width: 6,
              styles: PosStyles(
                align: PosAlign.left,
              )),
          PosColumn(
              text: amount.toStringAsFixed(2),
              width: 6,
              styles: PosStyles(
                align: PosAlign.right,
              )),
        ]);
        bytes += generator.row([
          PosColumn(
              text: 'CHANGE',
              width: 6,
              styles: PosStyles(
                align: PosAlign.left,
              )),
          PosColumn(
              text: change.toStringAsFixed(2),
              width: 6,
              styles: PosStyles(
                align: PosAlign.right,
              )),
        ]);
      } else {
        double change = amount - totalAmount;
        bytes += generator.row([
          PosColumn(
              text: 'AMOUNT PAID',
              width: 6,
              styles: PosStyles(
                align: PosAlign.left,
              )),
          PosColumn(
              text: amount.toStringAsFixed(2),
              width: 6,
              styles: PosStyles(
                align: PosAlign.right,
              )),
        ]);
        bytes += generator.row([
          PosColumn(
              text: 'CHANGE',
              width: 6,
              styles: PosStyles(
                align: PosAlign.left,
              )),
          PosColumn(
              text: change.toStringAsFixed(2),
              width: 6,
              styles: PosStyles(
                align: PosAlign.right,
              )),
        ]);
      }

      bytes += generator.hr();

      // ticket.feed(2);
      bytes += generator.text('Thank you, Please Come Again',
          styles: PosStyles(align: PosAlign.center, bold: true));

      bytes += generator.text('"Hargai Warisan Nelayan"',
          styles: PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.cut();
      return bytes;
    } catch (e) {
      rethrow;
    }
  }
}
