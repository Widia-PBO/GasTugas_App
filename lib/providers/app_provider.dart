import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import '../tugas_model.dart';

class AppProvider extends ChangeNotifier {
  List<Tugas> _daftarTugasUtama = [];
  String _idUserLoggedIn = "";
  String _namaUserLoggedIn = "";
  String _emailUserLoggedIn = "";
  
  // Menampung data teks bebas profil institusi dan prodi
  String _institusiUserLoggedIn = "";
  String _prodiUserLoggedIn = "";
  bool _isLoading = false;

  List<Tugas> get daftarTugasUtama => _daftarTugasUtama;
  String get namaUserLoggedIn => _namaUserLoggedIn;
  String get emailUserLoggedIn => _emailUserLoggedIn;
  
  // Getters untuk dibaca langsung oleh ProfilePage
  String get institusiUserLoggedIn => _institusiUserLoggedIn;
  String get prodiUserLoggedIn => _prodiUserLoggedIn;
  bool get isLoading => _isLoading;

  // [MATERI 11: SHARED PREFERENCES] Sinkronisasi Sesi Auto-Login
  Future<void> cekSessionLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _idUserLoggedIn = prefs.getString('id_user') ?? "";
    _namaUserLoggedIn = prefs.getString('nama') ?? "";
    _emailUserLoggedIn = prefs.getString('email') ?? "";
    
    // Memuat data institusi dan prodi yang tersimpan di memori HP
    _institusiUserLoggedIn = prefs.getString('institusi') ?? "";
    _prodiUserLoggedIn = prefs.getString('prodi') ?? "";

    if (_idUserLoggedIn.isNotEmpty) {
      await ambilDataTugasDariMysql();
    }
    notifyListeners(); // Memicu UI Profile memperbarui tampilan saat buka aplikasi
  }

  // ====================================================================
  // [MATERI 10 & 12: ASYNC & HTTP CRUD] REVISI LANGKAH 1 - REGISTER USER
  // ====================================================================
  Future<bool> prosesRegistrasiUser({
    required String nama,
    required String email,
    required String password,
    required String institusi,
    required String prodi,
  }) async {
    _isLoading = true;
    notifyListeners(); // Memicu loading spinner di UI halaman pendaftaran (UX Handling)

    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/register.php"),
        body: {
          "nama": nama,
          "email": email,
          "password": password,
          "institusi": institusi, 
          "prodi": prodi,         
        },
      );
      
      final resData = jsonDecode(response.body);
      
      // SINKRONISASI: Mengubah dari 'status' ke 'success' sesuai register.php Laragon
      if (resData['success'] == true) {
        return true;
      }
    } catch (e) {
      debugPrint("Error Proses Registrasi Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Menghentikan loading spinner (UI tidak freeze - Memenuhi P1)
    }
    return false;
  }

  // [MATERI 10, 11 & 12: ASYNC, HTTP, SP] Login & Menyimpan Sesi Akun
  Future<Map<String, dynamic>> prosesLogin(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/login.php"),
        body: {"email": email, "password": password},
      );
      final resData = jsonDecode(response.body);

      if (resData['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        _idUserLoggedIn = resData['data']['id_user'].toString();
        _namaUserLoggedIn = resData['data']['nama'];
        _emailUserLoggedIn = resData['data']['email'];
        
        // Catch data objek user dari database Laragon/MySQL kamu
        _institusiUserLoggedIn = resData['data']['institusi'] ?? "";
        _prodiUserLoggedIn = resData['data']['prodi'] ?? "";

        await prefs.setString('id_user', _idUserLoggedIn);
        await prefs.setString('nama', _namaUserLoggedIn);
        await prefs.setString('email', _emailUserLoggedIn);
        
        // Simpan ke SharedPreferences HP agar saat aplikasi ditutup data tidak hilang
        await prefs.setString('institusi', _institusiUserLoggedIn);
        await prefs.setString('prodi', _prodiUserLoggedIn);

        await ambilDataTugasDariMysql();
        
        notifyListeners(); // sinkronisasi state data akun ke profil secara real-time
      }
      return resData;
    } catch (e) {
      return {"status": false, "message": "Gagal terhubung ke server"};
    }
  }

  // [MATERI 12: CRUD - READ] Ambil Data Tugas User dari MySQL
  Future<void> ambilDataTugasDariMysql() async {
    if (_idUserLoggedIn.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          "${BaseUrl.url}/tugas.php?aksi=read&id_user=$_idUserLoggedIn"));
      final resData = jsonDecode(response.body);

      if (resData['status'] == true) {
        final List dataMentah = resData['data'];
        _daftarTugasUtama = dataMentah.map((e) => Tugas.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error Ambil Data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // [MATERI 12: CRUD - CREATE] Tambah Tugas Baru ke MySQL
  Future<bool> tambahTugasBaru(
      String presidential, String matkul, String deadline, String deskripsi) async {
    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/tugas.php?aksi=create"),
        body: {
          "id_user": _idUserLoggedIn,
          "judul": presidential,
          "mata_kuliah": matkul,
          "deadline": deadline,
          "deskripsi": deskripsi
        },
      );
      final resData = jsonDecode(response.body);
      if (resData['status'] == true) {
        await ambilDataTugasDariMysql(); 
        return true;
      }
    } catch (e) {
      debugPrint("Error Create: $e");
    }
    return false;
  }

  // [MATERI 12: CRUD - UPDATE] Edit Semua Field Tugas Kuliah
  Future<bool> perbaruiDataTugas({
    required String idTugas,
    required String judul,
    required String mataKuliah,
    required String deadline,
    required String deskripsi,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/tugas.php?aksi=update"),
        body: {
          "id_tugas": idTugas,
          "judul": judul,
          "mata_kuliah": mataKuliah,
          "deadline": deadline,
          "deskripsi": deskripsi,
          "status": status,
        },
      );
      final resData = jsonDecode(response.body);
      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Update Tugas: $e");
    }
    return false;
  }

  // [MATERI 12: CRUD - DELETE PERMANEN]
  Future<bool> hapusTugasPermanen(String idTugas) async {
    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/tugas.php?aksi=delete"),
        body: {"id_tugas": idTugas},
      );
      final resData = jsonDecode(response.body);
      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Delete Permanen: $e");
    }
    return false;
  }

  // [MATERI 12: CRUD - DELETE ORIGINAL / SELESAI] Bawaan Proyek Awal Kamu
  Future<bool> tandaiTugasSelesai(String idTugas) async {
    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/tugas.php?aksi=delete"),
        body: {"id_tugas": idTugas},
      );
      final resData = jsonDecode(response.body);
      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
    return false;
  }

  // Logout & Bersihkan Sesi SPREF
  Future<void> prosesLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _daftarTugasUtama.clear();
    _idUserLoggedIn = "";
    _namaUserLoggedIn = "";
    _emailUserLoggedIn = "";
    _institusiUserLoggedIn = "";
    _prodiUserLoggedIn = "";
    notifyListeners();
  }
}