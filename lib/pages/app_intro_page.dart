import 'package:flutter/material.dart';

class AnimatedIntroPage extends StatefulWidget {
  const AnimatedIntroPage({super.key});

  @override
  State<AnimatedIntroPage> createState() => _AnimatedIntroPageState();
}

class _AnimatedIntroPageState extends State<AnimatedIntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Hoşgeldiniz!",
      "description":
      "Bu uygulama ile kelime öğrenme testleri çözebilir, cevaplarınızı takip edebilirsiniz.",
      "color": Colors.blue.shade400,
      "icon": Icons.language,
    },
    {
      "title": "Testler",
      "description":
      "Farklı testlerle kelime bilginizi ölçün ve skorlarınızı kaydedin.",
      "color": Colors.green.shade400,
      "icon": Icons.quiz,
    },
    {
      "title": "İlerleme Takibi",
      "description":
      "Tüm sonuçlarınızı görebilir, hangi kelimelerde eksik olduğunuzu inceleyebilirsiniz.",
      "color": Colors.orange.shade400,
      "icon": Icons.show_chart,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage(Map<String, dynamic> page, bool active) {
    final double scale = active ? 1.0 : 0.8;
    final double opacity = active ? 1.0 : 0.5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: page["color"],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  page["icon"],
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Column(
                  children: [
                    Text(
                      page["title"],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page["description"],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    return List.generate(
      _pages.length,
          (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 20 : 10,
        height: 10,
        decoration: BoxDecoration(
          color:
          _currentPage == index ? Colors.white : Colors.white54,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  bool active = index == _currentPage;
                  return _buildPage(_pages[index], active);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildDots(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? "Başla" : "İleri",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
