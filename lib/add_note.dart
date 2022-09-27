import 'package:flutter/material.dart';
import 'model/button.dart';
import 'model/note.dart';
import 'model/buttons_storage.dart';
import 'model/buttons_model.dart';
import 'package:provider/provider.dart';

//For formatting DateTime
import 'package:intl/intl.dart';

import 'edit_note.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key, required this.button, required this.storage});

  final Button button;
  final ButtonsStorage storage;

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  DateTime _moment = DateTime.now();

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_moment),
    );
    if (newTime != null) {
      DateTime newMoment = DateTime(
        _moment.year,
        _moment.month,
        _moment.day,
        newTime.hour,
        newTime.minute,
      );
      setState(() {
        _moment = newMoment;
      });
    }
  }

  void _selectDate() async {
    final DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: _moment,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2024, 1), //TODO make a dynamic constraint
        helpText: 'Select a date');
    if (newDate != null) {
      DateTime newMoment = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        _moment.hour,
        _moment.minute,
      );
      setState(() {
        _moment = newMoment;
      });
    }
  }

  void _saveNoteRoutine(button, moment) async {
    Provider.of<ButtonsModel>(context, listen: false).addNote(button, moment);
    widget.storage
        .writeJSON(Provider.of<ButtonsModel>(context, listen: false).toJson());
  }

  void _validatedSubmit(DateTime moment) async {
    if (moment.isBefore(DateTime.now())) {
      _saveNoteRoutine(widget.button, moment);
      Navigator.pop(context);
      return;
    }
    final String alertResult = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: const Text('Just a check'),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            const Text('You have entered the date:'),
            Text(DateFormat.yMMMd().add_Hm().format(moment)),
            const Text('Are you sure event will occur in future?'),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Oops, no!'),
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
            ),
            TextButton(
              child: const Text('Sure'),
              onPressed: () {
                Navigator.pop(context, 'Ok');
              },
            ),
          ]),
      barrierDismissible: true,
    );
    if (alertResult == 'Ok') {
      _saveNoteRoutine(widget.button, moment);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtonsModel>(builder: (context, buttons, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enter new event')),
        body: Center(
          child: SizedBox(
            width: 320,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 15),
                  ButtonTitle(button: widget.button),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Ink(
                            height: 60,
                            width: 145,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _selectDate,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.date_range,
                                      size: 24, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Text(DateFormat.MMMd().format(_moment),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                          Ink(
                            height: 60,
                            width: 145,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _selectTime,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.schedule,
                                      size: 24, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Text(DateFormat.Hm().format(_moment),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 150),
                  Expanded(
                      child: Container(
                          width: 320,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All event records (${widget.button.notes.length})',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7B7B7B),
                                  ),
                                ),
                                //Border with Shadow
                                Divider(),
                                Expanded(
                                    child: Scrollbar(
                                  child: ListView(children: [
                                    for (Note note in widget.button
                                        .notesSortedDescByValue())
                                      NoteTile(
                                          note: note, button: widget.button)
                                  ]),
                                )),
                              ]))),
                ]),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'mainFAB',
          onPressed: () {
            _validatedSubmit(_moment);
          },
          label: const Text('Enter'),
          icon: const Icon(Icons.create),
        ),
      );
    });
  }
}

class ButtonTitle extends StatelessWidget {
  const ButtonTitle({
    super.key,
    required this.button,
  });
  final Button button;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: button.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                width: 35,
                height: 35,
                child: Text(
                  button.icon,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 30,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      button.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ));
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.button,
  });
  final Note note;
  final Button button;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMMMd()
                  .add_Hm()
                  .format(DateTime.fromMillisecondsSinceEpoch(note.value)),
              style: const TextStyle(
                color: Color(0xFF7B7B7B),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditNoteScreen(
                              button: button,
                              note: note,
                              storage: ButtonsStorage(),
                            )));
              },
              icon: const Icon(
                Icons.edit_note,
                color: Color(0xFF7B7B7B),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
