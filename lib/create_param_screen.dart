import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import 'model/buttons_storage.dart';
import 'model/buttons_model.dart';

class CreateParamScreen extends StatefulWidget {
  const CreateParamScreen({super.key, required this.storage});

  final ButtonsStorage storage;

  @override
  State<CreateParamScreen> createState() => _CreateParamScreenState();
}

class _CreateParamScreenState extends State<CreateParamScreen> {
  final _controller = TextEditingController();
  final _iconController = TextEditingController();
  String icon = '';
  Color color = Colors.grey[200]!;
  bool showLastNote = false;

  bool _showEmojiPicker = false;

  void onColorButtonTap(buttonColor) {
    setState(() {
      color = buttonColor;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtonsModel>(builder: (context, buttons, child) {
      return KeyboardDismisser(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text('Create new parameter'),
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: <Widget>[
                    //Name input
                    const SizedBox(height: 24.0),
                    TextField(
                      controller: _controller,
                      maxLength: 20,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: const InputDecoration(
                        labelText: 'Name it',
                        border: OutlineInputBorder(),
                        //errorText: 'smth wrong',
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Icon selector
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                      }, //show emoji picker
                      child: Container(
                        height: 65,
                        child: Row(children: <Widget>[
                          //dotted box with an Image selected
                          DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(3),
                              color: const Color(0xFFBABABA),
                              strokeWidth: 1,
                              child: Container(
                                alignment: Alignment.center,
                                width: 35,
                                height: 35,
                                child: Text(
                                  icon,
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              )),
                          const SizedBox(
                            width: 18,
                          ),
                          const Text('Icon: click to choose',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF818181),
                              )),
                        ]),
                      ),
                    ),
                    Offstage(
                      offstage: !_showEmojiPicker,
                      child: SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            setState(() {
                              _showEmojiPicker = false;
                              icon = emoji.emoji;
                            });
                          },
                          onBackspacePressed: () {
                            setState(() {
                              _showEmojiPicker = false;
                              icon = '';
                            });
                          },
                          textEditingController: _iconController,
                          config: const Config(
                            columns: 7,
                            emojiSizeMax: 32,
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            gridPadding: EdgeInsets.zero,
                            initCategory: Category.RECENT,
                            bgColor: const Color(0xFFF2F2F2),
                            indicatorColor: Colors.blue,
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                            backspaceColor: Colors.blue,
                            skinToneDialogBgColor: Colors.white,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            replaceEmojiOnLimitExceed: false,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              textAlign: TextAlign.center,
                            ),
                            //loadingIndicator: const SizedBox.shrink(),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL,
                            //checkPlatformCompatibility: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // COLOR PICKER
                    // 2 rows with evenly distributed fixed size circles
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.grey[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.deepOrange[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.orange[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.lightGreen[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.cyan[200]!,
                            selectedColor: color,
                          ),
                        ]),
                    const SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.indigo[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.pink[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.blueGrey[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.yellow[200]!,
                            selectedColor: color,
                          ),
                          ColorCircleButton(
                            onTap: onColorButtonTap,
                            color: Colors.purple[200]!,
                            selectedColor: color,
                          ),
                        ]),
                    const SizedBox(height: 50),
                    // ShowLastNote Switch
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Show time of the last note',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF818181),
                              )),
                          Switch(
                            value: showLastNote,
                            onChanged: (value) {
                              setState(() {
                                showLastNote = value;
                              });
                            },
                          ),
                        ]),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'mainFAB',
            onPressed: () {
              Provider.of<ButtonsModel>(context, listen: false)
                  .addButton(_controller.text, color, showLastNote, icon);
              widget.storage.writeJSON(buttons.toJson());
              Navigator.pop(context);
            },
            label: const Text('Create'),
            icon: const Icon(Icons.create),
          ),
        ),
      );
    });
  }
}

class ColorCircleButton extends StatelessWidget {
  const ColorCircleButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.selectedColor,
  });

  final Function onTap;
  final Color color;
  final Color selectedColor;

  bool isSelected() {
    return (color == selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected()
                  ? Border.all(width: 1, color: Colors.black)
                  : null),
          child: Center(
              child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  )))),
    );
  }
}
