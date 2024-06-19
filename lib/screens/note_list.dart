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
        child: SafeArea(
          child: Drawer(
            width: Get.width * .65,
            child: _getDrawerBody(),
          ),
        ),
      ),
      appBar: CustomAppBar.cusAppBar(title: "Notes"),
      body: Obx(
        () => SizedBox(
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.notes.isEmpty
                  ? _getEmpty(context)
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

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _getDrawerBody() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: Get.back,
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ),
        CircleAvatar(
          backgroundImage: const AssetImage("assets/guest.jpg"),
          radius: Get.width * .1,
        ),
        const Text(
          "Guest",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Obx(() => controller.notes.isNotEmpty
            ? MaterialButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.green,
                child: const Text(
                  "Sync Now",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : const SizedBox()),
        MaterialButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.deepPurple,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Login with", style: TextStyle(color: Colors.white)),
              Image.asset("assets/google_icon.png"),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: EdgeInsets.only(top: Get.height * .17),
          width: Get.width * .6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Get.back();
              Get.toNamed("bin");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recycle Bin",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.delete,
                  color: Colors.red[300],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _getEmpty(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(context, "detail");
          if (!context.mounted) return;
          _showAlertDialog(context, result.toString());
        },
        child: const Text(
          "Create a Note",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        ),
      ),
    );
  }
}
