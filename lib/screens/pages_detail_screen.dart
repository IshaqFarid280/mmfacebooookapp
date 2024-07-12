import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class PageDetailScreen extends StatefulWidget {
  final dynamic page;

  const PageDetailScreen({Key? key, required this.page}) : super(key: key);

  @override
  _PageDetailScreenState createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  List<dynamic>? _pagePosts;
  bool _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    _fetchPagePosts(widget.page['id'], widget.page['access_token']);
  }

  Future<void> _fetchPagePosts(String pageId, String accessToken) async {
    final graphResponse = await http.get(
      Uri.parse('https://graph.facebook.com/v20.0/$pageId/feed?fields=message,full_picture,created_time&limit=12'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (graphResponse.statusCode == 200) {
      final jsonData = jsonDecode(graphResponse.body);
      setState(() {
        _pagePosts = jsonData['data'];
        _loadingPosts = false;
      });
    } else {
      print('Failed to fetch page posts: ${graphResponse.statusCode}');
      setState(() {
        _loadingPosts = false;
      });
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yMMMd').add_jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.page['name']),
      ),
      body: _loadingPosts
          ? SafeArea(
            child: Center(
                    child: CircularProgressIndicator(),
                  ),
          )
          : Column(
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.2,
                    width:  MediaQuery.of(context).size.width*0.4,
                    child: CircleAvatar(

                      backgroundImage: NetworkImage('https://graph.facebook.com/${widget.page['id']}/picture?type=square',),
                    ),
                  ),
                  Text(widget.page['name'], style: TextStyle(
                      color: Colors.black, fontSize: 18.0
                  ),),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,)
                ],
              ),


              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                          ),
                          itemCount: _pagePosts?.length ?? 0,
                          itemBuilder: (context, index) {
                  final post = _pagePosts![index];
                  return GridTile(

                    child: Image.network(
                      post['full_picture'] ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                    footer: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.all(8),
                      child: Text(
                        _formatDateTime(post['created_time']),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                          },
                        ),
                ),
              ),
            ],
          ),
    );
  }
}
