// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../main.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formLoginKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final authProvider = context.read<AuthProvider>(); // Ambil AuthProvider

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formLoginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Image.asset('assets/logo.png',
                    width: 230,
                    errorBuilder: (c, e, s) => const Icon(Icons.book_rounded,
                        size: 90, color: Color(0xFF7B3FF2))),
              ),
              const SizedBox(height: 40),
              const Text('Masuk',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B3FF2))),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: _buildInputDecoration('Alamat Email', Icons.email),
                validator: (val) => (val == null || !val.contains('@'))
                    ? 'Email tidak valid'
                    : null,
              ),
              const SizedBox(height: 15),

              // Password
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                decoration:
                    _buildInputDecoration('Kata sandi', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Password wajib diisi'
                    : null,
              ),

              const SizedBox(height: 35),

              // Tombol Masuk Manual
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FF2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (_formLoginKey.currentState!.validate()) {
                      final res = await provider.prosesLogin(
                          _emailCtrl.text.trim(), _passCtrl.text.trim());
                      if (!context.mounted) return;
                      if (res['status'] == true) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainNavigation()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(res['message'] ?? "Gagal masuk")));
                      }
                    }
                  },
                  child: const Text('Masuk',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              const Center(child: Text("atau")),
              const SizedBox(height: 20),

              // TOMBOL LANJUTKAN DENGAN GOOGLE (BARU)
              // TOMBOL LANJUTKAN DENGAN GOOGLE
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // 1. Jalankan proses autentikasi
                    final authResult = await authProvider.authenticate(
                        context: context, isGoogle: true, isRegister: false);

                    // Cek apakah layar masih aktif setelah proses async (await) pertama
                    if (!context.mounted) return;

                    // 2. Cek apakah user berhasil login dari hasil auth (bisa cek status atau currentUser)
                    if (authProvider.currentUser != null) {
                      // 3. Tarik data user ke AppProvider
                      await context.read<AppProvider>().cekSessionLogin();

                      // Cek lagi apakah layar masih aktif sebelum pindah halaman
                      if (!context.mounted) return;

                      // 4. Pindah ke MainNavigation
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainNavigation()),
                      );
                    } else {
                      // Beri feedback jika login gagal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                authResult['message'] ?? "Login Google Gagal")),
                      );
                    }
                  },
                  icon: const Icon(Icons.login, color: Color(0xFF7B3FF2)),
                  label: const Text("Lanjutkan dengan Google"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7B3FF2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage())),
                    child: const Text('Daftar Sekarang',
                        style: TextStyle(
                            color: Color(0xFF7B3FF2),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF7B3FF2)),
      filled: true,
      fillColor: const Color(0xFFF3EFFF),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B3FF2))),
    );
  }
}
