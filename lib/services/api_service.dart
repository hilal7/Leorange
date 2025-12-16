// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:5000";

  // Login
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password }),
      );

      if (response.statusCode == 200 || response.statusCode ==201) {
        return jsonDecode(response.body);
      } else {
        try{
          return jsonDecode((response.body));
        } catch(_){
          return {
            "success": false,
            "message": "Sunucudan beklenmeyen yanıt: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      return {"success": false, "message": "Hata: $e"};
    }
  }

  Future<Map<String, dynamic>> googleLogin(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/google_login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Register
  Future<Map<String, dynamic>> registerUser(
      String firstName, String lastName, String nickname, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'nickname': nickname,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {
            "success": false,
            "message": "Sunucudan geçersiz yanıt: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      return {"success": false, "message": "Hata: $e"};
    }
  }


  Future<Map<String, dynamic>> fetchUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user_data/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Hata durumunda varsayılan boş veriler veya uygun bir hata mesajı döndür
      return {
        'success': false,
        'message': 'Kullanıcı verileri çekilemedi.',
        'xp': 0,
        'known_words': 0,
        'streak_days': []
      };
    }
  }
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user_stats/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kullanıcı istatistikleri alınamadı: ${response.statusCode}');
    }
  }









  // Verify code
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {"success": false, "message": "Hata: $e"};
    }
  }
}
