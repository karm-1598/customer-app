import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final ledController = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initFlow();
  }

  Future<void> initFlow() async {
    try {
      await ledController.getAccountNumber();

      final accountNo = ledController.accountNo.value;
      print('Account number: $accountNo');

      if (accountNo.isEmpty) {
        setState(() {
          _errorMessage = "Account number not found";
          _isLoading = false;
        });
        return;
      }

      final url = "http://hospitalitycenter.in/api/apiLedger.aspx?accountno=$accountNo";

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            onWebResourceError: (error) {
              setState(() {
                _errorMessage = "Failed to load: ${error.description}";
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      setState(() {
        _webViewController = controller;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ledger"),
        backgroundColor: AppColor.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (_webViewController != null &&
                await _webViewController!.canGoBack()) {
              _webViewController!.goBack();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _webViewController == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // padding top to push content down
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: WebViewWidget(controller: _webViewController!),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }
}