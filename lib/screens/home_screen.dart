import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../widgets/menu_page.dart';
import '../widgets/music_button.dart';
import '../widgets/page_indicator.dart';
import '../widgets/scale_arrow_button.dart';
import '../screens/i_miss_you_detail.dart';
import '../screens/how_are_you_detail.dart';
import '../screens/i_see_you_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  String _backgroundImage = 'assets/images/menu1_bg.png';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToDetailPage() {
    switch (_currentPage) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IMissYouDetailPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HowAreYouDetailPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ISeeYouDetailPage()),
        );
        break;
    }
  }

  void _updateBackgroundImage(int page) {
    String newBackgroundImage;
    switch (page) {
      case 0:
        newBackgroundImage = 'assets/images/menu1_bg.png';
        break;
      case 1:
        newBackgroundImage = 'assets/images/menu2_bg.png';
        break;
      case 2:
        newBackgroundImage = 'assets/images/menu3_bg.png';
        break;
      default:
        newBackgroundImage = 'assets/images/menu1_bg.png';
    }
    setState(() {
      _backgroundImage = newBackgroundImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _backgroundImage,
              key: ValueKey<String>(_backgroundImage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: menuItems.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _updateBackgroundImage(page);
            },
            itemBuilder: (context, index) {
              return AnimatedOpacity(
                opacity: _currentPage == index ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: MenuPage(item: menuItems[index]),
              );
            },
          ),
          // Conditional rendering for the left arrow
          if (_currentPage > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: ScaleArrowButton(
                  imagePath: 'assets/images/left_arrow.png',
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          // Conditional rendering for the right arrow
          if (_currentPage < menuItems.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: ScaleArrowButton(
                  imagePath: 'assets/images/right_arrow.png',
                  onPressed: () {
                    if (_currentPage < menuItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: PageIndicator(
              count: menuItems.length,
              currentIndex: _currentPage,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleArrowButton(
                imagePath: 'assets/images/down_arrow.png',
                onPressed: _navigateToDetailPage,
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: MusicControlButton(), // 공통 재생 버튼 위젯 사용
          ),
        ],
      ),
    );
  }
}
