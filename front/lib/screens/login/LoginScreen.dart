import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/auth_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
            body: SafeArea(
              child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(const Color(0x00000000))
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onProgress: (int progress) {
                          // Update loading bar.
                        },
                        onPageStarted: (String url) {
                          var index = url.indexOf("key=");
                          if (index != -1) {
                            var help = url.substring(index);
                            AuthRepository().login(help.split("=")[1]);
                            Navigator.pop(context, true);
                          }
                        },
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                        onNavigationRequest: (NavigationRequest request) {
                          if (request.url
                              .startsWith('https://www.youtube.com/')) {
                            return NavigationDecision.prevent;
                          }
                          return NavigationDecision.navigate;
                        },
                      ),
                    )
                    ..loadRequest(Uri.parse(
                        'http://ionnier.com/login?return_url=adasdasd'))),
            )));
  }
}
