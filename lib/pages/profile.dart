import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 2. "Jaring Pengaman": Memastikan data di-refresh saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().cekSessionLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    // [MATERI: PROVIDER GLOBAL STATE MANAGEMENT] Sinkronisasi data secara real-time
    final provider = context.watch<AppProvider>();

    // TAMBAHKAN BARIS INI untuk cek di Debug Console VS Code
    debugPrint("DEBUG PROFIL - Nama: ${provider.namaUserLoggedIn}");
    debugPrint("DEBUG PROFIL - Institusi: ${provider.institusiUserLoggedIn}");
    debugPrint("DEBUG PROFIL - Prodi: ${provider.prodiUserLoggedIn}");

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF), // Putih keunguan super clean
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. PREMIUM GRADIENT HEADER CANVAS WITH AVATAR (COMPACT CLEAN VERSION) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 65,
                  bottom: 30), // Padding disesuaikan agar lebih ringkas & pas
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3EFFF),
                    Color(0xFFEBE5FF),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B3FF2).withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Avatar Lingkaran dengan Ring Border Ganda yang Estetik
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B3FF2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: Text(
                          provider.namaUserLoggedIn.isNotEmpty
                              ? provider.namaUserLoggedIn[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF7B3FF2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nama Besar Pengguna
                  Text(
                    provider.namaUserLoggedIn.isNotEmpty
                        ? provider.namaUserLoggedIn
                        : "User GasTugas",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2543),
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),

                  // Email Badge Minimalis
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      provider.emailUserLoggedIn.isNotEmpty
                          ? provider.emailUserLoggedIn
                          : "mahasiswa@polindra.ac.id",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B3FF2),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. DETAIL ACCOUNT CARD SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 6, bottom: 12),
                    child: Text(
                      'INFORMASI AKADEMIK & AKUN',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black38,
                          letterSpacing: 1.0),
                    ),
                  ),

                  // Card Konten Utama Tunggal yang Clean & Lembut
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFECEEFA)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.005),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildIdentityRow(Icons.person_outline_rounded,
                            'Nama Lengkap', provider.namaUserLoggedIn),
                        _buildCustomDivider(),
                        _buildIdentityRow(Icons.email_outlined, 'Alamat Email',
                            provider.emailUserLoggedIn),
                        _buildCustomDivider(),
                        _buildIdentityRow(
                          Icons.school_outlined,
                          'Institusi / Kampus',
                          provider.institusiUserLoggedIn.isNotEmpty
                              ? provider.institusiUserLoggedIn
                              : "-",
                        ),
                        _buildCustomDivider(),
                        _buildIdentityRow(
                          Icons.badge_outlined,
                          'Program Studi',
                          provider.prodiUserLoggedIn.isNotEmpty
                              ? provider.prodiUserLoggedIn
                              : "-",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- 3. ERGONOMIS LOGOUT ACTION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFECEE),
                        foregroundColor: const Color(0xFFFF4D5A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // [MATERI: SHARED PREFERENCES RESET SESI]
                        provider.prosesLogout(context);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "LOGOUT",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Divider halus antar baris data
  Widget _buildCustomDivider() {
    return const Divider(color: Color(0xFFF6F5FA), height: 1, thickness: 1);
  }

  // Widget baris data profil yang presisi dan seimbang
  Widget _buildIdentityRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF7B3FF2), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isNotEmpty ? value : "-",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF352E4B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
