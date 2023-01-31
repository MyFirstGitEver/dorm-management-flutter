import 'package:flutter/material.dart';

import '../../stateless/loading_page.dart';
import '../screens/main_interactive_screens/document_screen.dart';
import '../screens/main_interactive_screens/renters_screen.dart';
import '../screens/main_interactive_screens/rooms_screen.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  State<MainActivity> createState() => _MainActivityState();
}

enum ScreenOptions {rooms, renters, document}
enum LoadState {loading, mainActivity}

class _MainActivityState extends State<MainActivity> {
  ScreenOptions _selectedScreen = ScreenOptions.rooms;
  LoadState _loadState = LoadState.loading;

  late final PageController _pageController;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () => setState((){
      _loadState = LoadState.mainActivity;
    }));

    _pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _loadState == LoadState.loading
              ? const LoadingPage()
              : _showScreen()),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Phòng trọ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Người thuê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet_rounded),
            label: 'Tài liệu',
          ),
        ],
        currentIndex: _selectedScreen.index,
        selectedItemColor: Colors.amber[800],
        onTap: (index){
          setState(() {
            _selectedScreen = ScreenOptions.values[index];
          });
          _pageController.animateToPage(index, duration: const Duration(milliseconds:  400), curve: Curves.decelerate);
        },
      ),
    );
  }

  Widget _showScreen(){
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: const <StatefulWidget>[
        RoomsScreen(),
        RentersScreen(),
        DocumentScreen()
      ],
      onPageChanged: (index) => setState(() {}),
    );
  }
}