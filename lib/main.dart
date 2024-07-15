import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mmfacebooookapp/buttom_navigation_screens.dart';
import 'package:mmfacebooookapp/reusable/text_widgets.dart';

import 'consts/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: primaryTextColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: primaryTextColor,
        ),
        scaffoldBackgroundColor: primaryTextColor,
      ),
      home: LoginScreen(), // Start with LoginScreen
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _checking = true;
  bool _isLoggingIn = false;
  AccessToken? _accessToken;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  _checkUserLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      setState(() {
        _accessToken = accessToken;
        _checking = false;
      });
    } else {
      setState(() {
        _checking = false;
      });
    }
  }

  _login() async {
    if (_isLoggingIn) return; // Prevent multiple login attempts

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'pages_show_list']);

      if (result.status == LoginStatus.success) {
        setState(() {
          _accessToken = result.accessToken;
        });
        // Save login details (if needed)
      } else {
        print('Failed to login: ${result.message}');
      }
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_accessToken != null) {
      return BottomNavigation(accessToken: _accessToken!);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: largeText(title: 'Login with Facebook'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _login,
            child: mediumText(title: 'Login with Facebook', color: blueColor),
          ),
        ),
      );
    }
  }
}
