// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _send() async {
    final text = _controller.text.trim();
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (text.isEmpty || profile == null) {
      return;
    }
    _controller.clear();
    await ref.read(appActionsProvider).sendMessage(text, profile.name);
  }

  void _showMessageActions(ChatMessageModel message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  await Clipboard.setData(ClipboardData(text: message.text));
                  if (!sheetContext.mounted) {
                    return;
                  }
                  Navigator.pop(sheetContext);
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скопировано')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: const Text('Поделиться'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Share.share(message.text);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFED1C24),
                ),
                title: const Text(
                  'Удалить',
                  style: TextStyle(color: Color(0xFFED1C24)),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await ref
                      .read(appActionsProvider)
                      .deleteMessage(message.id);
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сообщение удалено')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final uid = ref.watch(currentUidProvider);
    return KaspiScaffold(
      title: 'Чат с Kaspi Гид',
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) => ListView.builder(
                reverse: false,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final message = items[index];
                  final isOutgoing = uid != null && message.isOutgoing(uid);
                  return Align(
                    alignment: isOutgoing
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: () => _showMessageActions(message),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        constraints: const BoxConstraints(maxWidth: 290),
                        decoration: BoxDecoration(
                          color: isOutgoing
                              ? const Color(0xFFED1C24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isOutgoing
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  AsyncValueView(child: const SizedBox.shrink(), error: error),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton.small(
                    backgroundColor: const Color(0xFFED1C24),
                    onPressed: _send,
                    child: const Icon(Icons.send_rounded),
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
