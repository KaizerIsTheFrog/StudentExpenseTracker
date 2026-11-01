# Student Expense Tracker
A simple Flutter mobile application for students to record, view, edit, and delete daily expenses. Built as a course assignment demonstrating local SQLite persistence, form validation, pagination, and a clean mobile UI flow.

# Purpose
Students often juggle a limited allowance with frequent small expenses (meals, transport, textbooks, printing, leisure). Without a dedicated tracker, it is easy to lose sight of spending and run out of funds before the end of the month.

This app addresses that need by providing:

- Quick expense capture with title, category, amount, date, and optional notes.
- Persistent local storage using SQLite.
- Paginated browsing (10 records per page) ordered newest-first.
Details, editing, and deletion with confirmation dialogs to prevent mistakes.
- Clear validation and feedback so invalid or accidental entries are not saved.
- Malaysian Ringgit (RM) as the display currency.
- Intended users: Secondary school, pre-university, and university students managing personal spending.

# Record Fields & Database Structure
All records are stored in a local SQLite database file using the sqflite package.

Table: expenses

| Column | Type | Constraint | Description |
| -------- | -------- | -------- | -------- |
| id   | INTEGER   | PRIMARY KEY AUTOINCREMENT   | Unique record identifier   |			
| title  | TEXT  | NOT NULL  | Expense name (e.g. "Textbook", "Bus pass")  |
| category  | TEXT  | NOT NULL  | One of: Food, Transport, Books, Housing, Entertainment, Other   |
| amount  | REAL  | NOT NULL  | Expense value in Ringgit (must be > 0)  |
| date  | TEXT  | NOT NULL  | Expense date in YYYY-MM-DD format  |
| notes  | TEXT  | NOT NULL  | Optional details (stored as "" if empty)  |
| created_at  | TEXT  | NOT NULL  | ISO8601 timestamp when the record was inserted  |

Validation runs before the confirmation dialog. Cancel leaves the record unsaved.


# Setup & Installation
Prerequisites
- Flutter SDK (^3.13.4) installed
- An Android emulator, iOS simulator, or physical device
- Git

## Steps
```bash
# Clone or download the repository
git clone https://github.com/KaizerIsTheFrog/StudentExpenseTracker.git

# Navigate into the directory
cd StudentExpenseTracker

# Install dependencies
flutter pub get

# (Optional) Generate platform folders
flutter create .

# Run the app
flutter run
```

# Main Flow
1. Splash Screen (~3 seconds)
- Displays the app name and subtitle, then automatically navigates to the home screen.


2. Home Screen
- Shows saved expenses in a scrollable list (title, category, amount in RM).
- Empty state: "No expense records yet." when the database is empty.
- Floating Action Button (+) opens the Add form.
- App-bar Refresh re-queries SQLite.
- Bottom pagination shows Page X of Y with Previous/Next (disabled at boundaries).


3. Add Expense Form
- Inputs: title, category (dropdown), amount (number), date (calendar picker), notes (optional).
- Validation must pass before the confirmation dialog appears.
- On Confirm: inserts into SQLite, shows snackbar feedback, closes form, reloads page 1.


4. Expense Details
- Tap a list item to view all saved fields in a dialog.
- Includes an Edit action.


5. Edit Expense
- Prefilled form with existing values.
- Changes validated, confirmed, then saved to the same SQLite record ID.
- Cancel preserves original values.


6. Delete Expense
- Long-press a list item to open a delete confirmation.
- Confirmed deletion removes the record from SQLite and reloads the list
- Cancel preserves the record.


# Credits & References
- Flutter — UI framework (https://flutter.dev)
- sqflite — SQLite plugin for Flutter (https://pub.dev/packages/sqflite)
- path — Path manipulation utilities (https://pub.dev/packages/path)
- Material Icons — Used for buttons and list item icons
- App flow and interface follow [mysimplebudget Flutter project](https://github.com/ahmadhanis/FlutterA261/tree/main/mysimplebudget)

