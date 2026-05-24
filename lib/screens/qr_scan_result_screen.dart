import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../models/qr_scan_models.dart';
import '../widgets/common_widgets.dart';

class QrScanResultScreen extends StatelessWidget {
  const QrScanResultScreen({super.key, required this.payload});

  final QrScanPayload payload;

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Результат сканирования',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kaspiPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: kaspiPrimary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Код успешно отсканирован',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payload.formatLabel,
                            style: const TextStyle(
                              color: Color(0xFF9AA0A6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Значение кода',
                  style: TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  payload.rawValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Время: ${_formatTime(payload.scannedAt)}',
                  style: const TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (payload.looksLikePayment) {
                  context.push('/qr/payment', extra: payload.rawValue);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Код сохранён. Оплата недоступна для этого типа.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                payload.looksLikePayment
                    ? 'Оплатить по QR'
                    : 'Продолжить',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: kaspiPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: payload.rawValue),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скопировано')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Копировать'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kaspiPrimary,
                side: const BorderSide(color: kaspiPrimary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pushReplacement('/qr/scan'),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Сканировать снова'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Payment details screen after a successful QR scan.
class QrScanPaymentScreen extends StatefulWidget {
  const QrScanPaymentScreen({super.key, required this.scannedValue});

  final String scannedValue;

  @override
  State<QrScanPaymentScreen> createState() => _QrScanPaymentScreenState();
}

class _QrScanPaymentScreenState extends State<QrScanPaymentScreen> {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Оплата по QR',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Получатель',
                  style: TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _recipientLabel(widget.scannedValue),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Данные QR',
                  style: TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.scannedValue,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Сумма, ₸',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Комментарий (необязательно)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Оплата по QR отправлена')),
                );
                context.go('/home');
              },
              style: FilledButton.styleFrom(
                backgroundColor: kaspiPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Подтвердить оплату',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _recipientLabel(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('kaspi')) {
      return 'Получатель Kaspi';
    }
    if (value.startsWith('http')) {
      return 'Оплата по ссылке';
    }
    return 'Получатель по QR';
  }
}
