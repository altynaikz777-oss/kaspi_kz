import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/kaspi_catalog.dart';

/// Cached product/category image with Kaspi-style loading and error states.
class KaspiNetworkImage extends StatelessWidget {
  const KaspiNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.categoryHint,
    this.memCacheWidth,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String? categoryHint;
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    Widget child;
    if (url.isEmpty) {
      child = _KaspiImagePlaceholder(categoryHint: categoryHint);
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        fadeInDuration: const Duration(milliseconds: 220),
        fadeOutDuration: const Duration(milliseconds: 120),
        placeholder: (context, _) => _KaspiImageLoading(
          width: width,
          height: height,
        ),
        errorWidget: (context, _, __) => _KaspiImagePlaceholder(
          categoryHint: categoryHint,
          width: width,
          height: height,
        ),
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

class _KaspiImageLoading extends StatelessWidget {
  const _KaspiImageLoading({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F1F3),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: kaspiPrimary,
        ),
      ),
    );
  }
}

class _KaspiImagePlaceholder extends StatelessWidget {
  const _KaspiImagePlaceholder({
    this.categoryHint,
    this.width,
    this.height,
  });

  final String? categoryHint;
  final double? width;
  final double? height;

  IconData get _icon {
    return switch (categoryHint) {
      'smartphones' || 'phone' => Icons.smartphone_rounded,
      'tv' => Icons.tv_rounded,
      'laptops' || 'laptop' => Icons.laptop_mac_rounded,
      'shoes' || 'sneakers' => Icons.directions_run_rounded,
      'furniture' || 'sofa' || 'chair' => Icons.chair_rounded,
      'appliances' || 'washer' || 'fridge' => Icons.kitchen_rounded,
      'beauty' || 'hair' || 'perfume' => Icons.spa_rounded,
      'kids' || 'toys' || 'stroller' => Icons.toys_rounded,
      'home' || 'kitchen' => Icons.home_outlined,
      _ => Icons.image_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F6F8),
      alignment: Alignment.center,
      child: Icon(_icon, size: 44, color: const Color(0xFFB0B5BD)),
    );
  }
}
