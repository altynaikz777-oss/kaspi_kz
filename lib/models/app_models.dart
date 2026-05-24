import 'package:cloud_firestore/cloud_firestore.dart';

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }
  return fallback;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

DateTime? _asDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}

List<String> _parseImages(Map<String, dynamic> data) {
  final fromList = List<String>.from(
    (data['images'] as List<dynamic>? ?? const <dynamic>[]),
  );
  if (fromList.isNotEmpty) {
    return fromList;
  }
  final single = data['imageUrl'] as String?;
  if (single != null && single.isNotEmpty) {
    return [single];
  }
  return const [];
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.language,
    required this.pinHash,
    required this.pushNotifications,
    required this.soundNotifications,
    required this.faceId,
    this.photoUrl,
    this.goldBalance = 0,
    this.goldCardLast4 = '3722',
    this.bonusBalance = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String language;
  final String pinHash;
  final bool pushNotifications;
  final bool soundNotifications;
  final bool faceId;
  final String? photoUrl;
  final double goldBalance;
  final String goldCardLast4;
  final int bonusBalance;

  bool get hasPin => pinHash.isNotEmpty;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? language,
    String? pinHash,
    bool? pushNotifications,
    bool? soundNotifications,
    bool? faceId,
    String? photoUrl,
    double? goldBalance,
    String? goldCardLast4,
    int? bonusBalance,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      pinHash: pinHash ?? this.pinHash,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      soundNotifications: soundNotifications ?? this.soundNotifications,
      faceId: faceId ?? this.faceId,
      photoUrl: photoUrl ?? this.photoUrl,
      goldBalance: goldBalance ?? this.goldBalance,
      goldCardLast4: goldCardLast4 ?? this.goldCardLast4,
      bonusBalance: bonusBalance ?? this.bonusBalance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'photoURL': photoUrl,
      'avatarUrl': photoUrl,
      'language': language,
      'pinHash': pinHash,
      'faceId': faceId,
      'goldBalance': goldBalance,
      'goldCardLast4': goldCardLast4,
      'bonusBalance': bonusBalance,
      'notifications': {'push': pushNotifications, 'sound': soundNotifications},
    };
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final notifications =
        (data['notifications'] as Map<String, dynamic>?) ?? const {};
    return UserProfile(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Пользователь Kaspi',
      phone: (data['phone'] as String?) ?? '',
      photoUrl: (data['avatarUrl'] as String?) ??
          (data['photoURL'] as String?),
      language: (data['language'] as String?) ?? 'Русский',
      pinHash: (data['pinHash'] as String?) ?? '',
      pushNotifications: (notifications['push'] as bool?) ?? true,
      soundNotifications: (notifications['sound'] as bool?) ?? true,
      faceId: (data['faceId'] as bool?) ?? false,
      goldBalance: _asDouble(data['goldBalance']),
      goldCardLast4: (data['goldCardLast4'] as String?) ?? '3722',
      bonusBalance: _asInt(data['bonusBalance']),
    );
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.counterpartyName,
    this.counterpartyUid,
    required this.balanceAfter,
    this.message,
    this.timestamp,
  });

  final String id;
  final String type;
  final int amount;
  final String counterpartyName;
  final String? counterpartyUid;
  final double balanceAfter;
  final String? message;
  final DateTime? timestamp;

  bool get isSent => type == 'sent';
  bool get isReceived => type == 'received';

  factory WalletTransaction.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final legacyDirection = data['direction'] as String?;
    var type = (data['type'] as String?) ?? 'received';
    if (type == 'transfer') {
      type = legacyDirection == 'out' ? 'sent' : 'received';
    }
    return WalletTransaction(
      id: doc.id,
      type: type,
      amount: _asInt(data['amount']),
      counterpartyName: (data['counterpartyName'] as String?) ??
          (data['counterparty'] as String?) ??
          '',
      counterpartyUid: data['counterpartyUid'] as String?,
      balanceAfter: _asDouble(
        data['balanceAfter'],
        fallback: _asDouble(data['balance']),
      ),
      message: data['message'] as String?,
      timestamp: _asDateTime(data['timestamp']) ?? _asDateTime(data['date']),
    );
  }
}

class TransferRecipient {
  const TransferRecipient({
    required this.uid,
    required this.name,
    required this.phone,
  });

  final String uid;
  final String name;
  final String phone;

  factory TransferRecipient.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return TransferRecipient(
      uid: doc.id,
      name: (data['name'] as String?) ?? 'Клиент Kaspi',
      phone: (data['phone'] as String?) ?? '',
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int order;

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CategoryModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      order: _asInt(data['order']),
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.bonusPrice,
    required this.images,
    required this.sellerName,
    required this.rating,
    required this.installmentMonthly,
    required this.description,
    required this.tags,
  });

  final String id;
  final String title;
  final String category;
  final int price;
  final int bonusPrice;
  final List<String> images;
  final String sellerName;
  final double rating;
  final int installmentMonthly;
  final String description;
  final List<String> tags;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  Map<String, dynamic> toSummaryMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'bonusPrice': bonusPrice,
      'imageUrl': primaryImage,
      'sellerName': sellerName,
      'rating': rating,
      'installmentMonthly': installmentMonthly,
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProductModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      price: _asInt(data['price']),
      bonusPrice: _asInt(data['bonusPrice']),
      images: _parseImages(data),
      sellerName: (data['sellerName'] as String?) ?? 'Kaspi Магазин',
      rating: _asDouble(data['rating'], fallback: 4.8),
      installmentMonthly: _asInt(data['installmentMonthly']),
      description: (data['description'] as String?) ?? '',
      tags: List<String>.from(
        (data['tags'] as List<dynamic>? ?? const <dynamic>[]),
      ),
    );
  }

  factory ProductModel.fromEmbedded(Map<String, dynamic> data) {
    return ProductModel(
      id: (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      price: _asInt(data['price']),
      bonusPrice: _asInt(data['bonusPrice']),
      images: [
        if ((data['imageUrl'] as String?) != null) data['imageUrl'] as String,
      ],
      sellerName: (data['sellerName'] as String?) ?? 'Kaspi Магазин',
      rating: _asDouble(data['rating'], fallback: 4.8),
      installmentMonthly: _asInt(data['installmentMonthly']),
      description: (data['description'] as String?) ?? '',
      tags: List<String>.from(
        (data['tags'] as List<dynamic>? ?? const <dynamic>[]),
      ),
    );
  }
}

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final int price;
  final int quantity;

  int get totalPrice => price * quantity;

  factory CartItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CartItemModel(
      productId: (data['productId'] as String?) ?? doc.id,
      title: (data['title'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      price: _asInt(data['price']),
      quantity: _asInt(data['quantity'], fallback: 1),
    );
  }
}

class WishlistItemModel {
  const WishlistItemModel({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final int price;

  factory WishlistItemModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return WishlistItemModel(
      productId: (data['productId'] as String?) ?? doc.id,
      title: (data['title'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      price: _asInt(data['price']),
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String status;
  final int total;
  final DateTime? createdAt;
  final List<CartItemModel> items;

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawItems = data['items'] as List<dynamic>? ?? const <dynamic>[];
    return OrderModel(
      id: doc.id,
      status: (data['status'] as String?) ?? 'processing',
      total: _asInt(data['total']),
      createdAt: _asDateTime(data['createdAt']),
      items: rawItems
          .map(
            (item) => CartItemModel(
              productId: (item['productId'] as String?) ?? '',
              title: (item['title'] as String?) ?? '',
              imageUrl: (item['imageUrl'] as String?) ?? '',
              price: _asInt(item['price']),
              quantity: _asInt(item['quantity'], fallback: 1),
            ),
          )
          .toList(),
    );
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime? timestamp;

  bool isOutgoing(String currentUserId) => senderId == currentUserId;

  factory ChatMessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatMessageModel(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? '',
      timestamp: _asDateTime(data['timestamp']),
    );
  }
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.counterparty,
    required this.direction,
    required this.date,
  });

  final String id;
  final String type;
  final int amount;
  final String counterparty;
  final String direction;
  final DateTime? date;

  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TransactionModel(
      id: doc.id,
      type: (data['type'] as String?) ?? '',
      amount: _asInt(data['amount']),
      counterparty: (data['counterparty'] as String?) ?? '',
      direction: (data['direction'] as String?) ?? 'out',
      date: _asDateTime(data['date']),
    );
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  factory NotificationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return NotificationModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      read: (data['read'] as bool?) ?? false,
      createdAt: _asDateTime(data['createdAt']),
    );
  }
}

class GlobalSearchResult {
  const GlobalSearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    this.productId,
  });

  final String type;
  final String title;
  final String subtitle;
  final String route;
  final String? productId;
}

class SearchQueryModel {
  const SearchQueryModel({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  final String id;
  final String query;
  final DateTime? createdAt;

  factory SearchQueryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SearchQueryModel(
      id: doc.id,
      query: (data['query'] as String?) ?? '',
      createdAt: _asDateTime(data['createdAt']),
    );
  }
}
