import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_ui.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class PaymentsServiceScreen extends StatelessWidget {
  const PaymentsServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Платежи',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kaspiPaymentTypes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final payment = kaspiPaymentTypes[index];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.payments_rounded, color: kaspiPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        payment.subtitle,
                        style: const TextStyle(color: Color(0xFF7A7F86)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GovServiceScreen extends StatelessWidget {
  const GovServiceScreen({super.key});

  static const _items = [
    ('Справка о доходах', Icons.description_outlined),
    ('Регистрация ИП', Icons.business_center_outlined),
    ('Статус налогов', Icons.receipt_long_outlined),
    ('Цифровые документы', Icons.badge_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Госуслуги',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final (title, icon) = _items[index];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0F766E)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TravelServiceScreen extends StatelessWidget {
  const TravelServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Travel',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KaspiGradientBox(
            gradient: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Путешествия с Kaspi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Авиабилеты, отели и туры со скидкой до 15%',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PromoTile(
            title: 'Алматы → Стамбул',
            subtitle: 'от 89 000 ₸ · вылет 12 июня',
            icon: Icons.flight_takeoff_rounded,
          ),
          const SizedBox(height: 10),
          _PromoTile(
            title: 'Отели в Астане',
            subtitle: 'Кэшбэк 10% Kaspi Red',
            icon: Icons.hotel_rounded,
          ),
        ],
      ),
    );
  }
}

class MagnumServiceScreen extends StatelessWidget {
  const MagnumServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KaspiScaffold(
      title: 'Magnum',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KaspiGradientBox(
            gradient: const [Color(0xFF15803D), Color(0xFF4ADE80)],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доставка продуктов',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Закажите продукты с доставкой за 2 часа',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _PromoTile(
            title: 'Свежие овощи и фрукты',
            subtitle: 'Скидка 20% до конца недели',
            icon: Icons.eco_rounded,
          ),
          const SizedBox(height: 10),
          const _PromoTile(
            title: 'Набор для завтрака',
            subtitle: 'от 4 990 ₸',
            icon: Icons.breakfast_dining_rounded,
          ),
        ],
      ),
    );
  }
}

class TransfersServiceScreen extends ConsumerStatefulWidget {
  const TransfersServiceScreen({super.key});

  @override
  ConsumerState<TransfersServiceScreen> createState() =>
      _TransfersServiceScreenState();
}

class _TransfersServiceScreenState extends ConsumerState<TransfersServiceScreen> {
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return KaspiScaffold(
      title: 'Переводы',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _KaspiTransfersSegmentedControl(
              selectedIndex: _segmentIndex,
              onChanged: (index) => setState(() => _segmentIndex = index),
            ),
          ),
          Expanded(
            child: _segmentIndex == 0
                ? const _TransfersOptionsList()
                : transactions.when(
                    data: (items) => _TransactionList(items: items),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KaspiTransfersSegmentedControl extends StatelessWidget {
  const _KaspiTransfersSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _trackColor = Color(0xFFF3F3F5);
  static const _inactiveText = Color(0xFF6B6B70);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _trackColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _segment(label: 'Мои Переводы', index: 0),
              _segment(label: 'История', index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segment({required String label, required int index}) {
    final selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(0xFF202124) : _inactiveText,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransfersOptionsList extends StatelessWidget {
  const _TransfersOptionsList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: kaspiTransferOptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final option = kaspiTransferOptions[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: option.route == null
                ? null
                : () => context.push(option.route!),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(option.icon, color: kaspiPrimary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (option.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle!,
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFB0B5BD)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class HistoryServiceScreen extends ConsumerWidget {
  const HistoryServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final orders = ref.watch(ordersProvider);
    return DefaultTabController(
      length: 2,
      child: KaspiScaffold(
        title: 'История',
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const TabBar(
                indicatorColor: kaspiPrimary,
                labelColor: kaspiPrimary,
                tabs: [
                  Tab(text: 'Переводы'),
                  Tab(text: 'Заказы'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  transactions.when(
                    data: (items) => _TransactionList(items: items),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  orders.when(
                    data: (items) => items.isEmpty
                        ? const _HubEmpty(text: 'Заказов пока нет')
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final order = items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  title: Text('Заказ #${order.id.substring(0, 6)}'),
                                  subtitle: Text(order.status),
                                  trailing: Text(
                                    formatPrice(order.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.items});

  final List<TransactionModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _HubEmpty(text: 'История переводов пуста');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final txn = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            title: Text(txn.counterparty),
            subtitle: Text(txn.type),
            trailing: Text(
              '${txn.direction == "out" ? "-" : "+"}${formatPrice(txn.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class ShopServiceScreen extends StatelessWidget {
  const ShopServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const ShopScreen();
}

class FavoritesServiceScreen extends StatelessWidget {
  const FavoritesServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const FavoritesScreen();
}

class SettingsServiceScreen extends StatelessWidget {
  const SettingsServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsScreen();
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: kaspiPrimary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF7A7F86)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubEmpty extends StatelessWidget {
  const _HubEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(text, style: const TextStyle(color: Color(0xFF7A7F86))),
      ),
    );
  }
}
