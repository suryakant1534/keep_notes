import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/widgets/custom_app_bar.dart';

class NoteList extends GetView<NoteListController> {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Align(
        heightFactor: 2.29,
        alignment: Alignment.topLeft,
        child: Container(
          height: Get.height * .35,
          width: Get.width * .4,
          color: Colors.white,
          alignment: Alignment.topLeft,
        ),
      ),
      appBar: CustomAppBar.cusAppBar(title: "Notes"),
      body: Obx(
        () => SizedBox(
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _getNoteListView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "detail");
          if (!context.mounted) return;
          _showAlertDialog(context, result.toString());
        },
        backgroundColor: Colors.deepPurple,
        tooltip: "Add Note",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  _getNoteListView() {
    TextStyle? textStyle = Get.textTheme.bodyLarge;

    return ListView.builder(
      itemCount: controller.notes.length,
      itemBuilder: (context, index) {
        final Note note = controller.notes[index];
        return Card(
          color: Colors.white,
          elevation: 2.5,
          child: ListTile(
            onTap: () async {
              Map<String, dynamic> args = {'note': note, 'index': index};
              final result = await Get.toNamed("detail", arguments: args);
              if (!context.mounted) return;
              _showAlertDialog(context, result.toString());
            },
            leading: CircleAvatar(
              backgroundColor: note.priority == 1 ? Colors.yellow : Colors.red,
              child: Icon(
                note.priority == 1
                    ? Icons.keyboard_arrow_right
                    : Icons.play_arrow,
              ),
            ),
            title: Text(note.title, style: textStyle),
            subtitle: Text(note.dateTime),
            trailing: IconButton(
              onPressed: () {
                controller.deleteNote(note);
                _showSnackBar(context);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, String content) {
    if (content.toLowerCase() == "null") return;
    TextStyle textStyle = const TextStyle(
      color: Colors.deepPurple,
      fontSize: 16,
    );
    CupertinoAlertDialog alertDialog = CupertinoAlertDialog(
      actions: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const Text(
            "OK",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
      title: const Text(
        "Status",
        style: TextStyle(color: Colors.deepPurple, fontSize: 22),
      ),
      content: Text(content, style: textStyle),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _showSnackBar(BuildContext context) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.deepPurple,
      content: const Text("Note is successfully deleted."),
      action: SnackBarAction(
        backgroundColor: Colors.deepOrangeAccent,
        label: 'Close',
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
