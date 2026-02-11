import 'package:flutter/material.dart';
import 'package:logitrack_app/api_service.dart';
import 'package:logitrack_app/delivery_task_model.dart';
import 'package:logitrack_app/auth_service.dart';
import 'package:logitrack_app/qr_scanner_page.dart';
import 'package:logitrack_app/delivery_detail_page.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Panggil method fetchTasks dari provider setelah frame selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DeliveryTaskProvider>(context, listen: false).fetchTasks();
      }
    });
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
              final filteredTasks = provider.tasks.where((task) {
                final query = _searchQuery.toLowerCase();
                return task.title.toLowerCase().contains(query) || 
                       task.id.toString().contains(query);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Cari Pengiriman (ID atau Nama)',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: task.isCompleted ? Colors.green.shade50 : null,
                          child: ListTile(
                            leading: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.local_shipping,
                              color: task.isCompleted ? Colors.green : Colors.blue,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(task.isCompleted ? 'Status: Selesai' : 'ID: ${task.id}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeliveryDetailPage(task: task),
                                ),
                              );
                            },
                            // ... sisa implementasi ListTile
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
              
            default: // Initial state
              return const Center(child: Text('Memulai...'));
          }
        },
      ),
    );
  }
}