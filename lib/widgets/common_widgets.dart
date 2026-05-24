// ignore_for_file: unnecessary_underscores, use_null_aware_elements

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_models.dart';
import 'kaspi_network_image.dart';

final NumberFormat _tenge = NumberFormat.currency(
  locale: 'ru_RU',
  symbol: '₸',
  decimalDigits: 0,
);

String formatPrice(int value) => _tenge.format(value);

class KaspiScaffold extends StatelessWidget {
  const KaspiScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202124),
        elevation: 0,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(color: Color(0xFF7A7F86)),
                ),
            ],
          ),
        ),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text('Все')),
      ],
    );
  }
}

/// Horizontal Kaspi-style product card with image, price, installment badge.
class KaspiShopProductCard extends StatelessWidget {
  const KaspiShopProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width = 140,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: width * 0.85,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: KaspiNetworkImage(
                        imageUrl: product.primaryImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        categoryHint: product.category,
                        memCacheWidth: 320,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A75C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.installmentMonthly} ₸',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.trailing,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: KaspiNetworkImage(
                    imageUrl: product.primaryImage,
                    fit: BoxFit.cover,
                    categoryHint: product.category,
                    memCacheWidth: 400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatPrice(product.price),
              style: const TextStyle(
                color: Color(0xFF1C1F23),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'В рассрочку ${formatPrice(product.installmentMonthly)}/мес',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF5A623),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(product.rating.toStringAsFixed(1)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: KaspiNetworkImage(
                imageUrl: category.imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                categoryHint: category.id,
                memCacheWidth: 160,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0A6)),
          ],
        ),
      ),
    );
  }
}

class AsyncValueView extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.child,
    this.error,
    this.loading = false,
  });

  final Widget child;
  final Object? error;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не удалось загрузить данные.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return child;
  }
}
