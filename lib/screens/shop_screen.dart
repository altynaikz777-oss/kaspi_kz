// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredProductsProvider);

    return KaspiScaffold(
      title: 'Магазин',
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(
            title: 'Каталог',
            subtitle: 'Все категории товаров',
          ),
          const SizedBox(height: 12),
          categories.when(
            data: (items) => Column(
              children: items
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CategoryTile(
                        category: category,
                        onTap: () => context.push(
                          '/category/${category.id}',
                          extra: category.name,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                AsyncValueView(child: const SizedBox.shrink(), error: error),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Популярное сейчас'),
          const SizedBox(height: 12),
          featured.when(
            data: (items) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.63,
              ),
              itemBuilder: (context, index) => ProductCard(
                product: items[index],
                onTap: () => context.push('/product/${items[index].id}'),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                AsyncValueView(child: const SizedBox.shrink(), error: error),
          ),
        ],
      ),
    );
  }
}
