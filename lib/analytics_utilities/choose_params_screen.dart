import 'rich_data_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/button.dart';
import '../model/buttons_model.dart';

class ChooseParamsScreen extends StatefulWidget {
  const ChooseParamsScreen({
    super.key,
    this.chosenList = const [],
    this.requiredQuantity = 2,
  });

  final int requiredQuantity;
  final List<Button> chosenList;

  @override
  State<ChooseParamsScreen> createState() => _ChooseParamsScreenState();
}

class _ChooseParamsScreenState extends State<ChooseParamsScreen> {
  List<Button> _chosenList = [];
  int _chosenQty = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _chosenList = widget.chosenList;
      _chosenQty = _chosenQty + widget.chosenList.length;
    });
  }

  void _chooseThis(Button button) {
    if (_chosenList.contains(button)) {
      setState(() {
        _chosenQty = _chosenQty - 1;
        _chosenList.remove(button);
      });
      return;
    }

    if (_chosenQty != widget.requiredQuantity) {
      setState(() {
        _chosenQty = _chosenQty + 1;
        _chosenList.add(button);
      });
      return;
    }

    if (_chosenQty == widget.requiredQuantity) {
      setState(() {
        _chosenList.removeAt(0);
        _chosenList.add(button);
      });
      return;
    }
  }

  //Make Confirm FAB visible, when requirement on quantity of parameters is met
  bool _fabEnabled() {
    return _chosenQty == widget.requiredQuantity;
  }

  bool _isValidToSelect(Button button) {
    return button.eventDates().length > 2 && button.trackingPeriod()! > 9;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtonsModel>(builder: (context, buttons, child) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Choose ${widget.requiredQuantity} parameters'),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                        'For analysis purpose you are able to select parameters, that:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF818181),
                        )),
                    const Text(
                        '1. Each have 3+ event days (unique dates, when at least 1 event occured)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF818181),
                        )),
                    const Text(
                        '2. Each have 10+ days of tracking (calculated from creation to today)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF818181),
                        )),
                    const SizedBox(height: 15),
                    for (Button button in buttons.list)
                      Column(
                        children: [
                          RichDataButton(
                            button: button,
                            onTap: () {
                              _chooseThis(button);
                            },
                            selected: _chosenList.contains(button),
                            number: _chosenList.indexOf(button) + 1,
                            disabled: !_isValidToSelect(button),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _fabEnabled()
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context, _chosenList);
                },
                label: const Text('Confirm'),
              )
            : null,
      );
    });
  }
}
