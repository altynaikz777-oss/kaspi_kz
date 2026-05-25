import 'package:flutter/material.dart';

import 'kaspi_inbox_icons.dart';

class KaspiServiceItem {
  const KaspiServiceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.keywords = const [],
    this.gradient = const [Color(0xFFED1C24), Color(0xFFFF6A45)],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<String> keywords;
  final List<Color> gradient;
}

class KaspiBannerItem {
  const KaspiBannerItem({
    required this.title,
    required this.subtitle,
    required this.cta,
    this.gradient = const [Color(0xFFED1C24), Color(0xFFFF6A45)],
  });

  final String title;
  final String subtitle;
  final String cta;
  final List<Color> gradient;
}

class KaspiStoryItem {
  const KaspiStoryItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class KaspiPaymentItem {
  const KaspiPaymentItem({
    required this.title,
    required this.subtitle,
    this.keywords = const [],
  });

  final String title;
  final String subtitle;
  final List<String> keywords;
}

const kaspiPrimary = Color(0xFFED1C24);
const kaspiPrimaryLight = Color(0xFFFF6A45);
const kaspiBackground = Color(0xFFF5F6F8);
const kaspiGoldBalanceLabel = '101,26 ₸';
const kaspiTransferBlue = Color(0xFF0089D8);
const kaspiTransferGold = Color(0xFFD4A361);

const kaspiServices = <KaspiServiceItem>[
  KaspiServiceItem(
    id: 'bank',
    title: 'Мой Банк',
    subtitle: 'Карты, баланс, счета',
    icon: Icons.account_balance_wallet_rounded,
    route: '/services/bank',
    keywords: ['банк', 'карта', 'баланс', 'счет', 'кредит'],
  ),
  KaspiServiceItem(
    id: 'payments',
    title: 'Платежи',
    subtitle: 'Коммунальные и штрафы',
    icon: Icons.payments_rounded,
    route: '/services/payments',
    keywords: ['платеж', 'коммунал', 'штраф', 'оплата'],
    gradient: [Color(0xFF2563EB), Color(0xFF60A5FA)],
  ),
  KaspiServiceItem(
    id: 'gov',
    title: 'Госуслуги',
    subtitle: 'Справки и документы',
    icon: Icons.account_balance_rounded,
    route: '/services/gov',
    keywords: ['госуслуги', 'справка', 'документ', 'егов'],
    gradient: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
  ),
  KaspiServiceItem(
    id: 'shop',
    title: 'Магазин',
    subtitle: 'Товары и рассрочка',
    icon: Icons.storefront_rounded,
    route: '/services/shop',
    keywords: ['магазин', 'товар', 'рассрочка', 'заказ'],
    gradient: [Color(0xFFED1C24), Color(0xFFFF6A45)],
  ),
  KaspiServiceItem(
    id: 'travel',
    title: 'Travel',
    subtitle: 'Билеты и отели',
    icon: Icons.flight_takeoff_rounded,
    route: '/services/travel',
    keywords: ['travel', 'билет', 'отель', 'авиа'],
    gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  ),
  KaspiServiceItem(
    id: 'magnum',
    title: 'Magnum',
    subtitle: 'Доставка продуктов',
    icon: Icons.local_grocery_store_rounded,
    route: '/services/magnum',
    keywords: ['magnum', 'продукты', 'доставка', 'еда'],
    gradient: [Color(0xFF15803D), Color(0xFF4ADE80)],
  ),
  KaspiServiceItem(
    id: 'transfers',
    title: 'Переводы',
    subtitle: 'Отправить деньги',
    icon: Icons.swap_horiz_rounded,
    route: '/home/transfers',
    keywords: ['перевод', 'отправить', 'деньги', 'контакт'],
    gradient: [Color(0xFFEA580C), Color(0xFFFDBA74)],
  ),
  KaspiServiceItem(
    id: 'history',
    title: 'История',
    subtitle: 'Операции и заказы',
    icon: Icons.history_rounded,
    route: '/services/history',
    keywords: ['история', 'операции', 'транзакции'],
    gradient: [Color(0xFF475569), Color(0xFF94A3B8)],
  ),
  KaspiServiceItem(
    id: 'favorites',
    title: 'Избранное',
    subtitle: 'Сохраненные товары',
    icon: Icons.favorite_rounded,
    route: '/services/favorites',
    keywords: ['избранное', 'wishlist', 'сохранен'],
    gradient: [Color(0xFFDB2777), Color(0xFFF9A8D4)],
  ),
  KaspiServiceItem(
    id: 'jobs',
    title: 'Работа',
    subtitle: 'Вакансии и подработка',
    icon: Icons.work_outline_rounded,
    route: '/services/jobs',
    keywords: ['работа', 'вакансия', 'jobs'],
    gradient: [Color(0xFFED1C24), Color(0xFFFF6A45)],
  ),
  KaspiServiceItem(
    id: 'settings',
    title: 'Настройки',
    subtitle: 'Профиль и безопасность',
    icon: Icons.settings_rounded,
    route: '/services/settings',
    keywords: ['настройки', 'профиль', 'pin', 'язык'],
    gradient: [Color(0xFF334155), Color(0xFF64748B)],
  ),
];

const kaspiHomeBanners = <KaspiBannerItem>[
  KaspiBannerItem(
    title: 'Kaspi Red',
    subtitle: 'Кэшбэк до 30% в партнерской сети',
    cta: 'Подробнее',
  ),
  KaspiBannerItem(
    title: '0-0-24',
    subtitle: 'Рассрочка без переплат на тысячи товаров',
    cta: 'В магазин',
    gradient: [Color(0xFF2563EB), Color(0xFF60A5FA)],
  ),
  KaspiBannerItem(
    title: 'Kaspi Travel',
    subtitle: 'Авиабилеты и отели со скидкой',
    cta: 'Найти тур',
    gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  ),
];

class KaspiHomeQuickAction {
  const KaspiHomeQuickAction({
    required this.label,
    required this.icon,
    required this.route,
    this.iconColor,
    this.useMagnumStyle = false,
  });

  final String label;
  final IconData icon;
  final String route;
  final Color? iconColor;
  final bool useMagnumStyle;
}

class KaspiHomePromoCard {
  const KaspiHomePromoCard({
    required this.title,
    required this.badge,
    required this.icon,
    required this.colors,
    this.imageUrl,
  });

  final String title;
  final String badge;
  final IconData icon;
  final List<Color> colors;
  final String? imageUrl;
}

class KaspiDepositItem {
  const KaspiDepositItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class KaspiBankCardItem {
  const KaspiBankCardItem({
    required this.title,
    required this.balance,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.route,
  });

  final String title;
  final String balance;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String? route;
}

const kaspiBankCards = <KaspiBankCardItem>[
  KaspiBankCardItem(
    title: 'Kaspi Gold',
    balance: kaspiGoldBalanceLabel,
    subtitle: 'Основная карта',
    gradient: [Color(0xFFE8C882), Color(0xFFD4A361)],
    icon: Icons.people_outline_rounded,
    route: '/home/transfers',
  ),
  KaspiBankCardItem(
    title: 'Накопительный Депозит',
    balance: '450 000 ₸',
    subtitle: 'Ставка 20% годовых',
    gradient: [Color(0xFFFFE566), Color(0xFFF5C518)],
    icon: Icons.savings_outlined,
  ),
  KaspiBankCardItem(
    title: 'Kaspi Бонус',
    balance: '1 240 Б',
    subtitle: 'Кэшбэк и бонусы',
    gradient: [Color(0xFF4ADE80), Color(0xFF22A06B)],
    icon: Icons.loyalty_outlined,
    route: '/services/shop',
  ),
];

class KaspiInboxItem {
  const KaspiInboxItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.dateLabel,
    required this.icon,
    required this.iconBackground,
    this.iconAsset,
    this.route,
    this.pinned = false,
    this.iconColor = Colors.white,
  });

  final String id;
  final String title;
  final String preview;
  final String dateLabel;
  final IconData icon;
  final Color iconBackground;
  final String? iconAsset;
  final Color iconColor;
  final String? route;
  final bool pinned;
}

const kaspiHomeQuickActions = <KaspiHomeQuickAction>[
  KaspiHomeQuickAction(
    label: 'Магазин',
    icon: Icons.storefront_outlined,
    route: '/services/shop',
  ),
  KaspiHomeQuickAction(
    label: 'Мой Банк',
    icon: Icons.account_balance_wallet_outlined,
    route: '/services/bank',
  ),
  KaspiHomeQuickAction(
    label: 'Платежи',
    icon: Icons.receipt_long_outlined,
    route: '/services/payments',
  ),
  KaspiHomeQuickAction(
    label: 'Переводы',
    icon: Icons.swap_horiz_outlined,
    route: '/home/transfers',
  ),
  KaspiHomeQuickAction(
    label: 'Magnum',
    icon: Icons.local_grocery_store_outlined,
    route: '/services/magnum',
    iconColor: Color(0xFFE91E8C),
    useMagnumStyle: true,
  ),
  KaspiHomeQuickAction(
    label: 'Travel',
    icon: Icons.card_travel_outlined,
    route: '/services/travel',
  ),
  KaspiHomeQuickAction(
    label: 'Госуслуги',
    icon: Icons.account_balance_outlined,
    route: '/services/gov',
  ),
  KaspiHomeQuickAction(
    label: 'Работа',
    icon: Icons.work_outline_rounded,
    route: '/services/jobs',
  ),
];

const kaspiHomePromoCards = <KaspiHomePromoCard>[
  KaspiHomePromoCard(
    title: 'Подборка свадебных товаров',
    badge: '-30%',
    icon: Icons.diamond_outlined,
    colors: [Color(0xFFFFF0F3), Color(0xFFFFE4EC)],
    imageUrl:
        'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=400&q=85&auto=format&fit=crop',
  ),
  KaspiHomePromoCard(
    title: 'Мгновенные ответы и плейлист!',
    badge: '',
    icon: Icons.speaker_outlined,
    colors: [Color(0xFFE8F4FF), Color(0xFFD6EBFF)],
    imageUrl:
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=85&auto=format&fit=crop',
  ),
];

const kaspiDeposits = <KaspiDepositItem>[
  KaspiDepositItem(
    title: 'Накопительный Депозит 20%',
    icon: Icons.savings_outlined,
  ),
  KaspiDepositItem(
    title: 'Kaspi Депозит 15%',
    icon: Icons.currency_exchange_rounded,
  ),
];

const kaspiInboxDefaults = <KaspiInboxItem>[
  KaspiInboxItem(
    id: 'guide',
    title: 'Чат с Kaspi Гид',
    preview: 'Как получить карту?',
    dateLabel: '05.05.2026',
    icon: Icons.chat_bubble_outline_rounded,
    iconBackground: Color(0xFFED1C24),
    iconAsset: KaspiInboxIcons.guide,
    route: '/messages/guide',
    pinned: true,
  ),
  KaspiInboxItem(
    id: 'promo',
    title: 'Акции',
    preview: 'Скидки до 50%!',
    dateLabel: '05.05.2026',
    icon: Icons.card_giftcard_outlined,
    iconBackground: Color(0xFFED1C24),
    iconAsset: KaspiInboxIcons.promo,
    route: '/messages/promotions',
  ),
  KaspiInboxItem(
    id: 'gold',
    title: 'Kaspi Gold',
    preview: 'Перевод: 180 ₸',
    dateLabel: '05.05.2026',
    icon: Icons.people_outline_rounded,
    iconBackground: Color(0xFFC9A227),
    iconAsset: KaspiInboxIcons.gold,
    route: '/messages/gold',
  ),
  KaspiInboxItem(
    id: 'remote-pay',
    title: 'Удаленная оплата',
    preview: 'Оплата прошла успешно',
    dateLabel: 'Вчера',
    icon: Icons.description_outlined,
    iconBackground: Color(0xFFF5C518),
    iconAsset: KaspiInboxIcons.remotePay,
    route: '/messages/remote-payment',
  ),
  KaspiInboxItem(
    id: 'jobs',
    title: 'Kaspi Работа',
    preview: 'Новые вакансии рядом с вами',
    dateLabel: 'Вчера',
    icon: Icons.work_outline_rounded,
    iconBackground: Color(0xFFED1C24),
    iconAsset: KaspiInboxIcons.jobs,
    route: '/messages/jobs',
  ),
  KaspiInboxItem(
    id: 'bonus',
    title: 'Kaspi Бонус',
    preview: '+120 бонусов за покупку',
    dateLabel: 'Вчера',
    icon: Icons.loyalty_outlined,
    iconBackground: Color(0xFF22A06B),
    iconAsset: KaspiInboxIcons.bonus,
    route: '/messages/bonus',
  ),
];

const kaspiStories = <KaspiStoryItem>[
  KaspiStoryItem(label: 'Акции', icon: Icons.local_offer_rounded),
  KaspiStoryItem(label: 'Банк', icon: Icons.credit_card_rounded),
  KaspiStoryItem(label: 'Магазин', icon: Icons.shopping_bag_rounded),
  KaspiStoryItem(label: 'QR', icon: Icons.qr_code_scanner_rounded),
  KaspiStoryItem(label: 'Travel', icon: Icons.flight_rounded),
  KaspiStoryItem(label: 'Magnum', icon: Icons.eco_rounded),
];

class KaspiMenuGridItem {
  const KaspiMenuGridItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class KaspiFrequentPayment {
  const KaspiFrequentPayment({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
}

class KaspiTransferOption {
  const KaspiTransferOption({
    required this.title,
    this.subtitle,
    required this.icon,
    this.route,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? route;
}

class KaspiPartnerService {
  const KaspiPartnerService({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.iconBackground,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color iconBackground;
  final String route;
}

const kaspiServicesMenuGrid = <KaspiMenuGridItem>[
  KaspiMenuGridItem(
    label: 'Магазин',
    icon: Icons.shopping_cart_outlined,
    route: '/services/shop',
  ),
  KaspiMenuGridItem(
    label: 'Мой Банк',
    icon: Icons.smartphone_outlined,
    route: '/services/bank',
  ),
  KaspiMenuGridItem(
    label: 'Платежи',
    icon: Icons.receipt_long_outlined,
    route: '/services/payments',
  ),
  KaspiMenuGridItem(
    label: 'Переводы',
    icon: Icons.sync_rounded,
    route: '/home/transfers',
  ),
  KaspiMenuGridItem(
    label: 'Акции',
    icon: Icons.card_giftcard_outlined,
    route: '/services/shop',
  ),
  KaspiMenuGridItem(
    label: 'Travel',
    icon: Icons.card_travel_outlined,
    route: '/services/travel',
  ),
  KaspiMenuGridItem(
    label: 'Госуслуги',
    icon: Icons.account_balance_outlined,
    route: '/services/gov',
  ),
  KaspiMenuGridItem(
    label: 'Объявления',
    icon: Icons.article_outlined,
    route: '/services/shop',
  ),
  KaspiMenuGridItem(
    label: 'Гид',
    icon: Icons.person_outline_rounded,
    route: '/chat',
  ),
  KaspiMenuGridItem(
    label: 'Kaspi Maps',
    icon: Icons.location_on_outlined,
    route: '/services/travel',
  ),
  KaspiMenuGridItem(
    label: 'Сертификаты',
    icon: Icons.redeem_outlined,
    route: '/services/shop',
  ),
  KaspiMenuGridItem(
    label: 'Работа',
    icon: Icons.work_outline_rounded,
    route: '/services/jobs',
  ),
];

const kaspiFrequentPayments = <KaspiFrequentPayment>[
  KaspiFrequentPayment(
    title: 'Такси Колеса',
    subtitle: 'Тараз, +7 (747) 720-78-80',
    icon: Icons.local_taxi_rounded,
    iconColor: Color(0xFFF5C518),
  ),
  KaspiFrequentPayment(
    title: 'Activ',
    subtitle: '+7 (775) 243-11-77',
    icon: Icons.sim_card_outlined,
    iconColor: Color(0xFF7B68EE),
  ),
];

const kaspiTransferOptions = <KaspiTransferOption>[
  KaspiTransferOption(
    title: 'Между своими счетами',
    icon: Icons.sync_rounded,
    route: '/services/bank',
  ),
  KaspiTransferOption(
    title: 'Клиенту Kaspi',
    subtitle: 'На карту Kaspi Gold',
    icon: Icons.person_outline_rounded,
    route: '/home/transfers/client',
  ),
  KaspiTransferOption(
    title: 'Карта другого банка',
    subtitle: 'С карты на карту',
    icon: Icons.credit_card_outlined,
  ),
  KaspiTransferOption(
    title: 'Международные переводы',
    subtitle: 'По номеру карты или телефона',
    icon: Icons.public_outlined,
  ),
  KaspiTransferOption(
    title: 'Kaspi QR',
    subtitle: 'Сканируйте и платите',
    icon: Icons.qr_code_2_outlined,
    route: '/qr',
  ),
];

const kaspiPartnerServices = <KaspiPartnerService>[
  KaspiPartnerService(
    title: 'Glovo',
    subtitle: 'Сервис доставки еды',
    badge: '10% Б',
    icon: Icons.delivery_dining_rounded,
    iconBackground: Color(0xFFFFC400),
    route: '/services/shop',
  ),
  KaspiPartnerService(
    title: 'Alipay+',
    subtitle: 'Оплата за границей через QR',
    badge: '',
    icon: Icons.qr_code_scanner_outlined,
    iconBackground: Color(0xFF1677FF),
    route: '/qr',
  ),
];

const kaspiPaymentTypes = <KaspiPaymentItem>[
  KaspiPaymentItem(
    title: 'Мобильная связь',
    subtitle: 'Beeline, Kcell, Tele2',
    keywords: ['телефон', 'связь', 'мобильный'],
  ),
  KaspiPaymentItem(
    title: 'Коммунальные',
    subtitle: 'Вода, свет, газ',
    keywords: ['коммунал', 'квартплата', 'жкх'],
  ),
  KaspiPaymentItem(
    title: 'Штрафы',
    subtitle: 'ПДД и административные',
    keywords: ['штраф', 'пдд', 'гибдд'],
  ),
  KaspiPaymentItem(
    title: 'Налоги',
    subtitle: 'ИП и физлица',
    keywords: ['налог', 'ипн', 'кпн'],
  ),
];

KaspiServiceItem? findServiceById(String id) {
  for (final service in kaspiServices) {
    if (service.id == id) {
      return service;
    }
  }
  return null;
}
