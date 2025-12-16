import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:tezproje/pages/favorites_page.dart';
import 'package:tezproje/pages/test_page.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  final String username;

  const WelcomePage({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    await prefs.remove('userId');
    await prefs.remove('level'); // Seviyeyi de sil

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Future<String> _getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('level') ?? "Beginner"; // Varsayılan seviyeyi Beginner olarak al
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange.shade800,
              Colors.orange.shade600,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Hoş Geldiniz, $username 👋',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Level Bilgisi
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: FutureBuilder<String>(
                    future: _getLevel(),
                    builder: (context, snapshot) {
                      final level = snapshot.data ?? "Beginner";
                      return Text(
                        'Level: $level',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    "Öğrenmeye hemen başlayabilir veya uygulamayı keşfetmeye devam edebilirsin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),

                // Butonlar
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: size.width * 0.85,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text(
                        "A1-A2 Testi Başlat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black45,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('userId') ?? 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TestPage(userId: userId, levelId: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: SizedBox(
                    width: size.width * 0.85,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star, size: 24),
                      label: const Text(
                        "Favorilerim",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('userId') ?? 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesPage(userId: userId),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: SizedBox(
                    width: size.width * 0.85,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 24),
                      label: const Text(
                        "Çıkış Yap",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black38,
                      ),
                      onPressed: () => _logout(context),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
