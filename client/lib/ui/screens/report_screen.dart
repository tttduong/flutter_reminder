import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/category_state.dart';
import 'dart:math' as math;

import 'package:flutter_to_do_app/data/models/completed_state.dart';
import 'package:flutter_to_do_app/data/services/report_service.dart';
import 'package:flutter_to_do_app/ui/widgets/gradient_bg.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int selectedTimeFilter = 0; // 0: Day, 1: Week, 2: Month
  final List<String> timeFilters = ['Day', 'Week', 'Month'];
  List<CompletedStat> stats = [];
  final List<int> weeklyData = [];
  List<CategoryStat> categoryStats = [];
  List<CompletedStat> monthStats = [];
  final List<String> days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final result = await ReportService().fetchWeekCompletedStats();
    final monthData = await ReportService().fetchMonthCompletedStats();
    final categoryData = await ReportService().fetchCategoryStatsByDay();
    print('raw stats: $result');
    final weeklyStats = filterThisWeek(result);
    print('filtered this week: ${weeklyStats.map((e) => e.day).toList()}');
    final data = buildWeeklyData(weeklyStats);
    print('weeklyData (Mo..Su): $data');

    setState(() {
      stats = result;
      monthStats = monthData;
      categoryStats = categoryData;
      weeklyData.clear();
      weeklyData.addAll(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Report',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Stack(children: [
          const GradientBackground(), // nền
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Filter
                // _buildTimeFilterTabs(),
                // const SizedBox(height: 20),

                // Overview Cards
                _buildOverviewCards(),
                const SizedBox(height: 24),

                // Completion Chart
                _buildCompletionChart(),
                const SizedBox(height: 24),

                // Calendar Heatmap
                _buildCalendarHeatmap(monthStats),
                const SizedBox(height: 24),

                // Category Statistics
                _buildCategoryStats(),
                const SizedBox(height: 24),

                // // Goals & Achievements
                // _buildGoalsSection(),
                // const SizedBox(height: 24),

                // // Trends Comparison
                // _buildTrendsSection(),
                // const SizedBox(height: 24),

                // // Badges/Achievements
                // _buildBadgesSection(),
              ],
            ),
          ),
        ]));
  }

  // Widget _buildTimeFilterTabs() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(25),
  //     ),
  //     child: Row(
  //       children: List.generate(timeFilters.length, (index) {
  //         return Expanded(
  //           child: GestureDetector(
  //             onTap: () => setState(() => selectedTimeFilter = index),
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(vertical: 12),
  //               decoration: BoxDecoration(
  //                 color: selectedTimeFilter == index
  //                     ? Colors.blue[600]
  //                     : Colors.transparent,
  //                 borderRadius: BorderRadius.circular(25),
  //               ),
  //               child: Text(
  //                 timeFilters[index],
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: selectedTimeFilter == index
  //                       ? Colors.white
  //                       : Colors.grey[700],
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }

  Widget _buildOverviewCards() {
    // Lọc today
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final today = stats.firstWhere(
      (s) => s.day == todayStr,
      orElse: () => CompletedStat(day: todayStr, completed: 0),
    );

    // Tuần này
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekCompleted = stats.where((s) {
      if (s.day == "None") return false;
      final d = DateTime.tryParse(s.day);
      return d != null &&
          d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 1)));
    }).fold<int>(0, (sum, s) => sum + s.completed);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Today',
            value: '${today.completed}',
            subtitle: 'tasks',
            color: Colors.green,
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'This week',
            value: '$weekCompleted',
            subtitle: 'tasks',
            color: Colors.blue,
            icon: Icons.calendar_view_week,
          ),
        ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _buildStatCard(
        //     title: 'Streak',
        //     value: '5 days',
        //     subtitle: '>80% task',
        //     color: Colors.orange,
        //     icon: Icons.local_fire_department,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          // const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          // const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              )),
        ],
      ),
    );
  }

  List<CompletedStat> filterThisWeek(List<CompletedStat> stats) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday at 00:00
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    return stats.where((s) {
      // Bảo vệ nếu s.day là "None" hoặc null
      final parsed = DateTime.tryParse(s.day ?? '');
      if (parsed == null) return false;

      final dayOnly = DateTime(parsed.year, parsed.month, parsed.day);
      return !dayOnly.isBefore(startOfWeek) && !dayOnly.isAfter(endOfWeek);
    }).toList();
  }

  List<int> buildWeeklyData(List<CompletedStat> weeklyStats) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday at 00:00

    final result = List<int>.filled(7, 0);

    for (final s in weeklyStats) {
      final parsed = DateTime.tryParse(s.day ?? '');
      if (parsed == null) continue;

      final dayOnly = DateTime(parsed.year, parsed.month, parsed.day);
      final diff = dayOnly.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7) {
        result[diff] += s.completed;
      }
    }

    return result;
  }

  Widget _buildCompletionChart() {
    if (weeklyData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tránh lỗi chia 0
    final maxValue = weeklyData.isNotEmpty ? weeklyData.reduce(math.max) : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task completion statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Sử dụng Container thay vì SizedBox và loại bỏ Column lồng nhau
          Container(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Thêm để phân bố đều
              children: List.generate(weeklyData.length, (index) {
                // Nếu maxValue = 0 thì height = 0
                final height = maxValue > 0
                    ? (weeklyData[index] / maxValue) * 140
                    : 0.0; // Giảm từ 160 xuống 140

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4), // Sử dụng margin thay vì padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize:
                          MainAxisSize.min, // Thêm để tối ưu kích thước
                      children: [
                        // Value label
                        if (weeklyData[index] >
                            0) // Chỉ hiển thị nếu có giá trị
                          Text(
                            '${weeklyData[index]}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (weeklyData[index] > 0) const SizedBox(height: 4),

                        // Bar
                        Container(
                          width: double.infinity,
                          height: height.isNaN || height < 0
                              ? 0
                              : height.clamp(
                                  0, 140), // Clamp để đảm bảo không vượt quá
                          decoration: BoxDecoration(
                            color: weeklyData[index] > 0
                                ? Colors.blue[400]
                                : Colors.grey[300],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Day label
                        Text(
                          days[index],
                          style: const TextStyle(fontSize: 12),
                          overflow:
                              TextOverflow.ellipsis, // Tránh overflow text
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCalendarHeatmap() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('Daily Task Frequency',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             )),
  //         const SizedBox(height: 16),
  //         // Calendar heatmap simulation
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 7,
  //             childAspectRatio: 1,
  //             crossAxisSpacing: 4,
  //             mainAxisSpacing: 4,
  //           ),
  //           itemCount: 28,
  //           itemBuilder: (context, index) {
  //             final intensity = (index * 17) % 5; // Mock data
  //             return Container(
  //               decoration: BoxDecoration(
  //                 color: _getHeatmapColor(intensity),
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   '${index + 1}',
  //                   style: TextStyle(
  //                     fontSize: 10,
  //                     color: intensity > 2 ? Colors.white : Colors.black54,
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             const Text('Less',
  //                 style: TextStyle(fontSize: 12, color: Colors.grey)),
  //             const SizedBox(width: 8),
  //             ...List.generate(
  //                 5,
  //                 (index) => Container(
  //                       margin: const EdgeInsets.only(right: 4),
  //                       width: 12,
  //                       height: 12,
  //                       decoration: BoxDecoration(
  //                         color: _getHeatmapColor(index),
  //                         borderRadius: BorderRadius.circular(2),
  //                       ),
  //                     )),
  //             const SizedBox(width: 8),
  //             const Text('More',
  //                 style: TextStyle(fontSize: 12, color: Colors.grey)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildCalendarHeatmap(List<CompletedStat> monthStats) {
    // Lấy số ngày trong tháng
    final today = DateTime.now();
    final year = today.year;
    final month = today.month;
    final lastDay = DateTime(year, month + 1, 0).day;

    // Tạo map ngày -> completed để tra cứu nhanh
    final Map<int, int> dayToCompleted = {
      for (var s in monthStats)
        int.tryParse(s.day.split('-').last) ?? 0: s.completed
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Task Frequency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: lastDay,
            itemBuilder: (context, index) {
              final day = index + 1;
              final completed = dayToCompleted[day] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: _getHeatmapColor(completed), // intensity theo số task
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 10,
                      color: completed > 2 ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Less',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              ...List.generate(
                  5,
                  (index) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getHeatmapColor(index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
              const SizedBox(width: 8),
              const Text('More',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int intensity) {
    final colors = [
      Colors.grey[200]!,
      Colors.green[200]!,
      Colors.green[400]!,
      Colors.green[600]!,
      Colors.green[800]!,
    ];

    // Giới hạn intensity trong khoảng hợp lệ (0 → colors.length - 1)
    final safeIndex = intensity.clamp(0, colors.length - 1);
    return colors[safeIndex];
  }

  // Widget _buildCategoryStats() {
  //   final List<CategoryData> categories = [
  //     CategoryData('Study', 40, Colors.blue[400]!),
  //     CategoryData('Work', 35, Colors.green[400]!),
  //     CategoryData('Personal', 25, Colors.orange[400]!),
  //   ];

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('Category Distribution of Completed Tasks',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             )),
  //         const SizedBox(height: 20),
  //         Row(
  //           children: [
  //             Expanded(
  //               flex: 2,
  //               child: SizedBox(
  //                 height: 150,
  //                 width: 150,
  //                 child: CustomPaint(
  //                   painter: PieChartPainter(categories),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 20),
  //             Expanded(
  //               flex: 1,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: categories
  //                     .map((category) => _buildLegendItem(category.name,
  //                         category.color, '${category.percentage}%'))
  //                     .toList(),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Color parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // thêm alpha nếu chưa có
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Widget _buildCategoryStats() {
    if (categoryStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(children: [
          const Text('Category Distribution of Completed Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 20),
          Text(
            'No completed tasks yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ]),
      );
    }
    // final total = categoryStats.fold<int>(0, (sum, e) => sum + e.completed);

    // final List<CategoryData> categories = categoryStats
    //     .map((e) => CategoryData(
    //           e.name ?? 'Unknown',
    //           total > 0 ? ((e.completed / total) * 100).toDouble() : 0.0,
    //           parseColor(e.color ?? '#000000'),
    //         ))
    //     .toList();

    final total = categoryStats.fold<int>(0, (sum, e) => sum + e.completed);

// Bước 1: Tính tỉ lệ phần trăm thô
    final List<_TempCategory> raw = categoryStats
        .map((e) => _TempCategory(
              name: e.name ?? 'Unknown',
              color: parseColor(e.color ?? '#000000'),
              rawPercent: total > 0 ? (e.completed / total * 100) : 0.0,
            ))
        .toList();

// Bước 2: Làm tròn xuống & tính phần dư
    int sumInt = 0;
    for (var item in raw) {
      item.intPercent = item.rawPercent.floor();
      item.remainder = item.rawPercent - item.intPercent;
      sumInt += item.intPercent;
    }

// Bước 3: Nếu tổng < 100, phân bổ phần dư còn lại
    int remainderToAdd = 100 - sumInt;
    raw.sort(
        (a, b) => b.remainder.compareTo(a.remainder)); // Ưu tiên phần dư lớn
    for (int i = 0; i < remainderToAdd && i < raw.length; i++) {
      raw[i].intPercent += 1;
    }

// Bước 4: Convert sang CategoryData để hiển thị
    final List<CategoryData> categories = raw
        .map((e) => CategoryData(e.name, e.intPercent.toDouble(), e.color))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Distribution of Completed Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: CustomPaint(
                    painter: PieChartPainter(categories),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories
                      .map((category) => _buildLegendItem(category.name,
                          category.color, '${category.percentage}%'))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(percentage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Goals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          _buildGoalProgress('Completed Tasks', 32, 40, Colors.blue),
          const SizedBox(height: 12),
          _buildGoalProgress('Maintained Streak', 5, 7, Colors.orange),
          const SizedBox(height: 12),
          _buildGoalProgress('Completion Rate', 80, 100, Colors.green),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(
      String title, int current, int target, Color color) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text('$current/$target',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildTrendsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trend & Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'compared to last week',
                  '+12%',
                  true,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendCard(
                  'Average Productivity',
                  '8.5 task/day',
                  true,
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
      String title, String value, bool isPositive, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isPositive ? Colors.green[600] : Colors.red[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green[700] : Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Badges & Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge('🔥', 'Streak Master', '5 days in a row', true),
              _buildBadge('⚡', 'Speed Runner', '10 tasks in one day', true),
              _buildBadge('🎯', 'Goal Crusher', 'Achieve 100% of goals', false),
              _buildBadge('🌟', 'Perfect Week', '7 perfect days', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
      String emoji, String title, String description, bool achieved) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: achieved ? Colors.amber[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: achieved ? Colors.amber[400]! : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 24,
                color: achieved ? null : Colors.grey[500],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: achieved ? Colors.black87 : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 9,
            color: achieved ? Colors.grey[600] : Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TempCategory {
  final String name;
  final Color color;
  final double rawPercent;
  int intPercent = 0;
  double remainder = 0;

  _TempCategory({
    required this.name,
    required this.color,
    required this.rawPercent,
  });
}

// Custom Data Classes
class CategoryData {
  final String name;
  final double percentage;
  final Color color;

  CategoryData(this.name, this.percentage, this.color);
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<CategoryData> categories;

  PieChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    double startAngle = -math.pi / 2;

    for (final category in categories) {
      final sweepAngle = (category.percentage / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw percentage text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textCenter = Offset(
        center.dx + textRadius * math.cos(textAngle),
        center.dy + textRadius * math.sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${category.percentage.toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textCenter.dx - textPainter.width / 2,
          textCenter.dy - textPainter.height / 2,
        ),
      );

      startAngle += sweepAngle;
    }

    // Draw center circle (donut hole)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
