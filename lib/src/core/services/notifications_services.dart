import 'dart:convert';
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:azkar/src/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:workmanager/workmanager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  final sh = sl<SharedPreferences>();
  NotificationService._internal();
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint(title! + body!);
    final player = AssetsAudioPlayer();
    player.open(Audio('assets/adhan.wav'),
        autoStart: true,
        forceOpen: true,
        loopMode: LoopMode.none,
        playInBackground: PlayInBackground.enabled);
  }

  Future<void> initializenotification() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  backgroundtask(PrayerTimes value) {
    final currenttime = DateTime.now();
    if (value.fajr.toLocal().isAfter(currenttime)) {
      _schedulePrayerTimeNotification(value.fajr.toLocal(), 'الفجر');
    }
    if (value.dhuhr.toLocal().isAfter(currenttime)) {
      _schedulePrayerTimeNotification(value.dhuhr.toLocal(), 'الظهر');
    }

    if (value.asr.toLocal().isAfter(currenttime)) {
      _schedulePrayerTimeNotification(value.asr.toLocal(), 'العصر');
    }

    if (value.maghrib.toLocal().isAfter(currenttime)) {
      _schedulePrayerTimeNotification(value.maghrib.toLocal(), 'المغرب');
    }

    if (value.isha.toLocal().isAfter(currenttime)) {
      _schedulePrayerTimeNotification(value.isha.toLocal(), 'العشاء');
    }
  }

  Future<void> cancelPrayerNotifier() async {
    flutterLocalNotificationsPlugin.cancelAll();
    AndroidAlarmManager.cancel(0);
    // Workmanager().cancelAll();
  }

  Future<void> cancelSalyNotifier() async {
    flutterLocalNotificationsPlugin.cancel('saly'.hashCode);
  }

  Future<void> schedulePrayOnMuhammedNotification() async {
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentSound: true,
      sound: 'saly.wav',
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
    );
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('secondary_channel', 'Secondary Channel',
            channelDescription: "saly",
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('saly'));

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      'saly'.hashCode,
      'الصلاة على النبي ﷺ',
      'إِنَّ اللَّهَ وَمَلائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
      RepeatInterval.hourly,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _schedulePrayerTimeNotification(
      DateTime prayerTime, String prayerName) async {
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentSound: true,
      sound: 'adhan.wav',
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
    );

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: "adan",
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan'));

    const NotificationDetails notificationDetails2 = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    final formattedTime = DateFormat('h:mm a').format(prayerTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'وقت صلاة $prayerName',
      'حان الأن موعد أذان $prayerName, $formattedTime',
      tz.TZDateTime.from(prayerTime, tz.local),
      notificationDetails2,
      payload: Platform.isIOS
          ? jsonEncode({
              'aps': {
                'alert': "Adhan Alert",
                'sound': "adhan.wav",
              }
            })
          : null,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    // Workmanager()
    //     .registerOneOffTask(
    //   prayerName,
    //   "Pray Task",
    //   tag: prayerName.hashCode.toString(),
    //   initialDelay: Duration(
    //       seconds: tz.TZDateTime.from(prayerTime, tz.local)
    //           .difference(DateTime.now())
    //           .inSeconds),
    // )
    //     .then((value) {
    //   debugPrint(
    //       'Done $prayerName ${tz.TZDateTime.from(prayerTime, tz.local).difference(DateTime.now()).inSeconds} + SD');
    // });
  }
}


//Notification Befor prayer
  // const AndroidNotificationDetails androidNotificationDetails =
  //     AndroidNotificationDetails(
  //   'main_channel',
  //   'Main Channel',
  //   channelDescription: "ashwin",
  //   importance: Importance.max,
  //   priority: Priority.max,
  //   playSound: true,
  // );

  ///Add Darwin Details
  // const NotificationDetails notificationDetails1 = NotificationDetails(
  //     android: androidNotificationDetails, iOS: iosNotificationDetails);
  // await FlutterLocalNotificationsPlugin().zonedSchedule(
  //   prayerName.hashCode,
  //   prayerName,
  //   'حان وقت أذان الـ $prayerName بعد ${DateTime.now().difference(prayerTime).inMinutes} دقائق.',
  //   tz.TZDateTime.from(
  //       prayerTime.subtract(const Duration(minutes: 5)), tz.local),
  //   notificationDetails1,
  //   androidAllowWhileIdle: true, //to show notification when app is closed
  //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime,
  // );

  ////
  ///
  ///