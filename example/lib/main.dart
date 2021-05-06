import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rammus/rammus.dart' as rammus;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion = 'Unknown';

  @override
  initState() {
    super.initState();
    initPlatformState();
    if (!Platform.isAndroid) {
      rammus.configureNotificationPresentationOption();
    }
    rammus.initCloudChannelResult.listen((data) {
      print(
          "----------->init successful ${data.isSuccessful} ${data.errorCode} ${data.errorMessage}");
    });
    var channels = <rammus.NotificationChannel>[];
    channels.add(rammus.NotificationChannel(
      "centralized_activity",
      "集中活动",
      "集中活动",
      importance: rammus.AndroidNotificationImportance.MAX,
    ));
    channels.add(rammus.NotificationChannel(
      "psychological_tests",
      "心理测评",
      "心理测评",
      importance: rammus.AndroidNotificationImportance.MAX,
    ));
    channels.add(rammus.NotificationChannel(
      "system_notice",
      "公告信息",
      "公告信息",
      importance: rammus.AndroidNotificationImportance.MAX,
    ));
    getDeviceId();
    rammus.setupNotificationManager(channels);

    rammus.onNotification.listen((data) {
      print("----------->notification here ${data.summary}");
      setState(() {
        _platformVersion = data.summary;
      });
    });
    rammus.onNotificationOpened.listen((data) {
      print("-----------> ${data.summary} 被点了");
      setState(() {
        _platformVersion = "${data.summary} 被点了";
      });
    });

    rammus.onNotificationRemoved.listen((data) {
      print("-----------> $data 被删除了");
    });

    rammus.onNotificationReceivedInApp.listen((data) {
      print("-----------> ${data.summary} In app");
    });

    rammus.onNotificationClickedWithNoAction.listen((data) {
      print("${data.summary} no action");
    });

    rammus.onMessageArrived.listen((data) {
      print("received data -> ${data.content}");
      setState(() {
        _platformVersion = data.content;
      });
    });
//    rammus.initCloudChannel( );
  }

  getDeviceId() async {
    var deviceId = await rammus.deviceId;
    print("deviceId:::$deviceId");
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      platformVersion = await Rammus.platformVersion;
//    } on PlatformException {
//      platformVersion = 'Failed to get platform version.';
//    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
