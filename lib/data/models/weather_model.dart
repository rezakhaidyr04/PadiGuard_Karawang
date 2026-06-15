/// Weather Data Model
class WeatherModel {
  final String id;
  final double latitude;
  final double longitude;
  final double temperature; // in Celsius
  final double feelsLike;
  final int humidity; // percentage
  final int pressure; // hPa
  final double windSpeed; // m/s
  final double windDegree; // degrees
  final double cloudiness; // percentage
  final double? rainVolume; // mm (nullable if no rain)
  final String description; // e.g., "Scattered clouds"
  final String main; // e.g., "Clouds"
  final String icon; // icon code from API
  final double visibility; // meters
  final int sunrise; // unix timestamp
  final int sunset; // unix timestamp
  final double uvIndex;
  final DateTime timestamp;
  final String location; // e.g., "Karawang, Jawa Barat"

  WeatherModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDegree,
    required this.cloudiness,
    this.rainVolume,
    required this.description,
    required this.main,
    required this.icon,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.timestamp,
    required this.location,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      id: json['id']?.toString() ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      temperature: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: json['humidity'] as int,
      pressure: json['pressure'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      windDegree: (json['wind_deg'] as num?)?.toDouble() ?? 0.0,
      cloudiness: (json['clouds'] as num).toDouble(),
      rainVolume: (json['rain'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      main: json['main'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sunrise'] as int? ?? 0,
      sunset: json['sunset'] as int? ?? 0,
      uvIndex: (json['uvi'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      location: json['location'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': latitude,
      'lon': longitude,
      'temp': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'wind_speed': windSpeed,
      'wind_deg': windDegree,
      'clouds': cloudiness,
      'rain': rainVolume,
      'description': description,
      'main': main,
      'icon': icon,
      'visibility': visibility,
      'sunrise': sunrise,
      'sunset': sunset,
      'uvi': uvIndex,
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      'location': location,
    };
  }

  WeatherModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? temperature,
    double? feelsLike,
    int? humidity,
    int? pressure,
    double? windSpeed,
    double? windDegree,
    double? cloudiness,
    double? rainVolume,
    String? description,
    String? main,
    String? icon,
    double? visibility,
    int? sunrise,
    int? sunset,
    double? uvIndex,
    DateTime? timestamp,
    String? location,
  }) {
    return WeatherModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      windSpeed: windSpeed ?? this.windSpeed,
      windDegree: windDegree ?? this.windDegree,
      cloudiness: cloudiness ?? this.cloudiness,
      rainVolume: rainVolume ?? this.rainVolume,
      description: description ?? this.description,
      main: main ?? this.main,
      icon: icon ?? this.icon,
      visibility: visibility ?? this.visibility,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      uvIndex: uvIndex ?? this.uvIndex,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
    );
  }
}
