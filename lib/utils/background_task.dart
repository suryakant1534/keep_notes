import 'package:keep_notes/utils/firebase_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:keep_notes/models/note.dart';

final workmanager = Workmanager();

const insertTask = "insert";
const updateTask = "update";
const deleteTask = "delete";
const insertIntoBinTask = "insert_bin";
const deleteIntoBinTask = "delete_bin";
const restoreTask = "restore";

@pragma('vm:entry-point')
void callbackDispatcher() async {
  workmanager.executeTask((taskName, inputData) async {
    if (inputData != null) {
      FirebaseHelper helper = await FirebaseHelper.getObj;
      try {
        final Note note = Note.fromMapObj(inputData);
        switch (taskName) {
          case insertTask:
            return await _insert(note, helper);
          case updateTask:
            return await _update(note, helper);
          case deleteTask:
            return _delete(note, helper);
          case insertIntoBinTask:
            return await _insertIntoBin(note, helper);
          case deleteIntoBinTask:
            return await _deleteFromBin(note, helper);
          case restoreTask:
            return await _restore(note, helper);
          default:
            return true;
        }
      } catch (e) {
        return false;
      }
    }

    return true;
  });
}

Future<bool> _insert(Note note, FirebaseHelper helper) async {
  await helper.insert(note: note);
  return true;
}

Future<bool> _update(Note note, FirebaseHelper helper) async {
  await helper.update(note);
  return true;
}

Future<bool> _delete(Note note, FirebaseHelper helper) async {
  await helper.delete(note: note);
  await _insertIntoBin(note, helper);
  return true;
}

Future<bool> _insertIntoBin(Note note, FirebaseHelper helper) async {
  await helper.insert(note: note, wantToInsertIntoBin: true);
  return true;
}

Future<bool> _deleteFromBin(Note note, FirebaseHelper helper) async {
  await helper.delete(note: note, wantToDeleteFromBin: true);
  return true;
}

Future<bool> _restore(Note note, FirebaseHelper helper) async {
  await helper.restore(note: note);
  return true;
}

Future<void> createATask({
  required String taskName,
  required Map<String, dynamic> inputData,
}) async {
  await workmanager.registerOneOffTask(
    DateTime.now().toString(),
    taskName,
    initialDelay: Duration.zero,
    constraints: Constraints(networkType: NetworkType.connected),
    inputData: inputData,
  );
}
