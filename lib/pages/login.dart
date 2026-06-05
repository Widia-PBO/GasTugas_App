import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
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
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<AppProvider>();

    final authResult = await authProvider.authenticate(
        context: context, isGoogle: true, isRegister: false);

    if (!context.mounted) return;

    if (authProvider.currentUser != null) {
      // Ambil profil & tugas
      await appProvider.fetchProfilDariMysql(authProvider.currentUser!.email!);
      await appProvider.ambilDataTugasDariMysql();

      if (!context.mounted) return;
      navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(authResult['message'] ?? "Login Google Gagal"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
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

              TextFormField(
                controller: _emailCtrl,
                decoration: _buildInputDecoration('Alamat Email', Icons.email),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                decoration: _buildInputDecoration('Password', Icons.lock),
              ),

              const SizedBox(height: 25),

              // 1. TOMBOL MASUK MANUAL
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FF2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    // Panggil fungsi login manual
                    final authProvider = context.read<AuthProvider>();
                    final appProvider = context.read<AppProvider>();

                    // Ambil hasil return dari fungsi authenticate
                    final result = await authProvider.authenticate(
                      context: context,
                      isGoogle: false,
                      isRegister: false,
                      email: _emailCtrl.text.trim(),
                      password: _passCtrl.text.trim(),
                    );

                    // CEK APAKAH LOGIN BERHASIL
                    if (result['status'] == true) {
                      // 1. Ambil data profil setelah login
                      await appProvider
                          .fetchProfilDariMysql(_emailCtrl.text.trim());
                      await appProvider.ambilDataTugasDariMysql();

                      // 2. Pindah ke Dashboard
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MainNavigation()), // Sesuaikan dengan navigasi utamamu
                        );
                      }
                    } else {
                      // 3. Jika gagal, tampilkan pesan error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(result['message'] ?? "Login Gagal")),
                        );
                      }
                    }
                  },
                  child: const Text('Masuk',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 15),

              // 2. TOMBOL LANJUTKAN DENGAN GOOGLE
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _handleGoogleLogin(context),
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
