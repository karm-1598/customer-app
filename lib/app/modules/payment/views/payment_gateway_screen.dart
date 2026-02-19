import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/order/views/order_history_screen.dart';
import 'package:shopperz/app/modules/payment/views/payment_failed_screen.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/utils/svg_icon.dart';
import 'package:shopperz/widgets/custom_snackbar.dart';
import 'package:shopperz/widgets/primary_button.dart';
import 'package:shopperz/widgets/textwidget.dart';

class PaymentView extends StatefulWidget {
  final int? orderId;
  final String? slug;
  
  const PaymentView({super.key, this.orderId, this.slug});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String? selectedUrl;
  bool isLoading = true;
  PullToRefreshController? pullToRefreshController;
  MyInAppBrowser? browser;

  @override
  void initState() {
    super.initState();
    if (widget.slug != null && widget.orderId != null) {
      selectedUrl = "${ApiList.baseUrl}/payment/${widget.slug}/pay/${widget.orderId}";
      _initData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customSnackbar("ERROR".tr, "Invalid payment details".tr, AppColor.error);
        Get.back();
      });
    }
  }

  void _initData() async {
    try {
      browser = MyInAppBrowser(
        onLoadingChanged: (loading) {
          if (mounted) {
            setState(() {
              isLoading = loading;
            });
          }
        },
      );

      if (Platform.isAndroid) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(true);
        
        bool swAvailable = await WebViewFeature.isFeatureSupported(
            WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
        bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
            WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

        if (swAvailable && swInterceptAvailable) {
          ServiceWorkerController serviceWorkerController =
              ServiceWorkerController.instance();
          await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              return null;
            },
          ));
        }
      }

      pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(
          color: AppColor.primaryColor,
        ),
        onRefresh: () async {
          if (Platform.isAndroid) {
            await browser?.webViewController?.reload();
          } else if (Platform.isIOS) {
            final url = await browser?.webViewController?.getUrl();
            if (url != null) {
              await browser?.webViewController?.loadUrl(
                urlRequest: URLRequest(url: url),
              );
            }
          }
        },
      );

      if (browser != null) {
        browser!.pullToRefreshController = pullToRefreshController;
      }

      await browser?.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(selectedUrl!)),
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            hideUrlBar: true,
            hideToolbarTop: true,
            toolbarTopBackgroundColor: AppColor.primaryColor,
          ),
          webViewSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
            javaScriptEnabled: true,
            domStorageEnabled: true,
            clearCache: false,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        customSnackbar("ERROR".tr, "Failed to load payment page".tr, AppColor.error);
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    browser?.close();
    browser = null;
    pullToRefreshController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.whiteColor,
        body: Center(
          child: Stack(
            children: [
              if (isLoading)
                Container(
                  color: AppColor.whiteColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyInAppBrowser extends InAppBrowser {
  bool _canRedirect = true;
  final Function(bool)? onLoadingChanged;
  PullToRefreshController? pullToRefreshController;

  MyInAppBrowser({this.onLoadingChanged});

  @override
  Future onBrowserCreated() async {
    debugPrint("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    onLoadingChanged?.call(true);
    _pageRedirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    onLoadingChanged?.call(false);
    _pageRedirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    onLoadingChanged?.call(false);
    debugPrint("Load Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
      onLoadingChanged?.call(false);
    }
  }

  @override
  void onExit() {
    if (_canRedirect) {
      _canRedirect = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.context != null) {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  contentPadding: EdgeInsets.all(10.r),
                  content: const PaymentFailedView(),
                ),
              );
            },
          );
        }
      });
    }
  }

  @override
  Future<NavigationActionPolicy>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) async {
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(LoadedResource resource) {
    debugPrint("Resource loaded: ${resource.url}");
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    debugPrint("Console: ${consoleMessage.message}");
  }

  void _pageRedirect(String url) async {
    if (!_canRedirect) return;

    await Future.delayed(const Duration(seconds: 1));

    if (!_canRedirect) return;

    bool isSuccess = url.contains('success') && url.contains(ApiList.baseUrl);
    bool isFailed = url.contains('fail') && url.contains(ApiList.baseUrl);
    bool isCancel = url.contains('cancel') && url.contains(ApiList.baseUrl);
    bool isBack = url.contains('checkout/payment') && url.contains(ApiList.baseUrl);

    if (isSuccess || isFailed || isCancel || isBack) {
      _canRedirect = false;
      await close();

      if (isSuccess) {
        _handleSuccessPayment();
      } else if (isFailed || isCancel || isBack) {
        _handleFailedPayment();
      }
    }
  }

  void _handleSuccessPayment() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.context != null) {
        Get.back();
        Get.dialog(
          barrierDismissible: false,
          Dialog(
            insetPadding: EdgeInsets.all(10.r),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  height: 318.h,
                  width: 328.w,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16.h),
                        TextWidget(
                          text: 'Thank you for your order!'.tr,
                          color: AppColor.textColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 20.h),
                        Image.asset(
                          AppImages.oderConfirm,
                          height: 120.h,
                          width: 120.w,
                        ),
                        SizedBox(height: 20.h),
                        TextWidget(
                          text: 'Your order is confirmed.'.tr,
                          color: AppColor.textColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 16.h),
                        InkWell(
                          onTap: () {
                            Get.back();
                            Get.off(() => const OrderHistoryScreen());
                          },
                          child: PrimaryButton(
                            text: 'Go to order details'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(
                      SvgIcon.close,
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        customSnackbar(
          "SUCCESS".tr,
          "YOUR_PAYMENT_HAS_BEEN_CONFIRMED".tr,
          AppColor.success,
        );

        try {
          final CartController cartController = Get.find<CartController>();
          cartController.cartItems.clear();
        } catch (e) {
          debugPrint("Cart controller not found: $e");
        }
      }
    });
  }

  void _handleFailedPayment() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.context != null) {
        Get.back();
        customSnackbar(
          "ERROR".tr,
          "PAYMENT_FAILED".tr,
          AppColor.error,
        );
      }
    });
  }
}