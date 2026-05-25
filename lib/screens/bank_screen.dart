import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/kaspi_theme.dart';
import '../widgets/kaspi_transfer_ui.dart';

class BankServiceScreen extends ConsumerWidget {
  const BankServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: KaspiColors.background,
      appBar: const KaspiSubpageHeader(title: 'Мой Банк'),
      body: profile.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Войдите в аккаунт'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TappableBankCard(
                onTap: () => context.push('/home/transfers/client'),
                child: _GoldCardRow(
                  balance: formatGoldBalance(user.goldBalance),
                  cardMask: maskCardLast4(user.goldCardLast4),
                ),
              ),
              const SizedBox(height: 12),
              _TappableBankCard(
                onTap: () {},
                child: const _DepositOpenRow(),
              ),
              const SizedBox(height: 12),
              _TappableBankCard(
                onTap: () => context.push('/services/shop'),
                child: _BonusCardRow(
                  bonus: formatBonusBalance(user.bonusBalance),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TappableBankCard extends StatelessWidget {
  const _TappableBankCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: KaspiWhiteCard(child: child),
      ),
    );
  }
}

class _GoldCardRow extends StatelessWidget {
  const _GoldCardRow({
    required this.balance,
    required this.cardMask,
  });

  final String balance;
  final String cardMask;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const KaspiGoldIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kaspi Gold',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: KaspiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cardMask,
                style: const TextStyle(
                  fontSize: 13,
                  color: KaspiColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          balance,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: KaspiColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DepositOpenRow extends StatelessWidget {
  const _DepositOpenRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: KaspiColors.depositBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: KaspiColors.depositBlue, size: 22),
        ),
        const SizedBox(width: 12),
        const Text(
          'Открыть депозит',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: KaspiColors.depositBlue,
          ),
        ),
      ],
    );
  }
}

class _BonusCardRow extends StatelessWidget {
  const _BonusCardRow({required this.bonus});

  final String bonus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: KaspiColors.successGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Б',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Kaspi Бонус',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: KaspiColors.textPrimary,
            ),
          ),
        ),
        Text(
          bonus,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: KaspiColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
