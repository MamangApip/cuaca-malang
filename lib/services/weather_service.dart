import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String apiUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=35.73.05.1011';

  Future<WeatherResponse> fetchWeather() async {
    final uri = Uri.parse(apiUrl);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data BMKG. '
        'Kode HTTP: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format JSON dari BMKG tidak sesuai.');
    }

    final result = WeatherResponse.fromJson(decoded);

    if (result.forecasts.isEmpty) {
      throw Exception(
        'Data prakiraan tidak ditemukan dalam respons BMKG.',
      );
    }

    return result;
  }
}
