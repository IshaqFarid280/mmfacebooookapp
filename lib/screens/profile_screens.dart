import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mmfacebooookapp/reusable/customIcons.dart';
import 'package:mmfacebooookapp/reusable/custom_sizedBox.dart';
import 'package:mmfacebooookapp/reusable/text_widgets.dart';

import '../consts/colors.dart';

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
        title: largeText(title: 'Profile'),
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Sized(),
              _userData != null
                  ? Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: secondaryTextColor,width: 4),
                  shape: BoxShape.circle,
                  image: DecorationImage(image: NetworkImage(_userData!['picture']['data']['url'],),fit: BoxFit.cover),
                ),
              ):Container(),
              Sized(height: 0.03,),
              Divider(color: secondaryTextColor,),
              Sized(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomIcon(iconData: Icons.person),
                    _userData != null
                        ? mediumText(title: _userData!['name'])
                        : Container(),
                  ],
                ),
              ),
              Divider(color: secondaryTextColor,),
              Sized(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomIcon(iconData: Icons.mail),
                    _userData != null
                        ? mediumText(title: _userData!['email'])
                        : Container(),
                  ],
                ),
              ),
              Sized(height: 0.03,),
              Divider(color: secondaryTextColor,),
              // SizedBox(height: 10),
              // _userData != null
              //     ? smallText(title: _userData!['email']) Text('Facebook ID: ${_userData!['id']}')
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
