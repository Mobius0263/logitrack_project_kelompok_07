import 'package:flutter/material.dart';
import 'package:logitrack_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logitrack_app/login_page.dart';
import 'package:logitrack_app/auth_gate.dart' as logitrack_app; // Alias to avoid conflicts if any

class RegisterPage extends StatefulWidget {
  const RegisterPage( {super.key} );

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool isLoading = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await _authService.registerWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        
        if (!mounted) return;
        
        // Login berhasil, kembali ke root (AuthGate akan menangani sisanya jika masih ada di stack, 
        // tapi karena kita menggunakan pushReplacement sebelumnya, aman untuk navigasi ulang ke AuthGate)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const logitrack_app.AuthGate()),
        ); // Note: Perlu import AuthGate
        
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message = 'Register gagal.';
        if (e.code == 'weak-password') {
          message = 'Password terlalu lemah.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Email sudah digunakan.';
        } else if (e.code == 'invalid-email') {
          message = 'Format email tidak valid.';
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
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... AppBar tetap sama
      appBar: AppBar(
        title: const Text('LogiTrack - Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
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
            
            // 4. Tambahkan Tombol Register
            // Bungkus dengan SizedBox agar bisa mengatur lebar tombol
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isLoading ? 50 : constraints.maxWidth,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: isLoading ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 16),
                      shape: isLoading
                          ? const CircleBorder()
                          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : handleRegister,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                );
              }
            ),
            const SizedBox(height: 16), // Memberi jarak vertikal
            
            // 5. Tambahkan Tombol Login
            // Bungkus dengan SizedBox agar bisa mengatur lebar tombol
            SizedBox(
              width: double.infinity, // Lebar tombol penuh
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login'),
              ),
            ),
          ],  
        ),
      ),  
      ),
    );
  }
}