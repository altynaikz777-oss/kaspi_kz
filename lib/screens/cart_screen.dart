// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartItemsProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;

    return KaspiScaffold(
      title: 'Корзина',
      body: cart.when(
        data: (items) {
          final total = items.fold<int>(
            0,
            (sum, item) => sum + item.totalPrice,
          );
          if (items.isEmpty) {
            return const Center(child: Text('Корзина пока пустая'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: KaspiNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              memCacheWidth: 180,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(formatPrice(item.price)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => ref
                                          .read(appActionsProvider)
                                          .updateCartQuantity(
                                            item.productId,
                                            item.quantity - 1,
                                          ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(appActionsProvider)
                                          .updateCartQuantity(
                                            item.productId,
                                            item.quantity + 1,
                                          ),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(appActionsProvider)
                                .removeFromCart(item.productId),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: items.length,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Итого', style: TextStyle(fontSize: 16)),
                          const Spacer(),
                          Text(
                            formatPrice(total),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: profile == null
                              ? null
                              : () async {
                                  await ref
                                      .read(appActionsProvider)
                                      .checkout(profile, items);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Заказ оформлен'),
                                      ),
                                    );
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFED1C24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Оформить заказ'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            AsyncValueView(child: const SizedBox.shrink(), error: error),
      ),
    );
  }
}
