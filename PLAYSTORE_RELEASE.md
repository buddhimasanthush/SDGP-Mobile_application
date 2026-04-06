# Play Store Release Setup

## 1) Android signing
1. Create `frontend/android/key.properties` from `frontend/android/key.properties.example`.
2. Set `storeFile` to your upload keystore path.

## 2) Required secrets
Use CI/CD secrets or local environment variables. Do not hardcode.

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_MAPS_API_KEY`

## 3) Build release
From `frontend/`:

```powershell
flutter build appbundle --release `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_anon_key `
  --dart-define=API_BASE_URL=https://your-backend-domain/api
```

For iOS builds, set `GOOGLE_MAPS_API_KEY` in Xcode build settings/environment.
