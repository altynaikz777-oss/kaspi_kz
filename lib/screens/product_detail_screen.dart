// ignore_for_file: unnecessary_underscores, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/kaspi_catalog.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kaspi_network_image.dart';

const _kaspiGreen = Color(0xFF00A75C);
const _kaspiBlue = Color(0xFF0070C9);
const _installmentYellow = Color(0xFFFFD100);

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _trackedProductId;
  int _imageIndex = 0;
  int _colorIndex = 0;
  int _storageIndex = 0;
  int _simIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final wishlist =
        ref.watch(wishlistItemsProvider).valueOrNull ??
        const <WishlistItemModel>[];

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Товар не найден')),
          );
        }
        if (_trackedProductId != product.id) {
          _trackedProductId = product.id;
          Future.microtask(
            () => ref.read(appActionsProvider).trackViewedProduct(product),
          );
        }
        final isFavorite = wishlist.any((item) => item.productId == product.id);
        final sellers = _buildSellers(product);
        final images = product.images.isEmpty
            ? [product.primaryImage]
            : product.images;
        final bonusPrice = product.bonusPrice > 0 && product.bonusPrice < product.price
            ? product.price - product.bonusPrice
            : (product.price * 0.97).round();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ProductTopBar(
                  onBack: () => context.pop(),
                  onSearch: () => context.push('/search'),
                  onClose: () => context.pop(),
                ),
                _ProductTabBar(controller: _tabs),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(
                        product: product,
                        images: images,
                        imageIndex: _imageIndex,
                        onImageChanged: (i) => setState(() => _imageIndex = i),
                        colorIndex: _colorIndex,
                        onColorChanged: (i) => setState(() => _colorIndex = i),
                        storageIndex: _storageIndex,
                        onStorageChanged: (i) =>
                            setState(() => _storageIndex = i),
                        simIndex: _simIndex,
                        onSimChanged: (i) => setState(() => _simIndex = i),
                        isFavorite: isFavorite,
                        bonusPrice: bonusPrice,
                        onFavorite: () => ref
                            .read(appActionsProvider)
                            .toggleWishlist(product, isFavorite),
                        sellers: sellers,
                      ),
                      _SellersTab(sellers: sellers),
                      _AboutTab(product: product),
                      _ReviewsTab(product: product),
                    ],
                  ),
                ),
                _ProductActionBar(
                  price: product.price,
                  onBuy: () => _addToCart(context, product),
                  onCart: () => _addToCart(context, product),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: AsyncValueView(child: const SizedBox.shrink(), error: error),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    await ref.read(appActionsProvider).addToCart(product);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар добавлен в корзину')),
      );
    }
  }

  List<_SellerOffer> _buildSellers(ProductModel product) {
    return [
      _SellerOffer(
        name: product.sellerName.toUpperCase(),
        rating: product.rating,
        reviews: 1333,
        price: product.price,
        installmentMonthly: product.installmentMonthly,
        bonusPrice: product.price - product.bonusPrice,
      ),
      _SellerOffer(
        name: 'ATEL',
        rating: 4.9,
        reviews: 58,
        price: product.price + 1200,
        installmentMonthly: product.installmentMonthly + 500,
        bonusPrice: product.price - product.bonusPrice + 800,
      ),
    ];
  }
}

class _SellerOffer {
  const _SellerOffer({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.installmentMonthly,
    required this.bonusPrice,
  });

  final String name;
  final double rating;
  final int reviews;
  final int price;
  final int installmentMonthly;
  final int bonusPrice;
}

class _ProductTopBar extends StatelessWidget {
  const _ProductTopBar({
    required this.onBack,
    required this.onSearch,
    required this.onClose,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Material(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onSearch,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Поиск товара',
                          style: TextStyle(color: Color(0xFF9AA0A6)),
                        ),
                      ),
                      Icon(Icons.photo_camera_outlined, color: Color(0xFF9AA0A6)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProductTabBar extends StatelessWidget {
  const _ProductTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: const Color(0xFFE8EAED),
      indicatorColor: kaspiPrimary,
      indicatorWeight: 2.5,
      labelColor: kaspiPrimary,
      unselectedLabelColor: const Color(0xFF6B7280),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      tabs: const [
        Tab(text: 'Обзор'),
        Tab(text: 'Продавцы'),
        Tab(text: 'О товаре'),
        Tab(text: 'Оценки и отзывы'),
      ],
    );
  }
}

class _OverviewTab extends StatefulWidget {
  const _OverviewTab({
    required this.product,
    required this.images,
    required this.imageIndex,
    required this.onImageChanged,
    required this.colorIndex,
    required this.onColorChanged,
    required this.storageIndex,
    required this.onStorageChanged,
    required this.simIndex,
    required this.onSimChanged,
    required this.isFavorite,
    required this.bonusPrice,
    required this.onFavorite,
    required this.sellers,
  });

  final ProductModel product;
  final List<String> images;
  final int imageIndex;
  final ValueChanged<int> onImageChanged;
  final int colorIndex;
  final ValueChanged<int> onColorChanged;
  final int storageIndex;
  final ValueChanged<int> onStorageChanged;
  final int simIndex;
  final ValueChanged<int> onSimChanged;
  final bool isFavorite;
  final int bonusPrice;
  final VoidCallback onFavorite;
  final List<_SellerOffer> sellers;

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  late final PageController _galleryController;

  static const _colors = ['оранжевый', 'белый', 'синий'];
  static const _storage = ['12 ГБ/256 ГБ', '12 ГБ/512 ГБ', '12 ГБ/1024 ГБ'];
  static const _sim = ['dual eSIM', 'nano SIM+eSIM'];

  @override
  void initState() {
    super.initState();
    _galleryController = PageController(
      initialPage: widget.imageIndex.clamp(0, widget.images.length - 1),
    );
  }

  @override
  void didUpdateWidget(covariant _OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageIndex != widget.imageIndex &&
        _galleryController.hasClients) {
      _galleryController.animateToPage(
        widget.imageIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _selectImage(int index) {
    widget.onImageChanged(index);
    _galleryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = widget.images;
    final imageIndex = widget.imageIndex;
    final showVariants = product.title.toLowerCase().contains('iphone') ||
        product.title.toLowerCase().contains('смартфон') ||
        product.tags.contains('phone');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: PageView.builder(
                  controller: _galleryController,
                  itemCount: images.length,
                  onPageChanged: widget.onImageChanged,
                  itemBuilder: (context, index) {
                    return KaspiNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      categoryHint: product.category,
                      memCacheWidth: 900,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kaspiBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Проверен продавцом',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${imageIndex + 1}/${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == imageIndex;
                return GestureDetector(
                  onTap: () => _selectImage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? kaspiPrimary : const Color(0xFFE8EAED),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: KaspiNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        categoryHint: product.category,
                        memCacheWidth: 160,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_formatCompact(widget.product.bonusPrice)} ₸',
                style: const TextStyle(
                  color: _kaspiGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: widget.onFavorite,
              icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: kaspiPrimary,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ],
        ),
        Text(
          '${_formatCompact(widget.product.price)} ₸',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1F23),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PriceOptionCard(
                color: const Color(0xFFE8F8EF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatCompact(widget.bonusPrice)} ₸',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'с учетом Бонусов при оплате',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PriceOptionCard(
                color: const Color(0xFFFFF8E1),
                child: Row(
                  children: [
                    const Text(
                      'В кредит',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _installmentYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_formatCompact(widget.product.installmentMonthly)} ₸ × 24',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showVariants) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = widget.colorIndex == index;
                return GestureDetector(
                  onTap: () => widget.onColorChanged(index),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? kaspiPrimary : const Color(0xFFE8EAED),
                        width: selected ? 2 : 1,
                      ),
                      color: [
                        const Color(0xFFFF9F0A),
                        const Color(0xFFF5F5F5),
                        const Color(0xFF5AC8FA),
                      ][index],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Цвет: ${_colors[widget.colorIndex]}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Объем памяти',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_storage.length, (i) {
              return _OptionChip(
                label: _storage[i],
                selected: widget.storageIndex == i,
                onTap: () => widget.onStorageChanged(i),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text(
            'Тип SIM-карты',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_sim.length, (i) {
              return _OptionChip(
                label: _sim[i],
                selected: widget.simIndex == i,
                onTap: () => widget.onSimChanged(i),
              );
            }),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.product.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 20),
                Text(
                  widget.product.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '(1333) >',
                    style: TextStyle(color: _kaspiBlue, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Продавцы',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _DeliveryChip(label: 'Сегодня, завтра', selected: true),
              SizedBox(width: 8),
              _DeliveryChip(label: 'До 2 дней'),
              SizedBox(width: 8),
              _DeliveryChip(label: 'До 5 дней'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SellerCard(offer: widget.sellers.first),
      ],
    );
  }
}

class _SellersTab extends StatelessWidget {
  const _SellersTab({required this.sellers});

  final List<_SellerOffer> sellers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sellers.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFE8EAED)),
      itemBuilder: (context, index) => _SellerCard(offer: sellers[index]),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.offer});

  final _SellerOffer offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  offer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: _kaspiBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Выбрать', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 18),
              const SizedBox(width: 4),
              Text(
                '${offer.rating.toStringAsFixed(1)} · ${offer.reviews} отзывов',
                style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${_formatCompact(offer.price)} ₸',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _installmentYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_formatCompact(offer.installmentMonthly)} ₸ × 24',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatCompact(offer.bonusPrice)} ₸ с учетом Бонусов',
                    style: const TextStyle(
                      color: _kaspiGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: _kaspiGreen, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _DeliveryLine(
            icon: Icons.inventory_2_outlined,
            text: 'Postomat, Вс, 24 мая, бесплатно',
          ),
          const SizedBox(height: 4),
          const _DeliveryLine(
            icon: Icons.local_shipping_outlined,
            text: 'Доставка межгород, Вс, 24 мая, бесплатно',
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          product.description.isEmpty
              ? 'Описание товара загружается из Firestore.'
              : product.description,
          style: const TextStyle(height: 1.5, color: Color(0xFF4B5563)),
        ),
        const SizedBox(height: 16),
        Text(
          'Продавец: ${product.sellerName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.tags
              .map((tag) => Chip(label: Text(tag)))
              .toList(),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
                      Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
                      Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
                      Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
                      Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1333 отзыва',
                    style: TextStyle(color: Color(0xFF9AA0A6)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...const [
          ('Айгерим', 'Отличный товар, доставка быстрая'),
          ('Данияр', 'Соответствует описанию'),
          ('Биржан', 'Рекомендую продавца'),
        ].map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  review.$2,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductActionBar extends StatelessWidget {
  const _ProductActionBar({
    required this.price,
    required this.onBuy,
    required this.onCart,
  });

  final int price;
  final VoidCallback onBuy;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: onBuy,
              style: FilledButton.styleFrom(
                backgroundColor: _kaspiGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Купить сейчас',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onCart,
              style: FilledButton.styleFrom(
                backgroundColor: _kaspiBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'В корзину',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceOptionCard extends StatelessWidget {
  const _PriceOptionCard({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kaspiPrimary : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1C1F23),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1C1F23) : const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF1C1F23),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DeliveryLine extends StatelessWidget {
  const _DeliveryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9AA0A6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

String _formatCompact(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(s[i]);
  }
  return buffer.toString();
}
