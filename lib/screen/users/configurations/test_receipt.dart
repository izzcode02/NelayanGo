import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;

class PrintReceipt {
  static Future<List<int>> getTestTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Load the image from assets
    final ByteData data = await rootBundle.load('assets/icons/receiptheader.png');
    final Uint8List imageData = data.buffer.asUint8List();
    final Img.Image? image = Img.decodeImage(imageData);

    // Print the image
    bytes += generator.image(image!); 

    // Print the divider
    bytes += generator.hr();

    bytes += generator.text("Muzium Nelayan GO Printer Test",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        "Your Printer is Working!",
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.hr();

    // ticket.feed(2);
    bytes += generator.text('the receipt have been printed!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("your setup maybe fine.",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text("Notice: Make sure Bluetooth is ONLINE",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text("Otherwise, it is not work",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text('"Hargai Warisan Nelayan"',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

}
