import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../providers/app_providers.dart';
import '../widgets/kaspi_avatar.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final locale = ref.watch(appLocaleProvider);
    final isRu = locale.languageCode == 'ru';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: kaspiPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Сервисы',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1F23),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LangPill(
                        label: 'Қаз',
                        active: !isRu,
                        onTap: () => ref
                            .read(appLocaleProvider.notifier)
                            .setLocale(const Locale('kk')),
                      ),
                      const SizedBox(width: 6),
                      _LangPill(
                        label: 'Рус',
                        active: isRu,
                        onTap: () => ref
                            .read(appLocaleProvider.notifier)
                            .setLocale(const Locale('ru')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8EAED)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  profile.when(
                    data: (value) => InkWell(
                      onTap: () => context.push('/services/settings'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            KaspiAvatar(
                              photoUrl: value?.photoUrl,
                              radius: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value?.name ?? 'Пользователь Kaspi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const Text(
                                    'Настройки',
                                    style: TextStyle(
                                      color: Color(0xFF9AA0A6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFB0B5BD),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loading: () => const SizedBox(height: 56),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kaspiServicesMenuGrid.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 2,
                      childAspectRatio: 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final item = kaspiServicesMenuGrid[index];
                      return InkWell(
                        onTap: () => context.push(item.route),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, color: kaspiPrimary, size: 30),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Частые платежи',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...kaspiFrequentPayments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: payment.iconColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                payment.icon,
                                color: payment.iconColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    payment.subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
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
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Партнерские сервисы',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...kaspiPartnerServices.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => context.push(service.route),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: service.iconBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  service.icon,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      service.subtitle,
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (service.badge.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    service.badge,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _LangPill extends StatelessWidget {
  const _LangPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? kaspiPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? kaspiPrimary : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF1C1F23),
          ),
        ),
      ),
    );
  }
}
