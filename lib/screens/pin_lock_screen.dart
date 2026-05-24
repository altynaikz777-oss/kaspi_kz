import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/kaspi_avatar.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  bool get _isCreateMode => !widget.profile.hasPin;

  Future<void> _submit() async {
    if (_controller.text.length != 4) {
      setState(() => _error = 'Введите 4 цифры');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final actions = ref.read(appActionsProvider);
    try {
      if (_isCreateMode) {
        await actions.savePin(_controller.text);
      } else {
        final success = await actions.verifyPin(_controller.text);
        if (!success) {
          setState(() => _error = 'Неверный PIN-код');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFED1C24),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaspiAvatar(
                      photoUrl:
                          ref
                              .watch(currentUserProfileProvider)
                              .valueOrNull
                              ?.photoUrl ??
                          widget.profile.photoUrl,
                      radius: 32,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isCreateMode ? 'Создайте PIN' : 'Введите PIN',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCreateMode
                          ? 'Закрепим быстрый вход в Kaspi для этого устройства.'
                          : 'Добро пожаловать, ${widget.profile.name}',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'PIN-код',
                        errorText: _error,
                        filled: true,
                        fillColor: const Color(0xFFF6F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFED1C24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isCreateMode ? 'Сохранить PIN' : 'Открыть'),
                      ),
                    ),
                    if (!_isCreateMode) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await ref.read(authFlowProvider.notifier).logout();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          child: const Text('Выйти из аккаунта'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
