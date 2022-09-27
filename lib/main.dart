import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
//import 'package:nanoid/nanoid.dart';

import 'model/button.dart';
import 'model/buttons_model.dart';
import 'model/buttons_storage.dart';

import 'add_note.dart';
import 'create_param_screen.dart';
import 'edit_param_screen.dart';
import 'analytics_screen.dart';

//For formatting DateTime
import 'package:intl/intl.dart';

//import 'dart:collection';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ButtonsModel(),
    child: MyApp(storage: ButtonsStorage()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.storage});

  final ButtonsStorage storage;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();

    //update the ButtonsModel from File
    updateModelFromFile();
  }

  void updateModelFromFile() async {
    String json = await widget.storage.readFile();

    if (!mounted) return;
    Provider.of<ButtonsModel>(context, listen: false).updateFromFile(json);
    //ButtonsModel().updateFromFile(json);

    // await widget.storage.readFile().then((value) {
    //   Provider.of<ButtonsModel>(context, listen: false).updateFromFile(value);
    // });
    print('changing loaded state');
    setState(() {
      _dataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buttons demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ParamScreen(dataLoaded: _dataLoaded),
    );
  }
}

class ParamScreen extends StatelessWidget {
  const ParamScreen({super.key, required this.dataLoaded});

  final bool dataLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Parameters'),
        actions: [
          IconButton(
              icon: const Icon(Icons.analytics),
              tooltip: 'Analytics',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen()));
              })
        ],
      ),
      body: dataLoaded
          ? const ButtonsList()
          : const Center(child: Text('Loading')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'mainFAB',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateParamScreen(storage: ButtonsStorage())),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ButtonsList extends StatelessWidget {
  const ButtonsList({super.key});

  @override
  Widget build(BuildContext context) {
    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double scaleValue =
                Curves.fastOutSlowIn.transform(animation.value);
            return Transform.scale(
                scale: 1 + 0.1 * scaleValue, child: Material(child: child));
          },
          child: child);
    }

    return Consumer<ButtonsModel>(builder: (context, buttons, child) {
      if (buttons.list.isEmpty) {
        return Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                    'You have no parameters yet. Click + to add new one and start tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF818181),
                    ))));
      }

      return ReorderableListView(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 100),
        proxyDecorator: proxyDecorator,
        onReorder: (int oldIndex, int newIndex) {
          buttons.reorderButtons(oldIndex, newIndex);
          ButtonsStorage().writeJSON(buttons.toJson());
        },
        children: [
          for (Button button in buttons.list)
            Column(key: Key(button.id), children: [
              const SizedBox(height: 5),
              ParamButton(
                button: button,
              ),
              const SizedBox(height: 5),
            ]),
        ],
      );
    });
  }
}

class ParamButton extends StatefulWidget {
  const ParamButton({
    super.key,
    required this.button,
  });
  final Button button;

  @override
  State<ParamButton> createState() => _ParamButtonState();
}

class _ParamButtonState extends State<ParamButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNoteScreen(
                  button: widget.button, storage: ButtonsStorage())),
        );
      },
      child: Container(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: widget.button.color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              width: 35,
              height: 35,
              child: Text(
                widget.button.icon,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    child: FittedBox(
                      //fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.button.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (widget.button.notes.isNotEmpty &&
                      widget.button.showLastNote == true)
                    Text(
                      DateFormat.yMMMd()
                          .add_Hm()
                          .format(widget.button.lastEvent()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B7B7B),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditParamScreen(
                              button: widget.button,
                              storage: ButtonsStorage())));
                },
                icon: const Icon(Icons.edit_note, color: Color(0xFF818181))),
          ],
        ),
      ),
    );
  }
}
