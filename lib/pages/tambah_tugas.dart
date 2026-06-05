import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TambahTugasPage extends StatefulWidget {
  const TambahTugasPage({super.key});

  @override
  State<TambahTugasPage> createState() => _TambahTugasPageState();
}

class _TambahTugasPageState extends State<TambahTugasPage> {
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _matkulCtrl = TextEditingController();
  final TextEditingController _deadlineCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  String _statusSelected = 'Belum dikerjakan';

  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B3FF2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String bulan = picked.month.toString().padLeft(2, '0');
        String hari = picked.day.toString().padLeft(2, '0');
        _deadlineCtrl.text = "${picked.year}-$bulan-$hari";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Tugas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7B3FF2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(_judulCtrl, 'Judul Tugas', Icons.book),
            const SizedBox(height: 15),
            _buildField(_matkulCtrl, 'Mata Kuliah', Icons.school),
            const SizedBox(height: 15),
            TextField(
              controller: _deadlineCtrl,
              readOnly: true,
              onTap: () => _pilihTanggal(context),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.calendar_today, color: Color(0xFF7B3FF2)),
                labelText: 'Deadline',
                labelStyle: const TextStyle(color: Colors.black45),
                filled: true,
                fillColor: const Color(0xFFF3EFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildField(_deskripsiCtrl, 'Deskripsi', null, maxLines: 3),
            const SizedBox(height: 20),
            const Text(
              'Status Tugas',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4557),
                  fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              initialSelection: _statusSelected,
              width: MediaQuery.of(context).size.width - 40,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF3EFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    _statusSelected = value;
                  });
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry<String>(
                  value: 'Belum dikerjakan',
                  label: 'Belum dikerjakan',
                  leadingIcon: Icon(Icons.radio_button_checked,
                      color: Color(0xFF7B3FF2)),
                ),
                DropdownMenuEntry<String>(
                  value: 'Sedang dikerjakan',
                  label: 'Sedang dikerjakan',
                  leadingIcon:
                      Icon(Icons.hourglass_bottom, color: Colors.orangeAccent),
                ),
              ],
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B3FF2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  if (_judulCtrl.text.isEmpty ||
                      _matkulCtrl.text.isEmpty ||
                      _deadlineCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Harap isi Judul, Mata Kuliah, dan Deadline!")),
                    );
                    return;
                  }

                  final sukses =
                      await context.read<AppProvider>().tambahTugasBaru(
                            _judulCtrl.text,
                            _matkulCtrl.text,
                            _deadlineCtrl.text,
                            _deskripsiCtrl.text,
                          );

                  if (context.mounted) {
                    if (sukses) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Tugas berhasil disimpan ke server!")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal menyimpan tugas!")),
                      );
                    }
                  }
                },
                child: const Text(
                  'Simpan Tugas',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData? icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF7B3FF2)) : null,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFF3EFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
