// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/Auth/AnimIcon.dart';
import 'package:project/Auth/auth.dart';
import 'package:project/Auth/user.dart';
import 'package:project/Deadline.dart';
import 'AnimText.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  final User user;
  final String baseUrl;
  const Home({required this.user, required this.baseUrl, super.key});

  @override
  State<Home> createState() => _HomeState();
  User getUser() {
    return user;
  }
}

Future<void> _writeData({required bool isLightTheme, required List<Color> themeColor, required List<Color> colorLight, required List<Color> colorDark, required User user}) async {
  if (user.username.isEmpty || user.password.isEmpty) {
    return;
  }
  
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');

  final data = {'isLightTheme': isLightTheme, 'themeColor': themeColor.map((c) => c.value).toList(), 'colorLight': colorLight.map((c) => c.value).toList(), 'colorDark': colorDark.map((c) => c.value).toList(), 'username': user.username, 'password': user.password};
  await file.writeAsString(jsonEncode(data));
}

Future<User> readData(User u) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');
  User currentUser = u;

  if (await file.exists()) {
    try {
      final data = jsonDecode(await file.readAsString());
      isLightTheme = data['isLightTheme'] ?? true;
      themeColor = (data['themeColor'] != null)
          ? (data['themeColor'] as List).map((v) => Color(v)).toList()
          : isLightTheme
          ? colorLight
          : colorDark;
      colorLight = (data['colorLight'] != null) ? (data['colorLight'] as List).map((v) => Color(v)).toList() : colorLight;
      colorDark = (data['colorDark'] != null) ? (data['colorDark'] as List).map((v) => Color(v)).toList() : colorDark;
      
      final fileUsername = data['username'] ?? '';
      final filePassword = data['password'] ?? '';
      if (fileUsername.isNotEmpty && filePassword.isNotEmpty) {
        currentUser = User(username: fileUsername, password: filePassword);
      }
      
      await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: currentUser);
    } catch (e) {
      await file.delete();
      await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: currentUser);
    }
  } else {
    await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: currentUser);
  }
  
  return currentUser;
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

void restore(User u) {
  colorLight = [Color.fromARGB(255, 246, 246, 246), Colors.blue];
  colorDark = [Color.fromARGB(255, 20, 20, 20), Colors.deepPurple];
  isLightTheme = true;
  themeColor = colorLight;
  themeIcon = iconLight;
  deadlines.clear();
  dates.clear();
  deadlineIds.clear();
  _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: u);
}

bool sortFlag = true;
String prevSortBy = '';

void sortDeadlines(String sortBy) {
  List<Deadline> temp = [];
  for (int i = 0; i < deadlines.length; i++) {
    temp.add(Deadline(deadlineIds[i], deadlines[i], dates[i]));
  }
  if (sortFlag) {
    if (sortBy == 'name') {
    temp.sort((a, b) => a.d_name.compareTo(b.d_name));
    } else if (sortBy == 'date') {
      temp.sort((a, b) => a.d_date.compareTo(b.d_date));
    }
  } else {
    if (sortBy == 'name') {
      temp.sort((a, b) => b.d_name.compareTo(a.d_name));
    } else if (sortBy == 'date') {
      temp.sort((a, b) => b.d_date.compareTo(a.d_date));
    }
  }
  if(prevSortBy == sortBy) {
    sortFlag = !sortFlag;
  } else {
    sortFlag = true;
    prevSortBy = sortBy;
  }
  deadlines.clear();
  dates.clear();
  deadlineIds.clear();
  for (int i = 0; i < temp.length; i++) {
    deadlines.add(temp[i].d_name);
    dates.add(temp[i].d_date);
    deadlineIds.add(temp[i].d_id);
  }
}

List<Color> colorLight = [Color.fromARGB(255, 246, 246, 246), Colors.blue];
List<Color> colorDark = [Color.fromARGB(255, 20, 20, 20), Colors.deepPurple];
List<IconData> iconLight = [Icons.light_mode_outlined];
List<IconData> iconDark = [Icons.dark_mode_outlined];

bool isLightTheme = true;
List<String> deadlines = [];
List<DateTime> dates = [];
List<int> deadlineIds = [];
TextEditingController deadlineController = TextEditingController();

DateTime nowDate = DateTime.now();

List<Color> themeColor = colorLight;
List<IconData> themeIcon = iconLight;

Future<void> getDeadlinesFromDB(String baseUrl, String username) async {
  sortFlag = true;
  prevSortBy = '';
  try {
    final response = await http.get(Uri.parse('$baseUrl/getDeadlines.php?username=$username'));
    if (response.statusCode == 200) {
      final temp = jsonDecode(response.body);
      deadlines.clear();
      dates.clear();
      deadlineIds.clear();
      if (temp is List) {
        for (var item in temp) {
          deadlines.add(item['d_name'] ?? '');
          dates.add(DateTime.parse(item['d_date']));
          deadlineIds.add(int.parse(item['d_id'].toString()));
        }
      }
    }
  } catch (_) {}
}

Future<bool> insertDeadline(String baseUrl, String username, String d_name, DateTime d_date) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/insertDeadline.php'),
      body: jsonEncode({
        'username': username,
        'd_name': d_name,
        'd_date': d_date.toIso8601String()
      }),
      headers: {"Content-Type": "application/json"},
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<bool> updateDeadline(String baseUrl, String username, int d_id, String d_name, DateTime d_date) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/updateDeadline.php'),
      body: jsonEncode({
        'username': username,
        'd_id': d_id,
        'd_name': d_name,
        'd_date': d_date.toIso8601String()
      }),
      headers: {"Content-Type": "application/json"},
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<bool> deleteDeadline(String baseUrl, String username, int d_id) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteDeadline.php'),
      body: jsonEncode({
        'username': username,
        'd_id': d_id
      }),
      headers: {"Content-Type": "application/json"},
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

class _HomeState extends State<Home> {
  User? currentUser;

  Future<void> getDeadlines() async {
    setState(() {
      isLoading = true;
    });
    
    currentUser = await readData(widget.user);
    
    if (currentUser == null || currentUser!.username.isEmpty) {
      if (widget.user.username.isNotEmpty) {
        currentUser = widget.user;
      }
    }
    
    final effectiveUser = getEffectiveUser();
    if (effectiveUser.username.isNotEmpty && effectiveUser.password.isNotEmpty) {
      await getDeadlinesFromDB(widget.baseUrl, effectiveUser.username);
      await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: effectiveUser);
      currentUser = effectiveUser;
    }
    
    setState(() {
      isLoading = false;
    });
  }
  
  User getEffectiveUser() {
    if (currentUser != null && currentUser!.username.isNotEmpty) {
      return currentUser!;
    }
    if (widget.user.username.isNotEmpty) {
      return widget.user;
    }
    return currentUser ?? widget.user;
  }
  void themeSwitch() {
    setState(() {
      themeColor = isLightTheme ? colorDark : colorLight;
      themeIcon = isLightTheme ? iconDark : iconLight;
      isLightTheme = !isLightTheme;
    });
    _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
  }

  void updateTheme() {
    themeSwitch();
    themeSwitch();
    _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
  }

  String dateCalculator(DateTime date1, DateTime date2) {
    date2 = DateTime(date2.year, date2.month, date2.day, 23, 59, 59);

    int yeardiff = date2.year - date1.year;
    bool yearflag = false;
    int monthdiff = date2.month - date1.month;
    bool monthflag = false;
    int daydiff = date2.day - date1.day;

    if (date2.isBefore(date1)) return 'Date Passed';

    if (yeardiff == 0) {
      if (monthdiff == 0) {
        if (daydiff == 0) {
          return 'Today';
        } else {
          return daydiff == 1 ? 'Tomorrow' : 'in $daydiff days';
        }
      } else {
        if (daydiff >= 15) {
          monthdiff += 1;
          monthflag = true;
        }
        if (daydiff < 0 && monthdiff == 1) {
          daydiff += DateTime(date2.year, date2.month, 0).day;
          return daydiff == 1 ? 'Tomorrow' : 'in $daydiff days';
        }
        return monthdiff == 1 ? 'Next Month' : 'in ${monthflag ? '~' : ''}$monthdiff months';
      }
    } else {
      if (monthdiff >= 6) {
        yeardiff += 1;
        yearflag = true;
      }
      if (monthdiff < 0 && yeardiff == 1) {
        monthdiff += 12;
        return monthdiff == 1 ? 'Next Month' : 'in $monthdiff months';
      }
      return yeardiff == 1 ? 'Next Year' : 'in ${yearflag ? '~' : ''}$yeardiff months';
    }
  }

  String currentDeadline = '';
  DateTime currentDate = DateTime.utc(0, 0, 0);
  int currentDeadlineId = -1;

  int redIn = 0;
  int greenIn = 0;
  int blueIn = 0;
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDeadlines();
  }

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
                leadingWidth: 80,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
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
                    
                  IconButton(
                    icon: AnimIcon(themeColor[0], themeIcon[0], Icons.refresh),
                    onPressed: () {
                      getDeadlines();
                    },
                  ),
                  ],
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
                                    Text('Version: v2.0', style: TextStyle(color: themeColor[1])),
                                    Text('Created by: Yousef Kahwaji', style: TextStyle(color: themeColor[1])),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                                      child: TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: themeColor[0],
                                              title: Text('Confirm', style: TextStyle(color: themeColor[1])),
                                              content: Text('Are you sure you want to log out? All theme data will be deleted, deadlines will be saved.', style: TextStyle(color: themeColor[1])),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text('Cancel', style: TextStyle(color: themeColor[1])),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteData();
                                                    setState(() {
                                                      restore(widget.user);
                                                    });
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Auth(baseUrl: widget.baseUrl)));
                                                  },
                                                  child: Text('Log out', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Center(
                                          child: Text('Log out', style: TextStyle(color: themeColor[1])),
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Deadline Tracker'),
                  ),
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
                deadlineController.text = '';
                currentDate = DateTime.utc(0, 0, 0);
                currentDeadlineId = -1;
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
                                controller: deadlineController,
                                cursorColor: themeColor[1],
                                onChanged: (input) {
                                  setDialogState(() {
                                    if (input.length > 50) {
                                      deadlineController.text = currentDeadline;
                                      deadlineController.selection = TextSelection.fromPosition(TextPosition(offset: currentDeadline.length));
                                      return;
                                    }
                                    currentDeadline = input;
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
                                            setDialogState(() {
                                              currentDate = selectedDate;
                                            });
                                          }
                                        });
                                      },
                                      icon: AnimIcon(themeColor[1], themeIcon[0], Icons.date_range_outlined),
                                    ),
                                    currentDate != DateTime.utc(0, 0, 0)
                                        ? Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2, right: 8.0, bottom: 0.0, left: 1.0),
                                                  child: Text('${currentDate.month}/${currentDate.day}/${currentDate.year}', style: TextStyle(color: themeColor[1], fontSize: 16)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2, right: 0.0, bottom: 0.0, left: 18.0),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setDialogState(() {
                                                        currentDate = DateTime.utc(0, 0, 0);
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
                              onPressed: currentDeadline.isNotEmpty && currentDate != DateTime.utc(0, 0, 0) && getEffectiveUser().username.isNotEmpty
                                  ? () async {
                                      final success = await insertDeadline(widget.baseUrl, getEffectiveUser().username, currentDeadline, currentDate);
                                      if (success) {
                                        Navigator.of(context).pop();
                                        currentDeadline = '';
                                        deadlineController.text = '';
                                        currentDate = DateTime.utc(0, 0, 0);
                                        currentDeadlineId = -1;
                                        await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
                                        await getDeadlines();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to insert deadline')),
                                        );
                                      }
                                    }
                                  : null,
                              child: Text('Save', style: TextStyle(color: (currentDeadline.isNotEmpty && currentDate != DateTime.utc(0, 0, 0) && getEffectiveUser().username.isNotEmpty) ? themeColor[1] : Colors.grey)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
              },
              child: AnimIcon(themeColor[0], themeIcon[0], Icons.add),
            ),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: themeColor[1],
                  ),
                )
              : deadlines.isEmpty
                  ? Center(
                      child: AnimText('No Deadlines. Add some!', style: TextStyle(fontSize: 24, color: themeColor[1])),
                    )
                  : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 16.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(onPressed: () {
                              showMenu(context: context, position: RelativeRect.fill, color: themeColor[0],items: [
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      sortDeadlines('name');
                                    });
                                  },
                                  child: Text('Sort by Name ${prevSortBy == 'name' ? (sortFlag ? '↑' : '↓') : ''}', style: TextStyle(color: themeColor[1])),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      sortDeadlines('date');
                                    });
                                  },
                                  child: Text('Sort by Date ${prevSortBy == 'date' ? (sortFlag ? '↑' : '↓') : ''}', style: TextStyle(color: themeColor[1])),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    getDeadlines();
                                  },
                                  child: Text('Revert sort', style: TextStyle(color: themeColor[1])),
                                ),
                              ]);
                            }, icon: AnimIcon(themeColor[1], themeIcon[0], Icons.swap_vert)),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimText("You have ${deadlines.length} deadline${deadlines.length == 1 ? '' : 's'}:", style: TextStyle(fontSize: 24, color: themeColor[1])),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (int i = 0; i < deadlines.length; i++)
                        InkWell(
                          key: ValueKey('deadline_${deadlineIds[i]}_$i'),
                          onTap: () {
                            final deadline = deadlines[i];
                            if (i >= 0 && i < dates.length && i < deadlineIds.length) {
                              currentDeadline = deadline;
                              currentDate = dates[i];
                              currentDeadlineId = deadlineIds[i];
                              TextEditingController textEditingController = TextEditingController()..text = deadline;
                              showAdaptiveDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return StatefulBuilder(
                                    builder: (dialogContext, setDialogState) => Center(
                                      child: SingleChildScrollView(
                                        child: AlertDialog(
                                          backgroundColor: themeColor[0],
                                            actions: [
                                              TextButton(
                                                onPressed: (currentDeadline.isEmpty || currentDate == DateTime.utc(0, 0, 0) || (currentDeadline == deadline && currentDate == dates[i]))
                                                    ? null
                                                    : () async {
                                                        final success = await updateDeadline(widget.baseUrl, getEffectiveUser().username, currentDeadlineId, currentDeadline, currentDate);
                                                        if (success) {
                                                          Navigator.of(dialogContext).pop();
                                                          currentDeadline = '';
                                                          currentDate = DateTime.utc(0, 0, 0);
                                                          currentDeadlineId = -1;
                                                          await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
                                                          await getDeadlines();
                                                        } else {
                                                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                                                            SnackBar(content: Text('Failed to update deadline')),
                                                          );
                                                        }
                                                      },
                                                child: Text('Save', style: TextStyle(color: (currentDeadline.isEmpty || currentDate == DateTime.utc(0, 0, 0) || (currentDeadline == deadline && currentDate == dates[i])) ? Colors.grey : themeColor[1])),
                                              ),
                                          ],
                                          title: Text("Edit Deadline", style: TextStyle(color: themeColor[1])),
                                          content: Column(
                                            children: [
                                              TextField(
                                                controller: textEditingController,
                                                cursorColor: themeColor[1],
                                                onChanged: (input) {
                                                  setDialogState(() {
                                                    if (input.length > 50) {
                                                      textEditingController.text = currentDeadline;
                                                      textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: currentDeadline.length));
                                                      return;
                                                    }
                                                    currentDeadline = input;
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
                                                        context: dialogContext,
                                                        firstDate: DateTime.now(),
                                                        lastDate: DateTime(2100),
                                                        initialDate: currentDate != DateTime.utc(0, 0, 0) ? currentDate : DateTime.now(),
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
                                                          setDialogState(() {
                                                            currentDate = selectedDate;
                                                          });
                                                        }
                                                      });
                                                    },
                                                    icon: AnimIcon(themeColor[1], themeIcon[0], Icons.date_range_outlined),
                                                  ),
                                                  currentDate != DateTime.utc(0, 0, 0)
                                                      ? Expanded(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2, right: 8.0, bottom: 0.0, left: 1.0),
                                                                child: Text('${currentDate.month}/${currentDate.day}/${currentDate.year}', style: TextStyle(color: themeColor[1], fontSize: 16)),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2, right: 0.0, bottom: 0.0, left: 18.0),
                                                                child: IconButton(
                                                                  onPressed: () {
                                                                    setDialogState(() {
                                                                      currentDate = DateTime.utc(0, 0, 0);
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
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0, left: 18.0, right: 5.0, bottom: 10.0),
                                      child: AnimText(
                                        deadlines[i],
                                        style: TextStyle(fontSize: 19.5, color: themeColor[1]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    if (i < dates.length && dates[i] != DateTime.utc(0, 0, 0))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0, left: 20.0, right: 5.0, bottom: 10.0),
                                        child: AnimText('${dates[i].month}/${dates[i].day}/${dates[i].year}, Due ${dateCalculator(nowDate, dates[i])}', style: TextStyle(fontSize: 17, color: themeColor[1])),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, right: 1.0, bottom: 8.0, left: 2.0),
                                child: IconButton(
                                  onPressed: () {
                                    if (i >= 0 && i < deadlines.length && i < dates.length && i < deadlineIds.length) {
                                      final deadline = deadlines[i];
                                      currentDeadline = deadline;
                                      currentDate = dates[i];
                                      currentDeadlineId = deadlineIds[i];
                                      TextEditingController textEditingController = TextEditingController()..text = deadline;
                                      showAdaptiveDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return StatefulBuilder(
                                            builder: (dialogContext, setDialogState) => Center(
                                              child: SingleChildScrollView(
                                                child: AlertDialog(
                                                  backgroundColor: themeColor[0],
                                                  actions: [
                                                    TextButton(
                                                      onPressed: (currentDeadline.isEmpty || currentDate == DateTime.utc(0, 0, 0) || (currentDeadline == deadline && currentDate == dates[i]))
                                                          ? null
                                                          : () async {
                                                              final success = await updateDeadline(widget.baseUrl, getEffectiveUser().username, currentDeadlineId, currentDeadline, currentDate);
                                                              if (success) {
                                                                Navigator.of(dialogContext).pop();
                                                                currentDeadline = '';
                                                                currentDate = DateTime.utc(0, 0, 0);
                                                                currentDeadlineId = -1;
                                                                await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
                                                                await getDeadlines();
                                                              } else {
                                                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                                                  SnackBar(content: Text('Failed to update deadline')),
                                                                );
                                                              }
                                                            },
                                                      child: Text('Save', style: TextStyle(color: (currentDeadline.isEmpty || currentDate == DateTime.utc(0, 0, 0) || (currentDeadline == deadline && currentDate == dates[i])) ? Colors.grey : themeColor[1])),
                                                    ),
                                                  ],
                                                  title: Text("Edit Deadline", style: TextStyle(color: themeColor[1])),
                                                  content: Column(
                                                    children: [
                                                      TextField(
                                                        controller: textEditingController,
                                                        cursorColor: themeColor[1],
                                                        onChanged: (input) {
                                                          setDialogState(() {
                                                            if (input.length > 50) {
                                                              textEditingController.text = currentDeadline;
                                                              textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: currentDeadline.length));
                                                              return;
                                                            }
                                                            currentDeadline = input;
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
                                                                context: dialogContext,
                                                                firstDate: DateTime.now(),
                                                                lastDate: DateTime(2100),
                                                                initialDate: currentDate != DateTime.utc(0, 0, 0) ? currentDate : DateTime.now(),
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
                                                                  setDialogState(() {
                                                                    currentDate = selectedDate;
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            icon: AnimIcon(themeColor[1], themeIcon[0], Icons.date_range_outlined),
                                                          ),
                                                          currentDate != DateTime.utc(0, 0, 0)
                                                              ? Expanded(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 2, right: 8.0, bottom: 0.0, left: 1.0),
                                                                        child: Text('${currentDate.month}/${currentDate.day}/${currentDate.year}', style: TextStyle(color: themeColor[1], fontSize: 16)),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 2, right: 0.0, bottom: 0.0, left: 18.0),
                                                                        child: IconButton(
                                                                          onPressed: () {
                                                                            setDialogState(() {
                                                                              currentDate = DateTime.utc(0, 0, 0);
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
                                    }
                                  },
                                  icon: AnimIcon(themeColor[1], themeIcon[0], Icons.edit_outlined),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, right: 0.0, bottom: 8.0, left: 1.0),
                                child: IconButton(
                                  onPressed: () async {
                                    if (i >= 0 && i < deadlineIds.length && i < deadlines.length) {
                                      final success = await deleteDeadline(widget.baseUrl, getEffectiveUser().username, deadlineIds[i]);
                                      if (success) {
                                        await _writeData(isLightTheme: isLightTheme, themeColor: themeColor, colorLight: colorLight, colorDark: colorDark, user: getEffectiveUser());
                                        await getDeadlines();
                                        setState(() {});
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete deadline')),
                                        );
                                      }
                                    }
                                  },
                                  icon: AnimIcon(themeColor[1], themeIcon[0], Icons.delete_outlined),
                                ),
                              ),
                            ],
                          )
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
