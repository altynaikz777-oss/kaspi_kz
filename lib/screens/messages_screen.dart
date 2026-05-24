import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final chatMessages = ref.watch(chatMessagesProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Сообщения',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Color(0xFF1C1F23),
          ),
        ),
      ),
      body: notifications.when(
        data: (notifItems) => chatMessages.when(
          data: (chatItems) => transactions.when(
            data: (txnItems) {
              final rows = _buildInboxRows(
                notifications: notifItems,
                chatMessages: chatItems,
                transactions: txnItems,
              );
              if (rows.isEmpty) {
                return const Center(
                  child: Text(
                    'Сообщений пока нет',
                    style: TextStyle(color: Color(0xFF9AA0A6)),
                  ),
                );
              }
              return ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72, color: Color(0xFFE8EAED)),
                itemBuilder: (context, index) {
                  return _InboxListTile(
                    row: rows[index],
                    onTap: () => _openRow(context, rows[index]),
                    onLongPress: () => _showActions(context, ref, rows[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  List<_InboxRow> _buildInboxRows({
    required List<NotificationModel> notifications,
    required List<ChatMessageModel> chatMessages,
    required List<TransactionModel> transactions,
  }) {
    final rows = <_InboxRow>[];

    final latestOutgoing = _latestOutgoingTransfer(transactions);
    final amountFormat = NumberFormat('#,###', 'ru_RU');

    for (final item in kaspiInboxDefaults) {
      var preview = item.preview;
      var dateLabel = item.dateLabel;
      String? chatMessageId;
      if (item.id == 'guide' && chatMessages.isNotEmpty) {
        final last = chatMessages.last;
        preview = last.text;
        chatMessageId = last.id;
      }
      if (item.id == 'gold') {
        if (latestOutgoing != null) {
          preview =
              'Перевод: ${amountFormat.format(latestOutgoing.amount)} ₸';
          final transferDate = _formatDate(latestOutgoing.date);
          if (transferDate.isNotEmpty) {
            dateLabel = transferDate;
          }
        }
      }
      rows.add(
        _InboxRow(
          id: item.id,
          title: item.title,
          preview: preview,
          dateLabel: dateLabel,
          icon: item.icon,
          iconAsset: item.iconAsset,
          iconBackground: item.iconBackground,
          iconColor: item.iconColor,
          route: item.route,
          copyText: preview,
          chatMessageId: chatMessageId,
        ),
      );
    }

    for (final notif in notifications) {
      if (_isTransferNotification(notif)) {
        continue;
      }
      rows.add(
        _InboxRow(
          id: 'notif-${notif.id}',
          title: notif.title,
          preview: notif.body,
          dateLabel: _formatDate(notif.createdAt),
          icon: Icons.notifications_none_rounded,
          iconBackground: kaspiPrimary,
          copyText: '${notif.title}\n${notif.body}',
          notificationId: notif.id,
        ),
      );
    }

    return rows;
  }

  TransactionModel? _latestOutgoingTransfer(List<TransactionModel> transactions) {
    for (final txn in transactions) {
      if (_isTransferTransaction(txn) && txn.direction == 'out') {
        return txn;
      }
    }
    return null;
  }

  bool _isTransferTransaction(TransactionModel txn) {
    final type = txn.type.toLowerCase();
    return type == 'sent' ||
        type == 'received' ||
        type == 'transfer' ||
        type == 'out' ||
        type == 'in';
  }

  bool _isTransferNotification(NotificationModel notif) {
    final title = notif.title.toLowerCase();
    final body = notif.body.toLowerCase();
    if (title.contains('списание') || title.contains('поступление')) {
      return true;
    }
    if (body.contains('transfer') ||
        body.contains('sent') ||
        body.contains('received')) {
      return true;
    }
    return false;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return DateFormat('HH:mm').format(date);
    }
    if (now.difference(date).inDays == 1) {
      return 'Вчера';
    }
    return DateFormat('dd.MM.yyyy').format(date);
  }

  void _openRow(BuildContext context, _InboxRow row) {
    final route = row.route;
    if (route != null) {
      context.push(route);
    }
  }

  void _showActions(BuildContext context, WidgetRef ref, _InboxRow row) {
    final copyText = row.copyText ?? row.preview;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Копировать'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: copyText));
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Скопировано')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: const Text('Поделиться'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Share.share(copyText);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: kaspiPrimary,
                ),
                title: const Text(
                  'Удалить',
                  style: TextStyle(color: kaspiPrimary),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (row.chatMessageId != null) {
                    await ref
                        .read(appActionsProvider)
                        .deleteMessage(row.chatMessageId!);
                  } else if (row.notificationId != null) {
                    await ref
                        .read(appActionsProvider)
                        .deleteNotification(row.notificationId!);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Удалено')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InboxRow {
  const _InboxRow({
    required this.id,
    required this.title,
    required this.preview,
    required this.dateLabel,
    required this.icon,
    required this.iconBackground,
    this.iconAsset,
    this.iconColor = Colors.white,
    this.route,
    this.copyText,
    this.chatMessageId,
    this.notificationId,
  });

  final String id;
  final String title;
  final String preview;
  final String dateLabel;
  final IconData icon;
  final String? iconAsset;
  final Color iconBackground;
  final Color iconColor;
  final String? route;
  final String? copyText;
  final String? chatMessageId;
  final String? notificationId;
}

class _InboxLeadingIcon extends StatelessWidget {
  const _InboxLeadingIcon({required this.row});

  final _InboxRow row;

  @override
  Widget build(BuildContext context) {
    final asset = row.iconAsset;
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          asset,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: row.iconBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(row.icon, color: row.iconColor, size: 24),
    );
  }
}

class _InboxListTile extends StatelessWidget {
  const _InboxListTile({
    required this.row,
    required this.onTap,
    required this.onLongPress,
  });

  final _InboxRow row;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InboxLeadingIcon(row: row),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1C1F23),
                          ),
                        ),
                      ),
                      if (row.dateLabel.isNotEmpty)
                        Text(
                          row.dateLabel,
                          style: const TextStyle(
                            color: Color(0xFF9AA0A6),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AA0A6),
                      fontSize: 14,
                      height: 1.25,
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
