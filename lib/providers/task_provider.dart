import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isFirstTime = true;
  int _totalCoins = 0;

  List<Task> get allTasks => _tasks;
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  bool get isFirstTime => _isFirstTime;
  int get totalCoins => _totalCoins;

  final Box<String> _tasksBox = Hive.box<String>('tasksBox');
  final Box _settingsBox = Hive.box('settingsBox');

  TaskProvider() {
    _loadData();
  }

  void _loadData() {
    _isFirstTime = _settingsBox.get('isFirstTime', defaultValue: true);
    _totalCoins = _settingsBox.get('totalCoins', defaultValue: 0);

    final List<String> tasksStringList = _tasksBox.values.toList();
    _tasks = tasksStringList.map((taskStr) => Task.fromJson(taskStr)).toList();
    
    notifyListeners();
  }

  void _saveData() {
    _tasksBox.clear();
    for (var task in _tasks) {
      _tasksBox.add(task.toJson());
    }
  }

  void completeOnboarding() {
    _isFirstTime = false;
    _settingsBox.put('isFirstTime', false);
    notifyListeners();
  }

  void addTask(String title) {
    if (title.trim().isEmpty) return;
    
    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
    );
    _tasks.insert(0, newTask);
    _saveData();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      bool wasCompleted = _tasks[taskIndex].isCompleted;
      _tasks[taskIndex].isCompleted = !wasCompleted;
      
      // Handle coins
      if (!wasCompleted) {
        _totalCoins += _tasks[taskIndex].rewardCoins; // Gained coins
      } else {
        _totalCoins -= _tasks[taskIndex].rewardCoins; // Lost coins
      }
      _settingsBox.put('totalCoins', _totalCoins);
      
      _saveData();
      notifyListeners();
    }
  }

  void updateTask(String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].title = newTitle;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveData();
    notifyListeners();
  }

  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks.length / _tasks.length;
  }
  
  Map<String, int> getCategoryStats() {
    int personal = _tasks.where((t) => t.category == 'Personal').length;
    int work = _tasks.where((t) => t.category == 'Work').length;
    int other = _tasks.where((t) => t.category == 'Other').length;
    
    return {
      'Personal': personal,
      'Work': work,
      'Other': other,
    };
  }
}

