import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AccessToken? _accessToken;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  _fetchProfileData() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final userData = await FacebookAuth.instance.getUserData();
      setState(() {
        _userData = userData;
        _loading = false;
      });
    } else {
      print('Access token not found.');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _userData != null
                ? CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                _userData!['picture']['data']['url'],
              ),
            )
                : Container(),
            SizedBox(height: 20),
            _userData != null
                ? Text(
              '${_userData!['name']}',
              style: TextStyle(fontSize: 24),
            )
                : Container(),
            SizedBox(height: 10),
            _userData != null
                ? Text('Email: ${_userData!['email']}')
                : Container(),
            SizedBox(height: 10),
            _userData != null
                ? Text('Facebook ID: ${_userData!['id']}')
                : Container(),
          ],
        ),
      ),
    );
  }
}
