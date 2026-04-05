# Deploy MediFind Backend To Railway

This repository now includes a root `Dockerfile`, so Railway can deploy directly from the repo root.
It also includes a root `.python-version` to pin Railway/Railpack to Python `3.12`.

## 1) Push code to GitHub

Make sure these files are committed:
- `Dockerfile`
- `.dockerignore`
- `.python-version`
- `backend/.env.example`

Your real `backend/.env` is ignored and should never be committed.

## 2) Create Railway project

1. Open Railway.
2. Click `New Project` -> `Deploy from GitHub repo`.
3. Select this repository.
4. Railway should detect the root `Dockerfile` automatically.

## 3) Add environment variables in Railway

In Railway service `Variables`, add:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ANON_KEY`
- `JWT_SECRET`
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASSWORD`
- `SMTP_FROM`
- `SMTP_USE_SSL`
- `MAX_SMTP_RETRIES`
- `OTP_EXPIRY_MINUTES`
- `DEEPSEEK_API_KEY`

`PORT` is set by Railway automatically.

## 4) Deploy and test

After deploy, open the generated Railway URL and test:
- `GET /`
- `POST /api/email/send-otp`
- `POST /api/ocr/upload` (if OCR is enabled and dependencies install correctly)

## Build timeout note

If Railway uses Railpack/Nixpacks (instead of the Dockerfile), the backend requirements are now pinned to CPU-only PyTorch wheels via:

- `--extra-index-url https://download.pytorch.org/whl/cpu`
- `torch==2.11.0+cpu`
- `torchvision==0.26.0+cpu`

This avoids downloading large CUDA packages that can cause build export timeouts.

## 5) Point Flutter app to Railway

Use your Railway domain when running/building frontend:

```bash
flutter run --dart-define=API_BASE_URL=https://YOUR_APP.up.railway.app
```

The app will automatically append `/api`, so do not add `/api` twice.
