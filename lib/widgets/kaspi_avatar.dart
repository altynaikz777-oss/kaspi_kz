import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/kaspi_catalog.dart';

/// Profile avatar with cached network image and Kaspi styling.
class KaspiAvatar extends StatelessWidget {
  const KaspiAvatar({
    super.key,
    this.photoUrl,
    required this.radius,
    this.onTap,
    this.showEditBadge = false,
    this.isLoading = false,
  });

  final String? photoUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFE5E6),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: _buildImage(size),
      ),
    );

    if (isLoading) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (showEditBadge && !isLoading) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: kaspiPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  Widget _buildImage(double size) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: kaspiPrimary,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      memCacheWidth: 256,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: kaspiPrimary,
      ),
      errorWidget: (context, _, __) => Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: kaspiPrimary,
      ),
    );
  }
}
