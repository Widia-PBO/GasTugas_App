import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'tambah_tugas.dart';
import 'detail_tugas.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // [MATERI: PROVIDER GLOBAL STATE MANAGEMENT] Sinkronisasi state daftar tugas secara terpusat
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F8FF), // Latar belakang ungu pastel super soft
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height:
                    24), // Memberi ruang napas yang rapi di area paling atas layar

            // ====================================================================
            // 1. UTAMA PALING ATAS: LOGO GASTUGAS PAS DI TENGAH-TENGAH LAYAR (CLEAN TOTAL)
            // ====================================================================
            Align(
              alignment:
                  Alignment.center, // Memaksa logo berada tepat di tengah layar
              child: Image.asset(
                'assets/logo.png',
                height:
                    150, // Tinggi ideal logo vertikal agar proporsional dan rapi
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Text(
                  'GasTugas',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B3FF2)),
                ),
              ),
            ),

            // ====================================================================
            // 2. DI BAWAH LOGO: SUB-JUDUL "Reminder Tugas" + LONCENG UNGU
            // ====================================================================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: Color(0xFF7B3FF2), size: 26), // Ikon lonceng
                  SizedBox(width: 10),
                  Text(
                    'Reminder Tugas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3E65), // Warna ungu gelap anggun
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // ====================================================================
            // KONTEN UTAMA: DAFTAR LIST REMINDER DENGAN ISI CARD LENGKAP DATA ASLI
            // ====================================================================
            Expanded(
              child: provider.daftarTugasUtama.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_off_rounded,
                              color: Colors.black26, size: 44),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada alarm reminder aktif.',
                            style: TextStyle(
                                color: Colors.black38,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.daftarTugasUtama.length,
                      itemBuilder: (context, index) {
                        final item = provider.daftarTugasUtama[index];

                        // Logika warna badge status dinamis sesuai database Laragon
                        Color statusTextColor =
                            item.status.toLowerCase() == 'sedang dikerjakan'
                                ? const Color(0xFF2196F3)
                                : const Color(0xFFFFA000);
                        Color statusBgColor =
                            item.status.toLowerCase() == 'sedang dikerjakan'
                                ? const Color(0xFFE3F2FD)
                                : const Color(0xFFFFF3E0);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailTugasPage(tugas: item))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFECE9F5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.01),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Ikon Notifikasi Ungu Lembut di Kiri Card
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3EFFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.alarm_on_rounded,
                                      color: Color(0xFF7B3FF2), size: 22),
                                ),
                                const SizedBox(width: 16),

                                // Informasi Data Tugas Kuliah secara Lengkap
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // A. Judul Tugas
                                      Text(
                                        item.judul,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF2D2543)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // B. Mata Kuliah & Kapsul Badge Status Asli Data
                                      Row(
                                        children: [
                                          Text(
                                            item.mataKuliah,
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: statusBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                color: statusTextColor,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // C. Tanggal Batas Waktu (Deadline)
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_month_rounded,
                                              size: 13,
                                              color: Color(0xFF7B3FF2)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Deadline: ${item.deadline}",
                                            style: const TextStyle(
                                                color: Color(0xFF7B3FF2),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(Icons.chevron_right_rounded,
                                    color: Colors.black26, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ====================================================================
            // UTILITY BAWAH: BUTTON TAMBAH TUGAS KAPSUL UNGU POLOS CLEAN
            // ====================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TambahTugasPage()),
                  ),
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                  label: const Text(
                    'Tambah Tugas Baru',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
