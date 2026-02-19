import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopperz/app/apiServices/extension_widget.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/utils/images.dart';

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

Future<bool?> toast(String txt) => Fluttertoast.showToast(
      msg: txt,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColor.primaryColor,
      textColor: AppColor.whiteColor,
      fontSize: 16.0,
    );

/// 🔥 REPLACED flutter_animated_dialog
handleError(String value, BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Error",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedValue =
          Curves.fastOutSlowIn.transform(animation.value);

      return Transform.translate(
        offset: Offset(0, (1 - curvedValue) * 200),
        child: Opacity(
          opacity: animation.value,
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding:
                  const EdgeInsets.symmetric(vertical: 10),
              width: getScreenWidth(context) * 0.8,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ).alertCard(context),
            ),
          ),
        ),
      );
    },
  );
}

class LoadingStateWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingStateWidget({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: child,
        ),
        Visibility(
          visible: isLoading,
          child: const LoadingWidget(),
        ),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SpinKitCircle(
        color: AppColor.primaryColor,
        size: 40,
      ),
    );
  }
}

Widget cachedNetWorkImageForCircle(
  String? url,
  double radius, {
  double? height,
  double? width,
}) {
  return (url == null || url.isEmpty)
      ? Image.asset(
          AppImages.banner,
          scale: 2,
        )
      : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.fill,
          height: height,
          width: width,
          imageBuilder: (context, imageProvider) =>
              Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(radius),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.fill,
              ),
            ),
          ),
          placeholder: (context, url) =>
              const CupertinoActivityIndicator(
            radius: 10.0,
            animating: true,
            color: AppColor.primaryColor,
          ),
          errorWidget: (context, url, error) =>
              const Text("Please check this image"),
        );
}
