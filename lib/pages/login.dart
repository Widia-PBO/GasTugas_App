// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // [MATERI 12: FORM VALIDATION KEY] Kunci pengontrol validasi input massal
  final _formLoginKey = GlobalKey<FormState>();
  
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  // State untuk mengontrol visibilitas password (lihat/sembunyi)
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Membaca instance AppProvider (Materi 13)
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formLoginKey, // Bungkus Column dengan widget Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Gaya rata kiri clean
            children: [
              const SizedBox(height: 100),
              Center(
                  child: Image.asset('assets/logo.png',
                      width: 230,
                      errorBuilder: (c, e, s) => const Icon(Icons.book_rounded,
                          size: 90, color: Color(0xFF7B3FF2)))),
              const SizedBox(height: 40),
              const Text('Login',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B3FF2))),
              const SizedBox(height: 20),

              // 1. Kolom Input Email dengan Validasi Otomatis (Materi 12)
              TextFormField(
                controller: _emailCtrl,
                decoration: _buildInputDecoration('Email Address', Icons.email),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat email tidak boleh kosong! ⚠️';
                  }
                  if (!value.contains('@')) {
                    return 'Format alamat email tidak valid! ⚠️';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 2. Kolom Input Password dengan Validasi & Fitur Toggle Lihat/Sembunyi
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: const Color(0xFF7B3FF2).withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password wajib diisi! ⚠️';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 35),

              // 3. Tombol Masuk / Login Terintegrasi Sesi Shared Preferences & Async-Await (Materi 10 & 11)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FF2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    // Memicu validasi form internal sebelum menembak API Laragon
                    if (_formLoginKey.currentState!.validate()) {
                      
                      // Mengirim request data secara Asynchronous (Materi 10)
                      final res = await provider.prosesLogin(
                          _emailCtrl.text.trim(), _passCtrl.text.trim());
                      
                      if (!context.mounted) return;
                      
                      // Jika status bernilai true (Login berhasil & Sesi SPREF terkunci)
                      if (res['status'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login Berhasil! Selamat datang kembali. 👋")),
                        );
                        
                        // Masuk ke halaman utama dashboard & hapus tumpukan halaman login (Materi 09)
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainNavigation()));
                      } else {
                        // Memunculkan SnackBar pesan error dinamis kiriman login.php Laragon (Misal: Password salah!)
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'] ?? "Gagal masuk.")));
                      }
                    }
                  },
                  child: const Text('Masuk',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 35),

              // 4. Baris Navigasi beralih ke halaman Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage())),
                    child: const Text('Daftar',
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

  // Desain dasar tema input dekorasi terpusat (Materi 08)
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF7B3FF2).withValues(alpha: 0.4)),
      prefixIcon: Icon(icon, color: const Color(0xFF7B3FF2)),
      filled: true,
      fillColor: const Color(0xFFF3EFFF),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B3FF2), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }
}