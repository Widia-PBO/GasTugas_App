import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tambah_tugas.dart';
import 'detail_tugas.dart';
import '../models/tugas_model.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sinkronisasi state daftar tugas secara terpusat
    final provider = context.watch<AppProvider>();

    // Filter tugas yang belum selesai
    final List<Tugas> daftarReminder = provider.daftarTugasUtama
        .where((t) => t.status.toLowerCase() != 'selesai')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // --- LOGO GASTUGAS ---
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Text('GasTugas',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B3FF2))),
              ),
            ),
            const SizedBox(height: 24),

            // --- JUDUL REMINDER ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: Color(0xFF7B3FF2), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Reminder Tugas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3E65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- DAFTAR LIST REMINDER ---
            Expanded(
              child: daftarReminder.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_off_rounded,
                              color: Colors.black26, size: 48),
                          SizedBox(height: 12),
                          Text('Belum ada alarm aktif.',
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: daftarReminder.length,
                      itemBuilder: (context, index) {
                        final item = daftarReminder[index];
                        return _buildReminderCard(context, item);
                      },
                    ),
            ),

            // --- TOMBOL TAMBAH TUGAS ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FF2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TambahTugasPage()),
                  ),
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                  label: const Text('Tambah Tugas Baru',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kartu reminder
  Widget _buildReminderCard(BuildContext context, Tugas item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE9F5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailTugasPage(tugas: item))),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFF5EFFF),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.alarm_on_rounded,
              color: Color(0xFF7B3FF2), size: 20),
        ),
        title: Text(item.judul,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Color(0xFF2D2543))),
        subtitle: Text("${item.mataKuliah} • ${item.status}",
            style: const TextStyle(fontSize: 11.5)),
        trailing:
            const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
      ),
    );
  }
}
