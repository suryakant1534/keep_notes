import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/bin_note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/widgets/cus_progress_indicator.dart';
import 'package:keep_notes/widgets/custom_app_bar.dart';

class BinNoteList extends StatefulWidget {
  const BinNoteList({super.key});

  @override
  State<BinNoteList> createState() => _BinNoteListState();
}

class _BinNoteListState extends State<BinNoteList> {
  BinNoteListController get controller => BinNoteListController.to;

  @override
  void dispose() {
    controller.changeSelectActive(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.cusAppBar(
        title: "Recycle Bin",
        actions: [
          Obx(
            () => controller.isSelectActive
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: controller.isSelectAll,
                        onChanged: (bool? value) {
                          if (value != null) {
                            controller.selectAllOrNot(value);
                          }
                        },
                      ),
                      InkWell(
                        onTap: () =>
                            controller.selectAllOrNot(!controller.isSelectAll),
                        child: const Text(
                          "Select All",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
          ),
          Obx(
            () {
              if (controller.notes.isEmpty) {
                return const SizedBox();
              }
              return TextButton(
                onPressed: controller.changeSelectActive,
                child: Text(
                  controller.isSelectActive ? "CANCEL" : "SELECT",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.notes.isEmpty) {
            return const Center(
              child: Text(
                "No notes in Recycle Bin",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.notes.length,
            itemBuilder: (context, index) {
              final Note note = controller.notes[index];
              return Row(
                children: [
                  Obx(
                    () => controller.isSelectActive
                        ? Checkbox(
                            value: controller.getIsSelectNote(index),
                            onChanged: (value) {
                              controller.onChangeCheckBoxValue(index);
                            },
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: ListTile(
                      onTap: () async {
                        if (controller.isSelectActive) {
                          controller.onChangeCheckBoxValue(index);
                        } else {
                          final String? result = (await Get.toNamed(
                            "bin_detail",
                            arguments: {"note": note, 'index': index},
                          )) as String?;
                          if (context.mounted) {
                            if (result != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white.withOpacity(.9),
                                  title: const Text(
                                    "Status",
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.red),
                                  ),
                                  content: Text(result),
                                  actions: [
                                    TextButton(
                                      onPressed: Get.back,
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor:
                            note.priority == 1 ? Colors.yellow : Colors.red,
                        child: Icon(
                          note.priority == 1
                              ? Icons.keyboard_arrow_right
                              : Icons.play_arrow,
                        ),
                      ),
                      title: Text(note.title),
                      subtitle: Text(note.dateTime),
                      trailing: Obx(
                        () => !controller.isSelectActive
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await CusProgressIndicator.show(
                                        context,
                                        futureMethod: () async =>
                                            await controller.restoreNote(index),
                                      );
                                      _getSnackBar("Restored");
                                    },
                                    icon: const Icon(
                                      Icons.restore,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showAlertDialog(index);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Obx(() => controller.isSelectActive
          ? controller.showFloatingActionButton
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        await CusProgressIndicator.show(
                          context,
                          futureMethod: () async =>
                              await controller.restoreSelectedNote(),
                        );
                        _getSnackBar("Restore");
                      },
                      tooltip: "Restore",
                      child: const Icon(
                        Icons.restore,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton(
                      onPressed: () {
                        _showAlertDialog();
                      },
                      tooltip: "Delete",
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              : const SizedBox()
          : const SizedBox()),
    );
  }

  _getSnackBar([String message = "Deleted"]) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$message note(s) successfully"),
      backgroundColor: Colors.deepPurple,
    ));
  }

  _showAlertDialog([int? index]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(.9),
        title: const Text(
          "WARNING!!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 22,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure!\nDo want to delete data?\nWhen you will delete this data then you will lose this document.\n",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            Text(
              "Do you want to continue?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.red,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      await CusProgressIndicator.show(
                        context,
                        futureMethod: () async {
                          index == null
                              ? await controller.deleteSelectedNote()
                              : await controller.deleteNote(index);
                        },
                      );
                      _getSnackBar();
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: Get.back,
                    child: const Text(
                      "NO",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
