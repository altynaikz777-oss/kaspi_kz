import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController(text: '+7');
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFlowProvider);
    final storedPhone = ref.watch(storedPhoneProvider).valueOrNull;
    final effectiveHint = storedPhone?.isNotEmpty == true
        ? storedPhone
        : '+77001234567';
    final busy = authState.isSendingCode ||
        authState.isVerifyingCode ||
        authState.isSigningInWithGoogle;

    return Scaffold(
      backgroundColor: const Color(0xFFED1C24),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Kaspi.kz',
                      style: TextStyle(
                        color: Color(0xFFED1C24),
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authState.codeSent
                          ? 'Введите код доступа'
                          : 'Введите номер телефона',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authState.codeSent
                          ? 'Код отправлен на ${authState.phoneNumber}'
                          : 'Чтобы войти или зарегистрироваться в Kaspi',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!authState.codeSent) ...[
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !busy,
                        decoration: InputDecoration(
                          labelText: 'Номер телефона',
                          hintText: effectiveHint,
                          filled: true,
                          fillColor: const Color(0xFFF6F7F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : () => ref
                                    .read(authFlowProvider.notifier)
                                    .sendCode(_phoneController.text),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFED1C24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authState.isSendingCode
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Получить код',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _AuthDivider(),
                      const SizedBox(height: 16),
                      _GoogleSignInButton(
                        loading: authState.isSigningInWithGoogle,
                        enabled: !busy,
                        onPressed: () => ref
                            .read(authFlowProvider.notifier)
                            .signInWithGoogle(),
                      ),
                    ] else ...[
                      TextField(
                        controller: _otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        enabled: !busy,
                        decoration: InputDecoration(
                          labelText: 'Код доступа',
                          filled: true,
                          fillColor: const Color(0xFFF6F7F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => ref
                                      .read(authFlowProvider.notifier)
                                      .sendCode(authState.phoneNumber),
                            child: const Text('Получить код повторно'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () {
                                    _otpController.clear();
                                    ref.read(authFlowProvider.notifier).reset();
                                  },
                            child: const Text('Изменить номер'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : () => ref
                                    .read(authFlowProvider.notifier)
                                    .verifyCode(_otpController.text),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFED1C24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authState.isVerifyingCode
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Войти',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: const TextStyle(color: Color(0xFFB42318)),
                        ),
                      ),
                    ],
                    if (!authState.codeSent) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Тестовый номер seed: +77001234567. После первого входа '
                        'профиль будет создан в стиле Kaspi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
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

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8EAED))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'или',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8EAED))),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.onPressed,
    required this.loading,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1C1F23),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE8EAED)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE8EAED)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Войти через Google',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
