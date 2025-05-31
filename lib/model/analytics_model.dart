// lib/model/analytics_model.dart

class AnalyticsModel {
  final int totalTrips;
  final double totalRevenue;
  final double totalProfit;
  final int completedTrips;
  final int cancelledTrips;
  final List<dynamic> driversData;
  final List<dynamic> locationsData;
  final List<dynamic> vehiclesData;
  final List<dynamic> monthlyData;
  final List<dynamic> chartData;

  AnalyticsModel({
    required this.totalTrips,
    required this.totalRevenue,
    required this.totalProfit,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.driversData,
    required this.locationsData,
    required this.vehiclesData,
    required this.monthlyData,
    required this.chartData,
  });

  factory AnalyticsModel.fromJson(
      Map<String, dynamic> trips,
      Map<String, dynamic> revenue,
      Map<String, dynamic> status,
      Map<String, dynamic> profit,
      List<dynamic> drivers,
      List<dynamic> locations,
      List<dynamic> vehicles,
      List<dynamic> monthly,
      List<dynamic> chart,
      ) {
    return AnalyticsModel(
      totalTrips: int.tryParse(trips['total_trips']?.toString() ?? '') ?? 0,
      totalRevenue: double.tryParse(revenue['total_revenue']?.toString() ?? '') ?? 0.0,
      totalProfit: double.tryParse(profit['total_profit']?.toString() ?? '') ?? 0.0,
      completedTrips: int.tryParse(status['completed']?.toString() ?? '') ?? 0,
      cancelledTrips: int.tryParse(status['cancelled']?.toString() ?? '') ?? 0,
      driversData: drivers,
      locationsData: locations,
      vehiclesData: vehicles,
      monthlyData: monthly,
      chartData: chart,
    );
  }
}
