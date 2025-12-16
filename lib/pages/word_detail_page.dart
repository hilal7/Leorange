import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailPage extends StatefulWidget {
  final int? userId;
  final int wordId;
  final String wordEn;
  final String wordTr;

  const WordDetailPage({
    super.key,
    this.userId,
    required this.wordId,
    required this.wordEn,
    required this.wordTr,
  });

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  String? _exampleEn;
  String? _exampleTr;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSpeaking = false;

  late FlutterTts _flutterTts;
  final String _generateEndpoint = 'http://10.0.2.2:5000/generate_sentence';

  @override
  void initState() {
    super.initState();
    _initTts();
    _initPage();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakWord(String word) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(word);
  }

  Future<void> _initPage() async {
    await _fetchFromServerAndCache();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchFromServerAndCache() async {
    setState(() => _isSaving = true);
    try {
      final res = await http.post(
        Uri.parse(_generateEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'word': widget.wordEn}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _exampleEn = data['example_en'];
          _exampleTr = data['example_tr'];
        });
      } else {
        setState(() {
          _exampleEn = 'Örnek alınamadı. Sunucu kodu: ${res.statusCode}';
          _exampleTr = 'Çeviri yok.';
        });
      }
    } catch (e) {
      setState(() {
        _exampleEn = 'Örnek alınamadı (Bağlantı Hatası)';
        _exampleTr = '';
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _highlightText(String text, String highlight) {
    final parts =
    text.split(RegExp('(${RegExp.escape(highlight)})', caseSensitive: false));

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
        children: parts.map((p) {
          final match = p.toLowerCase() == highlight.toLowerCase();
          return TextSpan(
            text: p,
            style: TextStyle(
              fontWeight: match ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlightTr = widget.wordTr.split(',').first.trim();

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.png', // Kendi logonuzun yolunu buraya yazın
            height: 30,
          ),
        ),
        title: const Text('Kelime Detayı'),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.orange)
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade600,
                  Colors.orange.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade300.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.wordEn,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isSpeaking ? Icons.stop : Icons.volume_up,
                          color: Colors.white,
                        ),
                        onPressed: () => _speakWord(widget.wordEn),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.wordTr,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "İngilizce Örnek",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_exampleEn != null)
                        _highlightText(_exampleEn!, widget.wordEn),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 14),
                      const Text(
                        "Türkçe Çeviri",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_exampleTr != null)
                        _highlightText(_exampleTr!, highlightTr),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    child: const Text(
                      "Geri Dön",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
