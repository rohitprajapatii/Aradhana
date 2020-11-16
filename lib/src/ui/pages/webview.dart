import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../resources/api_provider.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;
  const WebViewPage({Key key, this.url, this.title}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState(url: url);
}

class _WebViewPageState extends State<WebViewPage> {
  final String url;
  bool _isLoadingPage = true;

  @override
  void initState() {
    super.initState();
  }

  _WebViewPageState({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.title != null ? AppBar(title: Text(widget.title)) : AppBar(),
      body: Container(
        child: Stack(
          children: <Widget>[
            WebView(
              onPageStarted: (String url) {
                //
              },
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController wvc) {
                //
              },
              onPageFinished: (value) async {
                setState(() {
                  _isLoadingPage = false;
                });
              },
            ),
            _isLoadingPage
                ? Container(
                    color: Colors.white,
                    alignment: FractionalOffset.center,
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
