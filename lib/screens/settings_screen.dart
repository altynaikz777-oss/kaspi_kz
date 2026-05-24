// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../services/avatar_upload_exception.dart';
import '../services/photo_permission_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    return KaspiScaffold(
      title: 'Настройки',
      body: profile.when(
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Профиль недоступен'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileCard(profile: value),
              const SizedBox(height: 18),
              _SettingsSwitchTile(
                title: 'Push-уведомления',
                value: value.pushNotifications,
                onChanged: (enabled) => _saveProfile(
                  ref,
                  value.copyWith(pushNotifications: enabled),
                ),
              ),
              _SettingsSwitchTile(
                title: 'Звук уведомлений',
                value: value.soundNotifications,
                onChanged: (enabled) => _saveProfile(
                  ref,
                  value.copyWith(soundNotifications: enabled),
                ),
              ),
              _SettingsSwitchTile(
                title: 'Face ID / Touch ID',
                value: value.faceId,
                onChanged: (enabled) =>
                    _saveProfile(ref, value.copyWith(faceId: enabled)),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const ListTile(
                  title: Text('Язык приложения'),
                  subtitle: Text('Русский'),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Color(0xFFED1C24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authFlowProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFED1C24),
                    side: const BorderSide(color: Color(0xFFED1C24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Выйти'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            AsyncValueView(child: const SizedBox.shrink(), error: error),
      ),
    );
  }

  Future<void> _saveProfile(WidgetRef ref, UserProfile profile) {
    return ref.read(appActionsProvider).updateProfile(profile);
  }
}

class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  bool _uploading = false;
  String? _localPhotoUrl;

  Future<void> _changePhoto() async {
    if (_uploading) {
      return;
    }
    setState(() => _uploading = true);
    try {
      final url = await ref.read(appActionsProvider).changeAvatar();
      if (!mounted) {
        return;
      }
      if (url != null) {
        setState(() => _localPhotoUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото профиля обновлено')),
        );
      }
    } on AvatarUploadException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.code == 'photo-permission-denied') {
        _showPermissionDialog();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить фото: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Нет доступа к фото'),
        content: const Text(
          'Разрешите доступ к галерее в настройках устройства, '
          'чтобы выбрать фото профиля.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await PhotoPermissionService().openSettings();
            },
            style: FilledButton.styleFrom(backgroundColor: kaspiPrimary),
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(currentUserProfileProvider).valueOrNull ?? widget.profile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaspiAvatar(
                photoUrl: _localPhotoUrl ?? profile.photoUrl,
                radius: 34,
                onTap: _changePhoto,
                showEditBadge: true,
                isLoading: _uploading,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.phone.isEmpty
                          ? 'Номер не указан'
                          : profile.phone,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploading ? null : _changePhoto,
                      icon: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_outlined, size: 18),
                      label: Text(
                        _uploading ? 'Загрузка…' : 'Изменить фото',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kaspiPrimary,
                        side: const BorderSide(color: kaspiPrimary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFED1C24),
      ),
    );
  }
}
