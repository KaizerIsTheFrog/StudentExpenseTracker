import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the local SQLite database and provides expense insert, read,
/// update, and delete methods.
class ExpenseDatabase {
  ExpenseDatabase._();

  static final ExpenseDatabase instance = ExpenseDatabase._();
  static const _databaseName = 'student_expenses.db';
  static const _tableName = 'expenses';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Opening a missing database creates it; onCreate adds the expenses table.
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            notes TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        // Seed the database with sample student expenses so the app
        // starts with records to browse and paginate.
        await _seedExpenses(db);
      },
    );
    return _database!;
  }

  Future<int> insertExpense({
    required String title,
    required String category,
    required double amount,
    required String date,
    required String notes,
  }) async {
    final db = await database;
    return db.insert(_tableName, {
      'title': title,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateExpense({
    required int id,
    required String title,
    required String category,
    required double amount,
    required String date,
    required String notes,
  }) async {
    final db = await database;
    return db.update(
      _tableName,
      {
        'title': title,
        'category': category,
        'amount': amount,
        'date': date,
        'notes': notes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> getExpenses({
    required int limit,
    required int offset,
  }) async {
    final db = await database;
    // Limit and offset let the list request one page at a time.
    return db.query(
      _tableName,
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getExpenseCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $_tableName',
    );
    return (result.first['count'] as num).toInt();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Inserts sample student expense records when the database is first created.
  Future<void> _seedExpenses(Database db) async {
    final now = DateTime.now();
    final seedRecords = <Map<String, dynamic>>[
      {
        'title': 'Coffee',
        'category': 'Food',
        'amount': 4.50,
        'date': _formatDate(now.subtract(const Duration(days: 1))),
        'notes': 'Morning coffee before class',
      },
      {
        'title': 'Textbook',
        'category': 'Books',
        'amount': 85.00,
        'date': _formatDate(now.subtract(const Duration(days: 2))),
        'notes': 'Calculus textbook',
      },
      {
        'title': 'Bus pass',
        'category': 'Transport',
        'amount': 30.00,
        'date': _formatDate(now.subtract(const Duration(days: 3))),
        'notes': 'Monthly bus pass',
      },
      {
        'title': 'Cafeteria lunch',
        'category': 'Food',
        'amount': 7.50,
        'date': _formatDate(now.subtract(const Duration(days: 3))),
        'notes': 'Campus cafeteria',
      },
      {
        'title': 'Notebook',
        'category': 'Books',
        'amount': 3.00,
        'date': _formatDate(now.subtract(const Duration(days: 4))),
        'notes': 'Spiral notebook for lectures',
      },
      {
        'title': 'Laundry',
        'category': 'Housing',
        'amount': 4.00,
        'date': _formatDate(now.subtract(const Duration(days: 5))),
        'notes': 'Dorm laundry',
      },
      {
        'title': 'Movie ticket',
        'category': 'Entertainment',
        'amount': 12.00,
        'date': _formatDate(now.subtract(const Duration(days: 6))),
        'notes': 'Weekend movie with friends',
      },
      {
        'title': 'Snacks',
        'category': 'Food',
        'amount': 5.50,
        'date': _formatDate(now.subtract(const Duration(days: 6))),
        'notes': 'Study session snacks',
      },
      {
        'title': 'Uber ride',
        'category': 'Transport',
        'amount': 15.00,
        'date': _formatDate(now.subtract(const Duration(days: 7))),
        'notes': 'Ride to campus',
      },
      {
        'title': 'Printing',
        'category': 'Books',
        'amount': 2.00,
        'date': _formatDate(now.subtract(const Duration(days: 7))),
        'notes': 'Assignment printout',
      },
      {
        'title': 'Gym membership',
        'category': 'Other',
        'amount': 20.00,
        'date': _formatDate(now.subtract(const Duration(days: 8))),
        'notes': 'Student gym access',
      },
      {
        'title': 'Pizza dinner',
        'category': 'Food',
        'amount': 18.00,
        'date': _formatDate(now.subtract(const Duration(days: 9))),
        'notes': 'Group study dinner',
      },
      {
        'title': 'Phone bill',
        'category': 'Other',
        'amount': 40.00,
        'date': _formatDate(now.subtract(const Duration(days: 11))),
        'notes': 'Monthly mobile plan',
      },
      {
        'title': 'Pens',
        'category': 'Books',
        'amount': 2.50,
        'date': _formatDate(now.subtract(const Duration(days: 12))),
        'notes': 'Pack of pens',
      },
      {
        'title': 'Train ticket',
        'category': 'Transport',
        'amount': 10.00,
        'date': _formatDate(now.subtract(const Duration(days: 13))),
        'notes': 'Trip home for weekend',
      },
      {
        'title': 'Energy drink',
        'category': 'Food',
        'amount': 3.00,
        'date': _formatDate(now.subtract(const Duration(days: 13))),
        'notes': 'Late night study',
      },
      {
        'title': 'Concert ticket',
        'category': 'Entertainment',
        'amount': 35.00,
        'date': _formatDate(now.subtract(const Duration(days: 16))),
        'notes': 'Student concert',
      },
      {
        'title': 'Backpack',
        'category': 'Other',
        'amount': 45.00,
        'date': _formatDate(now.subtract(const Duration(days: 17))),
        'notes': 'New laptop backpack',
      },
      {
        'title': 'Groceries',
        'category': 'Food',
        'amount': 25.00,
        'date': _formatDate(now.subtract(const Duration(days: 18))),
        'notes': 'Weekly groceries',
      },
      {
        'title': 'Library fine',
        'category': 'Other',
        'amount': 5.00,
        'date': _formatDate(now.subtract(const Duration(days: 19))),
        'notes': 'Overdue book fine',
      },
      {
        'title': 'Birthday gift',
        'category': 'Other',
        'amount': 15.00,
        'date': _formatDate(now.subtract(const Duration(days: 21))),
        'notes': "Roommate's birthday gift",
      },
    ];

    final base = now.subtract(const Duration(days: 30));
    for (var i = 0; i < seedRecords.length; i++) {
      final record = seedRecords[i];
      await db.insert(_tableName, {
        'title': record['title'],
        'category': record['category'],
        'amount': record['amount'],
        'date': record['date'],
        'notes': record['notes'],
        'created_at': base.add(Duration(days: i)).toIso8601String(),
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
