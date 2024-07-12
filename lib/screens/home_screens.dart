import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AccessToken? _accessToken;
  List<dynamic>? _userPages;
  List<dynamic> _allPageFeeds = [];
  bool _loadingPages = true;
  bool _loadingFeed = true;
  bool _loadingMore = false;
  String? _nextFeedUrl;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserPages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_loadingMore) {
        _loadMoreFeeds();
      }
    });
  }

  Future<void> _fetchUserPages() async {
    setState(() {
      _loadingPages = true;
      _loadingFeed = true;
      _allPageFeeds.clear();
    });

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
          _loadingPages = false;
        });
        if (_userPages != null && _userPages!.isNotEmpty) {
          for (var page in _userPages!) {
            final pageAccessToken = await _getPageAccessToken(page['id']);
            if (pageAccessToken != null) {
              await _fetchPageFeed(page['id'], pageAccessToken);
            }
          }
        }
      } else {
        print('Failed to fetch user pages: ${graphResponse.statusCode}');
        setState(() {
          _loadingPages = false;
        });
      }
    } else {
      print('Access token not found.');
      setState(() {
        _loadingPages = false;
      });
    }
  }

  Future<String?> _getPageAccessToken(String pageId) async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final graphResponse = await http.get(
        Uri.parse('https://graph.facebook.com/v20.0/$pageId?fields=access_token'),
        headers: {
          'Authorization': 'Bearer ${accessToken.tokenString}',
          'Accept': 'application/json',
        },
      );

      if (graphResponse.statusCode == 200) {
        final jsonData = jsonDecode(graphResponse.body);
        return jsonData['access_token'];
      } else {
        print('Failed to fetch page access token: ${graphResponse.statusCode}');
      }
    }
    return null;
  }

  Future<void> _fetchPageFeed(String pageId, String pageAccessToken, {bool isLoadMore = false}) async {
    final feedUrl = _nextFeedUrl ?? 'https://graph.facebook.com/v20.0/$pageId/feed?fields=message,full_picture,created_time,comments.summary(true),likes.summary(true),shares&limit=10';
    final graphResponse = await http.get(
      Uri.parse(feedUrl),
      headers: {
        'Authorization': 'Bearer $pageAccessToken',
        'Accept': 'application/json',
      },
    );

    if (graphResponse.statusCode == 200) {
      final jsonData = jsonDecode(graphResponse.body);
      setState(() {
        _allPageFeeds.addAll(jsonData['data']);
        _nextFeedUrl = jsonData['paging']?['next'];
        _loadingFeed = false;
        _loadingMore = false;
      });
    } else {
      print('Failed to fetch page feed: ${graphResponse.statusCode}');
      setState(() {
        _loadingFeed = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMoreFeeds() async {
    if (_nextFeedUrl != null) {
      setState(() {
        _loadingMore = true;
      });

      final accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null) {
        for (var page in _userPages!) {
          final pageAccessToken = await _getPageAccessToken(page['id']);
          if (pageAccessToken != null) {
            await _fetchPageFeed(page['id'], pageAccessToken, isLoadMore: true);
          }
        }
      }
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yMMMd').add_jm().format(dateTime);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: _loadingPages || _loadingFeed
          ? Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _fetchUserPages,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _allPageFeeds.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _allPageFeeds.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final post = _allPageFeeds[index];
            final commentsCount = post['comments']?['summary']?['total_count'] ?? 0;
            final likesCount = post['likes']?['summary']?['total_count'] ?? 0;
            final sharesCount = post['shares']?['count'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post['full_picture'] != null)
                    Image.network(
                      post['full_picture'],
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.2,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.asset('assets/placeholder.png'), // replace with a placeholder asset
                  SizedBox(height: 8),
                  Text(post['message'] ?? 'No message'),
                  Text(_formatDateTime(post['created_time'])),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.thumb_up, size: 16),
                      SizedBox(width: 4),
                      Text('$likesCount'),
                      SizedBox(width: 16),
                      Icon(Icons.comment, size: 16),
                      SizedBox(width: 4),
                      Text('$commentsCount'),
                      SizedBox(width: 16),
                      Icon(Icons.share, size: 16),
                      SizedBox(width: 4),
                      Text('$sharesCount'),
                    ],
                  ),
                  Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
