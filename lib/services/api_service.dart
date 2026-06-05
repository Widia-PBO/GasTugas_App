import 'dart:convert';
import 'package:http/http.dart' as http;
import '../const.dart';

class ApiService {
  static Future<Map<String, dynamic>> postRequest(
      String aksi, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse("${BaseUrl.url}/tugas.php?aksi=$aksi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchTugas(String idUser) async {
    final response = await http.get(
      Uri.parse("${BaseUrl.url}/tugas.php?aksi=read&id_user=$idUser"),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTugas(
      Map<String, dynamic> data) async {
    return await postRequest('create', data);
  }

  static Future<Map<String, dynamic>> updateTugas(
      Map<String, dynamic> data) async {
    return await postRequest('update', data);
  }

  static Future<Map<String, dynamic>> deleteTugas(
      Map<String, dynamic> data) async {
    return await postRequest('delete', data);
  }

  static Future<Map<String, dynamic>> updateStatusTugas(
      Map<String, dynamic> data) async {
    return await postRequest('update', data);
  }
}
