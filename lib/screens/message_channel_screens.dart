import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../theme/kaspi_theme.dart';
import '../widgets/kaspi_network_image.dart';
import '../widgets/kaspi_transfer_ui.dart';

// ─── Shared chrome ───────────────────────────────────────────────

class _ChannelScaffold extends StatelessWidget {
  const _ChannelScaffold({
    required this.title,
    required this.leading,
    required this.body,
  });

  final String title;
  final Widget leading;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaspiColors.background,
      appBar: AppBar(
        backgroundColor: KaspiColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: KaspiColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: KaspiColors.divider),
        ),
      ),
      body: body,
    );
  }
}

String _chatDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) {
    return 'Сегодня';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Вчера';
  }
  return DateFormat('dd.MM.yyyy').format(date);
}

Widget _dateSeparator(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Center(
      child: label == 'Сегодня' || label.contains('.')
          ? Text(
              label,
              style: const TextStyle(
                color: KaspiColors.textSecondary,
                fontSize: 13,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: KaspiColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
    ),
  );
}

// ─── Kaspi Gold chat ─────────────────────────────────────────────

class KaspiGoldChatScreen extends ConsumerWidget {
  const KaspiGoldChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(walletTransactionsProvider);

    return _ChannelScaffold(
      title: 'Kaspi Gold',
      leading: const KaspiGoldIcon(size: 32),
      body: txns.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Операций пока нет',
                style: TextStyle(color: KaspiColors.textSecondary),
              ),
            );
          }
          final chronological = items.reversed.toList();
          String? lastDate;
          final children = <Widget>[];
          for (final txn in chronological) {
            final date = txn.timestamp;
            if (date != null) {
              final label = _chatDateLabel(date);
              if (label != lastDate) {
                children.add(_dateSeparator(label));
                lastDate = label;
              }
            }
            children.add(_GoldTxnBubble(txn: txn));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: children,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _GoldTxnBubble extends StatelessWidget {
  const _GoldTxnBubble({required this.txn});

  final WalletTransaction txn;

  String get _title {
    if (txn.type == 'sent') {
      return 'Перевод';
    }
    if (txn.message == 'purchase' || txn.type == 'purchase') {
      return 'Покупка';
    }
    return 'Пополнение';
  }

  @override
  Widget build(BuildContext context) {
    final time = txn.timestamp == null
        ? ''
        : DateFormat('HH:mm').format(txn.timestamp!);
    final balance = formatGoldBalance(txn.balanceAfter);

    if (txn.isSent) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_title: ${txn.amount} ₸',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(txn.counterpartyName),
                const SizedBox(height: 4),
                Text('Доступно: $balance'),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: KaspiColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFB0B5BD),
            child: Text(
              txn.counterpartyName.isNotEmpty
                  ? txn.counterpartyName[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KaspiColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_title: ${txn.amount} ₸',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(txn.counterpartyName),
                  const SizedBox(height: 4),
                  Text('Доступно: $balance'),
                  if (txn.message == 'purchase' || txn.type == 'purchase')
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Чек об оплате',
                        style: TextStyle(
                          color: KaspiColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: KaspiColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Guide FAQ chat ──────────────────────────────────────────────

class GuideChannelScreen extends StatefulWidget {
  const GuideChannelScreen({super.key});

  static const _faq = [
    (
      time: '10:00',
      text:
          'Здравствуйте! Я Kaspi Гид. Задайте вопрос о карте, переводах или платежах.',
    ),
    (
      time: '10:01',
      text:
          'Как получить карту Kaspi Gold?\nОформите карту в разделе «Мой Банк» → Kaspi Gold.',
    ),
    (
      time: '10:02',
      text:
          'Как перевести деньги клиенту Kaspi?\nСервисы → Переводы → Клиенту Kaspi.',
    ),
    (
      time: '10:03',
      text:
          'Где посмотреть историю операций?\nОткройте Kaspi Gold в сообщениях.',
    ),
  ];

  @override
  State<GuideChannelScreen> createState() => _GuideChannelScreenState();
}

class _GuideChatMessage {
  const _GuideChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  String get time => DateFormat('HH:mm').format(timestamp);

  factory _GuideChatMessage.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _GuideChatMessage(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      isUser: data['isUser'] == true,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class _GuideChannelScreenState extends State<GuideChannelScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_GuideChatMessage> _messages = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _messagesSubscription;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>>? get _messagesRef {
    final uid = _uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('kaspiGidMessages');
  }

  Future<void> _initializeChat() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    _uid = uid;
    _messagesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('kaspiGidMessages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) {
            return;
          }
          setState(() {
            _messages
              ..clear()
              ..addAll(
                snapshot.docs
                    .where((doc) => doc.data()['isDeleted'] != true)
                    .map(_GuideChatMessage.fromDoc),
              );
          });
          _scrollToBottom();
        });
    await _ensureInitialMessages();
  }

  Future<void> _ensureInitialMessages() async {
    final messagesRef = _messagesRef;
    if (messagesRef == null) {
      return;
    }
    final existing = await messagesRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < GuideChannelScreen._faq.length; i++) {
      final item = GuideChannelScreen._faq[i];
      final parts = item.time.split(':');
      final hour = int.tryParse(parts.first) ?? 10;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final timestamp = DateTime(now.year, now.month, now.day, hour, minute);
      batch.set(messagesRef.doc(), {
        'text': item.text,
        'isUser': false,
        'timestamp': Timestamp.fromDate(timestamp.add(Duration(minutes: i))),
        'isDeleted': false,
      });
    }
    await batch.commit();
  }

  String _guideReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('карт') || lower.contains('gold')) {
      return 'Оформите Kaspi Gold в разделе «Мой Банк» → Kaspi Gold.';
    }
    if (lower.contains('перевод')) {
      return 'Откройте Сервисы → Переводы → Клиенту Kaspi и введите номер получателя.';
    }
    if (lower.contains('платеж') || lower.contains('оплат')) {
      return 'Платежи доступны в разделе «Сервисы» → Платежи.';
    }
    if (lower.contains('истори') || lower.contains('операц')) {
      return 'Историю операций смотрите в сообщениях → Kaspi Gold.';
    }
    return 'Спасибо за вопрос! Напишите подробнее: карта, переводы, платежи или история.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    final messagesRef = _messagesRef;
    if (text.isEmpty || messagesRef == null) {
      return;
    }
    _textController.clear();

    await messagesRef.add({
      'text': text,
      'isUser': true,
      'timestamp': Timestamp.now(),
      'isDeleted': false,
    });
    final now = DateTime.now();
    await messagesRef.add({
      'text': _guideReply(text),
      'isUser': false,
      'timestamp': Timestamp.fromDate(now.add(const Duration(seconds: 1))),
      'isDeleted': false,
    });
  }

  Future<void> _showMessageOptions(_GuideChatMessage message) async {
    final uid = _uid;
    if (uid == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.black),
              title: const Text('Скопировать'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: message.text));
                if (!mounted) {
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Скопировано')));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.forward, color: Colors.black),
              title: const Text('Переслать'),
              onTap: () async {
                Navigator.pop(context);
                await Clipboard.setData(
                  ClipboardData(text: 'Переслано: ${message.text}'),
                );
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Сообщение скопировано для пересылки'),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            if (message.isUser)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('kaspiGidMessages')
                      .doc(message.id)
                      .update({'isDeleted': true});
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessageWidgets() {
    final widgets = <Widget>[];
    String? currentDateLabel;

    for (final message in _messages) {
      final nextDateLabel = _chatDateLabel(message.timestamp);
      if (nextDateLabel != currentDateLabel) {
        currentDateLabel = nextDateLabel;
        widgets.add(_dateSeparator(nextDateLabel));
      }

      final bubble = message.isUser
          ? _GuideUserBubble(message: message)
          : _GuideAssistantBubble(message: message);

      widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () => _showMessageOptions(message),
          child: bubble,
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return _ChannelScaffold(
      title: 'Чат с Kaspi Гид',
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kaspiPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: _buildMessageWidgets(),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: KaspiColors.card,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        filled: true,
                        fillColor: const Color(0xFFF2F2F7),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: KaspiColors.primaryBlue,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _send,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideUserBubble extends StatelessWidget {
  const _GuideUserBubble({required this.message});

  final _GuideChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A56DB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideAssistantBubble extends StatelessWidget {
  const _GuideAssistantBubble({required this.message});

  final _GuideChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _GuideAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.black, height: 1.35),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: KaspiColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideAvatar extends StatelessWidget {
  const _GuideAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: kaspiPrimary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'K',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Promotions channel ──────────────────────────────────────────

class PromotionsChannelScreen extends StatefulWidget {
  const PromotionsChannelScreen({super.key});

  @override
  State<PromotionsChannelScreen> createState() =>
      _PromotionsChannelScreenState();
}

class _PromotionsChannelScreenState extends State<PromotionsChannelScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return _ChannelScaffold(
      title: 'Акции',
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kaspiPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.card_giftcard, color: Colors.white, size: 18),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Все акции',
                  selected: _filter == 0,
                  onTap: () => setState(() => _filter = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Скидки',
                  selected: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Бонусы',
                  selected: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _dateSeparator('20.05.2026'),
                _PromoMessageCard(
                  avatar: _ChannelAvatar(
                    color: kaspiPrimary,
                    icon: Icons.card_giftcard,
                  ),
                  time: '14:11',
                  imageUrl:
                      'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=600&q=85&auto=format&fit=crop',
                  badge: 'до -70%',
                  body:
                      'Fashion Скидки на Kaspi.kz! Любимые бренды в подборке – успейте выгодно обновить гардероб:\n'
                      '• До -70% на одежду и обувь\n'
                      '• LC Waikiki, Colin\'s и не только\n'
                      'Акция только сегодня.',
                  buttonLabel: 'Перейти к подборке',
                  onTap: () => context.push('/services/shop'),
                ),
                const SizedBox(height: 12),
                _PromoMessageCard(
                  avatar: _ChannelAvatar(
                    color: kaspiPrimary,
                    icon: Icons.card_giftcard,
                  ),
                  time: '14:00',
                  imageUrl:
                      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&q=85&auto=format&fit=crop',
                  badge: 'до -50%',
                  body:
                      'Скидки до 50%! Помада, тушь, румяна или сразу всё – заказывайте бьюти-хиты.',
                  buttonLabel: 'Купить сейчас',
                  onTap: () => context.push('/services/shop'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kaspiPrimary : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : KaspiColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PromoMessageCard extends StatelessWidget {
  const _PromoMessageCard({
    required this.avatar,
    required this.time,
    required this.imageUrl,
    required this.badge,
    required this.body,
    required this.buttonLabel,
    required this.onTap,
  });

  final Widget avatar;
  final String time;
  final String imageUrl;
  final String badge;
  final String body;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      KaspiNetworkImage(
                        imageUrl: imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kaspiPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body, style: const TextStyle(height: 1.35)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: KaspiColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(buttonLabel),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KaspiColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Remote payment ──────────────────────────────────────────────

class RemotePaymentChannelScreen extends StatelessWidget {
  const RemotePaymentChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChannelScaffold(
      title: 'Удаленная оплата',
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5C518),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.payment, color: Colors.white, size: 18),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dateSeparator('15.05.2026'),
          _LeftBubble(
            avatar: const _ChannelAvatar(color: Color(0xFF636366), label: 'T'),
            time: '13:56',
            child: _PaymentCard(
              amount: '12 100 ₸',
              merchant: 'ТОО "ТАРАЗ ОПТИКА СЕРВИС"',
              address: 'г. Тараз, пр. Абая д. 141',
              sellerMessage: 'Мягкие контактные линзы,Раствор для МКЛ',
              cancelled: false,
            ),
          ),
          _dateSeparator('16.05.2026'),
          _LeftBubble(
            avatar: const _ChannelAvatar(color: Color(0xFF636366), label: 'T'),
            time: '13:47',
            child: _PaymentCard(
              amount: '13 400 ₸',
              merchant: 'ТОО "ТАРАЗ ОПТИКА СЕРВИС"',
              address: 'г. Тараз, пр. Абая д. 141',
              sellerMessage:
                  'Мягкие контактные линзы,Раствор для МКЛ,Контейн...',
              cancelled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.amount,
    required this.merchant,
    required this.address,
    required this.sellerMessage,
    required this.cancelled,
  });

  final String amount;
  final String merchant;
  final String address;
  final String sellerMessage;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cancelled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF3A3A3C),
              child: const Text(
                'Счет отменен',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (cancelled) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Вы не оплатили счет в течение 24 часов',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.store, color: kaspiPrimary, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(merchant)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, color: kaspiPrimary, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(address)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Сообщение продавца',
                  style: TextStyle(
                    color: KaspiColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sellerMessage),
                ),
                if (!cancelled)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Чек об оплате',
                      style: TextStyle(
                        color: KaspiColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Jobs channel ────────────────────────────────────────────────

class JobsChannelScreen extends StatelessWidget {
  const JobsChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChannelScaffold(
      title: 'Kaspi Работа',
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kaspiPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.work_outline, color: Colors.white, size: 18),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dateSeparator('01.05.2026'),
          _LeftBubble(
            avatar: _ChannelAvatar(
              color: kaspiPrimary,
              icon: Icons.work_outline,
            ),
            time: '21:06',
            child: const Text(
              'Мы советуем вам:\n'
              '• Переписываться только в приложении\n'
              '• Не переходить по ссылкам из WhatsApp и Telegram\n'
              '• Не сообщать данные вашей карты посторонним',
            ),
          ),
          _dateSeparator('09.05.2026'),
          _LeftBubble(
            avatar: _ChannelAvatar(
              color: kaspiPrimary,
              icon: Icons.work_outline,
            ),
            time: '12:30',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Рекламируйте резюме, чтобы получить больше предложений о работе',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: KaspiColors.divider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.image_not_supported, color: Color(0xFFB0B5BD)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UX/UI-дизайнер'),
                            Text(
                              'Договорная',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: KaspiColors.primaryBlue,
                    ),
                    child: const Text('Рекламировать'),
                  ),
                ),
              ],
            ),
          ),
          _LeftBubble(
            avatar: _ChannelAvatar(
              color: kaspiPrimary,
              icon: Icons.work_outline,
            ),
            time: '18:45',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('У вас 1 непрочитанное сообщение от работодателя'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: KaspiColors.primaryBlue,
                    ),
                    child: const Text('Посмотреть'),
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

// ─── Bonus channel ───────────────────────────────────────────────

class BonusChannelScreen extends StatelessWidget {
  const BonusChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChannelScaffold(
      title: 'Kaspi Бонус',
      leading: Container(
        width: 32,
        height: 32,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dateSeparator('16.04.2026'),
          _LeftBubble(
            avatar: const _BonusAvatar(),
            time: '08:20',
            child: _BonusTxnCard(
              purchase: 580,
              merchant: 'The first',
              balance: 919,
            ),
          ),
          _dateSeparator('05.05.2026'),
          _LeftBubble(
            avatar: const _BonusAvatar(),
            time: '18:09',
            child: _BonusTxnCard(
              purchase: 919,
              merchant: 'ИП ASYL MENS',
              balance: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BonusAvatar extends StatelessWidget {
  const _BonusAvatar();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: KaspiColors.successGreen,
      child: const Text(
        'Б',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _BonusTxnCard extends StatelessWidget {
  const _BonusTxnCard({
    required this.purchase,
    required this.merchant,
    required this.balance,
  });

  final int purchase;
  final String merchant;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Покупка: $purchase Б',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(merchant),
        const SizedBox(height: 4),
        Text('Баланс: $balance Б'),
        const SizedBox(height: 8),
        const Text(
          'Чек об оплате',
          style: TextStyle(
            color: KaspiColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Shared bubbles ──────────────────────────────────────────────

class _ChannelAvatar extends StatelessWidget {
  const _ChannelAvatar({this.color, this.icon, this.label});

  final Color? color;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color ?? kaspiPrimary,
      child: label != null
          ? Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _LeftBubble extends StatelessWidget {
  const _LeftBubble({
    required this.avatar,
    required this.time,
    required this.child,
  });

  final Widget avatar;
  final String time;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          avatar,
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: KaspiColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
