/// Curated Kaspi.kz-style catalog with stable, category-matched photo URLs.
class KaspiShopCategorySeed {
  const KaspiShopCategorySeed({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int order;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'imageUrl': imageUrl,
        'order': order,
      };
}

class KaspiShopProductSeed {
  const KaspiShopProductSeed({
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
    this.tags = const [],
    this.searchKeywords = const [],
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
  final List<String> searchKeywords;

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'category': category,
        'price': price,
        'bonusPrice': bonusPrice,
        'images': images,
        'imageUrl': images.first,
        'sellerName': sellerName,
        'rating': rating,
        'installmentMonthly': installmentMonthly,
        'description': description,
        'tags': tags,
        'searchKeywords': _buildKeywords(),
      };

  List<String> _buildKeywords() {
    final base = <String>{
      ...searchKeywords,
      ...title.toLowerCase().split(RegExp(r'\s+')),
      category,
      ...tags,
    };
    return base.where((e) => e.length > 2).toList();
  }
}

/// Unsplash CDN — stable IDs, cropped for product cards.
String _u(String photoId, {int w = 900}) =>
    'https://images.unsplash.com/$photoId?w=$w&q=85&auto=format&fit=crop';

const shopCatalogVersion = 2;

final kaspiShopCategories = <KaspiShopCategorySeed>[
  KaspiShopCategorySeed(
    id: 'smartphones',
    name: 'Смартфоны',
    imageUrl: _u('photo-1592286927506-01b27fbd1b07', w: 600),
    order: 1,
  ),
  KaspiShopCategorySeed(
    id: 'tv',
    name: 'Телевизоры',
    imageUrl: _u('photo-1593359671219-136489bf12c7', w: 600),
    order: 2,
  ),
  KaspiShopCategorySeed(
    id: 'laptops',
    name: 'Ноутбуки',
    imageUrl: _u('photo-1496181133206-80ce9b88a853', w: 600),
    order: 3,
  ),
  KaspiShopCategorySeed(
    id: 'shoes',
    name: 'Обувь',
    imageUrl: _u('photo-1542291026-7eec264c27ff', w: 600),
    order: 4,
  ),
  KaspiShopCategorySeed(
    id: 'furniture',
    name: 'Мебель',
    imageUrl: _u('photo-1555041469-a587c0749466', w: 600),
    order: 5,
  ),
  KaspiShopCategorySeed(
    id: 'appliances',
    name: 'Бытовая техника',
    imageUrl: _u('photo-1626806787468-ee69c8ae74aa', w: 600),
    order: 6,
  ),
  KaspiShopCategorySeed(
    id: 'beauty',
    name: 'Красота',
    imageUrl: _u('photo-1596462502278-27bfdc403348', w: 600),
    order: 7,
  ),
  KaspiShopCategorySeed(
    id: 'kids',
    name: 'Детские товары',
    imageUrl: _u('photo-1515488042361-ee00e0ddd4e4', w: 600),
    order: 8,
  ),
  KaspiShopCategorySeed(
    id: 'home',
    name: 'Дом и сад',
    imageUrl: _u('photo-1616046229475-ee4cfb373c65', w: 600),
    order: 9,
  ),
];

final kaspiShopProducts = <KaspiShopProductSeed>[
  KaspiShopProductSeed(
    id: 'iphone-15-pro-256',
    title: 'Apple iPhone 15 Pro 256 ГБ, титановый',
    category: 'smartphones',
    price: 649990,
    bonusPrice: 629990,
    images: [
      _u('photo-1695048133142-258a654a7e20'),
      _u('photo-1592286927506-01b27fbd1b07'),
      _u('photo-1510557880182-3d4d3cba35a5'),
      _u('photo-1432030265177-7a03ba6853f5'),
    ],
    sellerName: 'TECHNODOM',
    rating: 4.9,
    installmentMonthly: 27083,
    description:
        'iPhone 15 Pro с чипом A17 Pro, титановым корпусом и продвинутой камерой 48 Мп.',
    tags: ['phone', 'apple', 'iphone'],
    searchKeywords: ['айфон', 'iphone', 'apple', 'смартфон'],
  ),
  KaspiShopProductSeed(
    id: 'samsung-s24-ultra',
    title: 'Samsung Galaxy S24 Ultra 512 ГБ, черный',
    category: 'smartphones',
    price: 599990,
    bonusPrice: 579990,
    images: [
      _u('photo-1610945265064-c3f39c4c8b8d'),
      _u('photo-1511707171634-5f897ff02aa9'),
      _u('photo-1610945265064-c3f39c4c8b8d'),
    ],
    sellerName: 'Sulpak',
    rating: 4.8,
    installmentMonthly: 24999,
    description: 'Флагман Samsung с S Pen, AI-функциями и камерой 200 Мп.',
    tags: ['phone', 'samsung'],
    searchKeywords: ['samsung', 'galaxy', 'смартфон'],
  ),
  KaspiShopProductSeed(
    id: 'xiaomi-14',
    title: 'Xiaomi 14 12/512 ГБ, белый',
    category: 'smartphones',
    price: 329990,
    bonusPrice: 319990,
    images: [
      _u('photo-1598327105666-54b350f0a300'),
      _u('photo-1511707171634-5f897ff02aa9'),
    ],
    sellerName: 'Mechta',
    rating: 4.7,
    installmentMonthly: 13750,
    description: 'Компактный флагман Xiaomi с Leica-камерой и Snapdragon 8 Gen 3.',
    tags: ['phone', 'xiaomi'],
    searchKeywords: ['xiaomi', 'сяоми', 'смартфон'],
  ),
  KaspiShopProductSeed(
    id: 'lg-oled-55',
    title: 'LG OLED55C4 55", 4K Smart TV',
    category: 'tv',
    price: 899990,
    bonusPrice: 869990,
    images: [
      _u('photo-1593359671219-136489bf12c7'),
      _u('photo-1593784991095-a205069470b6'),
      _u('photo-1574944985070-8f948fb2450c'),
    ],
    sellerName: 'TECHNODOM',
    rating: 4.9,
    installmentMonthly: 37499,
    description: 'OLED-телевизор с идеальным чёрным, webOS и HDMI 2.1.',
    tags: ['tv', 'oled'],
    searchKeywords: ['телевизор', 'lg', 'oled'],
  ),
  KaspiShopProductSeed(
    id: 'samsung-qled-65',
    title: 'Samsung QE65Q80D 65", QLED 4K',
    category: 'tv',
    price: 749990,
    bonusPrice: 729990,
    images: [
      _u('photo-1593784991095-a205069470b6'),
      _u('photo-1593359671219-136489bf12c7'),
    ],
    sellerName: 'Sulpak',
    rating: 4.8,
    installmentMonthly: 31249,
    description: 'QLED TV с Quantum HDR и голосовым помощником.',
    tags: ['tv', 'samsung'],
    searchKeywords: ['телевизор', 'samsung', 'qled'],
  ),
  KaspiShopProductSeed(
    id: 'macbook-air-m3',
    title: 'Apple MacBook Air 13" M3, 16/512 ГБ',
    category: 'laptops',
    price: 749990,
    bonusPrice: 729990,
    images: [
      _u('photo-1496181133206-80ce9b88a853'),
      _u('photo-1517336714731-489689fd1ca8'),
      _u('photo-1541807083899-bbf43d2d1b1a'),
    ],
    sellerName: 'TECHNODOM',
    rating: 4.9,
    installmentMonthly: 31249,
    description: 'Ультратонкий MacBook Air на чипе M3 для работы и учёбы.',
    tags: ['laptop', 'apple'],
    searchKeywords: ['macbook', 'ноутбук', 'apple'],
  ),
  KaspiShopProductSeed(
    id: 'asus-rog-strix',
    title: 'ASUS ROG Strix G16, RTX 4060, 16/1 ТБ',
    category: 'laptops',
    price: 649990,
    bonusPrice: 629990,
    images: [
      _u('photo-1603302576837-37561b2e2302'),
      _u('photo-1496181133206-80ce9b88a853'),
    ],
    sellerName: 'Mechta',
    rating: 4.7,
    installmentMonthly: 27083,
    description: 'Игровой ноутбук с дисплеем 165 Гц и видеокартой RTX 4060.',
    tags: ['laptop', 'gaming'],
    searchKeywords: ['ноутбук', 'asus', 'игровой'],
  ),
  KaspiShopProductSeed(
    id: 'nike-air-max',
    title: 'Nike Air Max 90, мужские кроссовки',
    category: 'shoes',
    price: 89990,
    bonusPrice: 84990,
    images: [
      _u('photo-1542291026-7eec264c27ff'),
      _u('photo-1606107557195-0aef09b8b5b8'),
      _u('photo-1460353581641-37baddab0fa6'),
    ],
    sellerName: 'Sportmaster',
    rating: 4.8,
    installmentMonthly: 3749,
    description: 'Классические кроссовки Nike Air Max 90 на каждый день.',
    tags: ['shoes', 'sneakers'],
    searchKeywords: ['кроссовки', 'nike', 'обувь'],
  ),
  KaspiShopProductSeed(
    id: 'adidas-ultraboost',
    title: 'adidas Ultraboost Light, беговые',
    category: 'shoes',
    price: 109990,
    bonusPrice: 99990,
    images: [
      _u('photo-1608231387042-66d1773070a5'),
      _u('photo-1542291026-7eec264c27ff'),
    ],
    sellerName: 'Sportmaster',
    rating: 4.7,
    installmentMonthly: 4583,
    description: 'Лёгкие беговые кроссовки с амортизацией Boost.',
    tags: ['shoes', 'running'],
    searchKeywords: ['adidas', 'кроссовки', 'бег'],
  ),
  KaspiShopProductSeed(
    id: 'sofa-loft-green',
    title: 'Диван угловой Loft, зелёный велюр',
    category: 'furniture',
    price: 349990,
    bonusPrice: 329990,
    images: [
      _u('photo-1555041469-a587c0749466'),
      _u('photo-1493663284031-b7e3aefcae8f'),
      _u('photo-1586023492125-27b2c045efd7'),
    ],
    sellerName: 'Mebel.kz',
    rating: 4.6,
    installmentMonthly: 14583,
    description: 'Современный угловой диван с мягкой обивкой и ящиком для белья.',
    tags: ['furniture', 'sofa'],
    searchKeywords: ['диван', 'мебель', 'софа'],
  ),
  KaspiShopProductSeed(
    id: 'chair-office',
    title: 'Кресло офисное Ergo Comfort, чёрное',
    category: 'furniture',
    price: 89990,
    bonusPrice: 84990,
    images: [
      _u('photo-1580480055273-7d3f7a9e2aaf'),
      _u('photo-1506439773649-6e0eb8cfb237'),
    ],
    sellerName: 'Mebel.kz',
    rating: 4.5,
    installmentMonthly: 3749,
    description: 'Эргономичное кресло с поддержкой поясницы и подлокотниками.',
    tags: ['furniture', 'chair'],
    searchKeywords: ['кресло', 'офис', 'мебель'],
  ),
  KaspiShopProductSeed(
    id: 'washer-lg-9kg',
    title: 'Стиральная машина LG F2V5GS0W, 9 кг',
    category: 'appliances',
    price: 279990,
    bonusPrice: 269990,
    images: [
      _u('photo-1626806787468-ee69c8ae74aa'),
      _u('photo-1631548851659-0d2f80338e44'),
    ],
    sellerName: 'TECHNODOM',
    rating: 4.8,
    installmentMonthly: 11666,
    description: 'Инверторная стиральная машина с паровой обработкой Steam.',
    tags: ['appliance', 'washer'],
    searchKeywords: ['стиральная', 'машина', 'lg'],
  ),
  KaspiShopProductSeed(
    id: 'fridge-samsung',
    title: 'Холодильник Samsung RB38, No Frost',
    category: 'appliances',
    price: 389990,
    bonusPrice: 379990,
    images: [
      _u('photo-1571171637578-41bc2dd41cd2'),
      _u('photo-1631548851659-0d2f80338e44'),
    ],
    sellerName: 'Sulpak',
    rating: 4.7,
    installmentMonthly: 16249,
    description: 'Двухкамерный холодильник с системой No Frost и зоной свежести.',
    tags: ['appliance', 'fridge'],
    searchKeywords: ['холодильник', 'samsung'],
  ),
  KaspiShopProductSeed(
    id: 'dyson-hair',
    title: 'Фен Dyson Supersonic, никель/медь',
    category: 'beauty',
    price: 249990,
    bonusPrice: 239990,
    images: [
      _u('photo-1522338242992-e1a54906a8f0'),
      _u('photo-1596462502278-27bfdc403348'),
    ],
    sellerName: 'Technodom Beauty',
    rating: 4.9,
    installmentMonthly: 10416,
    description: 'Профессиональный фен с контролем температуры и магнитными насадками.',
    tags: ['beauty', 'hair'],
    searchKeywords: ['dyson', 'фен', 'красота'],
  ),
  KaspiShopProductSeed(
    id: 'perfume-set',
    title: 'Набор парфюмерии Premium, 3×50 мл',
    category: 'beauty',
    price: 49990,
    bonusPrice: 44990,
    images: [
      _u('photo-1596462502278-27bfdc403348'),
      _u('photo-1541643600914-78b084683601'),
    ],
    sellerName: 'Sephora KZ',
    rating: 4.6,
    installmentMonthly: 2083,
    description: 'Подарочный набор ароматов для неё и для него.',
    tags: ['beauty', 'perfume'],
    searchKeywords: ['парфюм', 'духи', 'набор'],
  ),
  KaspiShopProductSeed(
    id: 'lego-city',
    title: 'LEGO City Пожарная станция, 1137 деталей',
    category: 'kids',
    price: 89990,
    bonusPrice: 84990,
    images: [
      _u('photo-1515488042361-ee00e0ddd4e4'),
      _u('photo-1558060370-d644606edb17'),
    ],
    sellerName: 'Toy Store',
    rating: 4.9,
    installmentMonthly: 3749,
    description: 'Конструктор LEGO City с машинами и фигурками пожарных.',
    tags: ['kids', 'toys'],
    searchKeywords: ['lego', 'конструктор', 'дети'],
  ),
  KaspiShopProductSeed(
    id: 'stroller-premium',
    title: 'Коляска 2 в 1 Premium, серый меланж',
    category: 'kids',
    price: 199990,
    bonusPrice: 189990,
    images: [
      _u('photo-1519689680058-324335c77eba'),
      _u('photo-1515488042361-ee00e0ddd4e4'),
    ],
    sellerName: 'Mothercare',
    rating: 4.7,
    installmentMonthly: 8333,
    description: 'Коляска-трансформер с люлькой, прогулочным блоком и дождевиком.',
    tags: ['kids', 'stroller'],
    searchKeywords: ['коляска', 'детская'],
  ),
  KaspiShopProductSeed(
    id: 'coffee-machine',
    title: 'Кофемашина DeLonghi Magnifica S',
    category: 'home',
    price: 189990,
    bonusPrice: 179990,
    images: [
      _u('photo-1517668808822-9ebb02b2a0b0'),
      _u('photo-1616046229475-ee4cfb373c65'),
    ],
    sellerName: 'TECHNODOM',
    rating: 4.8,
    installmentMonthly: 7916,
    description: 'Автоматическая кофемашина с капучинатором и помолом зёрен.',
    tags: ['home', 'kitchen'],
    searchKeywords: ['кофемашина', 'delonghi', 'кофе'],
  ),
  KaspiShopProductSeed(
    id: 'air-purifier',
    title: 'Очиститель воздуха Xiaomi Smart Air 4',
    category: 'home',
    price: 99990,
    bonusPrice: 94990,
    images: [
      _u('photo-1585771724684-38269a6e7861'),
      _u('photo-1616046229475-ee4cfb373c65'),
    ],
    sellerName: 'Mechta',
    rating: 4.6,
    installmentMonthly: 4166,
    description: 'Умный очиститель с HEPA-фильтром и управлением из приложения.',
    tags: ['home', 'climate'],
    searchKeywords: ['очиститель', 'воздух', 'xiaomi'],
  ),
  KaspiShopProductSeed(
    id: 'pink-set-women',
    title: 'Розовая двойка женская, хлопок',
    category: 'home',
    price: 24990,
    bonusPrice: 21990,
    images: [
      _u('photo-1515372039744-b8f02a3ae446'),
      _u('photo-1434389677669-e08b4cac3105'),
    ],
    sellerName: 'Kaspi Магазин',
    rating: 4.5,
    installmentMonthly: 1041,
    description: 'Стильный комплект из худи и брюк пастельного розового цвета.',
    tags: ['fashion', 'women'],
    searchKeywords: ['розовая', 'двойка', 'женская'],
  ),
  KaspiShopProductSeed(
    id: 'black-dress',
    title: 'Чёрное платье женское, миди',
    category: 'home',
    price: 19990,
    bonusPrice: 17990,
    images: [
      _u('photo-1515372039744-b8f02a3ae446'),
      _u('photo-1496747611176-843222e1e910'),
    ],
    sellerName: 'Kaspi Магазин',
    rating: 4.6,
    installmentMonthly: 833,
    description: 'Элегантное чёрное платье на каждый день и вечер.',
    tags: ['fashion', 'women'],
    searchKeywords: ['платье', 'черное', 'женское'],
  ),
];
