// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  Future<void> _runSearch(String value) async {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      setState(() => _query = '');
      return;
    }
    await ref.read(appActionsProvider).recordSearch(normalized);
    setState(() => _query = normalized);
  }

  void _openResult(GlobalSearchResult result) {
    if (result.type == 'product' && result.productId != null) {
      context.push('/product/${result.productId}');
      return;
    }
    if (result.type == 'category') {
      context.push(result.route, extra: result.title);
      return;
    }
    context.push(result.route);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'product':
        return Icons.shopping_bag_outlined;
      case 'category':
        return Icons.category_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'service':
        return Icons.apps_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'product':
        return 'Товар';
      case 'category':
        return 'Категория';
      case 'payment':
        return 'Платеж';
      case 'service':
        return 'Сервис';
      default:
        return 'Результат';
    }
  }

  @override
  Widget build(BuildContext context) {
    final history =
        ref.watch(searchHistoryProvider).valueOrNull ??
        const <SearchQueryModel>[];
    final results = _query.isEmpty
        ? null
        : ref.watch(globalSearchProvider(_query));

    return KaspiScaffold(
      title: 'Поиск',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _runSearch,
            decoration: InputDecoration(
              hintText: 'Товары, сервисы, платежи, категории',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: () => _runSearch(_controller.text),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_query.isEmpty) ...[
            const SectionTitle(
              title: 'Недавние запросы',
              subtitle: 'Глобальный поиск по Kaspi',
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Text('Поисковая история пока пустая')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history
                    .map(
                      (item) => ActionChip(
                        label: Text(item.query),
                        onPressed: () {
                          _controller.text = item.query;
                          _runSearch(item.query);
                        },
                      ),
                    )
                    .toList(),
              ),
          ] else ...[
            Text(
              'Результаты для "$_query"',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            results!.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Ничего не найдено')),
                  );
                }
                final byType = <String, List<GlobalSearchResult>>{};
                for (final item in items) {
                  byType.putIfAbsent(item.type, () => []).add(item);
                }
                const order = ['service', 'payment', 'category', 'product'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final type in order)
                      if (byType[type]?.isNotEmpty ?? false) ...[
                        SectionTitle(title: _sectionTitle(type)),
                        const SizedBox(height: 8),
                        ...byType[type]!.map(
                          (result) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SearchResultTile(
                              result: result,
                              icon: _iconForType(result.type),
                              badge: _labelForType(result.type),
                              onTap: () => _openResult(result),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  AsyncValueView(child: const SizedBox.shrink(), error: error),
            ),
          ],
        ],
      ),
    );
  }

  String _sectionTitle(String type) {
    switch (type) {
      case 'product':
        return 'Товары';
      case 'category':
        return 'Категории';
      case 'payment':
        return 'Платежи';
      case 'service':
        return 'Сервисы';
      default:
        return 'Другое';
    }
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final GlobalSearchResult result;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFF1F1),
              child: Icon(icon, color: kaspiPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    result.subtitle,
                    style: const TextStyle(color: Color(0xFF7A7F86)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: kaspiPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
