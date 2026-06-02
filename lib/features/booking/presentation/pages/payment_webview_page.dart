import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String checkoutUrl;

  const PaymentWebViewPage({super.key, required this.checkoutUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // PayOS usually redirects to the cancelUrl or returnUrl
            // You can look for 'cancel' or 'success' in the URL to close the webview
            final url = request.url.toLowerCase();
            
            // If the backend configured the returnUrl to have 'cancel' or 'success'
            // We intercept it here
            if (url.contains('cancel') || url.contains('error') || url.contains('fail')) {
              // User cancelled or payment failed
              if (context.mounted) {
                context.pop('cancel');
              }
              return NavigationDecision.prevent;
            } else if (url.contains('success') || url.contains('complete') || url.contains('return')) {
              // Payment success
              if (context.mounted) {
                context.pop('success');
              }
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        title: const Text('Thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Cancel manually
            context.pop('manual_close');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
        ],
      ),
    );
  }
}
