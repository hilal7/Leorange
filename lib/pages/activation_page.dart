import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyPage extends StatefulWidget {
  final String email;
  const VerifyPage({super.key, required this.email});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _codeController = TextEditingController();
  final String baseUrl = "http://10.0.2.2:5000";

  Future<void> verifyCode() async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify'),
      body: {
        'email': widget.email,
        'code': _codeController.text,
      },
    );
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Mailinize gönderilen kodu girin:",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: "Kod")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: verifyCode, child: const Text("Doğrula"))
          ],
        ),
      ),
    );
  }
}
