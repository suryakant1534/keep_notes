import 'package:cloud_firestore/cloud_firestore.dart';
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
const restoreBatch = "restore_batch";
const deleteBatch = "delete_batch";
const insertBatch = "insert_batch";

const startWithDate = "data_time: ";
const startWithId = "id: ";
const startWithTitle = "title: ";
const startWithDescription = "description: ";
const startWithPriority = "priority: ";

@pragma('vm:entry-point')
void callbackDispatcher() async {
  workmanager.executeTask((taskName, inputData) async {
    if (inputData != null) {
      FirebaseHelper helper = await FirebaseHelper.getObj;
      try {
        late final Note note;
        if (taskName != restoreBatch &&
            taskName != deleteBatch &&
            taskName != insertBatch) {
          note = Note.fromMapObj(inputData);
        }
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
          case restoreBatch:
            return await _restoreBatch(inputData, helper);
          case deleteBatch:
            return await _deleteBatch(inputData, helper);
          case insertBatch:
            return await _insertBatch(inputData, helper);
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

Future<bool> _deleteBatch(Map inputData, FirebaseHelper helper) async {
  WriteBatch batch = helper.firestore.batch();
  for (final firebaseId in inputData.keys) {
    DocumentReference docRef = helper.docRef(firebaseId, true);
    batch.delete(docRef);
  }
  await batch.commit();
  return true;
}

Future<bool> _restoreBatch(
    Map<String, dynamic> inputData, FirebaseHelper helper) async {
  await _deleteBatch(inputData, helper);
  await _insertBatch(inputData, helper);
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

Note _getNote(List valueOfNote) {
  String dateTime = "";
  String id = "";
  String title = "";
  String description = "";
  String firebaseId = "";
  String priority = "";
  for (final value in valueOfNote) {
    if (value.startsWith(startWithDate)) {
      dateTime = value.split(startWithDate).last;
    } else if (value.startsWith(startWithDescription)) {
      description = value.split(startWithDescription).last;
    } else if (value.startsWith(startWithTitle)) {
      title = value.split(startWithTitle).last;
    } else if (value.startsWith(startWithId)) {
      id = value.split(startWithId).last;
    } else if (value.startsWith(startWithPriority)) {
      priority = value.split(startWithPriority).last;
    } else {
      firebaseId = value;
    }
  }
  return Note.withId(
    title: title,
    description: description,
    dateTime: dateTime,
    priority: int.parse(priority),
    firebaseId: firebaseId,
    id: int.parse(id),
  );
}

Future<bool> _insertBatch(Map<String, dynamic> inputData, FirebaseHelper helper) async {
  WriteBatch batch = helper.firestore.batch();
  inputData.forEach((key, value) {
    value.add(key);
    final note = _getNote(value);
    DocumentReference docRef = helper.docRef(key);
    batch.set(docRef, note.toMap());
  });
  await batch.commit();
  return true;
}