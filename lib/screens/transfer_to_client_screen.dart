import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_models.dart';
import '../models/transfer_models.dart';
import '../providers/app_providers.dart';
import '../theme/kaspi_theme.dart';
import '../utils/phone_utils.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_network_image.dart';
import '../widgets/kaspi_transfer_ui.dart';

class TransferToClientScreen extends ConsumerStatefulWidget {
  const TransferToClientScreen({super.key});

  @override
  ConsumerState<TransferToClientScreen> createState() =>
      _TransferToClientScreenState();
}

class _TransferToClientScreenState extends ConsumerState<TransferToClientScreen> {
  int _methodIndex = 0;
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _amountController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _phoneController.text = formatKzPhoneDisplay('+77052737122');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        ref.read(firestoreServiceProvider).ensureWalletFields(uid);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _amount =>
      int.tryParse(_amountController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  bool get _phoneComplete => isCompleteKzPhone(_phoneController.text);

  void _goConfirm(UserProfile recipient, UserProfile sender) {
    if (_amount <= 0) {
      return;
    }
    context.push(
      '/services/transfers/client/confirm',
      extra: TransferDraft(
        amount: _amount,
        recipientUid: recipient.id,
        recipientName: recipient.name,
        phone: normalizeKzPhone(_phoneController.text),
        message: _messageController.text.trim(),
        senderBalance: sender.goldBalance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final phone = _phoneController.text;
    final recipientAsync = _phoneComplete
        ? ref.watch(recipientByPhoneProvider(phone))
        : const AsyncValue<UserProfile?>.data(null);

    return Scaffold(
      backgroundColor: KaspiColors.background,
      appBar: const KaspiSubpageHeader(title: 'Клиенту Kaspi'),
      body: profile.when(
        data: (sender) {
          if (sender == null) {
            return const Center(child: Text('Войдите в аккаунт'));
          }
          final balanceLabel = formatGoldBalance(sender.goldBalance);
          final recipient = recipientAsync.valueOrNull;
          final loadingRecipient = _phoneComplete && recipientAsync.isLoading;
          final notFound = _phoneComplete &&
              recipientAsync.hasValue &&
              recipient == null;

          final isSelf = recipient?.id == sender.id;
          final canSubmit = recipient != null &&
              !isSelf &&
              _amount > 0 &&
              !loadingRecipient;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    KaspiGoldAccountRow(
                      title: 'Kaspi Gold',
                      balance: balanceLabel,
                    ),
                    const KaspiFlowChevron(),
                    KaspiMethodTabs(
                      index: _methodIndex,
                      onChanged: (i) => setState(() => _methodIndex = i),
                    ),
                    const SizedBox(height: 16),
                    _PhoneSection(
                      controller: _phoneController,
                      loading: loadingRecipient,
                      notFound: notFound || isSelf,
                      recipient: isSelf ? null : recipient,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    KaspiWhiteCard(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: KaspiColors.textPrimary,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          suffixText: '₸',
                          suffixStyle: TextStyle(
                            fontSize: 32,
                            color: KaspiColors.textPrimary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: KaspiColors.divider),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: KaspiColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    KaspiWhiteCard(
                      child: TextField(
                        controller: _messageController,
                        maxLength: 50,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Сообщение получателю',
                          hintStyle: const TextStyle(
                            color: KaspiColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          counterText:
                              '${_messageController.text.length}/50',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Рақмет!', 'За обед', 'Возвращаю :)'].map((chip) {
                        return OutlinedButton(
                          onPressed: () {
                            _messageController.text = chip;
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KaspiColors.textPrimary,
                            side: const BorderSide(color: KaspiColors.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          child: Text(chip),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: KaspiPrimaryButton(
                  label: 'Перевести $_amount ₸',
                  enabled: canSubmit,
                  onPressed: canSubmit
                      ? () => _goConfirm(recipient!, sender)
                      : null,
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

class _PhoneSection extends StatelessWidget {
  const _PhoneSection({
    required this.controller,
    required this.loading,
    required this.notFound,
    required this.recipient,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool loading;
  final bool notFound;
  final UserProfile? recipient;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final hasRecipient = recipient != null;
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Телефон получателя',
                        style: TextStyle(
                          color: KaspiColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [KzPhoneInputFormatter()],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: KaspiColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.only(top: 4),
                        ),
                        onChanged: (_) => onChanged(),
                      ),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      if (notFound)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Клиент не найден',
                            style: TextStyle(
                              color: KaspiColors.errorRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: KaspiColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          if (hasRecipient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: KaspiColors.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Деньги поступят на карту Kaspi Gold',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TransferConfirmScreen extends ConsumerStatefulWidget {
  const TransferConfirmScreen({super.key, required this.draft});

  final TransferDraft draft;

  @override
  ConsumerState<TransferConfirmScreen> createState() =>
      _TransferConfirmScreenState();
}

class _TransferConfirmScreenState extends ConsumerState<TransferConfirmScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(appActionsProvider).executeTransfer(
            recipientUid: widget.draft.recipientUid,
            amount: widget.draft.amount,
            recipientName: widget.draft.recipientName,
            recipientPhone: widget.draft.phone,
            message: widget.draft.message,
          );
      if (!mounted) {
        return;
      }
      ref.read(transferSuccessDraftProvider.notifier).state = widget.draft;
      context.pop();
      context.push('/services/transfers/client/success');
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider);
    final balanceLabel = profile.maybeWhen(
      data: (p) => p == null ? '—' : formatGoldBalance(p.goldBalance),
      orElse: () => formatGoldBalance(widget.draft.senderBalance),
    );

    return Scaffold(
      backgroundColor: KaspiColors.background,
      appBar: const KaspiSubpageHeader(title: 'Клиенту Kaspi'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                KaspiGoldAccountRow(
                  title: 'Kaspi Gold',
                  balance: balanceLabel,
                ),
                const KaspiFlowChevron(),
                KaspiGoldAccountRow(
                  title: widget.draft.recipientName,
                  showBalance: false,
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  label: 'Сумма перевода',
                  value: '${widget.draft.amount} ₸',
                ),
                const Divider(color: KaspiColors.divider, height: 24),
                const _DetailRow(label: 'Комиссия', value: '0 ₸'),
                const Divider(color: KaspiColors.divider, height: 24),
                _DetailRow(
                  label: 'Сумма списания',
                  value: '${widget.draft.totalDebit} ₸',
                  bold: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: KaspiPrimaryButton(
              label: 'Подтвердить и перевести ${widget.draft.amount} ₸',
              enabled: !_submitting,
              onPressed: _submitting ? null : _confirm,
            ),
          ),
          if (_submitting)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: KaspiColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: KaspiColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

String _transferShortName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) {
    return fullName;
  }
  if (parts.length == 1) {
    return parts.first;
  }
  return '${parts.first} ${parts.last[0]}.';
}

final _transferAmountFormat = NumberFormat('#,###', 'ru_RU');
final _transferBonusFormat = NumberFormat('#,###', 'ru_RU');

int _transferProductBonus(ProductModel product) =>
    (product.price * 0.0395).round();

class TransferSuccessScreen extends ConsumerStatefulWidget {
  const TransferSuccessScreen({super.key});

  @override
  ConsumerState<TransferSuccessScreen> createState() =>
      _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends ConsumerState<TransferSuccessScreen> {
  bool _saveToFavorites = false;

  void _returnToTransfers() {
    ref.read(transferSuccessDraftProvider.notifier).state = null;
    context.go('/services/transfers');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(transferSuccessDraftProvider);
    if (draft == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final featured = ref.watch(featuredProductsProvider);
    final amountText = '${_transferAmountFormat.format(draft.amount)} ₸';
    final recipientLabel = _transferShortName(draft.recipientName);

    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Переводы',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: KaspiColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: KaspiColors.successGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Ваш перевод совершен',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KaspiColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              amountText,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: KaspiColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _TransferSuccessActionsCard(
            recipientLabel: recipientLabel,
            saveToFavorites: _saveToFavorites,
            onReceiptTap: () => context.push('/services/history'),
            onFavoritesChanged: (value) {
              setState(() => _saveToFavorites = value);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Вас могут заинтересовать',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: KaspiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          featured.when(
            data: (items) => SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length.clamp(0, 8),
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final product = items[index];
                  return _TransferSuccessProductCard(
                    product: product,
                    onTap: () => context.push('/product/${product.id}'),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: KaspiPrimaryButton(
              label: 'Вернуться в Переводы',
              onPressed: _returnToTransfers,
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _TransferSuccessActionsCard extends StatelessWidget {
  const _TransferSuccessActionsCard({
    required this.recipientLabel,
    required this.saveToFavorites,
    required this.onReceiptTap,
    required this.onFavoritesChanged,
  });

  final String recipientLabel;
  final bool saveToFavorites;
  final VoidCallback onReceiptTap;
  final ValueChanged<bool> onFavoritesChanged;

  static const _kaspiRed = Color(0xFFED1C24);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KaspiColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onReceiptTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: _kaspiRed,
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Показать квитанцию',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: KaspiColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Квитанция сохранена в Истории',
                            style: TextStyle(
                              fontSize: 13,
                              color: KaspiColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: KaspiColors.textSecondary.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: KaspiColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.star_border_rounded,
                  color: _kaspiRed,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipientLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: KaspiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Сохранить в Частые',
                        style: TextStyle(
                          fontSize: 13,
                          color: KaspiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: saveToFavorites,
                  onChanged: onFavoritesChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferSuccessProductCard extends StatelessWidget {
  const _TransferSuccessProductCard({
    required this.product,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const width = 156.0;
    final bonusLabel =
        '${_transferBonusFormat.format(_transferProductBonus(product))} Б';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: KaspiColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KaspiColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: width * 0.88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: KaspiColors.successGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bonusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: KaspiColors.textPrimary,
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
