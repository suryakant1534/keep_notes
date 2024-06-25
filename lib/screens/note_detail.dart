import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/note_detail_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/widgets/cus_progress_indicator.dart';
import 'package:keep_notes/widgets/custom_app_bar.dart';

class NoteDetail extends StatefulWidget {
  const NoteDetail({super.key});

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  NoteDetailController get controller => NoteDetailController.to;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Note? note;
  bool isNew = false;
  late int currentIndex;

  _submit() async {
    final String result;
    if (formKey.currentState!.validate()) {
      final String title, description, dateTime;
      final int priority;
      priority = controller.priorityValue == 'Low' ? 1 : 2;
      title = controller.titleController.text;
      description = controller.descriptionController.text;
      dateTime = DateTime.now().toString().split('.').first;
      if (isNew) {
        note = Note(
          title: title,
          description: description,
          dateTime: dateTime,
          priority: priority,
        );
        result = "New note is successfully added.";
      } else {
        int id = note!.id;

        note = Note.withId(
          id: id,
          title: title,
          description: description,
          dateTime: dateTime,
          priority: priority,
          firebaseId: note!.firebaseId,
        );
        result = "Note is successfully updated.";
      }

      CusProgressIndicator.show(context);
      await controller.submit(note!, isNew, currentIndex);
      CusProgressIndicator.close();

      Get.back(result: result);
    }
  }

  _initialized() {
    Map<String, dynamic> map = Get.arguments ?? {};
    if (map.containsKey('note')) {
      note = map['note'];
      currentIndex = map['index'];
      controller.titleController.text = note!.title;
      controller.descriptionController.text = note!.description;
      controller.priorityValue = note!.priority == 1 ? 'Low' : 'High';
      isNew = false;
    } else {
      controller.titleController.clear();
      controller.descriptionController.clear();
      controller.priorityValue = 'Low';
      isNew = true;
      note = null;
      currentIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialized();
    return Scaffold(
      appBar: CustomAppBar.cusAppBar(title: "Edit Note"),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          left: 10,
          right: 10,
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              ListTile(
                title: Obx(
                  () => DropdownButton<String>(
                    items: controller.priorities
                        .map((String value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    value: controller.priorityValue,
                    onChanged: (String? value) {
                      controller.priorityValue = value!;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) {
                    Get.focusScope?.unfocus();
                  },
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "please enter title";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  onTapOutside: (_) {
                    Get.focusScope?.unfocus();
                  },
                  controller: controller.descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter description";
                    }
                    if (value.length < 4) {
                      return "Too small content please enter bigger content";
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: Colors.deepPurple,
                        onPressed: _submit,
                        child: Text(
                          isNew ? "SAVE" : "UPDATE",
                          textScaler: const TextScaler.linear(1.5),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: MaterialButton(
                        color: Colors.deepPurple,
                        onPressed: () async {
                          if (isNew) {
                            controller.titleController.clear();
                            controller.descriptionController.clear();
                            controller.priorityValue = 'Low';
                            return;
                          }

                          CusProgressIndicator.show(context);
                          await controller.deleteNote(note!);
                          CusProgressIndicator.close();

                          Get.back(result: "Note is successfully deleted.");
                        },
                        child: Text(
                          isNew ? "CLEAR" : "DELETE",
                          textScaler: const TextScaler.linear(1.5),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
