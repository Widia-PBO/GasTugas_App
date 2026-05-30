import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'tambah_tugas.dart';
import 'detail_tugas.dart';
import 'tugas_model.dart';

class DashboardPage extends StatelessWidget {
  final Function(int)? onNavigateToTab; // Callback navigasi navbar ke profile

  const DashboardPage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    // [MATERI: PROVIDER GLOBAL STATE MANAGEMENT] Sinkronisasi terpusat dengan MySQL Laragon
    final provider = context.watch<AppProvider>();

    final DateTime now = DateTime.now();
    final String formatHariIni =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Filter otomatis tugas khusus hari ini
    final List<Tugas> tugasHariIni = provider.daftarTugasUtama
        .where((t) => t.deadline == formatHariIni)
        .toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F8FF), // Latar belakang ungu pastel super soft
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B3FF2)))
            : RefreshIndicator(
                onRefresh: () => provider.ambilDataTugasDariMysql(),
                color: const Color(0xFF7B3FF2),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====================================================================
                      // FIX BARU: HEADER SEJAJAR - LOGO DI KIRI (BESAR), LONCENG & PROFIL DI KANAN
                      // ====================================================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Membuat semua komponen tegak lurus sejajar di tengah
                        children: [
                          // 1. Logo Utama di Pojok Kiri (Besar dan Proporsional)
                          Image.asset(
                            'assets/logo2.png',
                            height: 100, // Ukuran besar mantap sejajar
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Text(
                              'GasTugas',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B3FF2)),
                            ),
                          ),

                          // 2. Spacer Otomatis untuk mendorong kumpulan ikon aksi ke pojok kanan paling ujung
                          const Spacer(),

                          // 3. Kumpulan Aksi Lonceng + Avatar Profil (Tetap Sejajar dengan Logo)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.black87,
                                    size: 26),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Fitur Notifikasi akan segera hadir! 🔔")),
                                  );
                                },
                              ),
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () {
                                  if (onNavigateToTab != null) {
                                    onNavigateToTab!(
                                        2); // Pindah ke Tab Profile
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF7B3FF2),
                                  child: Text(
                                    provider.namaUserLoggedIn.isNotEmpty
                                        ? provider.namaUserLoggedIn[0]
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // 2. TEXT GREETING "Halo, Rina 🖐️"
                      // ==========================================
                      Text(
                        'Halo, ${provider.namaUserLoggedIn.isNotEmpty ? provider.namaUserLoggedIn : "User"} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xFF4A3764), // Ungu gelap elegan sesuai gambar
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ==========================================
                      // 3. NESTED CARD BOX: TUGAS HARI INI (LOGIKA WARNA MERAH)
                      // ==========================================
                      const Text(
                        'Tugas Hari Ini',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              16), // Lengkungan sudut rapi
                          border: Border.all(color: const Color(0xFFECE9F5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Baris Header di dalam Card
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    color: const Color(0xFF7B3FF2)
                                        .withValues(alpha: 0.7),
                                    size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  'Tugas Hari Ini',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87),
                                ),
                              ],
                            ),

                            // Pembatas tipis jika ada datanya
                            if (tugasHariIni.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                    color: Color(0xFFF3EFFF), height: 1),
                              ),

                            // List Tugas Inner Row
                            tugasHariIni.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 5),
                                    child: Text(
                                      'Tidak ada deadline hari ini',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: tugasHariIni.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                index == tugasHariIni.length - 1
                                                    ? 0
                                                    : 10),
                                        child: _buildInnerTaskRow(
                                            context, tugasHariIni[index], true),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==========================================
                      // 4. NESTED CARD BOX: DAFTAR SEMUA TUGAS (LOGIKA WARNA HIJAU)
                      // ==========================================
                      const Text(
                        'Daftar Tugas',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFECE9F5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: provider.daftarTugasUtama.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Center(
                                  child: Text('Belum ada tugas terdaftar.',
                                      style: TextStyle(
                                          color: Colors.black38, fontSize: 13)),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.daftarTugasUtama.length,
                                itemBuilder: (context, index) {
                                  final tgs = provider.daftarTugasUtama[index];
                                  bool cekApakahHariIni =
                                      tgs.deadline == formatHariIni;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index ==
                                                provider.daftarTugasUtama
                                                        .length -
                                                    1
                                            ? 0
                                            : 10),
                                    child: _buildInnerTaskRow(
                                        context, tgs, cekApakahHariIni),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(
                          height:
                              80), // Ruang kosong agar tidak tertutup tombol tambah
                    ],
                  ),
                ),
              ),
      ),

      // Floating Action Button (+) Ungu Bulat Sesuai Gambar
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B3FF2),
        elevation: 3,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TambahTugasPage())),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  // ====================================================================
  // REVISI FINAL: BARIS INTERNAL TUGAS YANG MEMILIKI STATUS SESUAI DATA
  // ====================================================================
  Widget _buildInnerTaskRow(BuildContext context, Tugas tugas, bool isToday) {
    // Logika pewarnaan bulatan indikator: Hari Ini -> Merah, Belum Hari Ini -> Hijau
    Color dotColor =
        isToday ? const Color(0xFFFF4B4B) : const Color(0xFF4CAF50);
    const Color rowBgColor =
        Color(0xFFF5EFFF); // Warna soft background ungu muda asli gambar

    // Penentuan warna dinamis teks dan background untuk Badge Status kecil sesuai datanya
    Color statusTextColor = tugas.status.toLowerCase() == 'sedang dikerjakan'
        ? const Color(0xFF2196F3) // Biru cerah progres
        : const Color(0xFFFFA000); // Oranye pending
    Color statusBgColor = tugas.status.toLowerCase() == 'sedang dikerjakan'
        ? const Color(0xFFE3F2FD)
        : const Color(0xFFFFF3E0);

    // Format tampilan teks tanggal singkat (Misal: 21 Mei / 24 Mei)
    String tanggalTampil = tugas.deadline;
    try {
      List<String> splitDate = tugas.deadline.split('-');
      if (splitDate.length == 3) {
        int bulanInt = int.parse(splitDate[1]);
        List<String> namaBulan = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
        tanggalTampil = "${int.parse(splitDate[2])} ${namaBulan[bulanInt]}";
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailTugasPage(tugas: tugas))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: rowBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Bulatan Polos Berwarna (Merah / Hijau)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Judul Tugas + Badge Status Di Bawahnya (Sesuai Datanya)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tugas.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Color(0xFF2D2543),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Baris Tambahan: Nama Mata Kuliah & Kapsul Badge Status Asli dari Data MySQL
                  Row(
                    children: [
                      Text(
                        tugas.mataKuliah,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // BADGE STATUS DINAMIS DI SETIAP CARD
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tugas
                              .status, // Menampilkan teks status asli ('Belum dikerjakan' / 'Sedang dikerjakan')
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Tanggal Batas Waktu Singkat + Panah Chevron Detail
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tanggalTampil,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black26,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
