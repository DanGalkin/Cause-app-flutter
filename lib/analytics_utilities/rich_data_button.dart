import '../model/button.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class RichDataButton extends StatelessWidget {
  const RichDataButton({
    super.key,
    required this.button,
    required this.onTap,
    this.selected = false,
    this.number = 0,
    this.disabled = false,
  });

  final Button button;
  final VoidCallback onTap;
  final bool selected;
  final int number;
  final bool disabled;

  //TODO: REFACTOR: all next stuff should not be calculated everytime:
  //this should be in Button class updated only when changed
  String _getFirstEvent(Button button) {
    if (button.notes.isNotEmpty) {
      return DateFormat.yMMMd().format(button.firstEvent());
    }
    return '--';
  }

  String _getLastEvent(Button button) {
    if (button.notes.isNotEmpty) {
      return DateFormat.yMMMd().format(button.lastEvent());
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: !disabled ? 1 : 0.3,
      child: Ink(
        height: 72,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: button.color,
          border: selected
              ? Border.all(
                  color: Colors.green,
                  width: 2,
                )
              : null,
        ),
        child: InkWell(
          onTap: !disabled ? onTap : () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 5, 10, 5),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 35,
                  height: 35,
                  child: Text(
                    number != 0 ? '#$number' : button.icon,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 30,
                          child: FittedBox(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  number != 0
                                      ? '${button.icon} ${button.name}'
                                      : button.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  )))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Event days: ',
                                    style: TextStyle(
                                      color: Color(0xFF7B7B7B),
                                      fontSize: 12,
                                    )),
                                Text(button.eventDates().length.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF7B7B7B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Tracking period: ',
                                    style: TextStyle(
                                      color: Color(0xFF7B7B7B),
                                      fontSize: 12,
                                    )),
                                Text(
                                    button.trackingPeriod() != null
                                        ? button.trackingPeriod().toString()
                                        : 'undefined',
                                    style: const TextStyle(
                                      color: Color(0xFF7B7B7B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ]),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
