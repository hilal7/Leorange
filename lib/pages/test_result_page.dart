import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pie_chart/pie_chart.dart';
import 'test_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestResultPage extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final int totalQuestions;
  final int userId;

  const TestResultPage({
    super.key,
    required this.resultData,
    required this.totalQuestions,
    required this.userId,
  });

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  late List wrongAnswers;
  final Set<int> favoriteWordIds = {};
  int? _realUserId;

  @override
  void initState() {
    super.initState();
    wrongAnswers = List.from(widget.resultData["wrong_answers"] ?? const []);
    _loadRealUserId();
  }

  Future<void> _loadRealUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt('userId') ?? 1;

    setState(() {
      _realUserId = widget.userId != 0 ? widget.userId : storedId;
    });

    await _fetchUserFavorites();
  }

  Future<void> _fetchUserFavorites() async {
    if (_realUserId == null) return;
    final url = Uri.parse('http://10.0.2.2:5000/get_favorites/$_realUserId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final favList = data['favorites'] as List;
      setState(() {
        favoriteWordIds.clear();
        favoriteWordIds.addAll(favList.map((e) => e['word_id'] as int));
      });
    }
  }

  Future<void> toggleFavorite(int wordId) async {
    final isFavorite = favoriteWordIds.contains(wordId);

    setState(() {
      if (isFavorite) {
        favoriteWordIds.remove(wordId);
      } else {
        favoriteWordIds.add(wordId);
      }
    });

    final url = Uri.parse(
        'http://10.0.2.2:5000/${isFavorite ? 'remove_favorite' : 'add_favorite'}');

    final userIdToSend = _realUserId ?? widget.userId;

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userIdToSend,
        "word_id": wordId,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int correct = widget.resultData["total_correct"];
    final int wrong = widget.totalQuestions - correct;
    final double scorePercentage = (correct / widget.totalQuestions) * 100;
    final bool passed = scorePercentage >= 70;

    Map<String, double> dataMap = {
      "Doğru": correct.toDouble(),
      "Yanlış": wrong.toDouble(),
    };

    return Scaffold(
      body: Container(
        width: double.infinity,
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: const Text(
                      "Test Sonucu",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInDown(
                    delay: const Duration(milliseconds: 300),
                    child: PieChart(
                      dataMap: dataMap,
                      chartRadius: 150,
                      colorList: [Colors.green, Colors.red],
                      chartType: ChartType.ring,
                      ringStrokeWidth: 30,
                      legendOptions: const LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.bottom,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (wrongAnswers.isNotEmpty)
                    FadeInDown(
                      delay: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Yanlış Cevaplar:",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 10),
                          for (var w in wrongAnswers)
                            Card(
                              color: Colors.red.shade50,
                              child: ListTile(
                                title: Text(w['word_en'] ?? ''),
                                trailing: IconButton(
                                  icon: Icon(
                                    favoriteWordIds.contains(w['word_id'])
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange.shade700,
                                  ),
                                  onPressed: () =>
                                      toggleFavorite(w['word_id'] ?? 0),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade400,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Doğru cevap: ${w['correct_answer']}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Senin cevabın: ${w['user_answer']}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: passed
                        ? Column(
                      children: [
                        BounceInDown(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "🎉 Tebrikler! 🎉",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Testi başarıyla tamamladınız.\nSeviye atladınız!",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange.shade800,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50)),
                              ),
                              child: const Text("Ana Sayfaya Dön"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                const int nextLevelId = 2;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestPage(
                                      userId: widget.userId,
                                      levelId: nextLevelId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50)),
                              ),
                              child: const Text("Yeni Teste Geç"),
                            ),
                          ],
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        const Text(
                          "Başarısız oldunuz! Testi tekrar deneyin.",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange.shade800,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50)),
                              ),
                              child: const Text("Ana Sayfaya Dön"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestPage(
                                      userId: widget.userId,
                                      levelId: 1,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50)),
                              ),
                              child: const Text("Tekrar Dene"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
