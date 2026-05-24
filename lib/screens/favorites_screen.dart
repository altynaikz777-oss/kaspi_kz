// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_network_image.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(wishlistItemsProvider);
    return KaspiScaffold(
      title: 'Избранное',
      body: favorites.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Сохраните товары в избранное'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => context.push('/product/${item.productId}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: KaspiNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      memCacheWidth: 160,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(formatPrice(item.price)),
                  trailing: const Icon(Icons.chevron_right_rounded),
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
