import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tambah_tugas.dart';
import 'detail_tugas.dart';
import '../models/tugas_model.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const DashboardPage({super.key, this.onNavigateToTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryUngu = const Color(0xFF7B3FF2);
  final Color gradientUngu = const Color(0xFF9D67F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().ambilDataTugasDariMysql();
      context.read<AppProvider>().cekSessionLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final String formatHariIni = DateTime.now().toString().split(' ')[0];

    final semua = provider.daftarTugasUtama
        .where((t) => t.status.toLowerCase() != 'selesai')
        .toList();
    final hariIni = semua.where((t) => t.deadline == formatHariIni).toList();
    final lainnya = semua.where((t) => t.deadline != formatHariIni).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
      appBar: AppBar(
        backgroundColor: primaryUngu,
        elevation: 0,
        title: const Text("GasTugas",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => widget.onNavigateToTab?.call(2),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                    provider.namaUserLoggedIn.isNotEmpty
                        ? provider.namaUserLoggedIn[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryUngu))
          : RefreshIndicator(
              onRefresh: () => provider.ambilDataTugasDariMysql(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- WELCOME GRADIENT CARD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: [primaryUngu, gradientUngu]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Halo, ${provider.namaUserLoggedIn.split(' ')[0]}! 👋',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          const Text(
                              'Waktunya produktif hari ini.\nTetap semangat ya! ✨',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Tugas Hari Ini'),
                    const SizedBox(height: 16),
                    _buildCardList(hariIni, formatHariIni),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Daftar Tugas Lainnya'),
                    const SizedBox(height: 16),
                    _buildCardList(lainnya, formatHariIni),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryUngu,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TambahTugasPage())),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D2543)));

  Widget _buildCardList(List<Tugas> list, String today) {
    if (list.isEmpty) {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: const Text("Belum ada tugas",
              style: TextStyle(color: Colors.black38)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, i) =>
          _buildModernCard(list[i], list[i].deadline == today),
    );
  }

  Widget _buildModernCard(Tugas tugas, bool isToday) {
    final Color accentColor =
        isToday ? const Color(0xFFFF4B4B) : const Color(0xFF4CAF50);
    final Color bgColor = isToday
        ? const Color(0xFFFF4B4B).withValues(alpha: 0.1)
        : const Color(0xFF4CAF50).withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailTugasPage(tugas: tugas))),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.assignment_rounded, color: accentColor, size: 20),
        ),
        title: Text(tugas.judul,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                color: Color(0xFF2D2543))),
        subtitle: Text("${tugas.mataKuliah} • ${tugas.status}",
            style: const TextStyle(fontSize: 11.5)),
        trailing:
            const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
      ),
    );
  }
}
