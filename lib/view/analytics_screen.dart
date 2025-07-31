import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodel/analytics_viewmodel.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel()..fetchAnalyticsData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("TARIQ AL BALRII Analytics"),
        ),
        body: Consumer<AnalyticsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _infoCard('Trips', '${viewModel.totalTrips}'),
                      _infoCard('Revenue', 'SAR ${viewModel.totalRevenue.toStringAsFixed(0)}'),
                      _infoCard('Profit', 'SAR ${viewModel.totalProfit.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text('Trips This Week', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 200, child: _buildLineChart(viewModel)),
                  _summaryRow('Completed', '${viewModel.completedTrips}'),
                  _summaryRow('Cancelled', '${viewModel.cancelledTrips}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 160,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('THIS MONTH', style: TextStyle(fontSize: 12, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLineChart(AnalyticsViewModel viewModel) {
    List<FlSpot> spots = [];

    for (int i = 0; i < viewModel.chartData.length; i++) {
      final item = viewModel.chartData[viewModel.chartData.length - 1 - i];
      final count = double.tryParse(item['count'].toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), count));
    }

    if (spots.isEmpty) spots = [FlSpot(0, 0)];

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: true),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
