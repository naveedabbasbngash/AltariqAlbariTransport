import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsService {
  final Map<String, String> _endpoints = {
    'monthly': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips-monthly',
    'vehicles': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-vehicles',
    'drivers': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-drivers',
    'locations': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/top-locations',
    'trips': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips',
    'revenue': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/revenue',
    'chart': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/trips-daily',
    'status': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/status-summary',
    'profit': 'https://kheloaurjeeto.net/transport_app/index.php/api/analytics/total-profit',
  };

  Future<Map<String, dynamic>> fetchAllAnalyticsData() async {
    final Map<String, dynamic> result = {};

    await Future.wait(_endpoints.entries.map((entry) async {
      try {
        final response = await http.get(Uri.parse(entry.value));
        if (response.statusCode == 200) {
          result[entry.key] = json.decode(response.body);
        } else {
          result[entry.key] = null;
        }
      } catch (e) {
        result[entry.key] = null;
      }
    }));

    return result;
  }
}
