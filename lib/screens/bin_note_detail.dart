import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_notes/controller/bin_note_list_controller.dart';
import 'package:keep_notes/models/note.dart';
import 'package:keep_notes/widgets/cus_progress_indicator.dart';
import 'package:keep_notes/widgets/custom_app_bar.dart';

class BinNoteDetail extends StatelessWidget {
  BinNoteDetail({super.key});

  final RxDouble bottom = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    BinNoteListController controller = BinNoteListController.to;
    Note note = Get.arguments['note'];

    return PopScope(
      canPop: true,
      onPopInvoked: (_) {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Scaffold(
        appBar: CustomAppBar.cusAppBar(
          title: "Deleted Note Detail",
          actions: [
            IconButton(
              onPressed: () async {
                await CusProgressIndicator.show(
                  context,
                  futureMethod: () async => await controller.restoreData(note),
                );
                Get.back(result: "Note Restore Successfully.");
              },
              icon: const Icon(Icons.restore, color: Colors.green),
            ),
            IconButton(
              onPressed: () async {
                await CusProgressIndicator.show(
                  context,
                  futureMethod: () async => await controller.deleteNotes(note),
                );
                Get.back(result: "Note Deleted Successfully");
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: GestureDetector(
                      onTap: () => _showSnackBar(context),
                      child: Text(
                        note.title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: GestureDetector(
                      onTap: () => _showSnackBar(context),
                      child: Text(
                        note.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      bottom: bottom.value,
                    ),
                    child: Text("Last Modified at: ${note.dateTime}"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    bottom(kToolbarHeight);
    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            backgroundColor: Colors.deepPurple,
            content: Text("Note is not allowed to modify."),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.hide) bottom(0);
    });
  }
}
