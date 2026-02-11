import 'package:flutter/material.dart';
import 'package:logitrack_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logitrack_app/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage( {super.key} );

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

bool isLoading = false;

void handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      isLoading = true; // 1. Mulai Loading
    });
    
    try {
      // Panggil service otentikasi
      await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      // Jika berhasil, AuthGate akan menangani navigasi
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      String message = 'Login gagal.';
      if (e.code == 'user-not-found') {
        message = 'Pengguna tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah.';
      } else {
        message = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // 2. Pastikan Loading berhenti apapun yang terjadi
        });
      }
    }
  }
}

final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  // ... di dalam build method LoginPage
  bool _isPasswordVisible = false;
  // Buat controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      // ... AppBar tetap sama
      appBar: AppBar(
        title: const Text('LogiTrack - Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(24.0), // Memberi jarak di sekeliling
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
          children: [
            // I. Tambahkan Ikon atau Logo
            const Icon(
              Icons.local_shipping,
              size: 80,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 48), // Memberi jarak vertikal
            
            // 2. Tambahkan TextFormField untuk Email
            TextFormField(
              controller: _emailController, // Hubungkan controller email
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  // Validasi format email sederhana
                  if (!value.contains('@')) {
                    return 'Masukkan format email yang valid';
                  }
                  return null; // Return null jika valid
                },
            ),
            const SizedBox(height: 16), // Memberi jarak vertikal

            // 3. Tambahkan TextFormField untuk Password
            TextFormField(
              controller: _passwordController, // Hubungkan controller password
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal harus 6 karakter';
                  }
                  return null; // Return null jika valid
                },
            ),
            const SizedBox(height: 32), // Memberi jarak vertikal
            
            // 4. Tambahkan Tombol Login
            // Bungkus dengan SizedBox agar bisa mengatur lebar tombol
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // Durasi animasi
                  width: isLoading ? 50 : constraints.maxWidth, // Gunakan constraints.maxWidth daripada double.infinity
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Hapus padding saat loading agar bentuk lingkaran sempurna dan konten muat
                      padding: isLoading ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 16),
                      // Sesuaikan shape agar menjadi lingkaran saat loading
                      shape: isLoading
                          ? const CircleBorder()
                          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    // Nonaktifkan tombol saat loading
                    onPressed: isLoading ? null : handleLogin, 
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white, 
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                );
              }
            ),
            const SizedBox(height: 16), // Memberi jarak vertikal
            
            // 5. Tambahkan Tombol Register
            // Bungkus dengan SizedBox agar bisa mengatur lebar tombol
            SizedBox(
              width: double.infinity, // Lebar tombol penuh
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Register'),
              ),
            ),
          ],  
        ),
      ),  
      ),
    ),
    );
  }
}