import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'word_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  final int userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final url =
    Uri.parse('http://10.0.2.2:5000/get_favorites/${widget.userId}');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          favorites = data['favorites'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Sunucu hatası: ${res.statusCode}");
      }
    } catch (e) {
      print("Favoriler alınamadı: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeFavorite(int wordId) async {
    final url = Uri.parse('http://10.0.2.2:5000/remove_favorite');
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId,
          "word_id": wordId,
        }),
      );
      if (res.statusCode == 200) {
        setState(() {
          favorites.removeWhere((item) => item['word_id'] == wordId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Favoriden kaldırıldı."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception("Kaldırma hatası: ${res.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata oluştu: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Kelimeler"),
        backgroundColor: Colors.orange.shade700,
        elevation: 4,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      )
          : favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star_border, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              "Henüz favori kelimen yok 🌟",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.orange.shade50,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                title: Text(
                  item['word_en'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  item['word_tr'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.star, color: Colors.orange),
                  onPressed: () => _removeFavorite(item['word_id']),
                  tooltip: "Favoriden kaldır",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordDetailPage(
                        userId: widget.userId,
                        wordId: item['word_id'],
                        wordEn: item['word_en'] ?? '',
                        wordTr: item['word_tr'] ?? '',
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
