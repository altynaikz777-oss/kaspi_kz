// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_network_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewed = ref.watch(viewedProductsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: kaspiPrimary,
          onRefresh: () async {
            ref.invalidate(viewedProductsProvider);
            ref.invalidate(featuredProductsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HomeSearchHeader(
                onSearch: () => context.push('/search'),
                onScanQr: () => context.push('/qr/scan'),
              ),
              const SizedBox(height: 14),
              Row(
                children: kaspiHomePromoCards
                    .map(
                      (card) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: card == kaspiHomePromoCards.first ? 6 : 0,
                            left: card == kaspiHomePromoCards.last ? 6 : 0,
                          ),
                          child: _PromoBannerCard(card: card),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kaspiHomeQuickActions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final action = kaspiHomeQuickActions[index];
                  return _QuickActionTile(
                    action: action,
                    onTap: () => context.push(action.route),
                  );
                },
              ),
              const SizedBox(height: 4),
              ...kaspiDeposits.map(
                (deposit) => _DepositRow(
                  deposit: deposit,
                  onTap: () => context.push('/services/bank'),
                ),
              ),
              const SizedBox(height: 16),
              _GlovoBanner(onTap: () => context.push('/services/shop')),
              const SizedBox(height: 22),
              viewed.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Вы недавно смотрели',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1F23),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 168,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final product = items[index];
                            return KaspiShopProductCard(
                              product: product,
                              width: 118,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchHeader extends StatelessWidget {
  const _HomeSearchHeader({
    required this.onSearch,
    required this.onScanQr,
  });

  final VoidCallback onSearch;
  final VoidCallback onScanQr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFF0F1F3),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onSearch,
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF9AA0A6), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Поиск по Kaspi.kz',
                        style: TextStyle(
                          color: Color(0xFF9AA0A6),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onScanQr,
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
          color: kaspiPrimary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Сканировать QR',
        ),
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined, size: 26),
          color: const Color(0xFF1C1F23),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard({required this.card});

  final KaspiHomePromoCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: card.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (card.imageUrl != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 90,
              child: KaspiNetworkImage(
                imageUrl: card.imageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 280,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.badge.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kaspiPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  card.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: Color(0xFF1C1F23),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onTap});

  final KaspiHomeQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = action.iconColor ?? kaspiPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.useMagnumStyle)
              const Text(
                'm',
                style: TextStyle(
                  color: Color(0xFFE91E8C),
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              )
            else
              Icon(action.icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1F23),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositRow extends StatelessWidget {
  const _DepositRow({required this.deposit, required this.onTap});

  final KaspiDepositItem deposit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C518),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(deposit.icon, color: const Color(0xFF1C1F23)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                deposit.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1F23),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB0B5BD)),
          ],
        ),
      ),
    );
  }
}

class _GlovoBanner extends StatelessWidget {
  const _GlovoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC400), Color(0xFFFF8A00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 12,
              bottom: 12,
              child: Row(
                children: [
                  _FoodIcon(icon: Icons.lunch_dining, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  _FoodIcon(icon: Icons.local_pizza, color: Colors.red.shade700),
                  const SizedBox(width: 6),
                  _FoodIcon(icon: Icons.local_cafe, color: Colors.blue.shade800),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Glovo на Kaspi.kz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '10% Бонусов за любой заказ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _BadgeChip(label: 'Gold'),
                      const SizedBox(width: 6),
                      _BadgeChip(label: 'Red+', dark: true),
                    ],
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

class _FoodIcon extends StatelessWidget {
  const _FoodIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1F23) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : const Color(0xFF1C1F23),
        ),
      ),
    );
  }
}
