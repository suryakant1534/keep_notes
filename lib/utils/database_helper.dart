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

  Future<Database> _getDatabase(bool isBin) async {
    Database db =
        await (isBin ? DatabaseHelper.binDatabase : DatabaseHelper.database);
    return db;
  }

  insertData(Note note, [bool isBin = false]) async {
    final database = await _getDatabase(isBin);

    final String sql = """
      INSERT INTO note(title, description, dateTime, priority ${_getFirebaseField(note)})
      VALUES (
      '${note.title}', '${note.description}',
      '${note.dateTime}', ${note.priority}
      ${_getFirebaseValue(note)}
      )""";

    await database.transaction((txn) async {
      final int id = await txn.rawInsert(sql);
      note.setId = id;

      return id;
    });
  }

  String _getFirebaseField(Note note) {
    return note.firebaseId == null ? "" : ", firebaseId";
  }

  String _getFirebaseValue(Note note) {
    return note.firebaseId == null ? "" : ", '${note.firebaseId!}'";
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

  deleteData([Note? note, bool isBin = false, List<Note>? notes]) async {
    Database database = await _getDatabase(isBin);
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
      int row = await txn.rawDelete(sql ?? "");
      if (!isBin && note != null) {
        insertData(note, true);
      }
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

  Future<List<Map<String, dynamic>>> readData([bool? isBin]) async {
    const String sql = "SELECT * FROM note";
    Database database = await _getDatabase(isBin ?? false);
    final List<Map<String, dynamic>> data = await database.rawQuery(sql);
    return data;
  }

  clearAllData() async {
    const String sql = "DELETE FROM note WHERE id > 0";
    Database database = await _getDatabase(false);
    await database.transaction((txn) async => await txn.rawDelete(sql));
    database = await _getDatabase(true);
    await database.transaction((txn) async => await txn.rawDelete(sql));
  }
}
