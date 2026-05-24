// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class CategoryProductsScreen extends ConsumerWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  final String categoryId;
  final String categoryTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsByCategoryProvider(categoryId));
    return KaspiScaffold(
      title: categoryTitle,
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
      body: products.when(
        data: (items) => GridView.builder(
          padding: const EdgeInsets.all(16),
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
    );
  }
}
