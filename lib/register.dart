import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

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

  // State untuk mengontrol visibilitas password
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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih murni
      body: SafeArea(
        child: Center( // Membuat semua konten otomatis berada di tengah layar secara vertikal & horizontal
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Padding ideal
            child: ConstrainedBox(
              // FIXED LAYOUT: Membatasi lebar agar pas (tidak kekecilan dan tidak kebesaran)
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri clean khas Login
                children: [
                  // --- 1. LOGO GASTUGAS (DI TENGAH LAYOUT) ---
                  Center(
                    child: Image.asset(
                      'assets/logo.png', 
                      width: 200, // Ukuran diperkecil sedikit agar lebih pas dan proporsional
                      errorBuilder: (c, e, s) => const Icon(Icons.book_rounded, size: 85, color: Color(0xFF7B3FF2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 2. HEADER TEXT ---
                  const Text(
                    'Daftar Akun',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF7B3FF2), // Ungu utama
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lengkapi data diri dan studi bebas untuk profilmu.',
                    style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 25),

                  // --- 3. INPUT FIELDS SECTION (CLEAN & PROPORSONAL) ---
                  _buildField(_namaController, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 15),
                  
                  _buildField(_emailController, 'Email Address', Icons.email),
                  const SizedBox(height: 15),

                  // Kustom TextField Password khusus dengan Tombol Mata (Toggle Visibility)
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: const Color(0xFF7B3FF2).withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF7B3FF2)),
                      filled: true, 
                      fillColor: const Color(0xFFF3EFFF),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Menjaga teks simetris di tengah
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7B3FF2), width: 1.5)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: const Color(0xFF7B3FF2).withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildField(_institusiController, 'Institusi Kampus', Icons.school),
                  const SizedBox(height: 15),

                  _buildField(_prodiController, 'Program Studi / Prodi', Icons.badge),
                  const SizedBox(height: 30),

                  // --- 4. BUTTON DAFTAR ---
                  SizedBox(
                    width: double.infinity, 
                    height: 52, // Tinggi tombol ideal
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B3FF2), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Radius 10
                        elevation: 0,
                      ),
                      onPressed: () async {
                        bool sukses = await provider.prosesRegistrasiUser(
                          nama: _namaController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          institusi: _institusiController.text,
                          prodi: _prodiController.text,
                        );

                        if (context.mounted) {
                          if (sukses) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Registrasi berhasil! Silakan login. 🔓")),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Registrasi gagal! Cek koneksi Laragon kamu.")),
                            );
                          }
                        }
                      },
                      child: const Text('Daftar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- 5. NAVIGASI KEMBALI KE LOGIN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? '),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // FIXED: Memakai onTap bawaan yang benar
                        child: const Text('Login', style: TextStyle(color: Color(0xFF7B3FF2), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pembantu TextField dinamis (Bentuk 100% kembar identik dengan style Login)
  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF7B3FF2).withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: const Color(0xFF7B3FF2)),
        filled: true, 
        fillColor: const Color(0xFFF3EFFF),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7B3FF2), width: 1.5)),
      ),
    );
  }
}