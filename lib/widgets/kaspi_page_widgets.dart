import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';

class KaspiSubpageScaffold extends StatelessWidget {
  const KaspiSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final Widget body;
  final Widget? trailing;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Color(0xFF1C1F23),
          ),
        ),
        actions: trailing == null ? null : [trailing!],
      ),
      body: body,
    );
  }
}

class KaspiPillSegment extends StatefulWidget {
  const KaspiPillSegment({
    super.key,
    required this.tabs,
    required this.bodyBuilder,
    this.initialIndex = 0,
  });

  final List<String> tabs;
  final Widget Function(BuildContext context, int index) bodyBuilder;
  final int initialIndex;

  @override
  State<KaspiPillSegment> createState() => _KaspiPillSegmentState();
}

class _KaspiPillSegmentState extends State<KaspiPillSegment> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(widget.tabs.length, (i) {
                final selected = _index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _index = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        widget.tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? const Color(0xFF1C1F23)
                              : const Color(0xFF9AA0A6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(child: widget.bodyBuilder(context, _index)),
      ],
    );
  }
}

class KaspiListRow extends StatelessWidget {
  const KaspiListRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF1C1F23),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Color(0xFF9AA0A6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB0B5BD),
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 76, color: Color(0xFFE8EAED)),
      ],
    );
  }
}

class KaspiRedIcon extends StatelessWidget {
  const KaspiRedIcon({super.key, required this.icon, this.size = 28});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: kaspiPrimary, size: size);
  }
}
