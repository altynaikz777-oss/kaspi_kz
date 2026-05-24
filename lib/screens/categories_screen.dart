// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return KaspiScaffold(
      title: 'Категории',
      body: categories.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => CategoryTile(
            category: items[index],
            onTap: () => context.push(
              '/category/${items[index].id}',
              extra: items[index].name,
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: items.length,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            AsyncValueView(child: const SizedBox.shrink(), error: error),
      ),
    );
  }
}
