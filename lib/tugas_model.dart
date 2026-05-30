class Tugas {
  final String idTugas;
  final String judul;
  final String mataKuliah;
  final String deadline;
  final String deskripsi;
  final String status;

  Tugas({
    required this.idTugas,
    required this.judul,
    required this.mataKuliah,
    required this.deadline,
    required this.deskripsi,
    required this.status,
  });

  // [MATERI 5: CRUD & JSON MAPPING] Konversi data JSON database MySQL ke Objek Dart
  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      idTugas: json['id_tugas'].toString(),
      judul: json['judul'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      deadline: json['deadline'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'Belum dikerjakan',
    );
  }
}