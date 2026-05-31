import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tambah_tugas.dart';
import 'detail_tugas.dart';
import '../models/tugas_model.dart';

// 1. Ubah ke StatefulWidget agar bisa memanggil fungsi saat halaman dibuka
class DashboardPage extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardPage({super.key, this.onNavigateToTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // 2. "Jaring Pengaman": Memastikan data ditarik setiap kali dashboard dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().ambilDataTugasDariMysql();
      context.read<AppProvider>().cekSessionLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final DateTime now = DateTime.now();
    final String formatHariIni =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 1. Ambil semua yang BELUM selesai
    final List<Tugas> semuaBelumSelesai = provider.daftarTugasUtama
        .where((t) => t.status.toLowerCase() != 'selesai')
        .toList();

// 2. Filter untuk "Tugas Hari Ini"
    final List<Tugas> tugasHariIni =
        semuaBelumSelesai.where((t) => t.deadline == formatHariIni).toList();

// 3. Filter untuk "Daftar Tugas" (Sisa tugas yang bukan hari ini)
    final List<Tugas> daftarTugasLain =
        semuaBelumSelesai.where((t) => t.deadline != formatHariIni).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
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
                      // HEADER
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/logo2.png',
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Text('GasTugas',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7B3FF2)))),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.black87,
                                    size: 26),
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            "Fitur Notifikasi segera hadir! 🔔"))),
                              ),
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () => widget.onNavigateToTab?.call(2),
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
                      Text(
                        'Halo, ${provider.namaUserLoggedIn.isNotEmpty ? provider.namaUserLoggedIn : "User"} 👋',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3764)),
                      ),
                      const SizedBox(height: 20),

                      // LIST TUGAS HARI INI
                      const Text('Tugas Hari Ini',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      const SizedBox(height: 10),
                      _buildCardContainer(
                          tugasHariIni, formatHariIni), // <--- Ini yang duluan

                      const SizedBox(height: 25),

                      // LIST SEMUA TUGAS (Daftar Tugas)
                      const Text('Daftar Tugas',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      const SizedBox(height: 10),
                      _buildCardContainer(daftarTugasLain,
                          formatHariIni), // <--- Ini yang setelahnya
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
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

  Widget _buildCardContainer(List<Tugas> list, String today) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE9F5)),
      ),
      child: list.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                  child: Text('Belum ada tugas',
                      style: TextStyle(color: Colors.black38))))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, i) => _buildInnerTaskRow(
                  context, list[i], list[i].deadline == today),
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
