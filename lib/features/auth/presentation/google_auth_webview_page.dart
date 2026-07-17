import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class GoogleAuthWebViewPage extends StatefulWidget {
  final String authUrl;

  const GoogleAuthWebViewPage({super.key, required this.authUrl});

  @override
  State<GoogleAuthWebViewPage> createState() => _GoogleAuthWebViewPageState();
}

class _GoogleAuthWebViewPageState extends State<GoogleAuthWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Standard mobile Chrome User-Agent to bypass Google's WebView OAuth block
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkAndExtractToken(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkAndExtractToken(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final token = _extractTokenFromUrl(url);
            if (token != null) {
              Navigator.of(context).pop(token);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  String? _extractTokenFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // Check query parameters
      if (uri.queryParameters.containsKey('token')) {
        return uri.queryParameters['token'];
      }
      if (uri.queryParameters.containsKey('accessToken')) {
        return uri.queryParameters['accessToken'];
      }
      if (uri.queryParameters.containsKey('access_token')) {
        return uri.queryParameters['access_token'];
      }
      // Check hash fragment (if frontend uses hash routing)
      if (uri.fragment.contains('token=')) {
        final fragmentUri = Uri.parse('?${uri.fragment}');
        return fragmentUri.queryParameters['token'];
      }
    } catch (_) {}
    return null;
  }

  Future<void> _checkAndExtractToken(String url) async {
    // 1. Check URL
    final urlToken = _extractTokenFromUrl(url);
    if (urlToken != null) {
      if (mounted) Navigator.of(context).pop(urlToken);
      return;
    }

    // 2. Try to extract token from LocalStorage or SessionStorage using JS
    try {
      final result = await _controller.runJavaScriptReturningResult(
        "localStorage.getItem('token') || localStorage.getItem('accessToken') || sessionStorage.getItem('token')",
      );
      
      // Clean up string returned by JS engine (e.g. remove quotes)
      var jsToken = result.toString().trim();
      if (jsToken.startsWith('"') && jsToken.endsWith('"')) {
        jsToken = jsToken.substring(1, jsToken.length - 1);
      }
      
      if (jsToken.isNotEmpty && jsToken != 'null') {
        if (mounted) Navigator.of(context).pop(jsToken);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      appBar: AppBar(
        title: Text(
          'Sign in with Google',
          style: TextStyle(color: context.cFg, fontSize: 16),
        ),
        backgroundColor: context.cCard,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.cFg),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.landingPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
