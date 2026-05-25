import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../data/kaspi_catalog.dart';
import '../data/kaspi_shop_catalog.dart';
import '../models/app_models.dart';

class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  double _asDouble(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _db
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CategoryModel.fromDoc).toList());
  }

  Stream<List<ProductModel>> watchFeaturedProducts() {
    return _db
        .collection('products')
        .orderBy('rating', descending: true)
        .limit(12)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ProductModel.fromDoc).toList());
  }

  Stream<List<ProductModel>> watchProductsByCategory(String categoryId) {
    return _db
        .collection('products')
        .where('category', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ProductModel.fromDoc).toList());
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) {
      return null;
    }
    return ProductModel.fromDoc(doc);
  }

  Future<List<ProductModel>> searchProducts(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return <ProductModel>[];
    }
    final snapshot = await _db
        .collection('products')
        .where('searchKeywords', arrayContains: query)
        .limit(30)
        .get();
    return snapshot.docs.map(ProductModel.fromDoc).toList();
  }

  Future<List<GlobalSearchResult>> globalSearch(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return <GlobalSearchResult>[];
    }
    final results = <GlobalSearchResult>[];

    for (final service in kaspiServices) {
      final haystack = [
        service.title.toLowerCase(),
        service.subtitle.toLowerCase(),
        ...service.keywords,
      ].join(' ');
      if (haystack.contains(query)) {
        results.add(
          GlobalSearchResult(
            type: 'service',
            title: service.title,
            subtitle: service.subtitle,
            route: service.route,
          ),
        );
      }
    }

    for (final payment in kaspiPaymentTypes) {
      final haystack = [
        payment.title.toLowerCase(),
        payment.subtitle.toLowerCase(),
        ...payment.keywords,
      ].join(' ');
      if (haystack.contains(query)) {
        results.add(
          GlobalSearchResult(
            type: 'payment',
            title: payment.title,
            subtitle: payment.subtitle,
            route: '/services/payments',
          ),
        );
      }
    }

    final categories = await _db
        .collection('categories')
        .orderBy('order')
        .get();
    for (final doc in categories.docs) {
      final category = CategoryModel.fromDoc(doc);
      if (category.name.toLowerCase().contains(query)) {
        results.add(
          GlobalSearchResult(
            type: 'category',
            title: category.name,
            subtitle: 'Категория товаров',
            route: '/category/${category.id}',
          ),
        );
      }
    }

    final products = await searchProducts(query);
    for (final product in products) {
      results.add(
        GlobalSearchResult(
          type: 'product',
          title: product.title,
          subtitle: product.sellerName,
          route: '/product/${product.id}',
          productId: product.id,
        ),
      );
    }

    return results;
  }

  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(NotificationModel.fromDoc).toList(),
        );
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserProfile.fromDoc(doc);
    });
  }

  /// Writes categories and products with premium image URLs when catalog is outdated.
  Future<void> seedShopCatalogIfNeeded() async {
    final meta = await _db.collection('meta').doc('shop').get();
    final version = meta.data()?['catalogVersion'] as int? ?? 0;
    if (version >= shopCatalogVersion) {
      return;
    }

    final batch = _db.batch();
    for (final category in kaspiShopCategories) {
      batch.set(
        _db.collection('categories').doc(category.id),
        category.toFirestore(),
      );
    }
    for (final product in kaspiShopProducts) {
      batch.set(
        _db.collection('products').doc(product.id),
        product.toFirestore(),
      );
    }
    batch.set(_db.collection('meta').doc('shop'), {
      'catalogVersion': shopCatalogVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<UserProfile?> findUserByPhone(String rawPhone) async {
    final phone = _normalizePhone(rawPhone);
    if (phone.length < 12) {
      return null;
    }
    final snapshot = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return UserProfile.fromDoc(snapshot.docs.first);
  }

  Future<void> ensureWalletFields(String uid) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    if (!doc.exists) {
      return;
    }
    final data = doc.data() ?? <String, dynamic>{};
    final updates = <String, dynamic>{};
    if (!data.containsKey('goldBalance')) {
      updates['goldBalance'] = 3000.0;
    }
    if (!data.containsKey('goldCardLast4')) {
      updates['goldCardLast4'] = '3722';
    }
    if (!data.containsKey('bonusBalance')) {
      updates['bonusBalance'] = 0;
    }
    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }

  Future<void> applyOneTimeTopUp({
    required String uid,
    required int amount,
    required String creditKey,
    String counterpartyName = 'Kaspi Пополнение',
    String message = 'Пополнение счета',
  }) async {
    if (amount <= 0) {
      throw StateError('Сумма пополнения должна быть больше 0');
    }

    await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final userSnap = await transaction.get(userRef);

      if (!userSnap.exists) {
        return;
      }

      final data = userSnap.data() ?? <String, dynamic>{};
      final appliedCredits =
          (data['appliedCredits'] as Map<String, dynamic>?) ?? const {};
      if (appliedCredits[creditKey] == true) {
        return;
      }

      final currentBalance = _asDouble(data['goldBalance']);
      final updatedBalance = currentBalance + amount;
      final now = FieldValue.serverTimestamp();

      transaction.update(userRef, {
        'goldBalance': updatedBalance,
        'appliedCredits.$creditKey': true,
      });

      final txn = {
        'type': 'received',
        'amount': amount,
        'counterpartyName': counterpartyName,
        'counterpartyUid': 'system',
        'balanceAfter': updatedBalance,
        'message': message,
        'timestamp': now,
        'direction': 'in',
        'counterparty': counterpartyName,
        'phone': '',
        'date': now,
      };

      transaction.set(userRef.collection('transactions').doc(), txn);
      transaction.set(
        _db.collection('transactions').doc(uid).collection('list').doc(),
        txn,
      );
    });
  }

  Future<void> executeTransfer({
    required String senderUid,
    required String recipientUid,
    required int amount,
    required String recipientName,
    required String recipientPhone,
    required String senderName,
    String message = '',
  }) async {
    if (amount <= 0) {
      throw StateError('Сумма перевода должна быть больше 0');
    }
    if (senderUid == recipientUid) {
      throw StateError('Нельзя перевести самому себе');
    }

    await _db.runTransaction((transaction) async {
      final senderRef = _db.collection('users').doc(senderUid);
      final recipientRef = _db.collection('users').doc(recipientUid);
      final senderSnap = await transaction.get(senderRef);
      final recipientSnap = await transaction.get(recipientRef);

      if (!senderSnap.exists || !recipientSnap.exists) {
        throw StateError('Пользователь не найден');
      }

      final senderBalance = _asDouble(senderSnap.data()?['goldBalance']);
      if (senderBalance < amount) {
        throw StateError('Недостаточно средств на Kaspi Gold');
      }

      final recipientBalance = _asDouble(recipientSnap.data()?['goldBalance']);

      transaction.update(senderRef, {'goldBalance': senderBalance - amount});
      transaction.update(recipientRef, {
        'goldBalance': recipientBalance + amount,
      });

      final now = FieldValue.serverTimestamp();
      final senderBalanceAfter = senderBalance - amount;
      final recipientBalanceAfter = recipientBalance + amount;

      final outTxn = {
        'type': 'sent',
        'amount': amount,
        'counterpartyName': recipientName,
        'counterpartyUid': recipientUid,
        'balanceAfter': senderBalanceAfter,
        'message': message,
        'timestamp': now,
        'direction': 'out',
        'counterparty': recipientName,
        'phone': recipientPhone,
        'date': now,
      };
      final inTxn = {
        'type': 'received',
        'amount': amount,
        'counterpartyName': senderName,
        'counterpartyUid': senderUid,
        'balanceAfter': recipientBalanceAfter,
        'message': message,
        'timestamp': now,
        'direction': 'in',
        'counterparty': senderName,
        'phone': recipientPhone,
        'date': now,
      };

      transaction.set(senderRef.collection('transactions').doc(), outTxn);
      transaction.set(recipientRef.collection('transactions').doc(), inTxn);
      transaction.set(
        _db.collection('transactions').doc(senderUid).collection('list').doc(),
        outTxn,
      );
      transaction.set(
        _db
            .collection('transactions')
            .doc(recipientUid)
            .collection('list')
            .doc(),
        inTxn,
      );
    });
  }

  Future<void> ensureUserProfile({
    required String uid,
    String phoneNumber = '',
    String? displayName,
    String? photoUrl,
  }) async {
    final ref = _db.collection('users').doc(uid);
    final existing = await ref.get();
    if (existing.exists) {
      await ensureWalletFields(uid);
      return;
    }
    final normalizedPhone = phoneNumber.isNotEmpty
        ? _normalizePhone(phoneNumber)
        : '';
    if (normalizedPhone == '+77001234567') {
      await _seedKnownKaspiUser(uid);
      return;
    }
    final profile = _defaultProfile(normalizedPhone);
    if (displayName != null && displayName.trim().isNotEmpty) {
      profile['name'] = displayName.trim();
    }
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      profile['photoURL'] = photoUrl.trim();
    }
    await ref.set(profile);
  }

  Future<void> savePin(String uid, String pin) async {
    await _db.collection('users').doc(uid).update({'pinHash': _hashPin(pin)});
  }

  Future<bool> verifyPin(String uid, String pin) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      return false;
    }
    final profile = UserProfile.fromDoc(doc);
    return profile.pinHash == _hashPin(pin);
  }

  Future<void> updateProfile(String uid, UserProfile profile) {
    return _db
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updatePhotoUrl(String uid, String photoUrl) {
    return _db.collection('users').doc(uid).set({
      'photoURL': photoUrl,
      'avatarUrl': photoUrl,
      'avatarUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<WalletTransaction>> watchWalletTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map(WalletTransaction.fromDoc).toList();
          items.sort(
            (a, b) => (b.timestamp ?? DateTime(1970)).compareTo(
              a.timestamp ?? DateTime(1970),
            ),
          );
          return items;
        });
  }

  Stream<List<CartItemModel>> watchCart(String uid) {
    return _db
        .collection('cart')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CartItemModel.fromDoc).toList());
  }

  Future<void> addToCart(
    String uid,
    ProductModel product, {
    int quantity = 1,
  }) async {
    final ref = _db
        .collection('cart')
        .doc(uid)
        .collection('items')
        .doc(product.id);
    final existing = await ref.get();
    final currentQuantity = existing.exists
        ? ((existing.data()?['quantity'] as num?)?.toInt() ?? 0)
        : 0;
    await ref.set({
      'productId': product.id,
      'title': product.title,
      'imageUrl': product.primaryImage,
      'price': product.price,
      'quantity': currentQuantity + quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateCartQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    final ref = _db
        .collection('cart')
        .doc(uid)
        .collection('items')
        .doc(productId);
    if (quantity <= 0) {
      await ref.delete();
      return;
    }
    await ref.update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String uid, String productId) {
    return _db
        .collection('cart')
        .doc(uid)
        .collection('items')
        .doc(productId)
        .delete();
  }

  Stream<List<WishlistItemModel>> watchWishlist(String uid) {
    return _db
        .collection('wishlist')
        .doc(uid)
        .collection('items')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(WishlistItemModel.fromDoc).toList(),
        );
  }

  Future<void> toggleWishlist(
    String uid,
    ProductModel product,
    bool exists,
  ) async {
    final ref = _db
        .collection('wishlist')
        .doc(uid)
        .collection('items')
        .doc(product.id);
    if (exists) {
      await ref.delete();
      return;
    }
    await ref.set({
      'productId': product.id,
      'title': product.title,
      'imageUrl': product.primaryImage,
      'price': product.price,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> watchOrders(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  Future<void> createOrderFromCart({
    required String uid,
    required UserProfile profile,
    required List<CartItemModel> items,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final total = items.fold<int>(
      0,
      (runningTotal, item) => runningTotal + item.totalPrice,
    );
    final orderRef = _db.collection('orders').doc();
    await orderRef.set({
      'userId': uid,
      'userName': profile.name,
      'status': 'processing',
      'total': total,
      'createdAt': FieldValue.serverTimestamp(),
      'items': items
          .map(
            (item) => {
              'productId': item.productId,
              'title': item.title,
              'imageUrl': item.imageUrl,
              'price': item.price,
              'quantity': item.quantity,
            },
          )
          .toList(),
    });

    final batch = _db.batch();
    for (final item in items) {
      final ref = _db
          .collection('cart')
          .doc(uid)
          .collection('items')
          .doc(item.productId);
      batch.delete(ref);
    }
    await batch.commit();
  }

  Stream<List<ChatMessageModel>> watchChatMessages(String uid) {
    return _db
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ChatMessageModel.fromDoc).toList(),
        );
  }

  Future<void> sendChatMessage({
    required String uid,
    required String text,
    required String senderName,
  }) async {
    await _db.collection('chats').doc(uid).collection('messages').add({
      'text': text,
      'senderId': uid,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
      'read': true,
    });
  }

  Future<void> deleteChatMessage({
    required String uid,
    required String messageId,
  }) async {
    await _db
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> deleteNotification({
    required String uid,
    required String notificationId,
  }) async {
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notificationId)
        .delete();
  }

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _db
        .collection('transactions')
        .doc(uid)
        .collection('list')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(TransactionModel.fromDoc).toList(),
        );
  }

  Future<void> createTransfer({
    required String uid,
    required int amount,
    required String counterparty,
    required String phone,
  }) async {
    await _db.collection('transactions').doc(uid).collection('list').add({
      'type': 'transfer',
      'amount': amount,
      'counterparty': counterparty,
      'phone': phone,
      'date': FieldValue.serverTimestamp(),
      'direction': 'out',
    });
  }

  Stream<List<ProductModel>> watchViewedProducts(String uid) {
    return _db
        .collection('viewHistory')
        .doc(uid)
        .collection('items')
        .orderBy('viewedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromEmbedded(
                  (doc.data()['product'] as Map<String, dynamic>? ?? const {}),
                ),
              )
              .where((product) => product.id.isNotEmpty)
              .toList(),
        );
  }

  Future<void> addViewedProduct(String uid, ProductModel product) async {
    await _db
        .collection('viewHistory')
        .doc(uid)
        .collection('items')
        .doc(product.id)
        .set({
          'viewedAt': FieldValue.serverTimestamp(),
          'product': {
            ...product.toSummaryMap(),
            'description': product.description,
            'tags': product.tags,
          },
        });
  }

  Stream<List<SearchQueryModel>> watchSearchHistory(String uid) {
    return _db
        .collection('searchHistory')
        .doc(uid)
        .collection('queries')
        .orderBy('createdAt', descending: true)
        .limit(12)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SearchQueryModel.fromDoc).toList(),
        );
  }

  Future<void> addSearchHistory(String uid, String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }
    final id = base64Url.encode(utf8.encode(normalized.toLowerCase()));
    await _db
        .collection('searchHistory')
        .doc(uid)
        .collection('queries')
        .doc(id)
        .set({'query': normalized, 'createdAt': FieldValue.serverTimestamp()});
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  String _normalizePhone(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) {
      return digits;
    }
    if (digits.startsWith('8')) {
      return '+7${digits.substring(1)}';
    }
    if (digits.startsWith('7')) {
      return '+$digits';
    }
    return phoneNumber.trim();
  }

  Map<String, dynamic> _defaultProfile(String phoneNumber) {
    return {
      'name': 'Пользователь Kaspi',
      'phone': _normalizePhone(phoneNumber),
      'photoURL': null,
      'language': 'Русский',
      'pinHash': '',
      'faceId': false,
      'goldBalance': 3000.0,
      'goldCardLast4': '3722',
      'bonusBalance': 0,
      'notifications': {'push': true, 'sound': true},
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> ensureDemoRecipient() => _seedDemoRecipient();

  Future<void> _seedDemoRecipient() async {
    const recipientId = 'demo-kaspi-recipient';
    await _db.collection('users').doc(recipientId).set({
      'name': 'Ақнұр С.',
      'phone': '+77052737122',
      'photoURL': null,
      'language': 'Русский',
      'pinHash': '',
      'faceId': false,
      'goldBalance': 2500.0,
      'goldCardLast4': '4521',
      'bonusBalance': 0,
      'notifications': {'push': true, 'sound': true},
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _seedKnownKaspiUser(String uid) async {
    await _seedDemoRecipient();
    await _db.collection('users').doc(uid).set({
      'name': 'Алтынай Д.',
      'phone': '+77001234567',
      'photoURL':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300',
      'pinHash': _hashPin('1234'),
      'language': 'Русский',
      'notifications': {'push': true, 'sound': true},
      'faceId': false,
      'goldBalance': 3000.0,
      'goldCardLast4': '3722',
      'bonusBalance': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .doc('guide-1')
        .set({
          'text': 'Здравствуйте, Алтынай!',
          'senderId': 'agent-g',
          'senderName': 'Г',
          'timestamp': FieldValue.serverTimestamp(),
          'read': true,
        });
    await _db
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .doc('guide-2')
        .set({
          'text': 'Как получить карту?',
          'senderId': uid,
          'senderName': 'Алтынай',
          'timestamp': FieldValue.serverTimestamp(),
          'read': true,
        });
    final userRef = _db.collection('users').doc(uid);
    await _db
        .collection('transactions')
        .doc(uid)
        .collection('list')
        .doc('txn-1')
        .set({
          'type': 'sent',
          'amount': 550,
          'counterpartyName': 'Биржан Ж.',
          'balanceAfter': 261.26,
          'timestamp': FieldValue.serverTimestamp(),
          'direction': 'out',
          'counterparty': 'Биржан Ж.',
          'date': FieldValue.serverTimestamp(),
        });
    await userRef.collection('transactions').doc('txn-sent-1').set({
      'type': 'sent',
      'amount': 550,
      'counterpartyName': 'Биржан Ж.',
      'balanceAfter': 261.26,
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 1)),
      ),
    });
    await userRef.collection('transactions').doc('txn-recv-1').set({
      'type': 'received',
      'amount': 100,
      'counterpartyName': 'Ақнұр С.',
      'counterpartyUid': 'demo-kaspi-recipient',
      'balanceAfter': 811.26,
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 2)),
      ),
    });
    await userRef.collection('transactions').doc('txn-purchase-1').set({
      'type': 'received',
      'amount': 580,
      'counterpartyName': 'The first',
      'balanceAfter': 711.26,
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 3)),
      ),
      'message': 'purchase',
    });
    await _db
        .collection('searchHistory')
        .doc(uid)
        .collection('queries')
        .doc('search-1')
        .set({
          'query': 'розовая двойка',
          'createdAt': FieldValue.serverTimestamp(),
        });
    await _db
        .collection('searchHistory')
        .doc(uid)
        .collection('queries')
        .doc('search-2')
        .set({
          'query': 'черное платье женское',
          'createdAt': FieldValue.serverTimestamp(),
        });
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc('notif-1')
        .set({
          'title': 'Kaspi Red',
          'body': 'Кэшбэк 30% активирован на выходные',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc('notif-2')
        .set({
          'title': 'Заказ доставлен',
          'body': 'Ваш заказ из магазина успешно доставлен',
          'read': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}
