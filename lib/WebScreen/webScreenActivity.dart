import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreenActivity extends StatefulWidget {
  final String url;

  const WebScreenActivity({Key? key, required this.url}) : super(key: key);

  @override
  State<WebScreenActivity> createState() => _WebScreenActivityState();
}

class _WebScreenActivityState extends State<WebScreenActivity> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController with the provided URL
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Check if the URL is from Kuensel, then inject JavaScript to hide elements
            if (url.contains("kuenselonline")) {
              _injectKuenselScript();
            }
            setState(() {
              isLoading = false; // Hide the loading indicator after page loads
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _injectKuenselScript() {
    _controller.runJavaScript('''
      (function() {
        // Hide the header
        var header = document.querySelector('header'); 
        if (header) {
          header.style.display = 'none';
        }
        // Hide the nav
        var nav = document.querySelector('nav');
        if (nav) {
          nav.style.display = 'none';
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller), // Display the WebView
          if (isLoading)
            Center(child: CircularProgressIndicator()), // Show loading indicator
        ],
      ),
    );
  }
}
