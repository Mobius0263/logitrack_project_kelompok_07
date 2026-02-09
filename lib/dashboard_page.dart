import 'package:flutter/material.dart';
import 'package:logitrack_app/api_service.dart';
import 'package:logitrack_app/delivery_task_model.dart';
import 'package:logitrack_app/auth_service.dart';
import 'package:logitrack_app/qr_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:logitrack_app/delivery_task_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}
  class DashboardPageState extends State<DashboardPage> {
    void _navigateToScanner() async {
  // Wait for result from QRScannerPage
  final result = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (context) => const QRScannerPage()),
  );

  if (result != null && mounted) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      // Show scan result in SnackBar
      ..showSnackBar(SnackBar(content: Text("Kode terdeteksi: $result")));
      
    // Logic to search and open task detail (optional but recommended)
    // You need access to 'tasks' list from FutureBuilder
    // This is advanced implementation requiring state management
    // For now, we only display the result.
  }
  }
  // 1. Buat instance ApiService
  final ApiService apiService = ApiService();

  // 2. Buat variabel untuk menampung hasil dari future
  late Future<List<DeliveryTask>> tasksFuture;

  @override
void initState() {
  super.initState();
  // Panggil method fetchTasks dari provider
  // listen: false sangat penting di initState
  Provider.of<DeliveryTaskProvider>(context, listen: false).fetchTasks();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'), // Assumed based on context
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // Call function to open scanner
              _navigateToScanner();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
      body: Consumer<DeliveryTaskProvider>(
        builder: (context, provider, child) {
          // Gunakan switch-case pada state enum
          switch (provider.state) {
            case TaskState.Loading:
              return const Center(child: CircularProgressIndicator());
              
            case TaskState.Error:
              return Center(child: Text('Error: ${provider.errorMessage}'));
              
            case TaskState.Loaded:
              return ListView.builder(
                itemCount: provider.tasks.length,
                itemBuilder: (context, index) {
                  final task = provider.tasks[index];
                  return Card(
                    // ... styling Card
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text('ID: ${task.id}'),
                      // ... sisa implementasi ListTile
                    ),
                  );
                },
              );
              
            default: // Initial state
              return const Center(child: Text('Memulai...'));
          }
        },
      ),
    );
  }
}