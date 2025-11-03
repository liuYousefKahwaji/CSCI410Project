// ignore_for_file: non_constant_identifier_names, deprecated_member_use, use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/AnimIcon.dart';
import 'AnimText.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> readData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');

    if (await file.exists()) {
      try {
        final data = jsonDecode(await file.readAsString());
        isLightTheme = data['isLightTheme'];
        themeColor = (data['themeColor'] != null)
            ? (data['themeColor'] as List).map((v) => Color(v)).toList()
            : isLightTheme
            ? colorLight
            : colorDark;
        colorLight = (data['colorLight'] as List).map((v) => Color(v)).toList();
        colorDark = (data['colorDark'] as List).map((v) => Color(v)).toList();
        deadlines = List<String>.from(data['deadlines']);
        dates = List<String>.from(data['dates']);
      } catch (e) {
        await file.delete();
      }
    }
  }

  readData().then((_) {
    runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MainApp()));
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

Future<void> _writeData({required bool isLightTheme, required List<Color> themeColor, required List<Color> colorLight, required List<Color> colorDark, required List<String> deadlines, required List<String> dates}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');

  final data = {'isLightTheme': isLightTheme, 'themeColor': themeColor.map((c) => c.value).toList(), 'colorLight': colorLight.map((c) => c.value).toList(), 'colorDark': colorDark.map((c) => c.value).toList(), 'deadlines': deadlines, 'dates': dates};
  await file.writeAsString(jsonEncode(data));
}

Future<void> _deleteData() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    null;
  }
}

void restore() {
  colorLight = [Color.fromARGB(255, 246, 246, 246), Colors.blue];
  colorDark = [Color.fromARGB(255, 20, 20, 20), Colors.deepPurple];
  isLightTheme = true;
  themeColor = colorLight;
  themeIcon = iconLight;
  deadlines.clear();
  dates.clear();
  _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
}

List<Color> colorLight = [Color.fromARGB(255, 246, 246, 246), Colors.blue];
List<Color> colorDark = [Color.fromARGB(255, 20, 20, 20), Colors.deepPurple];
List<IconData> iconLight = [Icons.light_mode_outlined];
List<IconData> iconDark = [Icons.dark_mode_outlined];

bool isLightTheme = true;
List<String> deadlines = [];
List<String> dates = [];

List<Color> themeColor = colorLight;
List<IconData> themeIcon = iconLight;

class _MainAppState extends State<MainApp> {
  void themeSwitch() {
    setState(() {
      themeColor = isLightTheme ? colorDark : colorLight;
      themeIcon = isLightTheme ? iconDark : iconLight;
      isLightTheme = !isLightTheme;
    });
    _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
  }

  void updateTheme() {
    themeSwitch();
    themeSwitch();
    _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
  }

  String currentDeadline = '';
  String currentDate = '';

  int redIn = 0;
  int greenIn = 0;
  int blueIn = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(primaryColor: themeColor[1])),
      debugShowCheckedModeBanner: false,
      home: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: themeColor[0],
        curve: Curves.easeInOut,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              color: themeColor[1],
              curve: Curves.easeInOut,
              child: AppBar(
                leading: IconButton(
                  onPressed: () {
                    setState(() {
                      showAdaptiveDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: themeColor[0],
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${isLightTheme ? 'Light' : 'Dark'} mode accent color:', style: TextStyle(color: themeColor[1], fontSize: 18.5)),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [Colors.blue, Colors.deepPurple, Colors.red, Colors.green, Colors.deepOrange, Colors.orange, Colors.purple, Colors.teal, Colors.brown, Colors.pink, Colors.amber, Colors.cyan]
                                      .map(
                                        (color) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isLightTheme) {
                                                colorLight[1] = color;
                                              } else {
                                                colorDark[1] = color;
                                              }
                                              updateTheme();
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SingleChildScrollView(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            if (isLightTheme) {
                                              setState(() {
                                                colorLight[1] = Colors.blue;
                                              });
                                            } else {
                                              setState(() {
                                                colorDark[1] = Colors.deepPurple;
                                              });
                                            }
                                            updateTheme();
                                          },
                                          icon: Icon(Icons.refresh_outlined, color: themeColor[1], size: 30),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0, left: 8.0),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            showAdaptiveDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setDialogState) => AlertDialog(
                                                    backgroundColor: themeColor[0],
                                                    title: Text('Custom Accent Color', style: TextStyle(color: themeColor[1], fontSize: 18.5)),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 75,
                                                            width: 75,
                                                            decoration: BoxDecoration(color: Color.fromARGB(255, redIn, greenIn, blueIn), shape: BoxShape.circle),
                                                          ),
                                                          Slider.adaptive(
                                                            value: redIn.toDouble(),
                                                            min: 0,
                                                            max: 255,
                                                            divisions: 255,
                                                            activeColor: Colors.red,
                                                            onChanged: (double value) {
                                                              setDialogState(() {
                                                                redIn = value.toInt();
                                                              });
                                                            },
                                                          ),
                                                          Slider.adaptive(
                                                            value: greenIn.toDouble(),
                                                            min: 0,
                                                            max: 255,
                                                            divisions: 255,
                                                            activeColor: Colors.green,
                                                            onChanged: (double value) {
                                                              setDialogState(() {
                                                                greenIn = value.toInt();
                                                              });
                                                            },
                                                          ),
                                                          Slider.adaptive(
                                                            value: blueIn.toDouble(),
                                                            min: 0,
                                                            max: 255,
                                                            divisions: 255,
                                                            activeColor: Colors.blue,
                                                            onChanged: (double value) {
                                                              setDialogState(() {
                                                                blueIn = value.toInt();
                                                              });
                                                            },
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                if (isLightTheme) {
                                                                  colorLight[1] = Color.fromARGB(255, redIn, greenIn, blueIn);
                                                                } else {
                                                                  colorDark[1] = Color.fromARGB(255, redIn, greenIn, blueIn);
                                                                }
                                                                updateTheme();
                                                                Navigator.of(context).pop();
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 12.0),
                                                              child: Text('Confirm', style: TextStyle(color: themeColor[1])),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(Icons.format_paint_outlined, color: themeColor[1], size: 30),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Icon(Icons.palette_outlined, color: themeColor[0], size: 23, key: ValueKey(themeIcon[0])),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: IconButton(
                      icon: AnimIcon(themeColor[0], themeIcon[0], Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Center(
                            child: SingleChildScrollView(
                              child: AlertDialog(
                                backgroundColor: themeColor[0],
                                title: Text('About', style: TextStyle(color: themeColor[1])),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Version: 1.0.0', style: TextStyle(color: themeColor[1])),
                                    Text('Created by: Yousef Kahwaji', style: TextStyle(color: themeColor[1])),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                                      child: TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: themeColor[0],
                                              title: Text('Confirm Deletion', style: TextStyle(color: themeColor[1])),
                                              content: Text('Are you sure you want to delete all saved data?\nThis action cannot be undone.', style: TextStyle(color: themeColor[1])),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text('Cancel', style: TextStyle(color: themeColor[1])),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    await _deleteData();
                                                     setState(() {
                                                      restore();
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Center(
                                          child: Text('Delete saved data', style: TextStyle(color: themeColor[1])),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: Icon(themeIcon[0], key: ValueKey(themeIcon[0]), color: themeColor[0]),
                    ),
                    onPressed: () {
                      setState(() {
                        themeSwitch();
                      });
                    },
                  ),
                ],
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  style: TextStyle(fontSize: 20, color: themeColor[0]),
                  child: Text('Deadline Tracker'),
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          floatingActionButton: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: FloatingActionButton(
              key: ValueKey(themeColor[1]),
              shape: CircleBorder(),
              backgroundColor: themeColor[1],
              onPressed: () {
                currentDeadline = '';
                currentDate = '';
                setState(() {
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) => AlertDialog(
                          title: Text('Add New Deadline', style: TextStyle(color: themeColor[1])),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  cursorColor: themeColor[1],
                                  onChanged: (input) {
                                    setState(() {
                                      setDialogState(() {
                                        currentDeadline = input;
                                      });
                                    });
                                  },
                                  style: TextStyle(color: themeColor[1]),
                                  decoration: InputDecoration(
                                    hintText: 'Enter deadline details',
                                    hintStyle: TextStyle(color: themeColor[1]),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor[1])),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor[1])),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          initialDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: isLightTheme ? ColorScheme.light(primary: themeColor[1].withOpacity(0.6), onPrimary: themeColor[1], onSurface: themeColor[1], surface: themeColor[0]) : ColorScheme.dark(primary: themeColor[1].withOpacity(0.6), onPrimary: themeColor[1], onSurface: themeColor[1], surface: themeColor[0]),
                                                textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: themeColor[1])),
                                                dividerColor: themeColor[1],
                                                dialogBackgroundColor: themeColor[1],
                                                dialogTheme: DialogThemeData(backgroundColor: themeColor[0], surfaceTintColor: Colors.transparent),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        ).then((selectedDate) {
                                          if (selectedDate != null) {
                                            setState(() {
                                              setDialogState(() {
                                                currentDate = '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
                                              });
                                            });
                                          }
                                        });
                                      },
                                      icon: AnimIcon(themeColor[1], themeIcon[0], Icons.date_range_outlined),
                                    ),
                                    currentDate.isNotEmpty
                                        ? Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2, right: 8.0, bottom: 0.0, left: 1.0),
                                                  child: Text(currentDate, style: TextStyle(color: themeColor[1], fontSize: 16)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2, right: 0.0, bottom: 0.0, left: 18.0),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        setDialogState(() {
                                                          currentDate = '';
                                                        });
                                                      });
                                                    },
                                                    icon: Icon(Icons.close_outlined, color: themeColor[1], size: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: themeColor[0],
                          actions: [
                            TextButton(
                              onPressed: currentDeadline.isNotEmpty
                                  ? () {
                                      setState(() {
                                        deadlines.add(currentDeadline);
                                        dates.add(currentDate);
                                        currentDeadline = '';
                                      });
                                      _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              child: Text('Save', style: TextStyle(color: currentDeadline.isNotEmpty ? themeColor[1] : Colors.grey)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
              },
              child: AnimIcon(themeColor[0], themeIcon[0], Icons.add),
            ),
          ),
          body: deadlines.isEmpty
              ? Center(
                  child: AnimText('No Deadlines. Add some!', style: TextStyle(fontSize: 24, color: themeColor[1])),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AnimText("You have ${deadlines.length} deadlines:", style: TextStyle(fontSize: 24, color: themeColor[1])),
                      ),
                      for (String deadline in deadlines)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0, left: 18.0, right: 5.0, bottom: 16.0),
                                child: AnimText(
                                  dates[deadlines.indexOf(deadline)].isNotEmpty ? "$deadline\nDue ${dates[deadlines.indexOf(deadline)]}" : deadline,
                                  style: TextStyle(fontSize: 19.5, color: themeColor[1]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: dates[deadlines.indexOf(deadline)].isNotEmpty ? 2 : 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 1.0, bottom: 8.0, left: 2.0),
                              child: IconButton(
                                onPressed: () {
                                  currentDeadline = deadline;
                                  currentDate = dates[deadlines.indexOf(deadline)];
                                  setState(() {
                                    TextEditingController textEditingController = TextEditingController()..text = deadline;
                                    showAdaptiveDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setDialogState) => Center(
                                            child: SingleChildScrollView(
                                              child: AlertDialog(
                                                backgroundColor: themeColor[0],
                                                actions: [
                                                  TextButton(
                                                    onPressed: (currentDeadline.isEmpty || (currentDeadline == deadline && currentDate == dates[deadlines.indexOf(deadline)]))
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              final i = deadlines.indexOf(deadline);
                                                              deadlines[i] = currentDeadline;
                                                              dates[i] = currentDate;
                                                              currentDeadline = '';
                                                              currentDate = '';
                                                              _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
                                                            });
                                                            Navigator.of(context).pop();
                                                          },
                                                    child: Text('Save', style: TextStyle(color: (currentDeadline.isEmpty || (currentDeadline == deadline && currentDate == dates[deadlines.indexOf(deadline)])) ? Colors.grey : themeColor[1])),
                                                  ),
                                                ],
                                                title: Text("Edit Deadline", style: TextStyle(color: themeColor[1])),
                                                content: Column(
                                                  children: [
                                                    TextField(
                                                      controller: textEditingController,
                                                      cursorColor: themeColor[1],
                                                      onChanged: (input) {
                                                        setState(() {
                                                          setDialogState(() {
                                                            currentDeadline = input;
                                                          });
                                                        });
                                                      },
                                                      style: TextStyle(color: themeColor[1]),
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter deadline details',
                                                        hintStyle: TextStyle(color: themeColor[1]),
                                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor[1])),
                                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor[1])),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime.now(),
                                                              lastDate: DateTime(2100),
                                                              initialDate: DateTime.now(),
                                                              builder: (context, child) {
                                                                return Theme(
                                                                  data: Theme.of(context).copyWith(
                                                                    colorScheme: isLightTheme ? ColorScheme.light(primary: themeColor[1].withOpacity(0.6), onPrimary: themeColor[1], onSurface: themeColor[1], surface: themeColor[0]) : ColorScheme.dark(primary: themeColor[1].withOpacity(0.6), onPrimary: themeColor[1], onSurface: themeColor[1], surface: themeColor[0]),
                                                                    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: themeColor[1])),
                                                                    dividerColor: themeColor[1],
                                                                    dialogBackgroundColor: themeColor[1],
                                                                    dialogTheme: DialogThemeData(backgroundColor: themeColor[0], surfaceTintColor: Colors.transparent),
                                                                  ),
                                                                  child: child!,
                                                                );
                                                              },
                                                            ).then((selectedDate) {
                                                              if (selectedDate != null) {
                                                                setState(() {
                                                                  setDialogState(() {
                                                                    currentDate = '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
                                                                  });
                                                                });
                                                              }
                                                            });
                                                          },
                                                          icon: AnimIcon(themeColor[1], themeIcon[0], Icons.date_range_outlined),
                                                        ),
                                                        currentDate.isNotEmpty
                                                            ? Expanded(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 2, right: 8.0, bottom: 0.0, left: 1.0),
                                                                      child: Text(currentDate, style: TextStyle(color: themeColor[1], fontSize: 16)),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 2, right: 0.0, bottom: 0.0, left: 18.0),
                                                                      child: IconButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            setDialogState(() {
                                                                              currentDate = '';
                                                                            });
                                                                          });
                                                                        },
                                                                        icon: Icon(Icons.close_outlined, color: themeColor[1], size: 18),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : SizedBox.shrink(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                                },
                                icon: AnimIcon(themeColor[1], themeIcon[0], Icons.edit_outlined),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 0.0, bottom: 8.0, left: 1.0),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    deadlines.remove(deadline);
                                    dates.removeAt(deadlines.indexOf(deadline) + 1);
                                    _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, deadlines: deadlines, dates: dates);
                                  });
                                },
                                icon: AnimIcon(themeColor[1], themeIcon[0], Icons.delete_outlined),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
