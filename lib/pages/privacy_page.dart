import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../service/token_service.dart';

class PrivacyPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(APP_TITLE)),
      body: WebView(
        initialUrl: 'https://www.freeprivacypolicy.com/privacy/view/f850a048a5ae4d2b2a5b5312d4a74236',
      )
    );
  }

}