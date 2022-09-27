import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../model/buttons_model.dart';
import 'correlation_dd_screen.dart';
import 'analytics_utilities/export_csv.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  void _exportData(ButtonsModel buttons) async {
    File file = await ExportCSV(buttons: buttons.list).writeCSV();
    await Share.shareFiles([file.path], text: 'Export Data');
    await file.delete();
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
              }),
          title: const Text('Analytics'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 15),
              ToolButton(
                title: 'Correlation: day-day',
                icon: const Icon(Icons.backup_table),
                description:
                    'This tool calculates 2x2 contingency matrix of days selected parameters has or has not occured. It helps understanding pattern of relation. Also, phi coefficient is calculated giving a sense of strength of relation.',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CorrelationDDScreen()));
                },
              ),
              const SizedBox(height: 15),
              ToolButton(
                  title: 'Export Data',
                  icon: const Icon(Icons.share),
                  description:
                      'Export your gathered data in a simple csv format so you can play with it or share (with a coach or a doctor)',
                  onPressed: () {
                    _exportData(buttons);
                  }),
            ],
          ),
        ),
      );
    });
  }
}

class ToolButton extends StatelessWidget {
  const ToolButton({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.description = '',
    super.key,
  });
  final String title;
  final Icon icon;
  final VoidCallback onPressed;
  final String description;

  Future<void> _showDescription(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2196F3),
          ),
        ),
        child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      icon,
                      const SizedBox(width: 20),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        _showDescription(context);
                      },
                    ),
                ],
              ),
            )));
  }
}
