// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

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
    try {
      return await _requestBrowserPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 25),
        maximumAge: Duration.zero,
      );
    } on DeviceLocationException catch (error) {
      if (error.message.contains('konum iznini reddetti')) rethrow;
    }

    try {
      return await _requestBrowserPosition(
        enableHighAccuracy: false,
        timeout: const Duration(seconds: 15),
        maximumAge: const Duration(minutes: 5),
      );
    } on DeviceLocationException {
      rethrow;
    }
  }

  static Future<DeviceCoordinates> _requestBrowserPosition({
    required bool enableHighAccuracy,
    required Duration timeout,
    required Duration maximumAge,
  }) async {
    try {
      final position =
          await html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: enableHighAccuracy,
        timeout: timeout,
        maximumAge: maximumAge,
      );
      final coordinates = position.coords;
      if (coordinates == null) {
        throw const DeviceLocationException('Konum bilgisi boş döndü.');
      }
      final latitude = coordinates.latitude?.toDouble();
      final longitude = coordinates.longitude?.toDouble();
      if (latitude == null || longitude == null) {
        throw const DeviceLocationException('Koordinatlar alınamadı.');
      }
      final accuracy = coordinates.accuracy?.toDouble();
      final isApproximate = accuracy == null || accuracy > 1000;
      return DeviceCoordinates(
        latitude: latitude,
        longitude: longitude,
        label: isApproximate ? 'Yaklaşık konum' : 'Konumum',
        isApproximate: isApproximate,
      );
    } on DeviceLocationException {
      rethrow;
    } on html.PositionError catch (error) {
      if (error.code == html.PositionError.PERMISSION_DENIED) {
        throw const DeviceLocationException(
          'Chrome konum iznini reddetti. Adres çubuğundaki site ayarlarından Konum iznini aç.',
        );
      }
      if (error.code == html.PositionError.POSITION_UNAVAILABLE) {
        throw const DeviceLocationException(
          'Windows konum hizmeti kapalı veya konum kaynağı bulunamadı. Windows Ayarlar > Gizlilik ve güvenlik > Konum bölümünü aç.',
        );
      }
      if (error.code == html.PositionError.TIMEOUT) {
        throw const DeviceLocationException(
          'Konum isteği zaman aşımına uğradı. Wi-Fi veya internet bağlantını kontrol edip tekrar dene.',
        );
      }
      throw DeviceLocationException(
        error.message ?? 'Tarayıcı konumu belirleyemedi.',
      );
    } catch (error) {
      throw const DeviceLocationException(
        'Tarayıcı konum servisine erişemedi. Sayfayı yenileyip tekrar dene.',
      );
    }
  }

  static Stream<DeviceCoordinates> watchPosition() =>
      html.window.navigator.geolocation
          .watchPosition(
            enableHighAccuracy: true,
            timeout: const Duration(seconds: 20),
            maximumAge: const Duration(seconds: 2),
          )
          .map(_coordinatesFromPosition)
          .where((coordinates) => coordinates != null)
          .cast<DeviceCoordinates>();

  static DeviceCoordinates? _coordinatesFromPosition(
    html.Geoposition position,
  ) {
    final latitude = position.coords?.latitude?.toDouble();
    final longitude = position.coords?.longitude?.toDouble();
    if (latitude == null || longitude == null) return null;
    final accuracy = position.coords?.accuracy?.toDouble();
    final isApproximate = accuracy == null || accuracy > 1000;
    return DeviceCoordinates(
      latitude: latitude,
      longitude: longitude,
      label: isApproximate ? 'Yaklaşık konum' : 'Konumum',
      isApproximate: isApproximate,
    );
  }
}
