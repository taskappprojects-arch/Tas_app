import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/widgets/custom_drawer.dart';
import 'package:todo_app/widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      Provider.of<TaskProvider>(context, listen: false)
          .addTask(_taskController.text.trim());
      _taskController.clear();
      FocusScope.of(context).unfocus(); // hide keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final tasks = taskProvider.allTasks;
    
    int completedCount = taskProvider.completedTasks.length;
    int totalCount = tasks.length;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(lang.translate('app_title'), style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String code) {
              lang.setLanguage(code);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'bn',
                child: Text('বাংলা'),
              ),
              const PopupMenuItem<String>(
                value: 'hi',
                child: Text('हिन्दी'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Coins Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '${taskProvider.totalCoins} Coins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Add Task Section - Redesigned to match image exactly
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            color: Colors.transparent, // Uses scaffold background
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: lang.translate('type_task_hint'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addTask,
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // Task List
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(lang)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskTile(task: task);
                    },
                  ),
          ),
          
          // Bottom Status or Celebration
          if (tasks.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: totalCount == completedCount 
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2) 
                  : Colors.transparent,
              child: Center(
                child: totalCount == completedCount
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          lang.translate('excellent_all_completed'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Text(
                      lang.translate('tasks_completed_count')
                          .replaceFirst('%d', completedCount.toString())
                          .replaceFirst('%d', totalCount.toString()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            lang.translate('no_tasks_yet'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang.translate('add_new_task_desc'),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

