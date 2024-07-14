import 'package:get/get.dart';
import 'package:keep_notes/controller/bin_note_list_controller.dart';
import 'package:keep_notes/controller/note_detail_controller.dart';
import 'package:keep_notes/controller/note_list_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteListController());
    Get.lazyPut(() => NoteDetailController());
    Get.lazyPut(() => BinNoteListController());
    Get.put(InitialController());
  }
}
