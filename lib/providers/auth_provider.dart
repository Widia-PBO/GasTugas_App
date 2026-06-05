import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastugas_app/services/notification_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../const.dart';
import 'app_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? _user;
  User? get currentUser => _user;
  bool _initialized = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_initialized) return;
    _initialized = true;
    await _googleSignIn.initialize(
      serverClientId:
          '436700117953-96lhabeub0hevf1vlhi4i6g5c80lsiu8.apps.googleusercontent.com',
    );
    await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<Map<String, dynamic>> authenticate({
    required BuildContext context,
    bool isGoogle = true,
    bool isRegister = false,
    String? email,
    String? password,
    String? nama,
    String? institusi,
    String? prodi,
  }) async {
    try {
      Map<String, String> body = {};

      if (isGoogle) {
        final GoogleSignInAccount user = await _googleSignIn.authenticate();
        final GoogleSignInAuthentication auth = user.authentication;

        if (auth.idToken == null) {
          return {"status": false, "message": "Token Google gagal"};
        }

        await _auth.signInWithCredential(
            GoogleAuthProvider.credential(idToken: auth.idToken));

        body = {
          "id_token": user.id,
          "nama": user.displayName ?? "User",
          "email": user.email,
        };
      } else {
        body = {
          "email": email!,
          "password": password!,
          if (nama != null) "nama": nama,
          if (isRegister && institusi != null) "institusi": institusi,
          if (isRegister && prodi != null) "prodi": prodi,
        };
      }

      String endpoint = isRegister ? "register.php" : "login.php";
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/$endpoint"),
        body: body,
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        bool isSuccess =
            (resData['status'] == true || resData['success'] == true);

        if (isSuccess) {
          if (!isRegister && resData['data'] != null) {
            final prefs = await SharedPreferences.getInstance();
            final data = resData['data'];

            await prefs.setString('id_user', data['id_user']?.toString() ?? "");
            await prefs.setString('nama', data['nama']?.toString() ?? "User");
            await prefs.setString('email', data['email']?.toString() ?? "");
            await prefs.setString('institusi',
                data['institusi']?.toString() ?? "Politeknik Negeri Indramayu");
            await prefs.setString(
                'prodi', data['prodi']?.toString() ?? "Sistem Informasi");
            if (data['id_user'] != null) {
              int parsedIdUser = int.tryParse(data['id_user'].toString()) ?? 0;
              if (parsedIdUser != 0) {
                await NotificationService()
                    .dapatkanDanSimpanToken(parsedIdUser);
              }
            }

            if (context.mounted) {
              await Provider.of<AppProvider>(context, listen: false)
                  .cekSessionLogin();
            }
          }

          return {"status": true, "message": resData['message'] ?? "Berhasil"};
        }

        return {
          "status": false,
          "message": resData['message'] ?? "Kesalahan tidak diketahui"
        };
      }
      return {
        "status": false,
        "message": "Server error: ${response.statusCode}"
      };
    } catch (e, stackTrace) {
      debugPrint("ERROR AUTH: $e");
      debugPrint("STACK: $stackTrace");

      return {
        "status": false,
        "message": e.toString(),
      };
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}
