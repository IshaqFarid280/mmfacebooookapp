import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mmfacebooookapp/screens/group_screens.dart';
import 'package:mmfacebooookapp/screens/home_screens.dart';
import 'package:mmfacebooookapp/screens/profile_screens.dart';

import 'consts/colors.dart';

class BottomNavigation extends StatefulWidget {
  final AccessToken accessToken;

  BottomNavigation({required this.accessToken});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    PagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: secondaryColor2,
        unselectedItemColor: listTileEditColor,
        selectedLabelStyle: TextStyle(color: secondaryColor2),
        unselectedLabelStyle: TextStyle(color: listTileEditColor),
        selectedIconTheme: IconThemeData(color: blueColor),
        unselectedIconTheme: IconThemeData(color: listTileEditColor),
        selectedFontSize: 12,
        unselectedFontSize: 10,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pages),
            label: 'Pages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
