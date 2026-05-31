import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/tugas_model.dart';

class DetailTugasPage extends StatefulWidget {
  final Tugas tugas;
  const DetailTugasPage({super.key, required this.tugas});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  late TextEditingController _judulController;
  late TextEditingController _matkulController;
  late TextEditingController _deadlineController;
  late TextEditingController _deskripsiController;

  String _statusTerbaru = 'Belum dikerjakan';
  final List<String> _opsiStatus = ['Belum dikerjakan', 'Sedang dikerjakan'];

  // Kumpulan kata motivasi acak untuk pop-up sukses
  final List<String> _listMotivasi = [
    "Sedikit demi sedikit tugasmu akan selesai.",
    "Hebat banget! Satu beban hidup perkuliahan resmi sirna! ✨🚀",
    "Gaspol terus! Dosen bangga, IPK aman, masa depan cerah menanti! 🎯🔥",
    "Mantap! Tugas selesai, waktunya istirahat atau mabar tanpa beban! 🎮",
    "Alhamdulillah! Selangkah lebih dekat menuju gelar sarjana! 🎓"
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.tugas.judul);
    _matkulController = TextEditingController(text: widget.tugas.mataKuliah);
    _deadlineController = TextEditingController(text: widget.tugas.deadline);
    _deskripsiController = TextEditingController(text: widget.tugas.deskripsi);

    if (_opsiStatus.contains(widget.tugas.status)) {
      _statusTerbaru = widget.tugas.status;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _matkulController.dispose();
    _deadlineController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.tugas.deadline) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ==========================================
  // POP-UP DIALOG MOTIVASI SESUAI IMAGE_17706A.PNG
  // ==========================================
  void _tampilkanPopUpSukses(BuildContext context, String kalimatMotivasi) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'POPUP MOTIVASI',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A4595)),
                ),
                const SizedBox(height: 10),
                Text(
                  '🎉 Selamat!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2543).withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tugas berhasil diselesaikan',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '"$kalimatMotivasi"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6A4595),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C41EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('OK',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _tampilkanDialogHapus(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan klik area luar
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Sampah dengan background soft red
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFFF4B4B), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hapus Permanen?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2543)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah kamu yakin ingin menghapus tugas ini secara permanen dari database?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Tombol Batal & Hapus
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.black45,
                        ),
                        child: const Text("Batal",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4B4B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Tutup dialog
                          bool sukses = await provider
                              .hapusTugasPermanen(widget.tugas.idTugas);
                          if (context.mounted) {
                            if (sukses) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Tugas berhasil dihapus! 🗑️")),
                              );
                              Navigator.pop(context); // Kembali ke dashboard
                            }
                          }
                        },
                        child: const Text("Ya, Hapus",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.black54, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Image.asset(
                'assets/logo.png',
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'Detail Tugas',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3E65)),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEAFA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBoxTextField(
                      controller: _judulController,
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Judul',
                    ),
                    const SizedBox(height: 14),

                    _buildBoxTextField(
                      controller: _matkulController,
                      icon: Icons.school_outlined,
                      label: 'Mata Kuliah',
                    ),
                    const SizedBox(height: 14),

                    _buildBoxTextField(
                      controller: _deadlineController,
                      icon: Icons.calendar_today_rounded,
                      label: 'Deadline',
                      readOnly: true,
                      onTap: () => _pilihTanggal(context),
                    ),
                    const SizedBox(height: 14),

                    const Text('  Deskripsi :',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E9FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _deskripsiController,
                        maxLines: 4,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('  Status :',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E9FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusTerbaru,
                          icon: const Icon(Icons.arrow_drop_down_rounded,
                              color: Color(0xFF7B3FF2)),
                          style: const TextStyle(
                              color: Color(0xFF2D2543),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _statusTerbaru = newValue;
                              });
                            }
                          },
                          items: _opsiStatus
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // REVISI: TOMBOL EDIT & HAPUS SAMA PANJANG LEBAR (SIMETRIS)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Button Hapus (Kotak Simetris)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical:
                                      14), // Di-matching agar tinggi seimbang
                              side: const BorderSide(
                                  color: Color(0xFFFFD1D1), width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                _tampilkanDialogHapus(context, provider),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 24),
                          ),
                        ),
                        const SizedBox(
                            width: 16), // Jarak renggang estetik di tengah

                        // Button Simpan Edit (Kotak Simetris - Sama Lebar 50:50 dengan tombol Hapus)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                  color: Color(0xFFE5D5FF), width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              bool sukses = await provider.perbaruiDataTugas(
                                idTugas: widget.tugas.idTugas,
                                judul: _judulController.text,
                                mataKuliah: _matkulController.text,
                                deadline: _deadlineController.text,
                                deskripsi: _deskripsiController.text,
                                status: _statusTerbaru,
                              );
                              if (context.mounted) {
                                if (sukses) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Perubahan berhasil disimpan! 💾")),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Gagal menyimpan perubahan!")),
                                  );
                                }
                              }
                            },
                            child: const Icon(Icons.save_rounded,
                                color: Color(0xFF7B3FF2), size: 24),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tombol Utama Panjang: Tandai Selesai
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9147FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          bool sukses =
                              await provider.tandaiTugasSelesai(widget.tugas);
                          if (context.mounted) {
                            if (sukses) {
                              final random = Random();
                              String kalimatSemangat = _listMotivasi[
                                  random.nextInt(_listMotivasi.length)];
                              _tampilkanPopUpSukses(context, kalimatSemangat);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Gagal memproses penyelesaian tugas.")),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check,
                            size: 20, color: Colors.white),
                        label: const Text(
                          'Tandai Selesai',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2543)),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF9147FF), size: 20),
          hintText: label,
          prefixText: '$label :  ',
          prefixStyle: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
