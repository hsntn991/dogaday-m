import 'dart:async';

import 'package:geolocator/geolocator.dart';

class DeviceCoordinates {
  const DeviceCoordinates({
    required this.latitude,
    required this.longitude,
    this.label = 'Konumum',
    this.isApproximate = false,
  });

  final double latitude;
  final double longitude;
  final String label;
  final bool isApproximate;
}

class DeviceLocationException implements Exception {
  const DeviceLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DeviceLocationService {
  const DeviceLocationService._();

  static Future<DeviceCoordinates> requestCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const DeviceLocationException(
        'Cihazın konum servisi kapalı. Telefon ayarlarından konumu açıp tekrar dene.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const DeviceLocationException(
        'Konum izni verilmedi. Yakındaki yerleri gösterebilmemiz için izin vermen gerekiyor.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const DeviceLocationException(
        'Konum izni kalıcı olarak kapatılmış. Uygulama ayarlarından konum iznini aç.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
      return DeviceCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Konumum',
      );
    } on TimeoutException {
      throw const DeviceLocationException(
        'Konum isteği zaman aşımına uğradı. Açık bir alanda tekrar dene.',
      );
    } catch (_) {
      throw const DeviceLocationException(
        'Cihaz konumu alınamadı. Konum ve internet ayarlarını kontrol et.',
      );
    }
  }

  static Stream<DeviceCoordinates> watchPosition() =>
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).map(
        (position) => DeviceCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          label: 'Konumum',
        ),
      );
}
