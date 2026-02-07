# How to View Your SQLite Database

The app stores assignments and attendance in a local SQLite file. Here’s how to find and inspect it.

## 1. Where the database file is

- **iOS Simulator:**  
  `~/Library/Developer/CoreSimulator/Devices/<device-id>/data/Containers/Data/Application/<app-id>/Documents/attendance_app.db`

- **Android Emulator / device:**  
  `/data/data/com.example.personal_attendance_management_app/databases/attendance_app.db`  
  (package name may differ; check `android/app/build.gradle`.)

- **macOS desktop:**  
  `~/Library/Containers/<bundle-id>/Data/Documents/attendance_app.db`

At startup the app logs the path in debug mode. Run the app from VS Code or Android Studio and check the **Debug Console** for a line like:

```text
SQLite database path: /path/to/attendance_app.db
```

Use that path in the steps below.

---

## 2. View data on your computer (recommended)

### Option A: DB Browser for SQLite (GUI)

1. Install **DB Browser for SQLite**:  
   https://sqlitebrowser.org/  
   (or `brew install --cask db-browser-for-sqlite` on macOS.)

2. Get the DB file on your machine:
   - **iOS Simulator:** In Finder, go to **Go → Go to Folder** and paste the path from the debug log (replace `~` with your home folder). Or use **Device and Simulators** in Xcode to open the app container and copy `Documents/attendance_app.db`.
   - **Android:** From project root run:
     ```bash
     adb pull /data/data/<your.package.name>/databases/attendance_app.db ./
     ```
     (Replace `<your.package.name>` with the value of `applicationId` in `android/app/build.gradle`.)

3. Open the file in DB Browser: **File → Open Database** → select `attendance_app.db`.

4. Use the **Browse Data** tab and pick a table:
   - `assignments` – assignment list (title, due date, priority, completed, etc.).
   - `attendance_records` – attendance history (session, date, time, present/absent).

You can run custom SQL in the **Execute SQL** tab (e.g. `SELECT * FROM assignments;`).

### Option B: Command line (sqlite3)

1. Get `attendance_app.db` on your machine (same as above: copy from simulator or `adb pull` for Android).

2. Open it:
   ```bash
   sqlite3 attendance_app.db
   ```

3. Example commands:
   ```sql
   .tables
   SELECT * FROM assignments;
   SELECT * FROM attendance_records;
   .quit
   ```

---

## 3. View data on Android without pulling the file

```bash
adb shell
run-as <your.package.name>
cd databases
sqlite3 attendance_app.db
.tables
SELECT * FROM assignments;
SELECT * FROM attendance_records;
.quit
exit
exit
```

Replace `<your.package.name>` with your app’s package name.

---

## 4. Tables in this app

| Table               | Purpose |
|---------------------|--------|
| `assignments`       | Assignment title, course, due date/time, priority, completed, notes. |
| `attendance_records`| Session title, date, time, present/absent, session type. |

New assignments and attendance you create in the app are written to these tables and will show up when you open the DB as above.
