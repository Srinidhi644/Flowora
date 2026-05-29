# Flowora

**Day. Work. Cooking.** — Your whole day, beautifully managed.

An all-in-one life management app built with Flutter + Spring Boot.

## Features

- **Smart Dashboard** — Today's tasks, schedule, meals, and habits at a glance
- **Task Management** — Priorities, categories, recurring tasks
- **Time Blocking** — Visual daily schedule with color-coded blocks
- **Recipe Book** — Save recipes, search by ingredients, "What can I cook?"
- **Meal Planner** — Weekly meal planning with auto shopping list
- **Habit Tracker** — Daily check-ins with streak tracking
- **Offline-First** — Works without internet, syncs when online
- **Dark Mode** — Beautiful dark theme

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.44 + Dart |
| State | Riverpod |
| Local DB | Hive |
| Backend | Spring Boot 3.2 + Java 17 |
| Auth | JWT (Spring Security) |
| Database | H2 (dev) / MySQL (prod) |
| Deploy | Docker + docker-compose |

## Getting Started

### Backend
```bash
cd backend
./mvnw spring-boot:run
# Runs on http://localhost:8080
```

### Flutter App
```bash
flutter pub get
flutter run
```

### Production
```bash
docker-compose up -d
```

See [DEPLOY.md](DEPLOY.md) for full deployment instructions.

## Project Structure

```
Flowora/
├── lib/                    # Flutter app (Dart)
│   ├── core/               # Theme, constants, utils, router
│   ├── models/             # Data models
│   ├── providers/          # Riverpod state management
│   ├── screens/            # 12 app screens
│   ├── services/           # API client, storage, notifications
│   └── widgets/            # Reusable UI components
├── backend/                # Spring Boot API (Java)
│   └── src/main/java/com/flowora/
│       ├── controller/     # REST endpoints
│       ├── entity/         # JPA entities
│       ├── repository/     # Data access
│       ├── service/        # Business logic
│       └── security/       # JWT auth
├── android/                # Android platform
├── ios/                    # iOS platform
├── web/                    # Web platform
└── docker-compose.yml      # Production deployment
```

## License

MIT
