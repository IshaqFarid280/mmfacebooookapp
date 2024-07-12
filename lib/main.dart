import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mmfacebooookapp/buttom_navigation_screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    final result = await FacebookAuth.instance.login(permissions: ['email', 'pages_show_list']);

    if (result.status == LoginStatus.success) {
      setState(() {
        _accessToken = result.accessToken;
      });
      // Save login details (if needed)
    } else {
      print('Failed to login: ${result.message}');
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
    } else if (_accessToken != null) {
      return BottomNavigation(accessToken: _accessToken!); // Navigate to bottom navigation with access token
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login with Facebook'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _login,
            child: Text('Login with Facebook'),
          ),
        ),
      );
    }
  }
}
