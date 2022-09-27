import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';

import '../model/buttons_storage.dart';
import '../model/buttons_model.dart';
import '../model/button.dart';
import '../model/note.dart';

class ExportCSV {
  ExportCSV({
    required this.buttons,
  });

  final List<Button> buttons;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path/Cause export ${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  //requir4ed context - should provide in the first place?
  String get _csv {
    List<List<dynamic>> listOfLists = [
      [
        'Parameter',
        'Time (milliseconds)',
        'Time (formatted)',
      ]
    ];
    for (Button button in buttons) {
      List<List<dynamic>> buttonListOfList = button.notes
          .map((Note note) => [
                button.name,
                note.value,
                DateFormat.yMMMd()
                    .add_Hm()
                    .format(DateTime.fromMillisecondsSinceEpoch(note.value))
              ])
          .toList();
      listOfLists = [...listOfLists, ...buttonListOfList];
    }
    return const ListToCsvConverter().convert(listOfLists);
  }

  Future<File> writeCSV() async {
    final file = await _localFile;
    return file.writeAsString(_csv);
  }
}
