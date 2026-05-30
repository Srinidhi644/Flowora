# Flowora

**Day. Work. Cooking.** — Your whole day, beautifully managed.

An all-in-one life management app built with Flutter + Spring Boot.

## Features

- **Smart Dashboard** — Schedule, meals, habits, and spending at a glance
- **Unified Schedule** — Time blocks + tasks in one view with status colors (green = done, grey = upcoming, red = missed)
- **Recipe Book** — Save recipes, search by ingredients, "What can I cook?"
- **Inventory Tracker** — Track fridge, pantry, and freezer items with expiry alerts
- **Smart Cooking Flow** — Assign a meal → inventory checked → missing items auto-added to shopping list. Mark cooking done → inventory auto-deducted
- **Meal Planner** — Weekly meal planning with auto shopping list
- **Habit Tracker** — Daily check-ins with streak tracking
- **Expense Tracker** — Track daily spending with category breakdowns
- **Shared Cooking Data** — Recipes and inventory shared across all users
- **Offline-First** — Works without internet, syncs when online
- **Dark/Light Mode** — Fully theme-aware UI

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.44 + Dart |
| State | Riverpod |
| Local DB | Hive |
| Backend | Spring Boot 3.2 + Java 17 |
| Auth | JWT (Spring Security) |
| Database | H2 (dev) / MySQL (prod) |
| Deploy | Docker + Render |

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

## Navigation

| Tab | Screen |
|-----|--------|
| Today | Dashboard with daily overview |
| Schedule | Time blocks + tasks with status colors |
| Recipes | Recipe book + "What can I cook?" |
| Inventory | Fridge/Pantry/Freezer tracker |
| Habits | Daily habit check-ins |

Additional screens accessible from Settings: Meal Planner, Shopping List, Expenses.

## License

MIT
