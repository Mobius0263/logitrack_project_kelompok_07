import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logitrack_app/delivery_task_model.dart';
import 'package:logitrack_app/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:logitrack_app/delivery_task_provider.dart';

class DeliveryDetailPage extends StatefulWidget {
  final DeliveryTask task;

  const DeliveryDetailPage({super.key, required this.task});

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  XFile? _imageFile;
  Position? _currentPosition; // State to store position
  final LocationService _locationService = LocationService(); // State untuk menyimpan file gambar

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      // Handle error, misal pengguna menolak izin
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengakses kamera.')),
      );
    }
  }

  Future<void> getCurrentLocationAndCompleteDelivery() async {
  try {
    final position = await _locationService.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    // Panggil Provider untuk update status task beserta data bukti
    if (mounted) {
      Provider.of<DeliveryTaskProvider>(context, listen: false).completeTask(
        widget.task.id,
        proofImagePath: _imageFile?.path,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    // Show success notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengiriman Selesai di Lat: ${position.latitude}, Lon: ${position.longitude}')),
    );
  } catch (e) {
    // Show error notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // Ambil data terbaru dari Provider berdasarkan ID
    // Ini memastikan status ter-update secara real-time saat tombol selesai ditekan
    final currentTask = context.select<DeliveryTaskProvider, DeliveryTask>((provider) {
      return provider.tasks.firstWhere(
        (t) => t.id == widget.task.id,
        orElse: () => widget.task,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${currentTask.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentTask.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Status: ${currentTask.isCompleted ? "Selesai" : "Dalam Proses"}',
              style: TextStyle(
                fontSize: 16,
                color: currentTask.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bukti Pengiriman:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Area untuk menampilkan gambar atau placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile != null
                  ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                  : (currentTask.proofImagePath != null
                      ? Image.file(File(currentTask.proofImagePath!), fit: BoxFit.cover)
                      : const Center(child: Text('Belum ada gambar'))),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto Bukti'),
                onPressed: pickImageFromCamera,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Widget to display location data
            if (_currentPosition != null)
              Text(
                'Lokasi Baru Terekam:\nLat: ${_currentPosition!.latitude}\nLon: ${_currentPosition!.longitude}',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              )
            else if (currentTask.latitude != null && currentTask.longitude != null)
              Text(
                'Lokasi Tersimpan:\nLat: ${currentTask.latitude}\nLon: ${currentTask.longitude}',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              )
            else
              const Text(
                'Lokasi belum direkam.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 16),

            // Button to complete delivery
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Selesaikan Pengiriman & Rekam Lokasi'),
                onPressed: getCurrentLocationAndCompleteDelivery,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}