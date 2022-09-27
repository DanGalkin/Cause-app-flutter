import 'note.dart';
import 'package:flutter/material.dart';
import '../analytics_utilities/common_utilities.dart';
import 'dart:convert';

class Button {
  Button({
    required this.id,
    required this.name,
    required this.notes,
    required this.icon,
    required this.color,
    required this.showLastNote,
    required this.timeCreated,
    required this.timeStartTracking,
  });

  final String id;
  String name;
  String icon;
  bool showLastNote;
  Color color;
  List<Note> notes;
  DateTime? timeCreated;
  DateTime? timeStartTracking;

  List<Note> notesSortedDescByValue() {
    List<Note> unsortedNotes = notes;
    unsortedNotes.sort((a, b) => b.value - a.value);
    return unsortedNotes;
  }

  DateTime lastEvent() {
    if (notes.isNotEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(
          notesSortedDescByValue()[0].value);
    }
    //TODO can't really understand what should be returned
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime firstEvent() {
    if (notes.isNotEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(
          notesSortedDescByValue()[notes.length - 1].value);
    }
    //TODO can't really understand what should be returned
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Set<DateTime> eventDates() {
    if (notes.isEmpty) return {};
    return Set.from(notes.map((note) => note.day()));
  }

  //return tracking period in days
  int? trackingPeriod() {
    if (timeStartTracking == null) return null;

    return (DateTime.now().difference(startOfDay(timeStartTracking!)).inDays +
        1);
  }

  void addNote(noteId, noteValue, timeStamp) {
    notes.add(Note(
      id: noteId,
      value: noteValue,
      timeAdded: timeStamp,
      timeLastEdited: timeStamp,
      buttonId: id,
    ));
    if (timeStartTracking != null &&
        DateTime.fromMillisecondsSinceEpoch(noteValue)
            .isBefore(timeStartTracking!)) {
      timeStartTracking = DateTime.fromMillisecondsSinceEpoch(noteValue);
    }
  }

  void deleteNote(noteId) {
    notes.removeWhere((note) => note.id == noteId);
  }

  void updateNote(noteId, newValue) {
    int noteIndex = notes.indexWhere((note) => note.id == noteId);
    notes[noteIndex].value = newValue;
    notes[noteIndex].timeLastEdited = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'showLastNote': showLastNote,
      'notes': [for (Note note in notes) note.toMap()],
      'timeCreated': timeCreated?.toIso8601String() ?? 'undefined',
      'timeStartTracking': timeStartTracking?.toIso8601String() ?? 'undefined',
    };
  }
}
