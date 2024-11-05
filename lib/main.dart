import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:azkar/src/core/services/notifications_services.dart';
import 'package:azkar/src/core/services/prayer_times_services.dart';
// import 'package:azkar/src/features/quran/presentation/widgets/audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';
import 'src/app.dart';
import 'src/injection_container.dart' as di;
import 'package:timezone/data/latest_all.dart' as tz;

@pragma('vm:entry-point')
void setPrayerTimes() {
  final prayerServ = PrayerTimesService();
  prayerServ.initialPrayerTimes();
}

final notiService = NotificationService();
final prayerService = PrayerTimesService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  initialBgTaska();
  runApp(const MyApp());
}

Future<void> initialBgTaska() async {
  final sh = di.sl<SharedPreferences>();
  bool? prayerOn = sh.getBool('/prayer');
  bool? salyOn = sh.getBool('/saly');
  if (prayerOn == null) {
    prayerOn = true;
    sh.setBool('/prayer', true);
  }
  if (salyOn == null) {
    salyOn = true;
    sh.setBool('/saly', true);
  }
  //
  if (prayerOn || salyOn) {
    await notiService.initializenotification();
  }
  //
  if (salyOn) {
    notiService.schedulePrayOnMuhammedNotification();
  } else {
    notiService.cancelSalyNotifier();
  }
  if (prayerOn) {
    tz.initializeTimeZones();
    if (Platform.isAndroid) {
      AndroidAlarmManager.periodic(
        const Duration(hours: 24), //repeat daily
        0, // alarm ID
        setPrayerTimes, //callback method
        exact: true,
        wakeup: true,
      );
    }
  } else {
    notiService.cancelPrayerNotifier();
  }
  //
  // Workmanager().executeTask((task, inputData) async {
//   try {

//   } catch (e) {
//     debugPrint(e.toString());
//   }

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final player = AudioP.player;
//     player.open(Audio('assets/adhan.wav'),
//         autoStart: true,
//         forceOpen: true,
//         loopMode: LoopMode.none,
//         respectSilentMode: false,
//         showNotification: false,
//         playInBackground: PlayInBackground.enabled);
//     return Future.value(true);
//   });
// }
}
