import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/app_models.dart';
import 'providers/app_providers.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/message_channel_screens.dart';
import 'screens/messages_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/product_detail_screen.dart';
import 'models/qr_scan_models.dart';
import 'screens/qr_scan_result_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/search_screen.dart';
import 'screens/bank_screen.dart';
import 'screens/service_hub_screens.dart';
import 'screens/services_screen.dart';
import 'models/transfer_models.dart';
import 'screens/transfer_to_client_screen.dart';

class KaspiAppBootstrap extends StatelessWidget {
  const KaspiAppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: KaspiApp());
  }
}

class KaspiApp extends ConsumerWidget {
  const KaspiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],

supportedLocales: const [
  Locale('ru'),
  Locale('en'),
],
      debugShowCheckedModeBanner: false,
      title: 'Kaspi',
      locale: locale,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFED1C24),
          primary: const Color(0xFFED1C24),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}

bool _isTransferFlowPath(String path) =>
    path.startsWith('/home/transfers');

bool _isTransferSuccessPath(String path) =>
    path == '/home/transfers/client/confirm/success';

/// Keeps GoRouter instance stable when profile/balance updates after a transfer.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen<AsyncValue<UserProfile?>>(
      currentUserProfileProvider,
      (_, _) => notifyListeners(),
    );
    ref.listen<bool>(pinVerifiedProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final bootstrap = ref.watch(bootstrapProvider);
  final auth = ref.watch(authStateProvider);
  final refresh = _RouterRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (bootstrap.isLoading || auth.isLoading) {
        return null;
      }
      final user = auth.valueOrNull;
      final currentPath = state.matchedLocation;
      final profile = ref.read(currentUserProfileProvider);
      final pinVerified = ref.read(pinVerifiedProvider);
      if (_isTransferSuccessPath(currentPath)) {
        return null;
      }
      if (user == null) {
        return currentPath == '/auth' ? null : '/auth';
      }
      final currentProfile = profile.valueOrNull;
      if (currentPath == '/auth') {
        return currentProfile == null || !pinVerified ? '/pin' : '/home';
      }
      if (profile.isLoading) {
        return null;
      }
      if (currentProfile == null) {
        if (_isTransferFlowPath(currentPath)) {
          return null;
        }
        return '/home';
      }
      if (!pinVerified && currentPath != '/pin') {
        return '/pin';
      }
      if (pinVerified && currentPath == '/pin') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/pin',
        builder: (context, state) {
          final currentProfile =
              ref.read(currentUserProfileProvider).valueOrNull ??
              const UserProfile(
                id: '',
                name: 'Пользователь Kaspi',
                phone: '',
                language: 'Русский',
                pinHash: '',
                pushNotifications: true,
                soundNotifications: true,
                faceId: false,
              );
          return PinLockScreen(profile: currentProfile);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'transfers',
                    name: '/home/transfers',
                    builder: (context, state) =>
                        const TransfersServiceScreen(),
                    routes: [
                      GoRoute(
                        path: 'client',
                        name: '/home/transfers/client',
                        builder: (context, state) =>
                            const TransferToClientScreen(),
                        routes: [
                          GoRoute(
                            path: 'confirm',
                            name: '/home/transfers/client/confirm',
                            builder: (context, state) {
                              final draft = state.extra as TransferDraft?;
                              if (draft == null) {
                                return const TransferToClientScreen();
                              }
                              return TransferConfirmScreen(draft: draft);
                            },
                            routes: [
                              GoRoute(
                                path: 'success',
                                name: '/home/transfers/client/confirm/success',
                                builder: (context, state) =>
                                    const TransferSuccessScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/qr',
                builder: (context, state) => const QrScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (context, state) => const ServicesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/services/bank',
        builder: (context, state) => const BankServiceScreen(),
      ),
      GoRoute(
        path: '/services/payments',
        builder: (context, state) => const PaymentsServiceScreen(),
      ),
      GoRoute(
        path: '/services/gov',
        builder: (context, state) => const GovServiceScreen(),
      ),
      GoRoute(
        path: '/services/shop',
        builder: (context, state) => const ShopServiceScreen(),
      ),
      GoRoute(
        path: '/services/travel',
        builder: (context, state) => const TravelServiceScreen(),
      ),
      GoRoute(
        path: '/services/magnum',
        builder: (context, state) => const MagnumServiceScreen(),
      ),
      GoRoute(
        path: '/services/history',
        builder: (context, state) => const HistoryServiceScreen(),
      ),
      GoRoute(
        path: '/services/favorites',
        builder: (context, state) => const FavoritesServiceScreen(),
      ),
      GoRoute(
        path: '/services/settings',
        builder: (context, state) => const SettingsServiceScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) => CategoryProductsScreen(
          categoryId: state.pathParameters['id']!,
          categoryTitle: (state.extra as String?) ?? 'Категория',
        ),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/messages/gold',
        builder: (context, state) => const KaspiGoldChatScreen(),
      ),
      GoRoute(
        path: '/messages/guide',
        builder: (context, state) => const GuideChannelScreen(),
      ),
      GoRoute(
        path: '/messages/promotions',
        builder: (context, state) => const PromotionsChannelScreen(),
      ),
      GoRoute(
        path: '/messages/remote-payment',
        builder: (context, state) => const RemotePaymentChannelScreen(),
      ),
      GoRoute(
        path: '/messages/jobs',
        builder: (context, state) => const JobsChannelScreen(),
      ),
      GoRoute(
        path: '/messages/bonus',
        builder: (context, state) => const BonusChannelScreen(),
      ),
      GoRoute(
        path: '/qr/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/qr/result',
        builder: (context, state) {
          final payload = state.extra as QrScanPayload?;
          if (payload == null) {
            return const QrScannerScreen();
          }
          return QrScanResultScreen(payload: payload);
        },
      ),
      GoRoute(
        path: '/qr/payment',
        builder: (context, state) {
          final value = state.extra as String? ?? '';
          return QrScanPaymentScreen(scannedValue: value);
        },
      ),
    ],
  );
});
