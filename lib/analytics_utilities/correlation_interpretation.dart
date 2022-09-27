import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DDcorrelationInterpretation extends StatelessWidget {
  const DDcorrelationInterpretation({
    super.key,
    required this.correlationDD,
  });

  final Map correlationDD;

  String phiInterpretation(double phi) {
    if (phi == 0) {
      return 'zero';
    }
    if (phi == -1) {
      return 'perfect negative';
    }
    if (phi == 1) {
      return 'perfect positive';
    }
    if (phi < 0.3 && phi > -0.3) {
      return 'weak';
    }
    if (phi > 0.3 && phi < 0.5) {
      return 'positive, but not very strong,';
    }
    if (phi > 0.5) {
      return 'strong positive';
    }
    if (phi < -0.3 && phi > -0.5) {
      return 'positive, but not very strong,';
    }
    if (phi < -0.5) {
      return 'strong negative';
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    String relation = phiInterpretation(correlationDD["phi"]);
    if (correlationDD.isEmpty) {
      return const Text("Correlation hasn't been calculated correctly");
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Phi coefficient = ${NumberFormat().format(correlationDD["phi"])}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF818181),
            )),
        Text('There is a $relation relation between two parameters.',
            style: const TextStyle(
              fontSize: 16,
              //fontWeight: FontWeight.w600,
              color: Color(0xFF818181),
            )),
        if (relation != 'weak' && relation != 'unknown')
          const Text('Remember! Correlation does not imply causation.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              )),
      ]);
    }
  }
}
