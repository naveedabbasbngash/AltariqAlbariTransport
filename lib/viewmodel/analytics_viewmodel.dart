import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  int totalTrips = 0;
  double totalProfit = 0.0;
  double totalRevenue = 0.0;
  int completedTrips = 0;
  int cancelledTrips = 0;

  List<dynamic> driversData = [];
  List<dynamic> locationsData = [];
  List<dynamic> vehiclesData = [];
  List<dynamic> monthlyData = [];
  List<Map<String, dynamic>> chartData = [];

  bool isLoading = true;
  String? errorMessage;
  Map<String, String> sectionErrors = {}; // For tracking individual API section failures

  Future<void> fetchAnalyticsData() async {
    isLoading = true;
    errorMessage = null;
    sectionErrors.clear();
    notifyListeners();

    try {
      final dataMap = await _service.fetchAllAnalyticsData();

      // Trips
      try {
        totalTrips = int.tryParse(dataMap['trips']?['total_trips'].toString() ?? '') ?? 0;
      } catch (_) {
        sectionErrors['trips'] = 'Failed to load trip data';
      }

      // Revenue
      try {
        totalRevenue = double.tryParse(dataMap['revenue']?['total_revenue'].toString() ?? '') ?? 0;
      } catch (_) {
        sectionErrors['revenue'] = 'Failed to load revenue';
      }

      // Status Summary
      try {
        completedTrips = int.tryParse(dataMap['status']?['completed'].toString() ?? '') ?? 0;
        cancelledTrips = int.tryParse(dataMap['status']?['cancelled'].toString() ?? '') ?? 0;
      } catch (_) {
        sectionErrors['status'] = 'Failed to load status summary';
      }

      // Profit
      try {
        totalProfit = double.tryParse(dataMap['profit']?['total_profit'].toString() ?? '') ?? 0.0;
      } catch (_) {
        sectionErrors['profit'] = 'Failed to load profit';
      }

      // Vehicles
      try {
        vehiclesData = dataMap['vehicles'] ?? [];
      } catch (_) {
        sectionErrors['vehicles'] = 'Failed to load vehicles';
      }

      // Drivers
      try {
        driversData = dataMap['drivers'] ?? [];
      } catch (_) {
        sectionErrors['drivers'] = 'Failed to load drivers';
      }

      // Locations
      try {
        locationsData = dataMap['locations'] ?? [];
      } catch (_) {
        sectionErrors['locations'] = 'Failed to load locations';
      }

      // Monthly
      try {
        monthlyData = dataMap['monthly'] ?? [];
      } catch (_) {
        sectionErrors['monthly'] = 'Failed to load monthly summary';
      }

      // Chart
      try {
        chartData = List<Map<String, dynamic>>.from(dataMap['chart'] ?? []);
      } catch (_) {
        sectionErrors['chart'] = 'Failed to load chart';
      }

    } catch (e) {
      errorMessage = "Something went wrong: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
