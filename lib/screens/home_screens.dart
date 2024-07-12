import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mmfacebooookapp/reusable/customIcons.dart';
import 'package:mmfacebooookapp/reusable/custom_floating_action.dart';
import 'package:mmfacebooookapp/reusable/custom_sizedBox.dart';
import 'package:mmfacebooookapp/reusable/text_widgets.dart';

import '../consts/colors.dart';

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
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_loadingMore) {
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
        Uri.parse(
            'https://graph.facebook.com/v20.0/$pageId?fields=access_token'),
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

  Future<void> _fetchPageFeed(String pageId, String pageAccessToken,
      {bool isLoadMore = false}) async {
    final feedUrl = _nextFeedUrl ??
        'https://graph.facebook.com/v20.0/$pageId/feed?fields=message,full_picture,created_time,comments.summary(true),likes.summary(true),shares&limit=10';
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
      floatingActionButton: CustomFloatingAction(onTap: () {  },),
      appBar: AppBar(
        title: largeText(title: 'Dashboard'),
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
                  return Card(
                    color: secondaryTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          post['full_picture'] != null
                              ? Container(
                            clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          post['full_picture'],
                                        ),
                                        fit: BoxFit.contain),
                                  ),
                            child: Image.network(post['full_picture'],),
                          )
                              : const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.black,
                                  ),
                                ),
                          // replace with a placeholder asset
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: smallText(title :post['message'] ?? 'No message')),
                              smallText(title:_formatDateTime(post['created_time'])),
                            ],
                          ),
                          Divider(color: listTileLeadingColor,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomIcon(iconData: Icons.thumb_up),
                                    Sized(),
                                    smallText(title: likesCount.toString(),fontSize: 16.0),
                                    Sized(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    CustomIcon(iconData: Icons.messenger_outlined),
                                    Sized(),
                                    smallText(title: commentsCount.toString(),fontSize: 16.0),
                                    Sized(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    CustomIcon(iconData: Icons.share_sharp),
                                    Sized(),
                                    smallText(title: sharesCount.toString(),fontSize: 16.0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Sized(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
