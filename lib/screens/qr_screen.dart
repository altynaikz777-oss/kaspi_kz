import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../widgets/kaspi_ui.dart';
import '../widgets/common_widgets.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'QR Kaspi',
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: kaspiPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Сканер'),
                Tab(text: 'Оплата'),
                Tab(text: 'Мой QR'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ScannerPane(scanController: _scanController),
                _QrPaymentPane(),
                _MyQrPane(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPane extends StatelessWidget {
  const _ScannerPane({required this.scanController});

  final AnimationController scanController;

  void _openScanner(BuildContext context) {
    context.push('/qr/scan');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openScanner(context),
            borderRadius: BorderRadius.circular(28),
            child: KaspiGradientBox(
              borderRadius: 28,
              child: Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: scanController,
                          builder: (context, child) {
                            return Positioned(
                              top: 40 + (scanController.value * 180),
                              child: Container(
                                width: 200,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Наведите камеру на QR-код Kaspi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _openScanner(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kaspiPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text(
                      'Открыть сканер',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QrActionCard(
                icon: Icons.photo_library_outlined,
                label: 'Из галереи',
                onTap: () => _openScanner(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QrActionCard(
                icon: Icons.flash_on_outlined,
                label: 'Вспышка',
                onTap: () => _openScanner(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QrPaymentPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(
          title: 'QR-оплата',
          subtitle: 'Оплатите по коду продавца',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Сумма, ₸',
                  filled: true,
                  fillColor: kaspiBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Комментарий (необязательно)',
                  filled: true,
                  fillColor: kaspiBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: kaspiPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Оплатить по QR'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyQrPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: kaspiBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  size: 140,
                  color: kaspiPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваш персональный QR',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Покажите код для получения перевода',
                style: TextStyle(color: Color(0xFF7A7F86)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
                label: const Text('Поделиться QR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kaspiPrimary,
                  side: const BorderSide(color: kaspiPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrActionCard extends StatelessWidget {
  const _QrActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kaspiPrimary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
