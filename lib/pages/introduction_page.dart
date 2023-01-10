import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Tutorial extends ConsumerStatefulWidget {
  const Tutorial({Key? key}) : super(key: key);

  @override
  TutorialCoachMarkExampleState createState() =>
      TutorialCoachMarkExampleState();
}

class TutorialCoachMarkExampleState extends ConsumerState<Tutorial> {
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  //チュートリアル画面のシーンを抽出するためのキー
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();
  final GlobalKey key3 = GlobalKey();
  final GlobalKey key4 = GlobalKey();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String LevelText = '位置情報をONにすると表示されます';

  @override
  void initState() {
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback(_layout);
    super.initState();
  }

  //1秒後にチュートリアル画面を表示する
  void _layout(_) {
    Future.delayed(const Duration(seconds: 1), () {
      showTutorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              title: const Text('トウケツライフ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              automaticallyImplyLeading: false,
            )),
        bottomNavigationBar: BottomNavigationBar(
          key: key4,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.ac_unit), label: '水道管凍結指数'),
            BottomNavigationBarItem(
                icon: Icon(Icons.my_location), label: '天気情報'),
          ],
          fixedColor: Colors.blue,
        ),
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10.0),
            child: const Text(
              '現在地の水道管凍結指数',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
            key: key1,
            margin: const EdgeInsets.all(10.0),
            child: Image.asset('images/level_4.png', scale: 2.3),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: const Text('現在、水道管凍結に注意です', style: TextStyle(fontSize: 15)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: FloatingActionButton.extended(
                key: key2,
                heroTag: "hero01",
                icon: const Icon(Icons.notification_add),
                label: const Text('毎日21時に通知する',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {}),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: FloatingActionButton.extended(
                key: key3,
                heroTag: "hero02",
                icon: const Icon(Icons.notifications_off),
                label: const Text('  通知をオフにする  ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {}),
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  icon: const Icon(Icons.help),
                  label: const Text(' 通知が届かない場合 ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
        ])));
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        color: Colors.blue, // マスクカラー。デフォルトは赤
        keyTarget: key1, // ターゲットキーを指定
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // ターゲットウィジェットのどちら側にチュートリアルを出すか
            builder: (context, controller) {
              return Container(
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "現在地の水道管凍結指数が \n表示されます",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "水道管凍結指数は、現在地の気温をもとに導き出しています。\n方角や風の計算はしていませんので、あくまで参考までに。",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        color: Colors.blue,
        keyTarget: key2,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "毎日21時に水道管凍結指数を\nお知らせします",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "通知を見るだけで、今夜の水抜きが必要かどうか確認できます。 \n水抜き忘れの防止にもなるのでおすすめです。\n\n※通知を行う際は、このアプリを終了しないようお願いします。\nアプリが終了してしまうと、天気情報を取得することができなくなります。\n必ずバックグラウンド状態にしておいてください。",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white),
                        onPressed: () {
                          controller.previous(); // 「チュートリアル戻る」ボタン
                        },
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    targets.add(
      TargetFocus(
        color: Colors.blue,
        keyTarget: key3,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "水抜きの必要がない時期になったら\n通知をオフにすることができます",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "水抜きの季節になったら再度通知をオンにしてくださいね。",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white),
                        onPressed: () {
                          controller.previous();
                        },
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );

    targets.add(
      TargetFocus(
        color: Colors.blue,
        keyTarget: key4,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "現在地の天気情報も見ることができます",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "天気情報も合わせて確認してみてください！\n\nこの後表示される、位置情報と通知の許可は、必ずオンにしていただくようお願いいたします。",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white),
                        onPressed: () {
                          controller.previous();
                        },
                        child: const Icon(Icons.chevron_left),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 10,
      ),
    );
  }

  void showTutorial() async {
    tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        textSkip: "SKIP",
        paddingFocus: 10,
        opacityShadow: 0.9,
        onSkip: () async {
          Navigator.pushNamed(context, '/first');
        },
        onFinish: () {
          Navigator.pushNamed(context, '/first');
        })
      ..show(context: context);
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
  }
}
