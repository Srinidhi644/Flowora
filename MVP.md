# Flowora MVP - Feature List

> **Goal:** Launch a usable app covering the 3 core pillars — Day, Work, Cooking — in the simplest form possible.

---

## Phase 1: MVP (v1.0)

### 1. Daily Dashboard

- **Today View** — Single screen showing: today's tasks, scheduled time blocks, and planned meals.
- **Quick Add** — Floating action button to quickly add a task, meal, or time block.
- **Date Navigation** — Swipe between days, jump to any date.

### 2. Task Management (Simplified)

- **Task Lists** — Create, edit, delete tasks with title, description, due date, and priority (High / Medium / Low).
- **Categories** — Work vs Personal toggle per task.
- **Daily Tasks View** — Tasks due today shown on dashboard, overdue items highlighted.
- **Mark Complete** — Tap to complete with satisfying animation.
- **Basic Recurring Tasks** — Daily, weekly, monthly repeat options.

### 3. Time Blocking

- **Visual Timeline** — Vertical day view (6 AM - 12 AM) with colored blocks.
- **Create Blocks** — Tap a time slot to add a block (Work, Deep Work, Cooking, Exercise, Rest, Personal).
- **Drag to Resize** — Adjust block duration by dragging edges.
- **Block Templates** — Save and reuse common day structures (e.g., "Workday", "Weekend").

### 4. Meal Planning (Core)

- **Recipe Book** — Add recipes with: name, ingredients list, steps, prep time, cook time, servings, photo.
- **Weekly Meal Planner** — Assign recipes to Breakfast / Lunch / Dinner / Snack for each day of the week.
- **Shopping List** — Auto-generated from the week's meal plan. Manual add/remove items. Tap to check off while shopping.
- **"What Can I Cook?"** — Input available ingredients, get matching recipes from your book (simple keyword match).

### 5. Basic Habit Tracking

- **Track Up to 5 Habits** — Water, exercise, sleep, reading, custom.
- **Daily Check-in** — Simple yes/no or quantity input per habit.
- **Streak Counter** — Current streak and best streak displayed.

### 6. App Essentials

- **User Auth** — Email/password + Google sign-in.
- **Profile Setup** — Name, dietary preferences (veg/non-veg/vegan), wake/sleep time.
- **Push Notifications** — Task reminders, meal prep reminders, habit nudges.
- **Offline Support** — Core features work without internet, sync when online.
- **Dark Mode** — System default + manual toggle.

---

## Explicitly NOT in MVP

| Feature | Why Deferred |
|---------|-------------|
| AI Daily Planner | Requires AI integration + tuning — Phase 2 |
| Fridge/Pantry Scanner (Camera) | Complex ML feature — Phase 2 |
| Voice Input | Nice-to-have, not essential — Phase 2 |
| Finance Tracking | Separate domain, adds scope — Phase 3 |
| Location-Based Reminders | Requires background location — Phase 2 |
| Family/Shared Mode | Multi-user sync is complex — Phase 3 |
| Wearable Integration | Third-party dependency — Phase 3 |
| Recipe Import from Web | Web scraping is fragile — Phase 2 |
| Pomodoro Timer | Can use external app for now — Phase 2 |
| Household Management | Scope creep risk — Phase 3 |
| Weekly PDF Reports | Analytics layer needed first — Phase 3 |

---

## MVP User Stories

### Onboarding
1. User signs up, sets name, dietary preference, and wake/sleep time.
2. App presents an empty "Today" dashboard ready to be filled.

### Daily Flow
1. **Morning:** User opens app, sees today's tasks, meals, and time blocks.
2. **Throughout day:** Checks off tasks, logs habits, follows time blocks.
3. **Cooking:** Taps on planned meal, sees recipe steps, follows along.
4. **Evening:** Reviews tomorrow, adjusts meal plan if needed.

### Weekly Flow
1. **Sunday evening:** User plans meals for the week from recipe book.
2. **Shopping list** auto-generates. User goes shopping, checks off items.
3. **End of week:** Glances at habit streaks, feels motivated.

---

## Data Models (High Level)

```
User
├── profile (name, preferences, wake/sleep time)
├── tasks[]
│   ├── title, description, dueDate, priority, category, isComplete, recurrence
├── timeBlocks[]
│   ├── date, startTime, endTime, type, label, color
├── recipes[]
│   ├── name, ingredients[], steps[], prepTime, cookTime, servings, photo
├── mealPlan[]
│   ├── date, breakfast, lunch, dinner, snack (recipe refs)
├── shoppingList[]
│   ├── item, quantity, unit, isChecked, source (auto/manual)
└── habits[]
    ├── name, type (boolean/quantity), logs[], currentStreak, bestStreak
```

---

## Tech Stack (MVP)

| Component | Choice | Notes |
|-----------|--------|-------|
| Framework | **Flutter** | Single codebase for Android + iOS |
| State Mgmt | **Riverpod** | Scalable, testable |
| Local DB | **Hive** or **Isar** | Fast offline-first storage |
| Backend | **Firebase** | Auth, Firestore, Cloud Messaging |
| Notifications | **Firebase Cloud Messaging** + flutter_local_notifications | |
| CI/CD | **Codemagic** or **GitHub Actions** | Auto build & deploy |

---

## MVP Success Metrics

- User completes onboarding: **> 80%**
- Daily active usage (opens app): **> 60% of registered users in week 1**
- Tasks created per user per week: **> 10**
- Meal plans created: **> 1 per week per active user**
- Shopping list usage: **> 50% of users who plan meals**
- App crash rate: **< 1%**

---

## Estimated Screen Count: 12

1. Splash / Onboarding (3 screens)
2. Login / Sign Up
3. Today Dashboard
4. Task List (with add/edit)
5. Time Block View (with add/edit)
6. Recipe Book (list + detail)
7. Add/Edit Recipe
8. Weekly Meal Planner
9. Shopping List
10. Habit Tracker
11. Settings / Profile
12. Notifications Preferences
