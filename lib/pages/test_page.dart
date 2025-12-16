import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_result_page.dart';

class TestPage extends StatefulWidget {
  final int userId;
  final int levelId;

  const TestPage({super.key, required this.userId, required this.levelId});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<dynamic> words = [];
  int currentIndex = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> answers = [];
  List<String> options = [];
  Random random = Random();
  late stt.SpeechToText _speech;
  bool isListening = false;
  String _recognizedText = "";
  String _level = "Beginner";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    fetchWords();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _level = prefs.getString('level') ?? "Beginner";
    });
  }

  Future<void> fetchWords() async {
    final url = Uri.parse(
        "http://10.0.2.2:5000/start_test/${widget.levelId}/${widget.userId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        setState(() {
          words = data["words"];
          isLoading = false;
        });

        final prefs = await SharedPreferences.getInstance();
        currentIndex =
            prefs.getInt('currentIndex_${widget.userId}_${widget.levelId}') ?? 0;
        final storedAnswers =
        prefs.getString('answers_${widget.userId}_${widget.levelId}');
        if (storedAnswers != null) {
          answers = List<Map<String, dynamic>>.from(jsonDecode(storedAnswers));
        }

        generateOptions();
      } else {
        _showErrorDialog(data["message"] ?? "Bilinmeyen bir hata oluştu.");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      _showErrorDialog("Sunucu hatası: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  void generateOptions() {
    if (words.isEmpty || currentIndex >= words.length) return;
    final currentWord = words[currentIndex];

    options = [currentWord["word_tr"]];
    while (options.length < 4) {
      String randomWord =
      words[random.nextInt(words.length)]["word_tr"].toString();
      if (!options.contains(randomWord)) {
        options.add(randomWord);
      }
    }
    options.shuffle();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Tamam"))
        ],
      ),
    );
  }

  Future<void> _listen() async {
    if (!isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _recognizedText = val.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 5),
          localeId: 'tr_TR',
        );
        Future.delayed(const Duration(seconds: 5), () {
          if (_speech.isListening) _speech.stop();
          setState(() => isListening = false);
        });
      }
    }
  }

  void submitAnswer(String selectedOption) async {
    final currentWord = words[currentIndex];
    bool isCorrect = selectedOption == currentWord["word_tr"];

    answers.add({
      "word_id": currentWord["word_id"],
      "is_correct": isCorrect,
      "correct_answer": currentWord["word_tr"],
      "user_answer": selectedOption,
      "spoken_text": _recognizedText
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentIndex_${widget.userId}_${widget.levelId}', currentIndex + 1);
    prefs.setString(
        'answers_${widget.userId}_${widget.levelId}', jsonEncode(answers));

    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        _recognizedText = "";
        generateOptions();
      });
    } else {
      await sendResults();
      prefs.remove('currentIndex_${widget.userId}_${widget.levelId}');
      prefs.remove('answers_${widget.userId}_${widget.levelId}');
    }
  }

  Future<void> sendResults() async {
    final url = Uri.parse("http://10.0.2.2:5000/submit_test");
    final body = jsonEncode({
      "user_id": widget.userId,
      "level_id": widget.levelId,
      "answers": answers,
    });

    final response =
    await http.post(url, headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultPage(
            resultData: data,
            totalQuestions: words.length,
            userId: widget.userId,
          ),
        ),
      );
    } else {
      _showErrorDialog(
          "Sonuçları gönderirken sunucu hatası: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange.shade800)),
      );
    }

    if (words.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Test kelimesi bulunamadı.")),
      );
    }

    final currentWord = words[currentIndex];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade700,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Text(
                    "Level: $_level",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    "Soru ${currentIndex + 1} / ${words.length}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      currentWord["word_en"],
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: size.width * 0.7,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange.shade800,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: _listen,
                      icon: Icon(isListening ? Icons.mic_none : Icons.mic),
                      label: Text(
                        isListening ? "Dinleniyor..." : "Konuş ve Dinle",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView(
                    children: options
                        .map(
                          (opt) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.orange.shade900,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))),
                          onPressed: () => submitAnswer(opt),
                          child: Text(
                            opt,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                        .toList(),
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
