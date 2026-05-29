# Flowora Backend — Spring Boot + Java 17

## Quick Start (H2 In-Memory DB)

```bash
cd backend
./mvnw spring-boot:run
```

Server starts at `http://localhost:8080`. H2 console at `http://localhost:8080/h2-console`.

No external DB setup needed — uses H2 in-memory by default.

## Run with MySQL

1. Make sure MySQL is running on `localhost:3306`
2. Run with the `mysql` profile:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=mysql
```

Or update `application.yml` with your MySQL credentials.

## API Endpoints

### Auth (Public)
| Method | Endpoint             | Body                                  |
|--------|---------------------|---------------------------------------|
| POST   | /api/auth/register  | `{email, password, name}`             |
| POST   | /api/auth/login     | `{email, password}`                   |
| GET    | /api/auth/me        | — (requires Bearer token)             |
| PUT    | /api/auth/profile   | `{name, dietaryPreference}`           |

### Tasks
| Method | Endpoint                | Description           |
|--------|------------------------|-----------------------|
| GET    | /api/tasks             | Get all tasks         |
| GET    | /api/tasks/date/{date} | Tasks for a date      |
| GET    | /api/tasks/overdue     | Overdue tasks         |
| POST   | /api/tasks             | Create task           |
| PUT    | /api/tasks/{id}        | Update task           |
| PATCH  | /api/tasks/{id}/toggle | Toggle complete       |
| DELETE | /api/tasks/{id}        | Delete task           |

### Recipes
| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| GET    | /api/recipes                    | Get all recipes          |
| GET    | /api/recipes/{id}               | Get recipe details       |
| POST   | /api/recipes                    | Create recipe            |
| PUT    | /api/recipes/{id}               | Update recipe            |
| GET    | /api/recipes/search?ingredients=| Search by ingredients    |
| DELETE | /api/recipes/{id}               | Delete recipe            |

### Time Blocks
| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| GET    | /api/time-blocks                | Get all blocks           |
| GET    | /api/time-blocks/date/{date}    | Blocks for a date        |
| POST   | /api/time-blocks                | Create block             |
| PUT    | /api/time-blocks/{id}           | Update block             |
| DELETE | /api/time-blocks/{id}           | Delete block             |

### Habits
| Method | Endpoint                  | Description              |
|--------|--------------------------|--------------------------|
| GET    | /api/habits              | Get all habits           |
| POST   | /api/habits              | Create habit             |
| PUT    | /api/habits/{id}         | Update habit             |
| POST   | /api/habits/{id}/log     | Log habit entry          |
| PATCH  | /api/habits/{id}/toggle  | Toggle today's log       |
| DELETE | /api/habits/{id}         | Delete habit             |

### Meal Plans
| Method | Endpoint                           | Description         |
|--------|------------------------------------|---------------------|
| GET    | /api/meal-plans                    | Get all plans       |
| GET    | /api/meal-plans/date/{date}        | Plan for a date     |
| GET    | /api/meal-plans/week/{weekStart}   | Plans for a week    |
| POST   | /api/meal-plans                    | Create/update plan  |
| PATCH  | /api/meal-plans/assign             | Assign meal to slot |
| DELETE | /api/meal-plans/{id}               | Delete plan         |

### Shopping List
| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| GET    | /api/shopping-list              | Get all items            |
| POST   | /api/shopping-list              | Add item                 |
| PATCH  | /api/shopping-list/{id}/toggle  | Toggle checked           |
| DELETE | /api/shopping-list/{id}         | Delete item              |
| DELETE | /api/shopping-list/clear-checked| Clear checked items      |
| POST   | /api/shopping-list/generate     | Generate from recipes    |

### Health
| Method | Endpoint     | Description   |
|--------|-------------|---------------|
| GET    | /api/health | Health check  |

## Auth Flow

1. Register or login to get a JWT token
2. Include token in all subsequent requests:
   ```
   Authorization: Bearer <your-token>
   ```
3. Token expires after 24 hours

## Tech Stack
- Java 17
- Spring Boot 3.2
- Spring Security + JWT
- Spring Data JPA
- H2 (dev) / MySQL (prod)
- Lombok
