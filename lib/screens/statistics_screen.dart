import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    
    final total = taskProvider.allTasks.length;
    final completed = taskProvider.completedTasks.length;
    final pending = taskProvider.pendingTasks.length;
    final progress = taskProvider.completionPercentage;
    final stats = taskProvider.getCategoryStats();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('statistics')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(child: _buildStatCard(context, lang.translate('total_tasks'), total.toString(), Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard(context, lang.translate('completed'), completed.toString(), Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard(context, lang.translate('pending'), pending.toString(), Colors.orange)),
              ],
            ),
            const SizedBox(height: 30),
            
            // Progress Section
            Text(
              lang.translate('progress'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).primaryColor,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Categories Pie Chart
            Text(
              lang.translate('categories'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (total > 0)
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: stats['Personal']?.toDouble() ?? 0,
                              title: '${stats['Personal']}',
                              color: Colors.blue,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: stats['Work']?.toDouble() ?? 0,
                              title: '${stats['Work']}',
                              color: Colors.green,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: stats['Other']?.toDouble() ?? 0,
                              title: '${stats['Other']}',
                              color: Theme.of(context).primaryColor,
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(lang.translate('personal'), Colors.blue, stats['Personal']!, total),
                          const SizedBox(height: 8),
                          _buildLegendItem(lang.translate('work'), Colors.green, stats['Work']!, total),
                          const SizedBox(height: 8),
                          _buildLegendItem(lang.translate('other'), Theme.of(context).primaryColor, stats['Other']!, total),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
               Center(
                child: Text(lang.translate('no_chart_data'), style: const TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, int count, int total) {
    final percentage = total == 0 ? 0 : ((count / total) * 100).toInt();
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
