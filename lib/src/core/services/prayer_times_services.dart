import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:azkar/src/core/services/notifications_services.dart';
import 'package:azkar/src/injection_container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

class PrayerTimesService {
  static final PrayerTimesService _prayerTimesService =
      PrayerTimesService._internal();

  factory PrayerTimesService() {
    return _prayerTimesService;
  }
  PrayerTimesService._internal();

  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;
  DateTime? get nextPrayerTime => prayerTimes == null
      ? null
      : _prayerTimes!.timeForPrayer(prayerTimes!.nextPrayer());
  String get nextPrayerName =>
      prayerTimes == null ? '' : arabicName(prayerTimes!.nextPrayer().name);

  String arabicName(String name) {
    switch (name) {
      case "fajr":
        return "الفجر";
      case "sunrise":
        return "الشروق";
      case "dhuhr":
        return "الظهر";
      case "asr":
        return "العصر";
      case "maghrib":
        return "المغرب";
      case "isha":
        return "العشاء";
      default:
        return '';
    }
  }

  Future<void> initialPrayerTimes() async {
    final sh = sl<SharedPreferences>();
    if (_prayerTimes != null) return;
    await getLocationData().then((locationData) {
      if (locationData != null) {
        sh.setString('/location', jsonEncode(locationData.toJson()));
        _prayerTimes = PrayerTimes(
            Coordinates(locationData.latitude, locationData.longitude),
            DateComponents.from(DateTime.now()),
            CalculationMethod.egyptian.getParameters());
      } else {
        final locData = sh.getString('/location');
        if (locData == null) return;
        final loc = Position.fromMap(jsonDecode(locData));
        _prayerTimes = PrayerTimes(
            Coordinates(loc.latitude, loc.longitude),
            DateComponents.from(DateTime.now()),
            CalculationMethod.egyptian.getParameters());
      }
      if (sh.getBool('/prayer') ?? true) {
        // Workmanager().cancelAll();
        NotificationService().backgroundtask(_prayerTimes!);
      }
    });
  }

  Future<Position?> getLocationData() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
}
