import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/apiServices/common_widget.dart';
import 'package:shopperz/app/controller/sign_in_controller.dart';
import 'package:shopperz/widgets/appbar3.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../utils/validation_rules.dart';
import '../../../../widgets/custom_form_field.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/form_field_title.dart';
import '../../../../widgets/primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // final authController = Get.put(AuthController());
  final LoginControllers _loginController = Get.put(LoginControllers());

  // final swapController = Get.put(SwapTitleController());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // final phoneController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  bool mark = false;

  @override
  void initState() {
    super.initState();
    // // authController.getSetting();
    // // authController.getCountryCode();
    //
    // emailController.text = box.read('email') == null ? '' : box.read('email').toString();
    // passController.text = box.read('password') == null ? '' : box.read('password').toString();
    // // phoneController.text = box.read('phone') == null ? '' : box.read('phone').toString();
    // if (box.read('email') != null || box.read('password') != null || box.read('country_code') != null || box.read('phone') != null) {
    //   mark = true;
    // } else {
    //   mark = false;
    // }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    // phoneController.dispose();
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
      child: GetX<LoginControllers>(
        init: LoginControllers(),
        builder: (controller) {
          return LoadingStateWidget(
            isLoading: controller.isLoading.value,
            child: Scaffold(
              appBar: const AppBarWidget3(text: ''),
              backgroundColor: AppColor.primaryBackgroundColor,
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Sing In".tr,
                          color: AppColor.primaryColor,
                          size: 26.sp,
                          weight: FontWeight.w700,
                        ),
                        SizedBox(height: 12.h),
                        CustomText(text: "Sign in to continue shopping".tr, size: 16.sp),
                        SizedBox(height: 30.h),
                        Form(
                          key: formkey,
                          child: Column(
                            children: [
                              FormFieldTitle(title: "Email".tr),
                              SizedBox(height: 4.h),
                              CustomFormField(
                                obsecure: false,
                                controller: emailController,
                                validator: (email) => ValidationRules().email(email),
                              ),
                              // const SwapFieldTitle(),
                              // SizedBox(height: 4.h),
                              // SwapFormField(
                              //   emailController: emailController,
                              //   emailValidator: (email) => ValidationRules().email(email),
                              //   // phoneController: phoneController,
                              //   prefix: Padding(
                              //     padding: EdgeInsets.only(left: 10.w),
                              //     child: PopupMenuButton(
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.all(
                              //           Radius.circular(10.r),
                              //         ),
                              //       ),
                              //       position: PopupMenuPosition.under,
                              //       // itemBuilder: (ctx) => authController.countryCodeModel != null
                              //       //     ? List.generate(
                              //       //         authController.countryCodeModel!.data!.length,
                              //       //         (index) => PopupMenuItem(
                              //       //               height: 32.h,
                              //       //               onTap: () async {
                              //       //                 setState(() {
                              //       //                   authController.countryCode =
                              //       //                       authController.countryCodeModel!.data![index].callingCode.toString();
                              //       //                 });
                              //       //               },
                              //       //               child: Text(
                              //       //                 authController.countryCodeModel!.data![index].callingCode.toString(),
                              //       //                 style:
                              //       //                     GoogleFonts.urbanist(color: AppColor.textColor, fontWeight: FontWeight.w500, fontSize: 16.sp),
                              //       //               ),
                              //       //             ))
                              //       //     : [],
                              //       child: Row(
                              //         children: [
                              //           Text(
                              //             authController.countryCode,
                              //             style: GoogleFonts.urbanist(color: AppColor.textColor, fontSize: 16.sp, fontWeight: FontWeight.w500),
                              //           ),
                              //           SizedBox(
                              //             width: 5.w,
                              //           ),
                              //           SvgPicture.asset(SvgIcon.down)
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              //   phoneValidator: (phone) => ValidationRules().normal(phone),
                              // ),
                              SizedBox(height: 20.h),
                              FormFieldTitle(title: "Password".tr),
                              SizedBox(height: 4.h),
                              CustomFormField(
                                obsecure: true,
                                controller: passController,
                                validator: (password) => ValidationRules().password(password),
                              ),
                              
                              SizedBox(height: 24.h),
                              PrimaryButton(
                                  text: "Sign In".tr,
                                  onTap: () {
                                    if (formkey.currentState!.validate()) {
                                      // if (swapController.isShowEmailField.value) {
                                      // if (mark == true) {
                                      //   box.write('email', emailController.text);
                                      //   box.write('password', passController.text);
                                      // } else if (mark == false) {
                                      //   box.remove('email');
                                      //   box.remove('password');
                                      // }
                                      _loginController.login(
                                          email: emailController.text,
                                          password: passController.text,
                                          deviceType: defaultTargetPlatform == TargetPlatform.android
                                              ? "android"
                                              : defaultTargetPlatform == TargetPlatform.iOS
                                              ? "ios"
                                              : "",
                                          context: context);
                                      // : authController.signInWithPhone(
                                      //     phone: "",
                                      //     // phoneController.text,
                                      // countryCode: authController.countryCode, password: passController.text);
                                    } else {
                                      debugPrint("Login is failed");
                                    }
                                  }),
                              SizedBox(height: 20.h),
                              
                            ],
                          ),
                        ),
                        SizedBox(height: 200.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
