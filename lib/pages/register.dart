import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Pastikan import AuthProvider

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _institusiController = TextEditingController();
  final _prodiController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institusiController.dispose();
    _prodiController.dispose();
    super.dispose();
  }

  // FUNGSI PROSES REGISTRASI KE AUTH PROVIDER
  Future<void> _handleRegister() async {
    // 1. Validasi input
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Email, dan Password wajib diisi!")),
      );
      return;
    }

    // 2. Panggil AuthProvider
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Gunakan fungsi authenticate dengan isRegister: true agar mengarah ke register.php
    // Di dalam register.dart, update _handleRegister:
    final result = await auth.authenticate(
      context: context,
      isGoogle: false,
      isRegister: true,
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      institusi: _institusiController.text.trim(), // Kirim data dari controller
      prodi: _prodiController.text.trim(), // Kirim data dari controller
    );

    // 3. Respon ke UI
    if (!mounted) return;

    if (result['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Registrasi berhasil!")),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Registrasi gagal!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                      errorBuilder: (c, e, s) => const Icon(Icons.book_rounded,
                          size: 85, color: Color(0xFF7B3FF2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Daftar Akun',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B3FF2))),
                  const SizedBox(height: 25),

                  _buildField(_namaController, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 15),
                  _buildField(_emailController, 'Email Address', Icons.email),
                  const SizedBox(height: 15),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFF7B3FF2)),
                      filled: true,
                      fillColor: const Color(0xFFF3EFFF),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7B3FF2)),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                      _institusiController, 'Institusi Kampus', Icons.school),
                  const SizedBox(height: 15),
                  _buildField(
                      _prodiController, 'Program Studi / Prodi', Icons.badge),
                  const SizedBox(height: 30),

                  // Button Daftar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3FF2)),
                      onPressed: _handleRegister,
                      child: const Text('Daftar Sekarang',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF7B3FF2)),
        filled: true,
        fillColor: const Color(0xFFF3EFFF),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }
}
