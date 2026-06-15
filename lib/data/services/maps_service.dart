// File: lib/data/services/maps_service.dart
import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Disabled for web/FlutLab
import 'package:logger/logger.dart';
import '../models/sawah_model.dart';

/// Service untuk Google Maps integration
/// NOTE: Google Maps disabled on web/FlutLab - use simple list view instead
class MapsService {
  static final MapsService _instance = MapsService._internal();
  late Logger _logger;

  // Default location: Karawang, West Java
  // static const LatLng defaultKarawangLocation = LatLng(-6.3027, 107.3250);
  static const Map<String, double> defaultKarawangLocation = {
    'latitude': -6.3027,
    'longitude': 107.3250,
  };

  factory MapsService() {
    return _instance;
  }

  MapsService._internal() {
    _logger = Logger();
  }

  /// Convert SawahModel list ke Marker data untuk Google Maps
  /// NOTE: On web/FlutLab, returns simplified data structure instead of Marker objects
  List<Map<String, dynamic>> generateMarkersFromSawah(
      List<SawahModel> sawahList) {
    try {
      final markerData = <Map<String, dynamic>>[];

      for (var sawah in sawahList) {
        final markerInfo = {
          'id': sawah.id,
          'latitude': sawah.latitude,
          'longitude': sawah.longitude,
          'nama': sawah.nama,
          'luasHektar': sawah.luasHektar,
          'jenisTanaman': sawah.jenisTanaman,
          'umurTanamanHari': sawah.umurTanamanHari,
          'statusKesehatan': sawah.statusKesehatan,
          'snippet': _getMarkerSnippet(sawah),
          'color': _getMarkerColorValue(sawah.statusKesehatan),
        };

        markerData.add(markerInfo);
      }

      _logger.i('Generated ${markerData.length} marker data');
      return markerData;
    } catch (e) {
      _logger.e('Error generating markers: $e');
      return [];
    }
  }

  /// Get info snippet untuk marker
  String _getMarkerSnippet(SawahModel sawah) {
    return '''
Luas: ${sawah.luasHektar.toStringAsFixed(2)} ha
Jenis: ${sawah.jenisTanaman}
Umur: ${sawah.umurTanamanHari} hari
Status: ${sawah.statusKesehatan}''';
  }


  /// Get marker color value as string (for web/list view)
  String _getMarkerColorValue(String statusKesehatan) {
    switch (statusKesehatan) {
      case 'sehat':
        return '#4CAF50'; // Green
      case 'risiko':
        return '#FFC107'; // Orange
      case 'sakit':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Generate polygon data untuk visualisasi field boundary
  /// NOTE: On web/FlutLab, returns simplified polygon data instead of Polygon objects
  /// (Jika ada koordinat polygon dari GPS survey)
  List<Map<String, dynamic>> generatePolygonsFromSawah(
      List<SawahModel> sawahList) {
    try {
      final polygonData = <Map<String, dynamic>>[];

      for (var sawah in sawahList) {
        // Simple polygon: circle around center point
        final points = _generateCirclePointsData(
          sawah.latitude,
          sawah.longitude,
          radiusMeters: 200, // Estimasi 2 hektar
        );

        final color = _getPolygonColorValue(sawah.statusKesehatan);

        final polygonInfo = {
          'id': sawah.id,
          'latitude': sawah.latitude,
          'longitude': sawah.longitude,
          'radius': 200,
          'color': color,
          'opacity': 0.3,
          'points': points,
        };

        polygonData.add(polygonInfo);
      }

      _logger.i('Generated ${polygonData.length} polygon data');
      return polygonData;
    } catch (e) {
      _logger.e('Error generating polygons: $e');
      return [];
    }
  }

  /// Generate circle points untuk polygon (as list of coordinate pairs)
  List<Map<String, double>> _generateCirclePointsData(
    double centerLat,
    double centerLng, {
    required int radiusMeters,
  }) {
    const earthRadiusMeters = 6371000.0;
    const pointsCount = 36;

    final points = <Map<String, double>>[];

    for (int i = 0; i < pointsCount; i++) {
      final angle = (i / pointsCount) * 2 * 3.14159;

      final dy = radiusMeters * (1 / earthRadiusMeters);
      final dx = radiusMeters *
          (1 / earthRadiusMeters) /
          (1 + cos(centerLat.abs() * 3.14159 / 180));

      final lat = centerLat + (dy * (180 / 3.14159) * cos(angle));
      final lng = centerLng + (dx * (180 / 3.14159) * sin(angle));

      points.add({'latitude': lat, 'longitude': lng});
    }

    return points;
  }

  // Native-specific marker/polygon helper functions removed (not used on web/FlutLab)

  /// Get polygon color value as hex string
  String _getPolygonColorValue(String statusKesehatan) {
    switch (statusKesehatan) {
      case 'sehat':
        return '#4CAF50'; // Green
      case 'risiko':
        return '#FFC107'; // Amber
      case 'sakit':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Generate heatmap data untuk risk visualization
  /// Menampilkan area dengan risiko tinggi
  /// NOTE: On web/FlutLab, returns simplified heatmap data
  List<Map<String, dynamic>> generateHeatmapCircles(
      List<SawahModel> sawahList) {
    try {
      final heatmapData = <Map<String, dynamic>>[];

      for (var sawah in sawahList) {
        if (sawah.skorRisiko > 50) {
          final circleInfo = {
            'id': 'heatmap_${sawah.id}',
            'latitude': sawah.latitude,
            'longitude': sawah.longitude,
            'radius': 300, // 300m radius
            'fillColor': '#FF6B6B',
            'opacity': 0.3,
            'skorRisiko': sawah.skorRisiko,
          };

          heatmapData.add(circleInfo);
        }
      }

      _logger.i('Generated ${heatmapData.length} heatmap circles');
      return heatmapData;
    } catch (e) {
      _logger.e('Error generating heatmap: $e');
      return [];
    }
  }

  /// Calculate bounds untuk auto-zoom pada set locations
  /// Returns map with bounds info (not CameraUpdateOptions which requires native)
  Map<String, double>? calculateZoomBounds(
      List<Map<String, double>> locations) {
    if (locations.isEmpty) return null;

    try {
      double minLat = locations.first['latitude'] ?? 0;
      double maxLat = locations.first['latitude'] ?? 0;
      double minLng = locations.first['longitude'] ?? 0;
      double maxLng = locations.first['longitude'] ?? 0;

      for (var location in locations) {
        final lat = location['latitude'] ?? 0;
        final lng = location['longitude'] ?? 0;
        minLat = (lat < minLat) ? lat : minLat;
        maxLat = (lat > maxLat) ? lat : maxLat;
        minLng = (lng < minLng) ? lng : minLng;
        maxLng = (lng > maxLng) ? lng : maxLng;
      }

      final bounds = {
        'minLat': minLat,
        'maxLat': maxLat,
        'minLng': minLng,
        'maxLng': maxLng,
        'centerLat': (minLat + maxLat) / 2,
        'centerLng': (minLng + maxLng) / 2,
      };

      _logger.i('Calculated zoom bounds: $bounds');
      return bounds;
    } catch (e) {
      _logger.e('Error calculating bounds: $e');
      return null;
    }
  }

  /// Calculate distance antara dua koordinat (dalam meter)
  double calculateDistance(
      double fromLat, double fromLng, double toLat, double toLng) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _toRadians(toLat - fromLat);
    final dLng = _toRadians(toLng - fromLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) *
            sin(dLng / 2) *
            cos(_toRadians(fromLat)) *
            cos(_toRadians(toLat));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusMeters * c;

    return distance;
  }

  /// Convert degrees ke radians
  double _toRadians(double degrees) {
    return degrees * (3.14159 / 180);
  }

  /// Get list sawah dalam radius tertentu
  List<SawahModel> getNearestSawah(
    List<SawahModel> sawahList,
    double userLat,
    double userLng,
    double radiusKm,
  ) {
    try {
      final radiusMeters = radiusKm * 1000;

      final nearestSawah = sawahList.where((sawah) {
        final distance = calculateDistance(
          userLat,
          userLng,
          sawah.latitude,
          sawah.longitude,
        );
        return distance <= radiusMeters;
      }).toList();

      // Sort by distance
      nearestSawah.sort((a, b) {
        final distA =
            calculateDistance(userLat, userLng, a.latitude, a.longitude);
        final distB =
            calculateDistance(userLat, userLng, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      _logger.i('Found ${nearestSawah.length} sawah within ${radiusKm}km');
      return nearestSawah;
    } catch (e) {
      _logger.e('Error getting nearest sawah: $e');
      return [];
    }
  }

  /// Generate street view URL untuk location tertentu
  String getStreetViewUrl(double latitude, double longitude, {String? apiKey}) {
    return 'https://maps.googleapis.com/maps/api/streetview?size=400x300&location=$latitude,$longitude&key=${apiKey ?? "YOUR_API_KEY"}';
  }

  /// Generate map static image URL
  String getStaticMapUrl(
    List<Map<String, double>> locations, {
    String? apiKey,
    int width = 400,
    int height = 300,
  }) {
    String markerString = '';
    for (var location in locations) {
      final lat = location['latitude'] ?? 0;
      final lng = location['longitude'] ?? 0;
      markerString += 'markers=color:red|$lat,$lng&';
    }

    return 'https://maps.googleapis.com/maps/api/staticmap?size=${width}x$height&${markerString}key=${apiKey ?? "YOUR_API_KEY"}';
  }
}
