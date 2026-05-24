# Kaspi Expo Clone

Expo React Native UI clone of Kaspi.kz with Firebase-backed shop, chat, cart, history, favorites, settings, and PIN lock flow.

## Run

1. `npm install`
2. `npm run start`

## Firebase seed

1. Create a Firebase service account JSON.
2. Export it as a single-line env var:
   `export FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account", ...}'`
3. Run:
   `npm run seed`

## Notes

- Android config points to `android/app/google-services.json`.
- Firebase web/native client config is in `src/services/firebase.ts`.
- Test seeded user phone: `+77001234567`
- Test PIN: `1234`
