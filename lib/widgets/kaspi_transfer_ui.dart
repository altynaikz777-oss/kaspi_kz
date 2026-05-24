import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/kaspi_theme.dart';

class KaspiWhiteCard extends StatelessWidget {
  const KaspiWhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: KaspiColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KaspiGoldIcon extends StatelessWidget {
  const KaspiGoldIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: KaspiColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.people_outline, color: Colors.white, size: 22),
    );
  }
}

class KaspiGoldAccountRow extends StatelessWidget {
  const KaspiGoldAccountRow({
    super.key,
    required this.title,
    this.balance,
    this.showBalance = true,
  });

  final String title;
  final String? balance;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    return KaspiWhiteCard(
      child: Row(
        children: [
          const KaspiGoldIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: KaspiColors.textPrimary,
              ),
            ),
          ),
          if (showBalance && balance != null)
            Text(
              balance!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: KaspiColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class KaspiFlowChevron extends StatelessWidget {
  const KaspiFlowChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: KaspiColors.textSecondary,
        size: 22,
      ),
    );
  }
}

class KaspiMethodTabs extends StatelessWidget {
  const KaspiMethodTabs({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KaspiColors.tabTrack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Телефон', 'Карта', 'Kaspi QR'].asMap().entries.map((entry) {
          final selected = index == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? KaspiColors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: KaspiColors.textPrimary.withValues(
                      alpha: selected ? 1 : 0.55,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class KaspiPrimaryButton extends StatelessWidget {
  const KaspiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: KaspiColors.primaryBlue,
          disabledBackgroundColor:
              KaspiColors.primaryBlue.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
    );
  }
}

class KaspiSubpageHeader extends StatelessWidget implements PreferredSizeWidget {
  const KaspiSubpageHeader({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KaspiColors.card,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: KaspiColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: KaspiColors.textPrimary,
        ),
      ),
    );
  }
}
