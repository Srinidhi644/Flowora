# Flowora — Deployment Guide

## What's Built

| Artifact | Location | Size |
|----------|----------|------|
| Android APK | `flowora-v1.0.0.apk` | 53 MB |
| Web App | `build/web/` | 41 MB |
| Backend Docker | `backend/Dockerfile` | — |

---

## 1. Deploy Backend (Choose One)

### Option A: Railway (Easiest — free tier)

1. Push code to GitHub
2. Go to [railway.app](https://railway.app), sign in with GitHub
3. New Project → Deploy from GitHub repo
4. Set root directory to `backend`
5. Add a **MySQL** service from Railway's marketplace
6. Set environment variables:
   ```
   SPRING_PROFILES_ACTIVE=prod
   DATABASE_URL=<railway provides this>
   DATABASE_DRIVER=com.mysql.cj.jdbc.Driver
   DATABASE_USERNAME=<from railway>
   DATABASE_PASSWORD=<from railway>
   JWT_SECRET=<generate a random 64-char string>
   ```
7. Deploy — Railway auto-detects the Dockerfile

### Option B: Render (Free tier)

1. Push to GitHub
2. Go to [render.com](https://render.com) → New Web Service
3. Connect repo, set root directory to `backend`
4. Set Build Command: `./mvnw package -DskipTests`
5. Set Start Command: `java -jar target/*.jar`
6. Add environment variables (same as above)
7. Add a Render PostgreSQL database (free)

### Option C: Docker Compose (VPS/AWS EC2)

```bash
# On your server
git clone <your-repo>
cd Flowora

# Set secrets
export JWT_SECRET="your-random-64-char-secret"
export MYSQL_ROOT_PASSWORD="your-db-password"

# Run
docker-compose up -d
```

Backend will be at `http://your-server-ip:8080`

---

## 2. Deploy Web App

### Option A: Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd build/web
vercel --prod
```

### Option B: Netlify

1. Go to [netlify.com](https://netlify.com) → Add new site
2. Drag & drop the `build/web/` folder
3. Done — you get a URL like `flowora.netlify.app`

### Option C: Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting  # set public dir to build/web
firebase deploy
```

---

## 3. Distribute Android APK

### Direct Download
- Share `flowora-v1.0.0.apk` directly
- Users enable "Install from unknown sources" and install

### Google Play Store
1. Create a [Google Play Developer account](https://play.google.com/console) ($25 one-time)
2. Build a signed App Bundle:
   ```bash
   flutter build appbundle --release
   ```
3. Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console
4. Fill in listing details, screenshots, etc.
5. Submit for review

---

## 4. Connect Flutter to Deployed Backend

Once your backend is deployed (e.g. `https://flowora-api.railway.app`):

### For Web:
```bash
flutter build web --dart-define=API_URL=https://flowora-api.railway.app/api
```

### For Android APK:
```bash
flutter build apk --release --dart-define=API_URL=https://flowora-api.railway.app/api
```

### For iOS:
```bash
flutter build ios --release --dart-define=API_URL=https://flowora-api.railway.app/api
```

---

## 5. iOS App Store (Requires Xcode + $99/year Apple Developer)

1. Install Xcode from Mac App Store
2. Enroll in [Apple Developer Program](https://developer.apple.com/programs/)
3. Build:
   ```bash
   flutter build ios --release --dart-define=API_URL=https://your-api.com/api
   ```
4. Open `ios/Runner.xcworkspace` in Xcode
5. Archive → Distribute App → App Store Connect
6. Fill listing in App Store Connect, submit for review
