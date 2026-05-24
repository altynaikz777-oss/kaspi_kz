import 'package:flutter/material.dart';

import '../data/kaspi_catalog.dart';

class KaspiGradientBox extends StatelessWidget {
  const KaspiGradientBox({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = 24,
    this.padding,
  });

  final Widget child;
  final List<Color>? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradient ?? const [kaspiPrimary, kaspiPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradient?.first ?? kaspiPrimary).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KaspiServiceCard extends StatefulWidget {
  const KaspiServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.compact = false,
  });

  final KaspiServiceItem service;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<KaspiServiceCard> createState() => _KaspiServiceCardState();
}

class _KaspiServiceCardState extends State<KaspiServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1,
    );
    _scale = _controller.drive(Tween<double>(begin: 1, end: 0.96));
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(widget.compact ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.compact ? 44 : 52,
                height: widget.compact ? 44 : 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: widget.service.gradient),
                ),
                child: Icon(
                  widget.service.icon,
                  color: Colors.white,
                  size: widget.compact ? 22 : 26,
                ),
              ),
              SizedBox(height: widget.compact ? 10 : 14),
              Text(
                widget.service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: widget.compact ? 14 : 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.service.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7A7F86),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KaspiSearchBar extends StatelessWidget {
  const KaspiSearchBar({super.key, required this.onTap, this.hint});

  final VoidCallback onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF9AA0A6)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint ?? 'Поиск товаров, услуг и платежей',
                  style: const TextStyle(color: Color(0xFF9AA0A6)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Kaspi',
                  style: TextStyle(
                    color: kaspiPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KaspiQuickChip extends StatelessWidget {
  const KaspiQuickChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kaspiPrimary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
