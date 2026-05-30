# Flowora MVP - Feature List

> **Goal:** Launch a usable app covering the 3 core pillars — Day, Work, Cooking — with expense tracking.

---

## Phase 1: MVP (v1.0)

### 1. Daily Dashboard

- **Today View** — Single screen showing: schedule blocks, planned meals, and spending stats.
- **Quick Add** — Floating action button to quickly add a schedule block, recipe, or expense.
- **Stats Card** — Schedule progress, meals planned, and today's spending at a glance.

### 2. Unified Schedule (Tasks + Time Blocks)

- **Visual Timeline** — Vertical day view with colored blocks.
- **Task Integration** — Tasks are schedule items with completion tracking.
- **Status Colors:**
  - **Green** — Completed on time
  - **Grey** — Upcoming
  - **Blue** — Currently in progress
  - **Red** — Missed (time passed, not completed)
- **Block Types** — Work, Deep Work, Cooking, Exercise, Rest, Personal, Task.
- **Week Selector** — Navigate between days with a week strip.

### 3. Meal Planning & Cooking Hub

- **Recipe Book** — Add recipes with: name, ingredients list, steps, prep time, cook time, servings.
- **Weekly Meal Planner** — Assign recipes to Breakfast / Lunch / Dinner / Snack for each day.
- **Shopping List** — Auto-generated from meal plan + manual items.
- **"What Can I Cook?"** — Search recipes by available ingredients.
- **Shared Cooking Data** — Recipes and inventory are shared across all users.

### 4. Inventory Tracker

- **Fridge/Pantry/Freezer** — Categorize items by storage location.
- **Quantity & Unit** — Track how much you have.
- **Expiry Dates** — Set expiry, get visual alerts (yellow = expiring soon, red = expired).
- **Low Stock Flag** — Mark items as low stock for quick shopping reference.
- **Filter Views** — All items, Low Stock only, Expiring only.

### 5. Expense Tracker

- **Quick Add** — Title, amount (₹), category, optional note.
- **Categories** — Groceries, Dining Out, Transport, Shopping, Bills, Health, Entertainment, Other.
- **Summary Card** — Today / This Week / This Month spending.
- **Category Breakdown** — Visual progress bars showing spend per category.
- **Recent List** — Chronological expense list with swipe-to-delete.

### 6. App Essentials

- **User Auth** — Email/password with JWT.
- **Profile Setup** — Name, dietary preferences.
- **Push Notifications** — Reminders.
- **Offline Support** — Hive local storage, syncs with API when online.
- **Dark/Light Mode** — Fully theme-aware UI with proper font colors.
- **Logout** — Sign out from settings.

---

## Navigation (Bottom Tabs)

| Tab | Screen |
|-----|--------|
| Today | Dashboard overview |
| Schedule | Time blocks + tasks with status |
| Recipes | Recipe book + "What can I cook?" |
| Inventory | Fridge/Pantry tracker |
| Expenses | Spending tracker |

Additional screens: Meal Planner, Shopping List (via Settings).

---

## Explicitly NOT in MVP

| Feature | Why Deferred |
|---------|-------------|
| AI Daily Planner | Phase 2 |
| Fridge Scanner (Camera) | Phase 2 |
| Voice Input | Phase 2 |
| Location-Based Reminders | Phase 2 |
| Family/Shared Mode | Phase 3 |
| Wearable Integration | Phase 3 |
| Weekly PDF Reports | Phase 3 |

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Flutter 3.44 |
| State | Riverpod |
| Local DB | Hive |
| Backend | Spring Boot 3.2 + Java 17 |
| Auth | JWT (Spring Security) |
| Database | H2 (dev) / MySQL (prod) |
| Deploy | Docker + Render |
