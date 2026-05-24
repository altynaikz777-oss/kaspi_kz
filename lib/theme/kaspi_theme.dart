import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Strict Kaspi.kz palette from product screenshots.
abstract final class KaspiColors {
  static const primaryBlue = Color(0xFF1A56DB);
  static const gold = Color(0xFFC9A96E);
  static const successGreen = Color(0xFF34C759);
  static const errorRed = Color(0xFFFF3B30);
  static const background = Color(0xFFF2F2F7);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF8E8E93);
  static const tabTrack = Color(0xFFE5E5EA);
  static const divider = Color(0xFFE5E5EA);
  static const depositBlue = Color(0xFF1A56DB);
  static const depositBlueBg = Color(0xFFE8F0FE);
}

final _balanceFormat = NumberFormat('#,##0.00', 'ru_RU');

String formatGoldBalance(double value) => '${_balanceFormat.format(value)} ₸';

String formatBonusBalance(int value) => '$value Б';

String maskCardLast4(String? last4) {
  final digits = (last4 ?? '0000').replaceAll(RegExp(r'\D'), '');
  final tail = digits.length >= 4 ? digits.substring(digits.length - 4) : digits.padLeft(4, '0');
  return '• $tail';
}
