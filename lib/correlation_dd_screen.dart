import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'analytics_utilities/choose_params_screen.dart';
import 'analytics_utilities/common_utilities.dart';
import 'model/button.dart';
import 'analytics_utilities/rich_data_button.dart';
import 'analytics_utilities/contingency_matrix.dart';
import 'analytics_utilities/correlation_interpretation.dart';

class CorrelationDDScreen extends StatefulWidget {
  const CorrelationDDScreen({super.key});

  @override
  State<CorrelationDDScreen> createState() => _CorrelationDDScreenState();
}

class _CorrelationDDScreenState extends State<CorrelationDDScreen> {
  List<Button> params = [];
  late DateTimeRange _range;
  int _lag = 0;
  bool _calculated = false;
  Map _correlationDD = {};

  //Checks if required parameters are chosen: 2 for this tool
  bool paramsChosen() {
    return params.length == 2;
  }

  //Goes to next screen to select parameters and return result
  Future<void> _navigateSelectionScreen(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChooseParamsScreen(chosenList: params)));
    //set new State range only if parameters has been selected
    if (result != null) {
      if (ListEquality().equals(result, params)) {
        setState(() {
          _calculated = false;
        });
      }
      setState(() {
        params = result;
        _range = _calculateDefaultRange(params);
      });
    }
  }

  //calculate default range based on 2 selected parameters
  DateTimeRange _calculateDefaultRange(List<Button> params) {
    DateTime now = DateTime.now();
    DateTime defaultEndDate = DateTime(now.year, now.month, now.day);
    DateTime defaultStartDate;

    //If default is calculated, we assume timeCreated and Notes are not null
    defaultStartDate = startOfDay(earliestDate([
      oldestDate([
        params[0].timeCreated!,
        params[0].firstEvent(),
      ]),
      oldestDate([
        params[1].timeCreated!,
        params[1].firstEvent(),
      ]),
    ]));

    return DateTimeRange(start: defaultStartDate, end: defaultEndDate);
  }

  String _rangeToPrettyString(DateTimeRange range) {
    String startText = DateFormat.yMMMd().format(range.start);
    String endText = DateFormat.yMMMd().format(range.end);
    return '$startText - $endText';
  }

  void _selectDateRange() async {
    final DateTimeRange? selectedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime.now(),
        initialDateRange: _range,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                surface: Colors.blue,
                primary: Colors.blue,
              ),
            ),
            child: child!,
          );
        });
    if (selectedRange != null) {
      DateTimeRange newRange =
          DateTimeRange(start: selectedRange.start, end: selectedRange.end);

      if (_rangeIsValid(newRange)) {
        setState(() {
          _calculated = false;
          _range = newRange;
        });
      } else {
        final String alertResult = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Incorrect range :('),
            content: SingleChildScrollView(
                child: ListBody(
              children: const [
                Text(
                    "The range you've chosen is too narrow: not enough for correlation analysis."),
                Text(
                    'Please choose the range with at least 2 events of every parameter')
              ],
            )),
            actions: [
              TextButton(
                child: const Text('I will reselect'),
                onPressed: () {
                  Navigator.pop(context, 'reselect');
                },
              ),
              TextButton(
                child: const Text('Set default range'),
                onPressed: () {
                  Navigator.pop(context, 'default');
                },
              ),
            ],
          ),
        );
        if (alertResult == 'reselect') {
          _selectDateRange();
        }
        if (alertResult == 'default') {
          setState(() {
            _calculated = false;
            _range = _calculateDefaultRange(params);
          });
        }
      }
    }
  }

  //checks if the range contains at least 1 event of any parameter
  bool _rangeIsValid(DateTimeRange range) {
    Set<DateTime> firstParamEventDates = params[0].eventDates();
    Set<DateTime> secondParamEventDates = params[1].eventDates();
    Set<DateTime> rangeSet = daysFromRange(range);

    return rangeSet.intersection(firstParamEventDates).length > 2 &&
        rangeSet.intersection(secondParamEventDates).length > 2;
  }

  Map<String, dynamic> _calculateDDCorrelation({
    required Button firstParameter,
    required Button secondParameter,
    required DateTimeRange dateRange,
    int lag = 0,
  }) {
    //elements of the contingency matrix
    int n01 = 0;
    int n00 = 0;
    int n10 = 0; // first occured, second did not
    int n11 = 0; // total occured on the same day
    //phi coefficient
    double phi;

    Set<DateTime> firstParamEventDates = firstParameter.eventDates();
    var laggedSecondParamDates = secondParameter
        .eventDates()
        .map((DateTime date) => date.subtract(Duration(days: lag)));
    Set<DateTime> secondParamEventDates = laggedSecondParamDates.toSet();
    Set<DateTime> rangeSet = daysFromRange(DateTimeRange(
        start: dateRange.start,
        end: dateRange.end.subtract(Duration(days: lag))));

    //Set<DateTime> secondParamLaggedEventDates =

    n11 = rangeSet
        .intersection(firstParamEventDates)
        .intersection(secondParamEventDates)
        .length;
    n01 = rangeSet.intersection(secondParamEventDates).length - n11;
    n10 = rangeSet.intersection(firstParamEventDates).length - n11;
    n00 = rangeSet.length - n11 - n01 - n10;

    //standard formula for phi coeficient
    phi = (n11 * n00 - n10 * n01) /
        sqrt((n00 + n10) * (n00 + n01) * (n11 + n10) * (n11 + n01));

    Map<String, dynamic> result = {
      'n00': n00,
      'n01': n01,
      'n10': n10,
      'n11': n11,
      'phi': phi,
    };
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Correlation: day-day'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
              child: SizedBox(
            width: 320,
            child: !paramsChosen()
                ? Column(children: [
                    const SizedBox(height: 25),
                    ControlButton(
                      title: 'Choose two parameters',
                      onPressed: () {
                        _navigateSelectionScreen(context);
                      },
                    ),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      const Text('Parameters: click to edit',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF818181),
                          )),
                      const SizedBox(height: 15),
                      for (Button param in params)
                        Column(
                          children: [
                            RichDataButton(
                              button: param,
                              onTap: () {
                                _navigateSelectionScreen(context);
                              },
                              number: params.indexOf(param) + 1,
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      if (paramsChosen())
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Block for choosing time period
                            const SizedBox(height: 10),
                            const Text('Analysis period: click to edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF818181),
                                )),
                            const SizedBox(height: 15),
                            Ink(
                              height: 40,
                              width: 320,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  _selectDateRange();
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(13, 5, 13, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.date_range,
                                          size: 24, color: Colors.blue),
                                      Text(_rangeToPrettyString(_range),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                      Text('${_range.duration.inDays + 1} days',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //Block for choosing lag
                            const SizedBox(height: 25),
                            const Text('Lag: click to edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF818181),
                                )),
                            const SizedBox(height: 15),
                            PopupMenuButton(
                                child: Container(
                                  height: 40,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue)),
                                  padding:
                                      const EdgeInsets.fromLTRB(13, 5, 13, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.stacked_line_chart,
                                          size: 24, color: Colors.blue),
                                      Text(_lag == 1 ? '1 day' : '$_lag days',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                onSelected: (int value) {
                                  if (value != _lag) {
                                    setState(() {
                                      _calculated = false;
                                      _lag = value;
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text('0 days'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text('1 day'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 2,
                                        child: Text('2 days'),
                                      ),
                                    ]),
                            const SizedBox(height: 25),
                            ControlButton(
                                title: _calculated
                                    ? 'Result:'
                                    : 'Calculate correlation',
                                onPressed: () {
                                  setState(() {
                                    _correlationDD = _calculateDDCorrelation(
                                        firstParameter: params[0],
                                        secondParameter: params[1],
                                        dateRange: _range,
                                        lag: _lag);
                                    _calculated = true;
                                  });
                                }),
                            const SizedBox(height: 25),
                            if (_calculated)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Contingency matrix',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF818181),
                                      )),
                                  const SizedBox(height: 15),
                                  ContingencyMatrix(
                                      firstParamColor: params[0].color,
                                      secondParamColor: params[1].color,
                                      n00: _correlationDD["n00"],
                                      n10: _correlationDD["n10"],
                                      n01: _correlationDD["n01"],
                                      n11: _correlationDD["n11"]),
                                  const SizedBox(height: 25),
                                  DDcorrelationInterpretation(
                                      correlationDD: _correlationDD),
                                  const SizedBox(height: 25),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
          )),
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton(
      {super.key, required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Ink(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF2196F3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
