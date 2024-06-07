import 'package:get/get.dart';
import 'package:keep_notes/controller/note_detail_controller.dart';
import 'package:keep_notes/controller/note_list_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NoteListController());
    Get.lazyPut(() => NoteDetailController());
  }
}