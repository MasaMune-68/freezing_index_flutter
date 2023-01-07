import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezing_index_flutter/main.dart';
import 'package:freezing_index_flutter/models/weather.dart';
import 'package:freezing_index_flutter/show_weather.dart';
import '../get_current_weather.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'current_weather_page.dart';
import 'home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class FreezingIndexPage extends StatefulWidget {
  const FreezingIndexPage({super.key});

  @override
  State<FreezingIndexPage> createState() => _FreezingIndexPage();
}

class _FreezingIndexPage extends State<FreezingIndexPage> {
  @override
  void initState() {
    super.initState();
    _init();
    _requestPermissions();
  }

  Weather? _weather;
  String NotificationLevelText = '位置情報をONにすると表示されます';
  String NowLevelText = '位置情報をONにすると表示されます';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FutureBuilder<dynamic>(
      builder: (context, snapshot) {
        _weather = snapshot.data;
        if (snapshot.data == null) {
          //読み込み中 表示されない場合は...に変更する
          return const CircularProgressIndicator(
            color: Colors.blue,
          );
        } else {
          return weatherBox(_weather!);
        }
      },
      future: getCurrentWeather(),
    )));
  }

  Widget weatherBox(Weather weather) {
    notificationText(weather);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        margin: const EdgeInsets.all(20.0),
        child: const Text(
          '現在地の水道管凍結指数',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      Container(
        margin: const EdgeInsets.all(10.0),
        child: showLevelIcon(weather),
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: showLevelText(weather),
      ),
      Container(
          margin: const EdgeInsets.only(top: 40),
          child: FloatingActionButton.extended(
              icon: const Icon(Icons.notification_add),
              label: const Text('毎日21時に通知する',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('毎日21時に水道管凍結指数を通知しても良いですか?'),
                        content: const Text(
                            '\n※通知を行う際は、このアプリを終了しないようお願いします。\nアプリが終了してしまうと、天気情報を取得することができなくなります。\n必ずバックグラウンド状態にしておいてください。\n\n通知が届かない場合は「設定」からアプリの通知をオンにしてください。'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              final tz.TZDateTime now =
                                  tz.TZDateTime.now(tz.local);
                              _registerMessage(
                                hour: now.hour,
                                minutes: now.minute + 1,
                                message: NotificationLevelText,
                              );
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              })),
      Container(
        margin: const EdgeInsets.all(10.0),
        child: FloatingActionButton.extended(
            icon: const Icon(Icons.notifications_off),
            label: const Text('  通知をオフにする  ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('通知をオフにしても良いですか?'),
                      content: const Text('オフにした場合、毎日21時に通知が届かなくなります。'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelNotification();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  });
            }),
      ),
      Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
              icon: const Icon(Icons.help),
              label: const Text('凍結指数が表示されない場合',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        content: const Text(
                            '凍結指数が表示されない場合は\n「設定」からアプリの位置情報をオンにしてください。'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              })),
    ]);
  }

  // 1分ごとに定期実行
  Future<void> mainLoop() async {
    while (true) {
      await Future<void>.delayed(const Duration(minutes: 10));
      setState(() {
        getCurrentWeather();
        print('10分経ちました');
      });
    }
  }

  notificationText(Weather weather) {
    if (weather.low > 1.0) {
      return NotificationLevelText = '今夜は水道管凍結の心配はありません';
    } else if (weather.low > -1.0) {
      return NotificationLevelText = '今夜は水道管凍結の可能性があります';
    } else if (weather.low > -3.0) {
      return NotificationLevelText = '今夜は水道管凍結に注意です';
    } else if (weather.low > -5.0) {
      return NotificationLevelText = '今夜は水道管凍結に警戒です';
    } else if (weather.low > -6.0) {
      return NotificationLevelText = '今夜は水道管の破裂に注意です';
    }
  }

  Future<void> _init() async {
    await _configureLocalTimeZone();
    await _initializeNotification();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  Future<void> _initializeNotification() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _registerMessage({
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'トウケツライフ',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          styleInformation: BigTextStyleInformation(message),
          icon: '@mipmap/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
