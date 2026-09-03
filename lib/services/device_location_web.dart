// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:http/http.dart' as http;

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
    DeviceLocationException? browserError;

    try {
      return await _requestBrowserPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 14),
        maximumAge: Duration.zero,
      );
    } on DeviceLocationException catch (error) {
      browserError = error;
    }

    try {
      return await _requestBrowserPosition(
        enableHighAccuracy: false,
        timeout: const Duration(seconds: 7),
        maximumAge: const Duration(seconds: 30),
      );
    } on DeviceLocationException catch (error) {
      browserError = error;
    }

    try {
      return await _requestApproximateIpPosition();
    } catch (_) {
      throw DeviceLocationException(
        '${browserError.message} '
        'İnternet üzerinden yaklaşık konum da alınamadı.',
      );
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
        label: isApproximate ? 'Yaklaşık konum' : 'Mevcut konum',
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

  static Future<DeviceCoordinates> _requestApproximateIpPosition() async {
    final response = await http
        .get(Uri.https('ipwho.is', '/'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw const DeviceLocationException(
        'Yaklaşık konum servisine ulaşılamadı.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == false) {
      throw DeviceLocationException(
        data['message']?.toString() ?? 'Yaklaşık konum bulunamadı.',
      );
    }

    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw const DeviceLocationException(
        'Yaklaşık konum koordinatları alınamadı.',
      );
    }

    final city = data['city']?.toString().trim();
    final region = data['region']?.toString().trim();
    final label = city != null && city.isNotEmpty
        ? city
        : region != null && region.isNotEmpty
            ? region
            : 'Yaklaşık konum';

    return DeviceCoordinates(
      latitude: latitude,
      longitude: longitude,
      label: label,
      isApproximate: true,
    );
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
      label: isApproximate ? 'Yaklaşık konum' : 'Mevcut konum',
      isApproximate: isApproximate,
    );
  }
}
