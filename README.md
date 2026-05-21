# Vaultiq (Flutter)

Mobile port of the Vaultiq personal finance app (React web version lives in `../debt-tracker-react`).

## Features

- Credit cards and loans with statement logging (interest & paydown)
- Savings goals with add/withdraw
- Dashboard overview and insights
- Dark / light theme
- Local storage (works offline)
- Optional Supabase sign-in and cloud sync (`user_financial_states` — same payload as the web app)
- JSON backup export / import

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.11+

## Run

```bash
cd vaultiq_flutter
flutter pub get
flutter run
```

## Project layout

| Path | Purpose |
|------|---------|
| `lib/models/` | Account, statement, savings, portfolio |
| `lib/providers/` | Portfolio state, theme |
| `lib/services/` | Local persistence, cloud sync |
| `lib/screens/` | Auth, dashboard, debts, savings, insights, settings |
| `lib/widgets/` | Currency input, account cards |

## Supabase

Uses the same project and table as the React app. For mobile deep links, configure redirect URLs in the Supabase dashboard if you add OAuth later; email/password works out of the box.

## Backup compatibility

Export/import JSON matches the web app shape: `{ accounts, statements, savings }`. Legacy backups with a `debts` array are also supported.
