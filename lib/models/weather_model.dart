class WeatherForecast {
  final DateTime? dateTime;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int cloudCover;
  final String visibility;
  final String description;
  final String? imageUrl;

  double? get windDirectionDegrees {
    final raw = windDirection.trim().toUpperCase();
    final numeric = double.tryParse(raw);

    if (numeric != null && numeric >= 0 && numeric <= 360) {
      return numeric;
    }

    const degrees = <String, double>{
      'N': 0,
      'NNE': 22.5,
      'NE': 45,
      'ENE': 67.5,
      'E': 90,
      'ESE': 112.5,
      'SE': 135,
      'SSE': 157.5,
      'S': 180,
      'SSW': 202.5,
      'SW': 225,
      'WSW': 247.5,
      'W': 270,
      'WNW': 292.5,
      'NW': 315,
      'NNW': 337.5,
    };

    return degrees[raw];
  }

  String get windDirectionLabel {
    final degrees = windDirectionDegrees;

    if (degrees == null) {
      return windDirection == '-' ? 'Tidak tersedia' : windDirection;
    }

    const directions = [
      'Utara',
      'Timur laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat daya',
      'Barat',
      'Barat laut',
    ];

    final index = (((degrees % 360) + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  String get windDirectionDisplay {
    final degrees = windDirectionDegrees;

    if (degrees == null) return windDirectionLabel;

    return '${degrees.round() % 360}° · $windDirectionLabel';
  }

  String get windDirectionToLabel {
    final degrees = windDirectionDegrees;

    if (degrees == null) return 'Arah tujuan tidak tersedia';

    final destination = (degrees + 180) % 360;
    const directions = [
      'Utara',
      'Timur laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat daya',
      'Barat',
      'Barat laut',
    ];

    final index = ((destination + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  String get visibilityDescription {
    final value = visibility.trim();

    if (value.isEmpty || value == '-') {
      return 'Data jarak pandang tidak tersedia';
    }

    final normalized = value.toLowerCase();

    if (normalized.contains('km') ||
        normalized.contains('meter') ||
        normalized.contains(' m')) {
      return 'Jarak pandang mendatar';
    }

    return 'Nilai asli dari data BMKG';
  }

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCover,
    required this.visibility,
    required this.description,
    this.imageUrl,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse('$value') ?? 0;
    }

    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse('$value') ?? 0;
    }

    final image = json['image'];
    String? imageUrl;

    if (image is Map) {
      imageUrl = image['url']?.toString();
    } else if (image is String) {
      imageUrl = image;
    }

    return WeatherForecast(
      dateTime: DateTime.tryParse(
        '${json['local_datetime'] ?? json['datetime'] ?? ''}',
      ),
      temperature: toDouble(json['t']),
      humidity: toInt(json['hu']),
      windSpeed: toDouble(json['ws']),
      windDirection: '${json['wd'] ?? '-'}',
      cloudCover: toInt(json['tcc']),
      visibility: '${json['vs_text'] ?? '-'}',
      description:
          '${json['weather_desc'] ?? json['weather_desc_en'] ?? 'Tidak diketahui'}',
      imageUrl: imageUrl,
    );
  }
}

class WeatherResponse {
  final String city;
  final String village;
  final List<WeatherForecast> forecasts;

  WeatherResponse({
    required this.city,
    required this.village,
    required this.forecasts,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final location = json['lokasi'] is Map
        ? Map<String, dynamic>.from(json['lokasi'] as Map)
        : <String, dynamic>{};

    final dataList = json['data'] is List ? json['data'] as List : <dynamic>[];

    final List<WeatherForecast> forecasts = [];

    // API BMKG dapat mengelompokkan prakiraan
    // dalam beberapa daftar berdasarkan hari.
    void collectForecasts(dynamic value) {
      if (value is List) {
        for (final item in value) {
          collectForecasts(item);
        }
      } else if (value is Map) {
        final item = Map<String, dynamic>.from(value);

        if (item.containsKey('t') &&
            (item.containsKey('local_datetime') ||
                item.containsKey('datetime'))) {
          forecasts.add(WeatherForecast.fromJson(item));
        } else if (item.containsKey('cuaca')) {
          collectForecasts(item['cuaca']);
        }
      }
    }

    collectForecasts(dataList);

    return WeatherResponse(
      city: '${location['kotkab'] ?? 'Kota Malang'}',
      village: '${location['desa'] ?? 'Lowokwaru'}',
      forecasts: forecasts,
    );
  }
}
