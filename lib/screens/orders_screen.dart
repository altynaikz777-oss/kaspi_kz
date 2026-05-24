// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return KaspiScaffold(
      title: 'Заказы',
      body: orders.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('У вас пока нет заказов'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = items[index];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Заказ ${order.id.substring(0, 6)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          order.status,
                          style: const TextStyle(
                            color: Color(0xFFED1C24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${order.items.length} товаров'),
                    const SizedBox(height: 8),
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items
                        .take(2)
                        .map(
                          (item) => Text('• ${item.title} × ${item.quantity}'),
                        ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            AsyncValueView(child: const SizedBox.shrink(), error: error),
      ),
    );
  }
}
