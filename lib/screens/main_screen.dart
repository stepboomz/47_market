import 'package:brand_store_app/screens/home.dart';
import 'package:brand_store_app/screens/search_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      bottomNavigationBar: showBottomNavigationBar(),
      body: IndexedStack(
        index: selectedIndex,
        children: const [Home(), SearchScreen()],
      ),
    );
  }


  Widget? showBottomNavigationBar() {
    final myNavBar = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: BottomNavigationBar(
          elevation: 0,
          enableFeedback: false,
          currentIndex: selectedIndex,
          unselectedItemColor: Theme.of(context).colorScheme.inverseSurface,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.orange,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/icons/home.png"),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/icons/search.png"),
              ),
              label: "Search",
            ),
          ]),
    );
    switch (selectedIndex) {
      case 0:
        return myNavBar;
      case 1:
        return myNavBar;
      case 2:
        return null;
      case 3:
        return myNavBar;
      default:
        return myNavBar;
    }
  }
}
