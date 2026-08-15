import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/screens/concours_list_screen.dart';
import 'package:monprof/prepa/home/widgets/dashboard_page.dart';
import 'package:monprof/prepa/home/widgets/keep_alive_page.dart';
import 'package:monprof/prepa/home/widgets/mes_cours_placeholder.dart';
import 'package:monprof/prepa/user/screens/profile_screen.dart';

class PrepaHomeScreen extends StatefulWidget {
  const PrepaHomeScreen({super.key});

  @override
  State<PrepaHomeScreen> createState() => _PrepaHomeScreenState();
}

class _PrepaHomeScreenState extends State<PrepaHomeScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          KeepAlivePage(child: DashboardPage()),
          KeepAlivePage(child: ConcoursListScreen()),
          // KeepAlivePage(child: MesCoursPlaceholder()),
          KeepAlivePage(child: PrepaProfileScreen()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeInOut,
            );
            setState(() => _currentIndex = i);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: prepaPrimaryColor,
          unselectedItemColor: onGrey300,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Mes Cours',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
