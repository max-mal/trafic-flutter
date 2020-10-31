import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mic_stream/mic_stream.dart';

String host = 'http://192.168.88.161/';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  Map<String, bool> sections = {
    'A': false,
    'B': false,
    'C': false,
    'D': false,
  };

  Map<String, DateTime> sectionsTime = {
    'A': null,
    'B': null,
    'C': null,
    'D': null,
  };

  Map<String, Timer> sectionsTimers = {
    'A': null,
    'B': null,
    'C': null,
    'D': null,
  };

  bool tapMode = false;
  double micSensitivity = 25;

  Map<String, bool> sectionsMic = {
    'A': true,
    'B': false,
    'C': false,
    'D': false,
  };

  bool hasConnection = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getState();
    Timer.periodic(Duration(seconds: 3), (timer) async {
      getState();
    });
  }

  getState() async {
    try {
      http.Response stateResponse = await http.get(host + 'relay/state');
      for (String relay in stateResponse.body.split(',')) {
        List<String> parts = relay.split(':');
        setState(() {
          sections[parts[0]] = parts[1] == "1" ? true : false;
        });
      }
      setState(() {
        hasConnection = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: !hasConnection,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: hasConnection ? 1 : 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text('Trafic',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Section(
                          color: sections["D"] ? Colors.green : Colors.black,
                          onTap: () {
                            toggleSection("D");
                          },
                        ),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Section(
                              color: sections["A"] ? Colors.red : Colors.black,
                              onTap: () {
                                toggleSection("A");
                              },
                            ),
                            Section(
                              color:
                                  sections["B"] ? Colors.yellow : Colors.black,
                              onTap: () {
                                toggleSection("B");
                              },
                            ),
                            Section(
                              color:
                                  sections["C"] ? Colors.green : Colors.black,
                              onTap: () {
                                toggleSection("C");
                              },
                            ),
                          ],
                        ),
                      ],
                    )),
                    SizedBox(
                      height: 40,
                    ),
                    FlatButton(
                      minWidth: 150,
                      onPressed: () {
                        switchToTrafic();
                      },
                      child: Text(
                        'Trafic mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      minWidth: 150,
                      onPressed: () {
                        setState(() {
                          tapMode = !tapMode;
                        });
                      },
                      child: Text(
                        'Tap mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: tapMode ? Colors.green : Colors.grey,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      minWidth: 150,
                      onPressed: () {
                        initMic();
                      },
                      child: Text(
                        'Mic mode ' + refSample.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      color: micStarted ? Colors.green : Colors.grey,
                    ),
                    AbsorbPointer(
                      absorbing: !Platform.isAndroid,
                      child: ExpansionTile(
                        onExpansionChanged: (state) async {
                          if (!state) {
                            return;
                          }
                          await Future.delayed(Duration(milliseconds: 500));
                          scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        },
                        title: Text(
                          'Mic Settings',
                          style: TextStyle(color: Colors.white),
                        ),
                        children: [
                          Slider(
                              value: micSensitivity,
                              min: 10,
                              max: 100,
                              onChanged: (newValue) {
                                setState(() {
                                  micSensitivity = newValue;
                                });
                              }),
                          Text(
                            micSensitivity.toStringAsPrecision(4),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  value: sectionsMic["A"],
                                  onChanged: (val) {
                                    setState(() {
                                      sectionsMic["A"] = !sectionsMic["A"];
                                    });
                                  },
                                  title: Text(
                                    "A",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                CheckboxListTile(
                                  value: sectionsMic["B"],
                                  onChanged: (val) {
                                    setState(() {
                                      sectionsMic["B"] = !sectionsMic["B"];
                                    });
                                  },
                                  title: Text(
                                    "B",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                CheckboxListTile(
                                  value: sectionsMic["C"],
                                  onChanged: (val) {
                                    setState(() {
                                      sectionsMic["C"] = !sectionsMic["C"];
                                    });
                                  },
                                  title: Text(
                                    "C",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                CheckboxListTile(
                                  value: sectionsMic["D"],
                                  onChanged: (val) {
                                    setState(() {
                                      sectionsMic["D"] = !sectionsMic["D"];
                                    });
                                  },
                                  title: Text(
                                    "D",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 1000),
              child: hasConnection
                  ? Container(
                      key: ValueKey(1),
                    )
                  : Container(
                      key: ValueKey(0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                          child: Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 80,
                      )),
                    ),
            )
          ],
        ),
      ),
    );
  }

  toggleSection(String section) async {
    if (tapMode) {
      if (sectionsTimers[section] != null) {
        sectionsTimers[section].cancel();
        sectionsTime[section] = null;
        sectionsTimers[section] = null;
        return;
      }

      if (sectionsTime[section] == null) {
        sectionsTime[section] = DateTime.now();
        return;
      }

      int delta = DateTime.now().millisecondsSinceEpoch -
          sectionsTime[section].millisecondsSinceEpoch;

      sectionsTimers[section] =
          Timer.periodic(Duration(milliseconds: delta), (timer) async {
        http.Response response;
        try {
          response = await http.get(host + 'relay/' + section);
        } catch (e) {
          print(e.toString());
        }
        if (response.body == "OK") {
          setState(() {
            sections[section] = !sections[section];
          });
        }
      });
    }

    http.Response response;
    try {
      response = await http.get(host + 'relay/' + section);
    } catch (e) {
      showError(e.toString());
    }

    if (response.body == "OK") {
      setState(() {
        sections[section] = !sections[section];
      });
    } else {
      showError(response.body);
    }
  }

  switchToTrafic() async {
    http.Response response;
    try {
      response = await http.get(host + 'relay/trafic');
    } catch (e) {
      showError(e.toString());
    }

    if (response.body == "OK") {
      setState(() {
        sections = {
          'A': false,
          'B': false,
          'C': false,
          'D': false,
        };
      });
      showDialog(
          context: context,
          child: CupertinoAlertDialog(
            title: Text('Выполнено'),
            content: Text('Переключение выполнено'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ));
    } else {
      showError(response.body);
    }
  }

  showError(String error) {
    showDialog(
        context: context,
        child: CupertinoAlertDialog(
          title: Text('Ошибка'),
          content: Text(error),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  bool micStarted = false;
  StreamSubscription<List<int>> listener;

  int refSample = 0;
  bool isEnabled = false;
  DateTime lastAction;

  void initMic() {
    if (micStarted) {
      setState(() {
        micStarted = false;
      });
      listener.cancel();
      return;
    }

    if (!Platform.isAndroid) {
      return showError("Available on Android only");
    }

    setState(() {
      micStarted = true;
    });
    print('start');

    Stream<List<int>> stream = microphone(sampleRate: 44100);
    listener = stream.listen((samples) {
      // print(DateTime.now());
      // int sample = samples[samples.length - 1];
      for (int sample in samples) {
        if (refSample == 0) {
          refSample = sample;
          return;
        }

        if (sample - refSample > micSensitivity && !isEnabled) {
          if (lastAction != null &&
              DateTime.now().millisecondsSinceEpoch -
                      lastAction.millisecondsSinceEpoch <
                  50) {
            continue;
          }
          isEnabled = true;
          print("Enable");
          for (String section in sectionsMic.keys.toList()) {
            if (!sectionsMic[section]) {
              continue;
            }

            toggleSection(section);
          }

          refSample = sample;
          lastAction = DateTime.now();
          setState(() {});
          continue;
        }

        if (sample < refSample - micSensitivity) {
          if (lastAction != null &&
              DateTime.now().millisecondsSinceEpoch -
                      lastAction.millisecondsSinceEpoch <
                  50) {
            continue;
          }
          isEnabled = false;
          print("Disable");
          refSample = sample;
          lastAction = DateTime.now();
          setState(() {});
        }
      }
    });
  }
}

class Section extends StatelessWidget {
  final Color color;
  final Function onTap;
  final Widget child;

  Section({this.color, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
