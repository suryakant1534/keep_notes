import 'package:keep_notes/models/note.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  static Future<Database> get database async {
    _database ??= await _createDatabase();
    return _database!;
  }

  static Future<Database> _createDatabase() async {
    String path = await getDatabasesPath();
    path += '/keep_note.db';

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      const String sql = """
          CREATE TABLE note (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          dateTime TEXT NOT NULL,
          priority INTEGER NOT NULL
          )""";
      await db.execute(sql);
    });

    return database;
  }

  insertData(Note note) async {
    final String sql = """
    INSERT INTO note(title, description, dateTime, priority)
    VALUES (
    '${note.title}', '${note.description}', '${note.dateTime}', ${note.priority}
    )""";
    Database database = await DatabaseHelper.database;

    await database.transaction((txn) async {
      final int id = await txn.rawInsert(sql);
      note.setId = id;

      return id;
    });
  }

  updateData(Note note) async {
    final String sql = """
    UPDATE note SET
    title = '${note.title}', description = '${note.description}',
    dateTime = '${note.dateTime}', priority = ${note.priority}
    WHERE id = ${note.id}
    """;
    Database database = await DatabaseHelper.database;

    await database.transaction((txn) async {
      int row = await txn.rawUpdate(sql);

      return row;
    });
  }

  deleteData(Note note) async {
    final String sql = """
    DELETE FROM note WHERE id = ${note.id}
    """;
    Database database = await DatabaseHelper.database;
    await database.transaction((txn) async {
      int row = await txn.rawDelete(sql);
      return row;
    });
  }

  Future<List<Map<String, dynamic>>> readData() async {
    const String sql = "SELECT * FROM note";
    Database database = await DatabaseHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(sql);
    return data;
  }
}
