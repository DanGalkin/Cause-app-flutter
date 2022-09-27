import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'button.dart';
import 'note.dart';
import 'buttons_storage.dart';

import 'dart:collection';
import 'dart:convert';

class ButtonsModel extends ChangeNotifier {
  List<Button> _buttons = [];

  UnmodifiableListView<Button> get list => UnmodifiableListView(_buttons);

  //update from JSON
  //TODO: put a method fromJSON to the button class and call it here
  void updateFromFile(String json) {
    print('updating from File');
    List<dynamic> buttonsListFromJson = jsonDecode(json);
    print('decoded from File');
    print(buttonsListFromJson);
    List<Button> buttonsRead = [];
    for (Map map in buttonsListFromJson) {
      buttonsRead.add(Button(
        name: map['name'],
        id: map['id'],
        icon: map['icon'] ?? '',
        color:
            map.containsKey('color') ? Color(map['color']) : Colors.grey[200]!,
        showLastNote: map['showLastNote'] ?? false,
        notes: map.containsKey('notes')
            ? [
                for (Map note in map['notes'])
                  Note(
                    id: note['id'],
                    value: note['value'],
                    timeAdded: note['timeAdded'],
                    timeLastEdited: note['timeLastEdited'],
                    buttonId: note['buttonId'],
                  )
              ]
            : [],
        timeCreated: map.containsKey('timeCreated')
            ? DateTime.parse(map['timeCreated'])
            : calculateUnknownTimeCreated(map),
        timeStartTracking: map.containsKey('timeStartTracking')
            ? DateTime.parse(map['timeStartTracking'])
            : calculateUnknownTimeCreated(map),
      ));
    }
    _buttons = buttonsRead;
    print('Buttons model updated');
    notifyListeners();
  }

  void addButton(
      String buttonName, Color color, bool showLastNote, String icon) {
    String id = nanoid(10);
    Button newButton = Button(
      id: id,
      name: buttonName,
      icon: icon,
      color: color,
      showLastNote: showLastNote,
      notes: [],
      timeCreated: DateTime.now(),
      timeStartTracking: DateTime.now(),
    );
    _buttons.add(newButton);
    //DECIDE save to JSON file?? - or should be controlled by widget?
    notifyListeners();
  }

  DateTime? calculateUnknownTimeCreated(Map map) {
    if (map.containsKey('notes') && map['notes'].isNotEmpty) {
      List<int> unsorted = [];
      for (Map note in map['notes']) {
        unsorted.add(note['value']);
      }
      unsorted.sort((a, b) => a - b);
      DateTime firstNoteTime = DateTime.fromMillisecondsSinceEpoch(unsorted[0]);
      return firstNoteTime;
    }

    return null;
  }

  void updateButton(String id, String buttonName, Color color,
      bool showLastNote, String icon) {
    int buttonIndex = _buttons.indexWhere((button) => button.id == id);
    _buttons[buttonIndex].name = buttonName;
    _buttons[buttonIndex].icon = icon;
    _buttons[buttonIndex].color = color;
    _buttons[buttonIndex].showLastNote = showLastNote;

    notifyListeners();
  }

  void updateNote(Button button, Note note, DateTime newMoment) {
    int newValue = newMoment.millisecondsSinceEpoch;
    button.updateNote(note.id, newValue);
    notifyListeners();
  }

  void deleteNote(Button button, Note note) {
    button.deleteNote(note.id);
    notifyListeners();
  }

  void deleteButton(String id) {
    _buttons.removeWhere((button) => button.id == id);
    notifyListeners();
  }

  void addNote(Button button, DateTime moment) {
    int noteValue = moment.millisecondsSinceEpoch;
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    String noteId = nanoid(10);
    button.addNote(noteId, noteValue, timeStamp);
    print('just added a note, new Buttons Object:');
    print(_buttons);

    notifyListeners();
  }

  void reorderButtons(int oldIndex, int newIndex) {
    if ((oldIndex > _buttons.length - 1) && (newIndex > _buttons.length - 1)) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Button movedButton = _buttons.removeAt(oldIndex);
    _buttons.insert(newIndex, movedButton);
    notifyListeners();
  }

  String toJson() {
    List<Map> buttonsMapped = [];
    for (Button button in _buttons) {
      buttonsMapped.add(button.toMap());
    }
    print('prepared an Encodable List of Buttons:');
    print(buttonsMapped);
    return jsonEncode(buttonsMapped);
  }
}
