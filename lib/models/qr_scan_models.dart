import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPayload {
  const QrScanPayload({
    required this.rawValue,
    required this.format,
    required this.scannedAt,
  });

  final String rawValue;
  final BarcodeFormat format;
  final DateTime scannedAt;

  String get formatLabel => barcodeFormatLabelRu(format);

  bool get looksLikePayment {
    final value = rawValue.toLowerCase();
    return value.contains('kaspi') ||
        value.contains('pay') ||
        value.contains('qr') ||
        value.startsWith('http');
  }

  static String barcodeFormatLabelRu(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.qrCode => 'QR-код',
      BarcodeFormat.code128 => 'Штрихкод Code 128',
      BarcodeFormat.code39 => 'Штрихкод Code 39',
      BarcodeFormat.code93 => 'Штрихкод Code 93',
      BarcodeFormat.ean13 => 'EAN-13',
      BarcodeFormat.ean8 => 'EAN-8',
      BarcodeFormat.upcA => 'UPC-A',
      BarcodeFormat.upcE => 'UPC-E',
      BarcodeFormat.dataMatrix => 'Data Matrix',
      BarcodeFormat.pdf417 => 'PDF417',
      BarcodeFormat.aztec => 'Aztec',
      BarcodeFormat.itf => 'ITF',
      BarcodeFormat.codabar => 'Codabar',
      _ => 'Код',
    };
  }
}
