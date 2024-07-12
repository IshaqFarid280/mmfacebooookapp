import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mmfacebooookapp/screens/pages_detail_screen.dart';


class PagesScreen extends StatefulWidget {
  @override
  _PagesScreenState createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  AccessToken? _accessToken;
  List<dynamic>? _userPages;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPages();
  }

  Future<void> _fetchUserPages() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final graphResponse = await http.get(
        Uri.parse('https://graph.facebook.com/v20.0/me/accounts'),
        headers: {
          'Authorization': 'Bearer ${accessToken.tokenString}',
          'Accept': 'application/json',
        },
      );

      if (graphResponse.statusCode == 200) {
        final jsonData = jsonDecode(graphResponse.body);
        setState(() {
          _userPages = jsonData['data'];
          _loading = false;
        });
      } else {
        print('Failed to fetch user pages: ${graphResponse.statusCode}');
        setState(() {
          _loading = false;
        });
      }
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
        title: Text('Pages'),
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _userPages?.length ?? 0,
        itemBuilder: (context, index) {
          final page = _userPages![index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageDetailScreen(page: page),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://graph.facebook.com/${page['id']}/picture?type=square'),
            ),
            title: Text(page['name']),
            subtitle: Text(page['id']),
          );
        },
      ),
    );
  }
}
