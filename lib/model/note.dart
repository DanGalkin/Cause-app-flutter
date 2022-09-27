import 'dart:convert';

class Note {
  Note({
    required this.id,
    required this.value,
    required this.timeAdded,
    required this.timeLastEdited,
    required this.buttonId,
  });

  final String id;
  int value;
  final int timeAdded;
  int timeLastEdited;
  final String buttonId;

  DateTime day() {
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(value);
    DateTime day = DateTime(timestamp.year, timestamp.month, timestamp.day);
    return day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timeAdded': timeAdded,
      'timeLastEdited': timeLastEdited,
      'buttonId': buttonId,
    };
  }

  //not used yet, maybe never
  Map<String, String> toStringMap() {
    return {
      'id': id,
      'value': value.toString(),
      'timeAdded': timeAdded.toString(),
      'timeLastEdited': timeLastEdited.toString(),
      'buttonId': buttonId,
    };
  }

  //not used yet, maybe never
  String toJson() {
    return jsonEncode({
      'id': id,
      'value': value,
      'timeAdded': timeAdded,
      'timeLastEdited': timeLastEdited,
      'buttonId': buttonId,
    });
  }
}
