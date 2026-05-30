import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'main.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Mengikuti gaya rata kiri halaman register baru
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

            // 1. Kolom Input Email (Menggunakan fungsi bawaanmu)
            _buildField(_emailCtrl, 'Email Address', Icons.email),
            const SizedBox(height: 15),

            // 2. Kustom Kolom Input Password dengan Fitur Toggle Lihat/Sembunyi
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePassword, // Diatur dinamis lewat state
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                    color: const Color(0xFF7B3FF2).withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF7B3FF2)),
                filled: true,
                fillColor: const Color(0xFFF3EFFF),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF7B3FF2), width: 1.5)),

                // Tambahan tombol ikon mata di ujung kanan kolom password
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF7B3FF2).withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword; // Mengubah status sembunyi/lihat teks
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 35),

            // 3. Tombol Masuk / Login
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FF2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  final res = await provider.prosesLogin(
                      _emailCtrl.text, _passCtrl.text);
                  if (!context.mounted) return;
                  if (res['status'] == true) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainNavigation()));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(res['message'])));
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
    );
  }

  // Widget pembantu awal kamu untuk input Email
  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: const Color(0xFF7B3FF2).withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: const Color(0xFF7B3FF2)),
        filled: true,
        fillColor: const Color(0xFFF3EFFF),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7B3FF2), width: 1.5)),
      ),
    );
  }
}
