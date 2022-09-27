import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ButtonsStorage {
  //locate documents folder
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //get a path to buttons.json
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/buttons.json');
  }

  //write a json to file
  Future<File> writeJSON(String json) async {
    final file = await _localFile;
    print('writing to File with:');
    print(file.path);
    print(json);
    return file.writeAsString(json);
  }

  //read a buttons.json
  Future<String> readFile() async {
    try {
      final file = await _localFile;
      bool fileExists = await file.exists();
      if (fileExists) {
        return file.readAsString();
      } else {
        return '[]';
      }
    } catch (e) {
      return '[]';
    }
  }
}
