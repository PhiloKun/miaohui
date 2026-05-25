import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reply.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<ReplyResult>> getReplies(String message) async {
    final response = await http.post(
      Uri.parse('/api/reply'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'message': message}),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final replies = (data['replies'] as List)
          .map((e) => ReplyResult.fromJson(e as Map<String, dynamic>))
          .toList();
      return replies;
    } else {
      throw Exception('服务器返回错误: ');
    }
  }
}
