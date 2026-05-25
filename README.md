<<<<<<< HEAD
# Kaspi Flutter Clone

Pure Flutter + Dart rebuild of the Kaspi.kz style app with Firebase-backed flows.

## Included flows

- PIN lock
- Home
- Shop
- Categories
- Product detail
- Cart
- Search
- Favorites
- Orders
- Kaspi Guide Chat
- Settings

## Stack

- Flutter + Dart
- Riverpod
- GoRouter
- Firebase Auth
- Cloud Firestore
- Firebase Storage

## Run

1. Install Flutter dependencies:
   `flutter pub get`
2. Run on Android:
   `flutter run -d android`
3. Run on Web after adding Firebase Web app values:
   `flutter run -d chrome --dart-define=FIREBASE_WEB_API_KEY=... --dart-define=FIREBASE_WEB_APP_ID=...`

## Google Sign-In

Enable **Google** in Firebase Console → Authentication → Sign-in method.

- **Android**: uses `google-services.json` OAuth client + `serverClientId` from the Web client.
- **Web**: uses `signInWithPopup` (authorized domain must include `localhost` for local dev).

Phone OTP and PIN flows are unchanged.

## Required Firebase dart-defines

- Android is already configured from `android/app/google-services.json`.
- Web still requires:
  `FIREBASE_WEB_API_KEY`, `FIREBASE_WEB_APP_ID`
- iOS requires:
  `FIREBASE_IOS_API_KEY`, `FIREBASE_IOS_APP_ID`, `FIREBASE_IOS_BUNDLE_ID`
- Web or desktop if used:
  matching platform `API_KEY` and `APP_ID`

## Shop catalog seed

On first launch the app seeds `categories`, `products`, and `meta/shop.catalogVersion`
with curated Kaspi-style products and matching Unsplash image URLs (phones, TVs,
shoes, furniture, etc.). Restart the app after upgrading to refresh catalog v2.

## Firebase Storage (avatars)

Profile photos upload to `users/{uid}/avatar.jpg`. Deploy rules from the project root:

```bash
firebase deploy --only storage
```

## Firestore collections used

- `users`
- `products`
- `categories`
- `meta`
- `cart/{uid}/items`
- `wishlist/{uid}/items`
- `searchHistory/{uid}/queries`
- `viewHistory/{uid}/items`
- `transactions/{uid}/list`
- `chats/{uid}/messages`
- `orders`
=======
# kaspi_kz
>>>>>>> ee8fe810b03d68cc058a48edd8abdb4675ad4e30
