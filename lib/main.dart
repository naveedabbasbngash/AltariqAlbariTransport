// Add these imports for loading and error handling
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view/paint_visualizer_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TARIQ AL BALRII Analytics',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        primaryColor: Color(0xFF0A0E21),
      ),
      home: AnalyticsScreen(),
    );
  }
}

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<dynamic> driversData = [];
  List<dynamic> locationsData = [];
  List<dynamic> vehiclesData = [];
  List<dynamic> monthlyData = [];
  String selectedLanguage = 'English';
  bool get isArabic => selectedLanguage == 'Arabic';

  int totalTrips = 0;
  double totalProfit = 0.0;
  double totalRevenue = 0;
  int completedTrips = 0;
  int cancelledTrips = 0;

  List<FlSpot> tripSpots = [];
  List<String> tripDates = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final urls = [
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips-monthly',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-vehicles',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-drivers',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-locations',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/revenue',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips-daily',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/status-summary',
        'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/total-profit',
      ];

      final responses = await Future.wait(urls.map((url) => http.get(Uri.parse(url))));

      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode != 200) {
          debugPrint('API failed: ${urls[i]}\nStatus: ${responses[i].statusCode}\nBody: ${responses[i].body}');
        }
      }

      final tripsData = responses[4].statusCode == 200 ? json.decode(responses[4].body) : {};
      final revenueData = responses[5].statusCode == 200 ? json.decode(responses[5].body) : {};
      final chartData = responses[6].statusCode == 200 ? json.decode(responses[6].body) : [];
      final statusData = responses[7].statusCode == 200 ? json.decode(responses[7].body) : {};
      final monthlyParsed = responses[0].statusCode == 200 ? json.decode(responses[0].body) : [];
      final profitDataDecoded = responses[8].statusCode == 200 ? json.decode(responses[8].body) : {};

      double fetchedProfit = double.tryParse(profitDataDecoded['total_profit']?.toString() ?? '') ?? 0.0;

      List<dynamic> vehiclesParsed = responses[1].statusCode == 200 ? json.decode(responses[1].body) : [];
      List<dynamic> driversParsed = responses[2].statusCode == 200 ? json.decode(responses[2].body) : [];
      List<dynamic> locationsParsed = responses[3].statusCode == 200 ? json.decode(responses[3].body) : [];

      processChartData(chartData);

      setState(() {
        totalTrips = int.tryParse(tripsData['total_trips']?.toString() ?? '') ?? 0;
        totalRevenue = double.tryParse(revenueData['total_revenue']?.toString() ?? '') ?? 0;
        completedTrips = int.tryParse(statusData['completed']?.toString() ?? '') ?? 0;
        cancelledTrips = int.tryParse(statusData['cancelled']?.toString() ?? '') ?? 0;
        monthlyData = monthlyParsed;
        vehiclesData = vehiclesParsed;
        driversData = driversParsed;
        locationsData = locationsParsed;
        totalProfit = fetchedProfit;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error fetching analytics: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Please try again later.';
      });
    }
  }
  void processChartData(List<dynamic> chartData) {
    tripSpots.clear();
    tripDates.clear();

    for (int index = 0; index < chartData.length; index++) {
      final entry = chartData[chartData.length - index - 1];
      final date = entry['trip_date'];
      final count = double.tryParse(entry['count'].toString()) ?? 0.0;

      if (date is String) tripDates.add(date);
      tripSpots.add(FlSpot(index.toDouble(), count));
    }
  }

  Widget buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isArabic ? 'التحليلات' : 'Analytics', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(isArabic ? 'نظرة عامة' : 'Overview', style: TextStyle(fontSize: 20, color: Colors.white70)),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _infoCard(isArabic ? 'الرحلات' : 'Trips', '$totalTrips'),
              _infoCard(isArabic ? 'الإيرادات' : 'Revenue', 'SAR ${totalRevenue.toStringAsFixed(0)}'),
              _infoCard(isArabic ? 'الربح' : 'Profit', 'SAR ${totalProfit.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 30),
          Text(isArabic ? 'رحلات هذا الأسبوع' : 'Trips This Week', style: TextStyle(fontSize: 20)),
          SizedBox(height: 200, child: _buildLineChart()),
          _summaryRow(isArabic ? 'مكتمل' : 'Completed', '$completedTrips'),
          _summaryRow(isArabic ? 'ملغاة' : 'Cancelled', '$cancelledTrips'),
          SizedBox(height: 24),
          _buildTopList('Top Drivers', driversData, 'driver_name', 'trip_count'),
          _buildTopList('Top Locations', locationsData, 'pickup_location', 'count'),
          _buildTopList('Top Vehicles', vehiclesData, 'vehicle_model', 'trip_count'),
          Center(
            child: DropdownButton<String>(
              dropdownColor: Colors.grey.shade900,
              value: selectedLanguage,
              style: TextStyle(color: Colors.white),
              items: ['English', 'Arabic'].map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang == 'Arabic' ? 'العربية' : 'English'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('TARIQ AL BALRII'),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16)))
            : buildAnalyticsContent(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.brush),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaintVisualizerScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final spotsToUse = tripSpots.isEmpty ? [FlSpot(0, 0)] : tripSpots;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: true),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spotsToUse,
            isCurved: true,
            gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            barWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('THIS MONTH', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopList(String title, List<dynamic> data, String labelKey, String valueKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...data.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item[labelKey] ?? '', style: TextStyle(fontSize: 16)),
              Text(item[valueKey].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ))
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}