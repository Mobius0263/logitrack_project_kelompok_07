import 'package:flutter/material.dart';
import 'package:logitrack_app/delivery_task_model.dart'; // Sesuaikan path
import 'package:logitrack_app/api_service.dart'; // Sesuaikan path

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
      _tasks = await _apiService.fetchDeliveryTasks();
      _state = TaskState.Loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TaskState.Error;
    }
    notifyListeners(); // Beri tahu UI bahwa proses selesai (sukses/gagal)
  }
}