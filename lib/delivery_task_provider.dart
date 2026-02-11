import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logitrack_app/delivery_task_model.dart'; // Sesuaikan path
import 'package:logitrack_app/api_service.dart'; // Sesuaikan path
import 'package:shared_preferences/shared_preferences.dart';

// Enum untuk merepresentasikan state
enum TaskState { Initial, Loading, Loaded, Error }

class DeliveryTaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<DeliveryTask> _tasks = [];
  TaskState _state = TaskState.Initial;
  String _errorMessage = '';

  // Getters untuk diakses oleh UI
  List<DeliveryTask> get tasks => _tasks;
  TaskState get state => _state;
  String get errorMessage => _errorMessage;

  // Business Logic
  Future<void> fetchTasks() async {
    _state = TaskState.Loading;
    notifyListeners(); // Beri tahu UI bahwa loading dimulai

    try {
      // 1. Fetch from API
      List<DeliveryTask> apiTasks = await _apiService.fetchDeliveryTasks();

      // Default value is API tasks
      _tasks = apiTasks;

      // 2. Load local persistence (Wrapped in try-catch to prevent app crash if plugin fails)
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? storedData = prefs.getString('completed_tasks');
        
        if (storedData != null) {
          final Map<String, dynamic> localData = jsonDecode(storedData);
          
          // 3. Merge API data with local data
          _tasks = apiTasks.map((task) {
            final String taskIdStr = task.id.toString();
            if (localData.containsKey(taskIdStr)) {
              final data = localData[taskIdStr];
              return task.copyWith(
                isCompleted: true,
                proofImagePath: data['proofImagePath'],
                latitude: data['latitude'],
                longitude: data['longitude'],
              );
            }
            return task;
          }).toList();
        }
      } catch (e) {
        debugPrint("Warning: Failed to load local storage (Plugin might need rebuild): $e");
      }
      
      _state = TaskState.Loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TaskState.Error;
    }
    notifyListeners(); // Beri tahu UI bahwa proses selesai (sukses/gagal)
  }

  // Method untuk menandai task sebagai selesai
  Future<void> completeTask(int taskId, {String? proofImagePath, double? latitude, double? longitude}) async {
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      // 1. Update Memory
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: true,
        proofImagePath: proofImagePath,
        latitude: latitude,
        longitude: longitude,
      );
      notifyListeners(); // Beri tahu UI ada perubahan data

      // 2. Update Local Storage
      try { // Wrap in try-catch to prevent crash if plugin is not linked yet
        final prefs = await SharedPreferences.getInstance();
        final String? storedData = prefs.getString('completed_tasks');
        Map<String, dynamic> localData = {};
        if (storedData != null) {
          try {
            localData = jsonDecode(storedData);
          } catch (_) {}
        }

        localData[taskId.toString()] = {
          'proofImagePath': proofImagePath,
          'latitude': latitude,
          'longitude': longitude,
        };

        await prefs.setString('completed_tasks', jsonEncode(localData));
      } catch (e) {
        debugPrint("Error saving to local storage: $e. (App might need a full restart)");
      }
    }
  }
}