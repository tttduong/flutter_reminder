import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/models/category_state.dart';
import 'package:flutter_to_do_app/data/models/completed_state.dart';

class ReportService {
  static const String baseUrl = "${Constants.URI}/api/v1";

  Future<List<CategoryStat>> fetchCategoryStatsByDay({DateTime? day}) async {
    final dateStr = (day ?? DateTime.now()).toIso8601String().split('T')[0];
    final response = await ApiService.dio.get(
      '$baseUrl/tasks/completed-by-category/by-day/',
      queryParameters: {'day': dateStr},
    );

    if (response.statusCode == 200) {
      final data = response.data as List;
      return data
          .map((item) => CategoryStat(
                categoryId: item['category_id'],
                name: item['name'], // lấy trực tiếp từ API
                color: item['color'],
                completed: item['completed'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load category stats');
    }
  }

  Future<List<CompletedStat>> fetchWeekCompletedStats() async {
    final response = await ApiService.dio.get(
      '$baseUrl/tasks/completed-per-day/current-week/',
    );

    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => CompletedStat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Future<List<CompletedStat>> fetchMonthCompletedStats() async {
    final response = await ApiService.dio.get(
      '$baseUrl/tasks/completed-per-day/current-month/',
    );

    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => CompletedStat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stats');
    }
  }
}
