import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();

  late Future<WeatherResponse> _weatherFuture;
  Timer? _clockTimer;
  Timer? _weatherTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWeather();

    // Jam pada layar diperbarui setiap menit.
    _clockTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });
        }
      },
    );

    // Data BMKG dimuat ulang berkala agar tidak terus memakai data lama.
    _weatherTimer = Timer.periodic(
      const Duration(hours: 3),
      (_) {
        if (mounted) {
          _refreshWeather();
        }
      },
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  void _loadWeather() {
    _weatherFuture = _service.fetchWeather();
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _now = DateTime.now();
      _loadWeather();
    });

    try {
      await _weatherFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  bool _isNight() => _now.hour < 5 || _now.hour >= 18;

  bool _isMorning() => _now.hour >= 5 && _now.hour < 10;

  bool _isAfternoon() => _now.hour >= 10 && _now.hour < 15;

  bool _isEvening() => _now.hour >= 15 && _now.hour < 18;

  bool _isRainy(String description) {
    final text = description.toLowerCase();
    return text.contains('rain') ||
        text.contains('hujan') ||
        text.contains('thunder') ||
        text.contains('petir');
  }

  bool _isCloudy(String description) {
    final text = description.toLowerCase();
    return text.contains('cloud') ||
        text.contains('berawan') ||
        text.contains('overcast') ||
        text.contains('mendung');
  }

  String _weatherIcon(String description) {
    final text = description.toLowerCase();

    if (text.contains('thunder') || text.contains('petir')) {
      return '⛈️';
    }
    if (text.contains('rain') || text.contains('hujan')) {
      return '🌧️';
    }
    if (text.contains('fog') || text.contains('kabut')) {
      return '🌫️';
    }
    if (_isCloudy(description)) {
      return '☁️';
    }
    if (text.contains('clear') || text.contains('cerah')) {
      return '☀️';
    }
    return '🌤️';
  }

  LinearGradient _background(String description) {
    // Malam diprioritaskan agar langit tetap bernuansa navy.
    if (_isNight()) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF25264F),
          Color(0xFF1B2549),
          Color(0xFF111D3B),
          Color(0xFF080F24),
        ],
      );
    }

    // Pagi dan sore tetap memiliki warna khas meskipun berawan/hujan.
    if (_isMorning()) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFC58B),
          Color(0xFFFFAA85),
          Color(0xFFEF9E9A),
          Color(0xFF536F9B),
          Color(0xFF243B60),
        ],
        stops: [0.0, 0.23, 0.45, 0.72, 1.0],
      );
    }

    if (_isEvening()) {
      return const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFFFAD76),
          Color(0xFFFF906F),
          Color(0xFFE9848C),
          Color(0xFF625A88),
          Color(0xFF24304F),
        ],
        stops: [0.0, 0.25, 0.48, 0.76, 1.0],
      );
    }

    // Pada siang hari, hujan memakai warna yang lebih teduh.
    if (_isRainy(description)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF526D85),
          Color(0xFF304B68),
          Color(0xFF172B46),
          Color(0xFF101D35),
        ],
      );
    }

    if (_isCloudy(description)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF76B8E1),
          Color(0xFF5197CC),
          Color(0xFF326FA7),
          Color(0xFF1D456F),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF72C7F4),
        Color(0xFF48A9E5),
        Color(0xFF3287C7),
        Color(0xFF245D96),
      ],
    );
  }

  String _timeLabel(DateTime? dateTime) {
    if (dateTime == null) return '--:--';

    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _dateLabel(DateTime? dateTime) {
    if (dateTime == null) return 'Waktu tidak tersedia';

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${days[dateTime.weekday - 1]}, '
        '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  // Dekorasi langit berubah mengikuti waktu HP.
  Widget _skyDecoration(String description) {
    final night = _isNight();
    final rainy = _isRainy(description);
    final cloudy = _isCloudy(description);

    double sunLeft = 0;
    double sunRight = 0;
    double sunTop = 75;
    Color sunColor = const Color(0xFFFFD34E);
    double sunSize = 76;

    if (_isMorning()) {
      sunLeft = 28;
      sunTop = 112;
      sunColor = const Color(0xFFFFA65C);
      sunSize = 66;
    } else if (_isAfternoon()) {
      sunRight = 0;
      sunTop = 76;
      sunColor = const Color(0xFFFFE36A);
      sunSize = 78;
    } else if (_isEvening()) {
      sunRight = 28;
      sunTop = 116;
      sunColor = const Color(0xFFFF9A5A);
      sunSize = 70;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            children: [
              if (night) ...[
                const Positioned(
                  top: 85,
                  right: 42,
                  child: Icon(
                    Icons.nightlight_round,
                    color: Color(0xFFFFF0C4),
                    size: 43,
                  ),
                ),
                ...[
                  const Offset(32, 94),
                  const Offset(91, 145),
                  const Offset(300, 112),
                  const Offset(255, 62),
                  const Offset(330, 200),
                  const Offset(48, 230),
                  const Offset(270, 255),
                  const Offset(140, 75),
                  const Offset(190, 185),
                  const Offset(120, 250),
                  const Offset(215, 120),
                ].map(
                  (point) => Positioned(
                    left: point.dx,
                    top: point.dy,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],

              // Matahari berpindah sesuai waktu.
              if (!night && !rainy && !cloudy)
                Positioned(
                  top: sunTop,
                  left: _isMorning() ? sunLeft : null,
                  right: _isMorning() ? null : sunRight,
                  child: Container(
                    width: sunSize,
                    height: sunSize,
                    decoration: BoxDecoration(
                      color: sunColor.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: sunColor.withOpacity(0.4),
                          blurRadius: 38,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),

              // Matahari masih dapat terlihat samar di balik awan.
              if (!night && !rainy && cloudy)
                Positioned(
                  top: _isMorning() ? 115 : 82,
                  left: _isMorning() ? 30 : null,
                  right: _isMorning() ? null : 35,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD98B).withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              if (cloudy || rainy) ...[
                Positioned(
                  top: 75,
                  right: 18,
                  child: Icon(
                    Icons.cloud,
                    size: 110,
                    color: Colors.white.withOpacity(0.23),
                  ),
                ),
                Positioned(
                  top: 123,
                  left: 8,
                  child: Icon(
                    Icons.cloud,
                    size: 78,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                Positioned(
                  top: 170,
                  right: 80,
                  child: Icon(
                    Icons.cloud,
                    size: 70,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ],

              // Kabut warna tipis untuk menyatukan area atas dan bawah.
              Positioned(
                top: 175,
                left: -70,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      night ? 0.025 : 0.06,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadiusGeometry radius = const BorderRadius.all(Radius.circular(24)),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String value, {
    String? subtitle,
  }) {
    return _glassCard(
      padding: const EdgeInsets.all(15),
      radius: BorderRadius.circular(23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD5EBFF),
            size: 23,
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 11,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _errorView(Object error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF25264F),
            Color(0xFF080F24),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white70,
                size: 56,
              ),
              const SizedBox(height: 18),
              const Text(
                'Cuaca belum dapat dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _refreshWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D35),
      body: FutureBuilder<WeatherResponse>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: _background(''),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Mengambil data cuaca BMKG...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _errorView(snapshot.error!);
          }

          final data = snapshot.data;

          if (data == null || data.forecasts.isEmpty) {
            return const Center(
              child: Text(
                'Data cuaca belum tersedia.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final forecasts = [...data.forecasts]..sort((a, b) {
              if (a.dateTime == null && b.dateTime == null) {
                return 0;
              }
              if (a.dateTime == null) return 1;
              if (b.dateTime == null) return -1;
              return a.dateTime!.compareTo(b.dateTime!);
            });

          int currentIndex = -1;

          for (int i = 0; i < forecasts.length; i++) {
            final forecastTime = forecasts[i].dateTime;

            if (forecastTime != null && !forecastTime.isAfter(_now)) {
              currentIndex = i;
            }
          }

          // Jika semua slot masih di masa depan, gunakan slot terdekat.
          if (currentIndex == -1) {
            currentIndex = forecasts.indexWhere(
              (forecast) => forecast.dateTime != null,
            );

            if (currentIndex == -1) {
              currentIndex = 0;
            }
          }

          final current = forecasts[currentIndex];
          final gradient = _background(current.description);

          final forecastCount = (forecasts.length - currentIndex) > 24
              ? 24
              : forecasts.length - currentIndex;

          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: RefreshIndicator(
              color: const Color(0xFFB7DDFB),
              backgroundColor: const Color(0xFF192B49),
              onRefresh: _refreshWeather,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 390,
                    elevation: 0,
                    backgroundColor: _isNight()
                        ? const Color(0xFF192B49)
                        : const Color(0xFF527FA5),
                    foregroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    title: const Text(
                      'Cuaca',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.4,
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Muat ulang cuaca',
                        onPressed: _refreshWeather,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      const SizedBox(width: 6),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: gradient,
                            ),
                          ),
                          _skyDecoration(current.description),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                76,
                                24,
                                15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    data.city,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 29,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    data.village,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.82),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    '${current.temperature.round()}°',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 91,
                                      height: 1.05,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: -5,
                                    ),
                                  ),
                                  Text(
                                    current.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sekarang · ${_timeLabel(_now)} WIB',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.18),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                        color: Color(0xFFD5EBFF),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${data.city}, Jawa Timur',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prakiraan mulai dari waktu yang paling relevan.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Prakiraan per 3 jam',
                            'Waktu prakiraan dari BMKG',
                          ),
                          _glassCard(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: SizedBox(
                              height: 118,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: forecastCount,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 5),
                                itemBuilder: (context, index) {
                                  final forecast =
                                      forecasts[currentIndex + index];

                                  return SizedBox(
                                    width: 66,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _timeLabel(forecast.dateTime),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          _weatherIcon(forecast.description),
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                        Text(
                                          '${forecast.temperature.round()}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Informasi cuaca
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
                      child: _sectionTitle(
                        'Kondisi cuaca',
                        'Informasi yang tersedia dari BMKG',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 11,
                        crossAxisSpacing: 11,
                        childAspectRatio: 1.16,
                      ),
                      delegate: SliverChildListDelegate([
                        _infoCard(
                          Icons.water_drop_outlined,
                          'Kelembapan',
                          '${current.humidity}%',
                        ),
                        _infoCard(
                          Icons.air_rounded,
                          'Kecepatan angin',
                          '${current.windSpeed} km/jam',
                        ),
                        _infoCard(
                          Icons.explore_outlined,
                          'Arah angin',
                          current.windDirectionDegrees != null
                              ? '${current.windDirectionDegrees!.round() % 360}°'
                              : '-',
                          subtitle: current.windDirectionLabel,
                        ),
                        _infoCard(
                          Icons.cloud_outlined,
                          'Tutupan awan',
                          '${current.cloudCover}%',
                        ),
                        _infoCard(
                          Icons.visibility_outlined,
                          'Visibilitas',
                          current.visibility,
                          subtitle: current.visibilityDescription,
                        ),
                        _infoCard(
                          Icons.schedule_rounded,
                          'Waktu prakiraan',
                          _dateLabel(current.dateTime),
                        ),
                      ]),
                    ),
                  ),

                  // Tombol peta
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
                      child: _glassCard(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFB7DDFB).withOpacity(0.17),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: Color(0xFFD5EBFF),
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jelajahi peta',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Lihat lokasi Kota Malang',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Buka peta',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MapScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Sumber data: BMKG',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Cuaca untuk Daerah Khusus Kota Malang',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
