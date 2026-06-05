import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gastugas_app/services/api_service.dart';
import 'package:gastugas_app/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../const.dart';
import '../models/tugas_model.dart';
import 'auth_provider.dart';

class AppProvider extends ChangeNotifier {
  List<Tugas> _daftarTugasUtama = [];
  String _idUserLoggedIn = "";
  String _namaUserLoggedIn = "";
  String _emailUserLoggedIn = "";
  String _institusiUserLoggedIn = "";
  String _prodiUserLoggedIn = "";
  bool _isLoading = false;

  List<Tugas> get daftarTugasUtama => _daftarTugasUtama;
  String get namaUserLoggedIn => _namaUserLoggedIn;
  String get emailUserLoggedIn => _emailUserLoggedIn;
  String get institusiUserLoggedIn => _institusiUserLoggedIn;
  String get prodiUserLoggedIn => _prodiUserLoggedIn;
  bool get isLoading => _isLoading;
  bool get isUserLoggedIn => _idUserLoggedIn.isNotEmpty;

  // --- 1. MANAJEMEN SESI ---
  Future<void> cekSessionLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data dengan kunci yang sama persis seperti saat Login
    _idUserLoggedIn = prefs.getString('id_user') ?? "";
    _namaUserLoggedIn = prefs.getString('nama') ?? "";
    _emailUserLoggedIn = prefs.getString('email') ?? "";

    // Tambahkan fallback jika data di prefs masih kosong/null
    _institusiUserLoggedIn =
        prefs.getString('institusi') ?? "Politeknik Negeri Indramayu";
    _prodiUserLoggedIn = prefs.getString('prodi') ?? "Sistem Informasi";

    notifyListeners(); // Memberi tahu UI untuk memperbarui tampilan
  }

  // --- 2. AUTHENTICATION (REGISTER & LOGIN) ---
  Future<bool> prosesRegistrasiUser({
    required String nama,
    required String email,
    required String password,
    required String institusi,
    required String prodi,
  }) async {
    _isLoading = true;
    notifyListeners();

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
      return resData['status'] == true;
    } catch (e) {
      debugPrint("Error Proses Registrasi Provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> prosesLogin(
      String email, String password) async {
    try {
      // 1. Panggil API Login
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/login.php"),
        body: {"email": email, "password": password},
      );

      // 2. Decode response dari PHP
      final resData = jsonDecode(response.body);

      if (resData['status'] == true) {
        final data = resData['data'];

        // 3. Update Variabel Lokal Provider
        _idUserLoggedIn = data['id_user']?.toString() ?? "";
        _namaUserLoggedIn = data['nama']?.toString() ?? "User";
        _emailUserLoggedIn = data['email']?.toString() ?? email;
        _institusiUserLoggedIn =
            data['institusi']?.toString() ?? "Politeknik Negeri Indramayu";
        _prodiUserLoggedIn = data['prodi']?.toString() ?? "Sistem Informasi";

        // 4. Sinkronisasi ke SharedPreferences (Persistent Storage)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', _idUserLoggedIn);
        await prefs.setString('nama', _namaUserLoggedIn);
        await prefs.setString('email', _emailUserLoggedIn);
        await prefs.setString('institusi', _institusiUserLoggedIn);
        await prefs.setString('prodi', _prodiUserLoggedIn);

        // 5. Ambil data tugas segera agar dashboard tidak kosong
        await ambilDataTugasDariMysql();
        int parsedIdUser = int.tryParse(_idUserLoggedIn) ?? 0;
        if (parsedIdUser != 0) {
          await NotificationService().dapatkanDanSimpanToken(parsedIdUser);
        }
        // 6. Notifikasi UI bahwa data telah berubah
        notifyListeners();
      }

      return Map<String, dynamic>.from(resData);
    } catch (e) {
      debugPrint("Error Login: $e");
      return {"status": false, "message": "Gagal terhubung ke server"};
    }
  }

  Future<void> ambilDataTugasDariMysql() async {
    if (_idUserLoggedIn.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final resData = await ApiService.fetchTugas(_idUserLoggedIn);

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

  // 1. Fungsi tambahTugasBaru
  Future<bool> tambahTugasBaru(
      String judul, String matkul, String deadline, String deskripsi) async {
    try {
      // Panggil ApiService
      final resData = await ApiService.createTugas({
        "id_user": _idUserLoggedIn,
        "judul": judul,
        "mata_kuliah": matkul,
        "deadline": deadline,
        "deskripsi": deskripsi,
        "status": "Belum dikerjakan"
      });

      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Create: $e");
    }
    return false;
  }

  // 2. Fungsi perbaruiDataTugas
  Future<bool> perbaruiDataTugas({
    required String idTugas,
    required String judul,
    required String mataKuliah,
    required String deadline,
    required String deskripsi,
    required String status,
  }) async {
    try {
      // Panggil ApiService
      final resData = await ApiService.updateTugas({
        "id_tugas": idTugas,
        "judul": judul,
        "mata_kuliah": mataKuliah,
        "deadline": deadline,
        "deskripsi": deskripsi,
        "status": status,
      });

      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Update: $e");
    }
    return false;
  }

  // 3. Fungsi hapusTugasPermanen
  Future<bool> hapusTugasPermanen(String idTugas) async {
    try {
      // Cukup panggil ApiService!
      final resData = await ApiService.deleteTugas({"id_tugas": idTugas});

      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
    return false;
  }

  // 4. Fungsi tandaiTugasSelesai
  Future<bool> tandaiTugasSelesai(Tugas tgs) async {
    try {
      final resData = await ApiService.updateStatusTugas({
        "id_tugas": tgs.idTugas,
        "judul": tgs.judul,
        "mata_kuliah": tgs.mataKuliah,
        "deadline": tgs.deadline,
        "deskripsi": tgs.deskripsi,
        "status": "Selesai"
      });

      if (resData['status'] == true) {
        await ambilDataTugasDariMysql();
        return true;
      }
    } catch (e) {
      debugPrint("Error Selesai: $e");
    }
    return false;
  }

  Future<void> fetchProfilDariMysql(String email) async {
    try {
      // Memastikan email dikirim dengan benar ke login.php
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/login.php"),
        body: {"email": email},
      );

      final resData = jsonDecode(response.body);

      // Pastikan status benar dan data ada
      if (resData['status'] == true && resData['data'] != null) {
        final data = resData['data'];

        // Update state provider
        _idUserLoggedIn = data['id_user'].toString();
        _namaUserLoggedIn = data['nama'] ?? "";
        _emailUserLoggedIn = data['email'] ?? email;
        _institusiUserLoggedIn =
            data['institusi'] ?? "Politeknik Negeri Indramayu";
        _prodiUserLoggedIn = data['prodi'] ?? "Sistem Informasi";

        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_user', _idUserLoggedIn);
        await prefs.setString('nama', _namaUserLoggedIn);
        await prefs.setString('email', _emailUserLoggedIn);
        await prefs.setString('institusi', _institusiUserLoggedIn);
        await prefs.setString('prodi', _prodiUserLoggedIn);

        // Sinkronisasi Token FCM (supaya notifikasi jalan)
        int parsedIdUser = int.tryParse(_idUserLoggedIn) ?? 0;
        if (parsedIdUser != 0) {
          await NotificationService().dapatkanDanSimpanToken(parsedIdUser);
        }

        // Ambil tugas setelah ID User tersedia
        await ambilDataTugasDariMysql();
        notifyListeners();
        debugPrint(
            "Profil dan Tugas berhasil disinkronkan untuk: $_namaUserLoggedIn");
      }
    } catch (e) {
      debugPrint("Error Fetch Profil: $e");
    }
  }

  Future<void> prosesLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _daftarTugasUtama.clear();
    _idUserLoggedIn = "";
    _namaUserLoggedIn = "";
    _emailUserLoggedIn = "";
    _institusiUserLoggedIn = "";
    _prodiUserLoggedIn = "";
    notifyListeners();

    if (!context.mounted) return;
    await Provider.of<AuthProvider>(context, listen: false).signOut();
  }
}
