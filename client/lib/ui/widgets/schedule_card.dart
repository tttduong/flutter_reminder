// ===== 5. schedule_card.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final String messageText;
  final bool isCurrentUser;
  final Map<String, dynamic> scheduleDraft;
  final String conversationId;

  const ScheduleCard({
    super.key,
    required this.messageText,
    required this.isCurrentUser,
    required this.scheduleDraft,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          messageText,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildScheduleContent(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[100],
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: () => _createSchedule(context),
          child: const Text("Create Schedule"),
        ),
      ],
    );
  }

  Widget _buildScheduleContent() {
    // Format có schedule_title
    if (scheduleDraft.containsKey('schedule_title')) {
      return _buildStructuredSchedule();
    }
    // Format date-based
    return _buildDateBasedSchedule();
  }

  Widget _buildStructuredSchedule() {
    final days = scheduleDraft['days'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scheduleDraft['schedule_title'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              scheduleDraft['schedule_title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (scheduleDraft['start_date'] != null)
          Text("Start: ${scheduleDraft['start_date']}"),
        if (scheduleDraft['end_date'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("End: ${scheduleDraft['end_date']}"),
          ),
        const SizedBox(height: 8),
        ...days.map(_buildDayTasks),
      ],
    );
  }

  Widget _buildDateBasedSchedule() {
    final scheduleEntries = scheduleDraft.entries
        .where((e) => e.value is List && (e.value as List).isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheduleEntries.map((entry) {
        final date = entry.key;
        final tasks = entry.value as List<dynamic>;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 4),
              ...tasks.map((taskItem) {
                final task = taskItem as Map<String, dynamic>? ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "- ${task['time'] ?? '-'} | ${task['description'] ?? '-'} (${task['length'] ?? '-'})",
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayTasks(dynamic dayItem) {
    final day = dayItem as Map<String, dynamic>? ?? {};
    final tasks = day['tasks'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day['date'] ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 4),
          ...tasks.map((taskItem) {
            final task = taskItem as Map<String, dynamic>? ?? {};
            return Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                "- ${task['time'] ?? '-'} | ${task['description'] ?? '-'} (${task['length'] ?? '-'})",
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _createSchedule(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );

    try {
      final categoryName = scheduleDraft['schedule_title'] ??
          'Schedule ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';

      final categoryResponse = await CategoryService.create_category(
        title: categoryName,
        color: '#6366F1',
        iconCodePoint: Icons.calendar_today.codePoint,
      );

      final categoryId = categoryResponse['id'];

      final result = await ApiService.createTasksFromSchedule(
        scheduleDraft: scheduleDraft,
        categoryId: categoryId,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Category '$categoryName' created with ${result['tasks_count'] ?? 'multiple'} tasks!",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
