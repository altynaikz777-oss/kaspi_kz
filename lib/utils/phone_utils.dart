import 'package:flutter/services.dart';

/// Normalizes to +7XXXXXXXXXX (12 chars).
String normalizeKzPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('8') && digits.length > 1) {
    digits = '7${digits.substring(1)}';
  }
  if (!digits.startsWith('7') && digits.isNotEmpty) {
    digits = '7$digits';
  }
  if (digits.length > 11) {
    digits = digits.substring(0, 11);
  }
  return '+$digits';
}

bool isCompleteKzPhone(String raw) {
  final digits = normalizeKzPhone(raw).replaceAll(RegExp(r'\D'), '');
  return digits.length == 11 && digits.startsWith('7');
}

String formatKzPhoneDisplay(String raw) {
  final normalized = normalizeKzPhone(raw);
  final digits = normalized.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 2) {
    return '+7';
  }
  final b = StringBuffer('+7');
  if (digits.length > 1) {
    b.write(' (');
    final area = digits.length > 4 ? digits.substring(1, 4) : digits.substring(1);
    b.write(area);
    if (digits.length >= 4) {
      b.write(')');
    }
  }
  if (digits.length > 4) {
    b.write(' ${digits.substring(4, digits.length > 7 ? 7 : digits.length)}');
  }
  if (digits.length > 7) {
    b.write('-${digits.substring(7, digits.length > 9 ? 9 : digits.length)}');
  }
  if (digits.length > 9) {
    b.write('-${digits.substring(9, digits.length > 11 ? 11 : digits.length)}');
  }
  return b.toString();
}

class KzPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var normalized = digits;
    if (normalized.startsWith('8')) {
      normalized = '7${normalized.substring(1)}';
    } else if (normalized.isNotEmpty && !normalized.startsWith('7')) {
      normalized = '7$normalized';
    }
    if (normalized.length > 11) {
      normalized = normalized.substring(0, 11);
    }
    final display = formatKzPhoneDisplay('+$normalized');
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}
