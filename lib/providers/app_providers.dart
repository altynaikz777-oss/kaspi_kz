import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/auth_models.dart';
import '../models/app_models.dart';
import '../models/transfer_models.dart';
import '../services/auth_service.dart';
import '../services/avatar_image_processor.dart';
import '../services/avatar_upload_exception.dart';
import '../services/firestore_service.dart';
import '../services/photo_permission_service.dart';
import '../services/session_storage_service.dart';
import '../services/locale_storage_service.dart';
import '../services/storage_service.dart';
import '../utils/phone_utils.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final storageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(ref.watch(firestoreProvider)),
);
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(storageProvider)),
);
final sessionStorageServiceProvider = Provider<SessionStorageService>(
  (ref) => SessionStorageService(ref.watch(secureStorageProvider)),
);
final localeStorageServiceProvider = Provider<LocaleStorageService>(
  (ref) => LocaleStorageService(),
);
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
final photoPermissionServiceProvider = Provider<PhotoPermissionService>(
  (ref) => PhotoPermissionService(),
);

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((
  ref,
) {
  return AppLocaleNotifier(ref.watch(localeStorageServiceProvider));
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier(this._storage) : super(const Locale('ru')) {
    _load();
  }

  final LocaleStorageService _storage;

  Future<void> _load() async {
    state = await _storage.readLocale();
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.saveLocale(locale);
  }
}

final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(sessionStorageServiceProvider).setPinUnlocked(false);
  final firestore = ref.read(firestoreServiceProvider);
  await firestore.seedShopCatalogIfNeeded();
  await firestore.ensureDemoRecipient();
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await firestore.ensureWalletFields(user.uid);
    await firestore.applyOneTimeTopUp(
      uid: user.uid,
      amount: 3000,
      creditKey: 'support_top_up_2026_05_24',
      counterpartyName: 'Kaspi Support',
      message: 'Пополнение баланса на 3000 ₸',
    );
  }
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref
      .watch(authStateProvider)
      .maybeWhen(data: (user) => user?.uid, orElse: () => null);
});

final pinVerifiedProvider = StateProvider<bool>((ref) => false);
final storedPhoneProvider = FutureProvider<String?>((ref) {
  return ref.read(sessionStorageServiceProvider).readStoredPhone();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchUserProfile(uid);
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).watchCategories();
});

final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firestoreServiceProvider).watchFeaturedProducts();
});

final productsByCategoryProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, categoryId) {
      return ref
          .watch(firestoreServiceProvider)
          .watchProductsByCategory(categoryId);
    });

final productProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  productId,
) {
  return ref.watch(firestoreServiceProvider).getProduct(productId);
});

final searchResultsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, query) {
    return ref.watch(firestoreServiceProvider).searchProducts(query);
  },
);

final globalSearchProvider =
    FutureProvider.family<List<GlobalSearchResult>, String>((ref, query) {
      return ref.watch(firestoreServiceProvider).globalSearch(query);
    });

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchNotifications(uid);
});

final cartItemsProvider = StreamProvider<List<CartItemModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchCart(uid);
});

final wishlistItemsProvider = StreamProvider<List<WishlistItemModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchWishlist(uid);
});

final viewedProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchViewedProducts(uid);
});

final searchHistoryProvider = StreamProvider<List<SearchQueryModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchSearchHistory(uid);
});

final walletTransactionsProvider = StreamProvider<List<WalletTransaction>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchWalletTransactions(uid);
});

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchTransactions(uid);
});

/// Persists transfer result across GoRouter refresh (profile balance updates).
final transferSuccessDraftProvider = StateProvider<TransferDraft?>(
  (ref) => null,
);

final ordersProvider = StreamProvider<List<OrderModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchOrders(uid);
});

final recipientByPhoneProvider = FutureProvider.autoDispose
    .family<UserProfile?, String>((ref, rawPhone) {
      if (!isCompleteKzPhone(rawPhone)) {
        return null;
      }
      return ref.watch(firestoreServiceProvider).findUserByPhone(rawPhone);
    });

final chatMessagesProvider = StreamProvider<List<ChatMessageModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchChatMessages(uid);
});

class AuthFlowController extends StateNotifier<AuthFlowState> {
  AuthFlowController(this.ref) : super(const AuthFlowState());

  final Ref ref;

  AuthService get _auth => ref.read(authServiceProvider);
  FirestoreService get _firestore => ref.read(firestoreServiceProvider);
  SessionStorageService get _session => ref.read(sessionStorageServiceProvider);

  String _normalizePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    if (cleaned.startsWith('8')) {
      return '+7${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('7')) {
      return '+$cleaned';
    }
    return raw.trim();
  }

  Future<void> sendCode(String rawPhone) async {
    final phoneNumber = _normalizePhone(rawPhone);
    if (phoneNumber.length < 12) {
      state = state.copyWith(
        errorMessage: 'Введите номер в формате +7XXXXXXXXXX',
        clearError: false,
      );
      return;
    }
    state = state.copyWith(
      phoneNumber: phoneNumber,
      isSendingCode: true,
      isVerifyingCode: false,
      clearError: true,
    );
    await _auth.startPhoneSignIn(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId, _) {
        state = state.copyWith(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          codeSent: true,
          isSendingCode: false,
          clearError: true,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isSendingCode: false,
          errorMessage: _mapAuthError(error),
        );
      },
      onAutoVerified: (credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          await _finalizeSignIn(
            userCredential.user,
            sessionKey: phoneNumber,
            phoneNumber: phoneNumber,
          );
        } on FirebaseAuthException catch (error) {
          state = state.copyWith(
            isSendingCode: false,
            errorMessage: _mapAuthError(error),
          );
        }
      },
    );
  }

  Future<void> verifyCode(String code) async {
    if (code.trim().length < 6) {
      state = state.copyWith(errorMessage: 'Введите 6-значный код доступа');
      return;
    }
    state = state.copyWith(isVerifyingCode: true, clearError: true);
    try {
      final userCredential = await _auth.verifyOtp(
        smsCode: code.trim(),
        verificationId: state.verificationId,
      );
      await _finalizeSignIn(
        userCredential.user,
        sessionKey: state.phoneNumber,
        phoneNumber: state.phoneNumber,
      );
      state = const AuthFlowState();
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(
        isVerifyingCode: false,
        errorMessage: _mapAuthError(error),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      isSigningInWithGoogle: true,
      isSendingCode: false,
      isVerifyingCode: false,
      clearError: true,
    );
    try {
      final credential = await _auth.signInWithGoogle();
      if (credential == null) {
        state = state.copyWith(isSigningInWithGoogle: false);
        return;
      }
      final user = credential.user;
      final sessionKey = user?.phoneNumber ?? user?.email ?? user?.uid ?? '';
      await _finalizeSignIn(
        user,
        sessionKey: sessionKey,
        phoneNumber: user?.phoneNumber ?? '',
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
      );
      state = const AuthFlowState();
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(
        isSigningInWithGoogle: false,
        errorMessage: _mapGoogleAuthError(error),
      );
    } catch (_) {
      state = state.copyWith(
        isSigningInWithGoogle: false,
        errorMessage: 'Не удалось войти через Google. Попробуйте еще раз.',
      );
    }
  }

  Future<void> _finalizeSignIn(
    User? user, {
    required String sessionKey,
    String phoneNumber = '',
    String? displayName,
    String? photoUrl,
  }) async {
    if (user == null) {
      state = state.copyWith(
        isSendingCode: false,
        isVerifyingCode: false,
        isSigningInWithGoogle: false,
        errorMessage: 'Не удалось авторизоваться. Попробуйте еще раз.',
      );
      return;
    }
    await _firestore.ensureUserProfile(
      uid: user.uid,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
    );
    await _session.persistAuthSession(uid: user.uid, phoneNumber: sessionKey);
    await _session.setPinUnlocked(false);
    ref.read(pinVerifiedProvider.notifier).state = false;
    state = const AuthFlowState();
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _session.clear();
    ref.read(pinVerifiedProvider.notifier).state = false;
    state = const AuthFlowState();
  }

  void reset() {
    state = const AuthFlowState();
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-verification-code':
      case 'invalid-code':
        return 'Неверный код доступа. Проверьте код и попробуйте снова.';
      case 'session-expired':
        return 'Срок действия кода истек. Запросите новый код.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже.';
      case 'invalid-phone-number':
        return 'Некорректный номер телефона.';
      case 'missing-confirmation':
        return 'Сначала запросите код доступа.';
      default:
        return error.message ?? 'Не удалось выполнить вход.';
    }
  }

  String _mapGoogleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-closed-by-user':
        return 'Вход через Google отменен';
      case 'account-exists-with-different-credential':
        return 'Этот email уже привязан к другому способу входа';
      case 'network-request-failed':
        return 'Проверьте интернет и попробуйте снова';
      case 'web-context-cancelled':
        return 'Вход через Google отменен';
      default:
        return error.message ?? 'Не удалось войти через Google';
    }
  }
}

final authFlowProvider =
    StateNotifierProvider<AuthFlowController, AuthFlowState>(
      (ref) => AuthFlowController(ref),
    );

class AppActions {
  AppActions(this.ref);

  final Ref ref;

  FirestoreService get _firestore => ref.read(firestoreServiceProvider);

  String? get _uidOrNull => ref.read(currentUidProvider);

  Future<void> savePin(String pin) async {
    final uid = _uidOrNull;
    if (uid == null) {
      return;
    }
    await _firestore.savePin(uid, pin);
    await ref.read(sessionStorageServiceProvider).setPinUnlocked(true);
    ref.read(pinVerifiedProvider.notifier).state = true;
  }

  Future<bool> verifyPin(String pin) async {
    final uid = _uidOrNull;
    if (uid == null) {
      return false;
    }
    final success = await _firestore.verifyPin(uid, pin);
    if (success) {
      await ref.read(sessionStorageServiceProvider).setPinUnlocked(true);
    }
    ref.read(pinVerifiedProvider.notifier).state = success;
    return success;
  }

  Future<void> addToCart(ProductModel product) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.addToCart(uid, product);
  }

  Future<void> updateCartQuantity(String productId, int quantity) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.updateCartQuantity(uid, productId, quantity);
  }

  Future<void> removeFromCart(String productId) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.removeFromCart(uid, productId);
  }

  Future<void> toggleWishlist(ProductModel product, bool exists) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.toggleWishlist(uid, product, exists);
  }

  Future<void> trackViewedProduct(ProductModel product) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.addViewedProduct(uid, product);
  }

  Future<void> recordSearch(String query) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.addSearchHistory(uid, query);
  }

  Future<void> sendMessage(String text, String senderName) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.sendChatMessage(
      uid: uid,
      text: text,
      senderName: senderName,
    );
  }

  Future<void> deleteMessage(String messageId) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.deleteChatMessage(uid: uid, messageId: messageId);
  }

  Future<void> deleteNotification(String notificationId) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.deleteNotification(
      uid: uid,
      notificationId: notificationId,
    );
  }

  Future<void> checkout(UserProfile profile, List<CartItemModel> items) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.createOrderFromCart(
      uid: uid,
      profile: profile,
      items: items,
    );
  }

  Future<UserProfile?> findUserByPhone(String phone) {
    return _firestore.findUserByPhone(phone);
  }

  Future<void> executeTransfer({
    required String recipientUid,
    required int amount,
    required String recipientName,
    required String recipientPhone,
    String message = '',
  }) async {
    final uid = _uidOrNull;
    if (uid == null) {
      throw StateError('Необходимо войти в аккаунт');
    }
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) {
      throw StateError('Профиль не загружен');
    }
    return _firestore.executeTransfer(
      senderUid: uid,
      recipientUid: recipientUid,
      amount: amount,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      senderName: profile.name,
      message: message,
    );
  }

  Future<void> updateProfile(UserProfile profile) {
    final uid = _uidOrNull;
    if (uid == null) {
      return Future.value();
    }
    return _firestore.updateProfile(uid, profile);
  }

  /// Picks a gallery photo, uploads to Storage, saves URL in Firestore.
  /// Returns the new download URL, or null if the user cancelled picking.
  Future<String?> changeAvatar() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? _uidOrNull;
    if (uid == null) {
      throw const AvatarUploadException(
        'Войдите в аккаунт, чтобы изменить фото профиля',
      );
    }

    final permissionState = await ref
        .read(photoPermissionServiceProvider)
        .ensureGalleryAccess();
    print('Avatar permission state: $permissionState');
    if (permissionState == PhotoAccessState.permanentlyDenied ||
        permissionState == PhotoAccessState.denied) {
      throw const AvatarUploadException(
        'Нет доступа к фото. Разрешите доступ к галерее в настройках устройства.',
        code: 'photo-permission-denied',
      );
    }

    final picked = await ref
        .read(imagePickerProvider)
        .pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );
    if (picked == null) {
      print('Avatar picker cancelled: pickedFile == null');
      return null;
    }

    try {
      print('Picked avatar image path: ${picked.path}');
      if (picked.path.isEmpty) {
        throw const AvatarUploadException(
          'Не удалось получить путь к выбранному фото.',
        );
      }

      final file = File(picked.path);
      final fileExists = await file.exists();
      print('Picked avatar file exists: $fileExists');

      final bytes = await picked.readAsBytes();
      print('Picked avatar bytes length: ${bytes.length}');
      if (bytes.isEmpty) {
        throw const AvatarUploadException(
          'Выбранное фото пустое или недоступно для загрузки.',
        );
      }

      final processedBytes = AvatarImageProcessor().process(bytes);
      print('Processed avatar bytes length: ${processedBytes.length}');

      final storage = ref.read(storageServiceProvider);
      String downloadUrl;
      if (fileExists) {
        try {
          downloadUrl = await storage.uploadProfilePhotoFile(
            uid: uid,
            file: file,
          );
        } catch (error) {
          print(
            'Avatar putFile failed, retrying with putData bytes upload: $error',
          );
          downloadUrl = await storage.uploadProfilePhoto(
            uid: uid,
            data: processedBytes,
          );
        }
      } else {
        downloadUrl = await storage.uploadProfilePhoto(
          uid: uid,
          data: processedBytes,
        );
      }

      if (downloadUrl.trim().isEmpty) {
        throw const AvatarUploadException(
          'Firebase Storage вернул пустой download URL.',
        );
      }

      final cacheBustedUrl = _appendCacheBuster(downloadUrl);
      print('Avatar cache-busted URL: $cacheBustedUrl');

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatarUrl': cacheBustedUrl,
        'photoURL': cacheBustedUrl,
        'avatarUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('Avatar URL saved to Firestore for uid=$uid');

      if (currentUser != null) {
        await currentUser.updatePhotoURL(cacheBustedUrl);
        print('Avatar URL saved to FirebaseAuth profile for uid=$uid');
      }

      ref.invalidate(currentUserProfileProvider);

      return cacheBustedUrl;
    } on FirebaseException catch (error) {
      print(
        'FirebaseStorageException in changeAvatar: code=${error.code}, message=${error.message}',
      );
      throw AvatarUploadException(_mapStorageError(error), code: error.code);
    } on FormatException catch (error) {
      print('Avatar processing exception: $error');
      throw AvatarUploadException(error.message);
    } on FileSystemException catch (error) {
      print('Avatar file exception: $error');
      throw AvatarUploadException(
        'Не удалось прочитать выбранное фото: ${error.message}',
      );
    } catch (error) {
      print('Avatar upload exception: $error');
      if (error is AvatarUploadException) {
        rethrow;
      }
      throw AvatarUploadException(
        'Не удалось загрузить фото: $error',
      );
    }
  }

  String _appendCacheBuster(String url) {
    final uri = Uri.parse(url);
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'v': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    ).toString();
  }

  String _mapStorageError(FirebaseException error) {
    switch (error.code) {
      case 'unauthorized':
      case 'permission-denied':
        return 'Нет доступа к Firebase Storage. Проверьте авторизацию и правила Storage.';
      case 'canceled':
        return 'Загрузка отменена';
      case 'retry-limit-exceeded':
        return 'Слабое соединение. Повторите загрузку позже.';
      default:
        return error.message ??
            'Ошибка загрузки фото в Firebase Storage (${error.code})';
    }
  }
}

final appActionsProvider = Provider<AppActions>((ref) => AppActions(ref));
