import 'package:keep_notes/models/note.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;
  static Database? _binDatabase;

  static Future<void> initialize() async {
    await _createDatabase('/keep_note.db');
    await _createDatabase("/bin_keep_note.db");
    _databaseHelper = DatabaseHelper._createInstance();
  }

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  static Future<Database> get database async {
    _database ??= await _createDatabase('/keep_note.db');
    return _database!;
  }

  static Future<Database> get binDatabase async {
    _binDatabase ??= await _createDatabase("/bin_keep_note.db");
    return _binDatabase!;
  }

  static Future<Database> _createDatabase(String dbName) async {
    String path = await getDatabasesPath();
    path += dbName;

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      const String sql = """
          CREATE TABLE note (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          dateTime TEXT NOT NULL,
          priority INTEGER NOT NULL,
          firebaseId TEXT NULL
          )""";
      await db.execute(sql);
    });

    return database;
  }

  Future<Database> _getDatabase({bool isBin = false}) async =>
      await (isBin ? DatabaseHelper.binDatabase : DatabaseHelper.database);

  Future insertData(Note note, {bool insertIntoBin = false}) async {
    final database = await _getDatabase(isBin: insertIntoBin);

    final String sql = """
      INSERT INTO note(title, description, dateTime, priority, firebaseId)
      VALUES (
      ?, ?,
      '${note.dateTime}', ${note.priority}, '${note.firebaseId}'
      )""";

    await database.transaction((txn) async {
      final int id = await txn.rawInsert(sql, [note.title, note.description]);
      note.setId = id;

      return id;
    });
  }

  Future updateData(Note note, {bool updateOnBin = false}) async {
    final String sql = """
    UPDATE note SET
    title = ?, description = ?,
    dateTime = '${note.dateTime}', priority = ${note.priority}
    WHERE id = ${note.id}
    """;
    Database database = await _getDatabase(isBin: updateOnBin);

    await database.transaction((txn) async {
      int row = await txn.rawUpdate(sql, [note.title, note.description]);
      return row;
    });
  }

  Future deleteData({
    Note? note,
    bool deleteFromBin = false,
    List<Note>? notes,
  }) async {
    Database database = await _getDatabase(isBin: deleteFromBin);
    String? sql;
    if (notes != null) {
      sql = """
      DELETE FROM note WHERE id = ${_getId(notes)};
      """;
    }
    if (note != null) {
      sql ??= """
    DELETE FROM note WHERE id = ${note.id};
    """;
    }
    await database.transaction((txn) async {
      int row = await txn.rawDelete(sql!);
      return row;
    });
  }

  String _getId(List<Note> notes) {
    String temp = notes.first.id.toString();
    for (int i = 1; i < notes.length; i++) {
      temp += " OR id = ${notes[i].id}";
    }
    return temp;
  }

  Future<List<Map<String, dynamic>>> readData({
    bool selectFromBin = false,
  }) async {
    const String sql = "SELECT * FROM note";
    Database database = await _getDatabase(isBin: selectFromBin);
    return await database.rawQuery(sql);
  }

  clearAllData() async {
    const String sql = "DELETE FROM note WHERE id > 0";
    Database database = await _getDatabase();
    await database.transaction((txn) async => await txn.rawDelete(sql));
    database = await _getDatabase(isBin: true);
    await database.transaction((txn) async => await txn.rawDelete(sql));
  }
}
