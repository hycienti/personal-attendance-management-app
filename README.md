![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

# ALU Assistant

> A personal attendance management app built for **African Leadership University** students to track attendance, manage assignments, view schedules, and monitor academic progress — all offline-first with SQLite.

---

## Features

### Dashboard
- Personalized greeting with real-time date and week number
- At-a-glance stats: pending tasks, upcoming deadlines
- Low attendance alert banner when below 75% (calculates sessions needed to recover)
- Today's sessions in a horizontally scrollable card list
- Attendance health card with circular progress, status badge, and weekly breakdown

### Attendance Tracking
- Automatic attendance percentage calculation from recorded sessions
- Monthly progress comparison (current month vs. last month)
- Filter history by session type (Class, Mastery, Workshop, Study, PSL)
- PRESENT / ABSENT badges on each session record
- Info dialog with full attendance summary
- Alert system when attendance drops below 75%

### Assignments
- Create, edit, and complete assignments
- Priority levels: High, Medium, Low
- Due date and time tracking
- Course/module association
- Filter and sort assignment list

### Schedule
- View and manage scheduled sessions by day
- Session types: Class, Mastery, Workshop, Study, PSL
- Toggle attendance directly from the schedule
- Create new sessions with title, type, time range, and location

### Authentication
- Secure login and account creation
- SHA-256 password hashing with salt
- Persistent session management (auto-login on restart)
- Test account seeded for development

### Profile
- View user information (name, email, student ID)
- Logout functionality

---

## Tech Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| Framework          | Flutter 3.10+                       |
| Language           | Dart                                |
| Database           | SQLite (sqflite)                    |
| State Management   | Provider (ChangeNotifier)           |
| Navigation         | go_router (declarative)             |
| Formatting         | intl                                |
| Equality           | equatable                           |
| Security           | crypto (SHA-256)                    |
| Theming            | Material Design 3, Dark mode        |

---

## Architecture

The app follows a **feature-based Clean Architecture** pattern with clear separation between data, domain, and presentation layers.

```
lib/
├── app/                        # Router, shell scaffold
├── core/                       # Shared infrastructure
│   ├── auth/                   #   Password hashing
│   ├── constants/              #   App & route constants
│   ├── database/               #   SQLite singleton (AppDatabase)
│   ├── errors/                 #   Custom exceptions
│   ├── logging/                #   Logger wrapper
│   ├── theme/                  #   Colors, light/dark themes
│   └── utils/                  #   UiState (loading/success/error/empty)
├── features/
│   ├── assignments/            # CRUD assignments
│   ├── attendance/             # Attendance tracking & history
│   ├── auth/                   # Login, registration, session
│   ├── dashboard/              # Home screen, stats
│   ├── profile/                # User profile
│   └── schedule/               # Session scheduling
├── shared/                     # Reusable widgets (AluCard, AluButton, etc.)
└── main.dart                   # Entry point, DI setup
```

**Key patterns:**
- **Store / Repository** — abstract interfaces with SQLite + mock implementations
- **ViewModel** — ChangeNotifier classes for presentation logic
- **Dependency Injection** — Provider tree in `main.dart`
- **UiState** — sealed-class-style wrapper for loading / success / empty / error states

---

## Database Schema

**SQLite database:** `attendance_app.db` (version 4)

| Table                | Purpose                                  |
|----------------------|------------------------------------------|
| `users`              | User accounts (email, hashed password)   |
| `session`            | Current logged-in user (singleton row)   |
| `assignments`        | Tasks with priority, due date, status    |
| `schedule_sessions`  | Scheduled classes with attendance toggle  |
| `attendance_records` | Legacy attendance history                |

---

## Getting Started

### Prerequisites

- Flutter SDK **3.10+**
- Dart SDK (bundled with Flutter)
- Xcode (for iOS) or Android Studio (for Android)

### Installation

```bash
# Clone the repo
git clone https://github.com/your-username/personal-attendance-management-app.git
cd personal-attendance-management-app

# Install dependencies
flutter pub get

# Run on a connected device or simulator
flutter run
```

### Test Account

A test user is seeded automatically on first launch:

| Field       | Value                  |
|-------------|------------------------|
| Email       | `test@alustudent.com`  |
| Password    | `test1234`             |
| Name        | Test User              |
| Student ID  | ALU2024001             |

---

## Navigation

| Path                    | Screen              | Nav Bar |
|-------------------------|----------------------|---------|
| `/`                     | Dashboard            | Home    |
| `/assignments`          | Assignment List      | Tasks   |
| `/assignments/new`      | New Assignment       | —       |
| `/assignments/:id/edit` | Edit Assignment      | —       |
| `/schedule`             | Schedule             | Schedule|
| `/schedule/new`         | New Session          | —       |
| `/attendance/history`   | Attendance History   | History |
| `/profile`              | Profile              | Profile |
| `/login`                | Login                | —       |
| `/create-account`       | Create Account       | —       |

---

## Platforms

| Platform | Status |
|----------|--------|
| iOS      | Supported |
| Android  | Supported |
| Web      | Supported |
| macOS    | Supported |
| Linux    | Supported |
| Windows  | Supported |

---

## Running Tests

```bash
flutter test
```

---

## License

This project is for personal and educational use at **African Leadership University**.
