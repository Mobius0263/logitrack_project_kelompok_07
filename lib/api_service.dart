import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'dart:async'; // Diperlukan untuk TimeoutException
import 'package:flutter/foundation.dart'; // Diperlukan untuk compute
import 'package:http/http.dart' as http;
import 'package:logitrack_app/delivery_task_model.dart'; 

// Fungsi top-level untuk parsing JSON di isolate terpisah
List<DeliveryTask> parseTasks(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<DeliveryTask>((json) => DeliveryTask.fromJson(json)).toList();
}

class ApiService {
  // URL endpoint dari API
  final String apiUrl = "https://jsonplaceholder.typicode.com/todos";
  
  // Fungsi untuk mengambil data
  Future<List<DeliveryTask>> fetchDeliveryTasks() async {
    try {
      // Tambahkan timeout 15 detik dan headers untuk menghindari 403 Forbidden
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
          "Accept": "*/*",
        }, 
      ).timeout(const Duration(seconds: 15));

      // Cek jika request berhasil (status code 200)
      if (response.statusCode == 200) {
        // Gunakan compute untuk parsing di background isolate agar UI tidak freeze
        return await compute(parseTasks, response.body);
      } else {
        throw Exception('Gagal memuat data dari API. Status Code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Koneksi timeout. Periksa internet Anda.');
    } catch (e) {
      throw Exception('Terjadi Kesalahan (${e.runtimeType}): $e');
    }
  }
}