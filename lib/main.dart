// main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/word_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('wordCache');
  runApp(const MyApp());
}


//void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Uygulama acildiginda hangi sayfa
  Future<Widget> _getStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String username = prefs.getString('username') ?? '';

    if (isLoggedIn && username.isNotEmpty) {
      return WelcomePage(username: username);
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Veriler yüklenirken bir loading gösterebiliriz
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: snapshot.data,
        );
      },
    );
  }
}
