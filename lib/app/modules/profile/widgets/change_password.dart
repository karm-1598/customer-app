import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/loader/loader.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../widgets/custom_form_field.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/form_field_title.dart';
import '../../../../widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ProfileController profileController = Get.isRegistered<ProfileController>()?Get.find<ProfileController>(): Get.put(ProfileController());
  Worker? _worker;

  void initState() {
    super.initState();
    setState(() {
      hideOldPass=true;
      hideNewPass=true;
    });
    _worker = ever(profileController.passwordUpdateStatus, (int status) {
      if (status == 1) {
        // ✅ Success
        
        Get.snackbar(
          'CHANGE_PASSWORD'.tr,
          'PASSWORD_UPDATE_SUCCESSFULLY'.tr,
          backgroundColor: AppColor.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); // ✅ instead of Get.back()
    });
        
      } else if (status == 2) {
        // ✅ Failed
        Get.snackbar(
          'CHANGE_PASSWORD'.tr,
          'PASSWORD_UPDATE_FAILED'.tr,
          backgroundColor: AppColor.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }
  @override
  void dispose() {
    _worker?.dispose(); // ✅ clean up worker
    super.dispose();
  }

  bool validate = false;
  bool hideOldPass=true;
  bool hideNewPass=true;


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Obx(
        ()=> Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              backgroundColor: AppColor.primaryBackgroundColor,
              resizeToAvoidBottomInset: true,
              appBar: AppBarWidget3(text: '',),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Change Password".tr,
                        color: AppColor.primaryColor,
                        size: 22.sp,
                        weight: FontWeight.w700,
                      ),
                      SizedBox(height: 30.h),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormFieldTitle(title: "Old Password".tr),
                            SizedBox(height: 4.h),
                            CustomFormField(
                              controller: profileController.oldPasswordController,
                                    validator: (value) => value!.isEmpty
                                                  ? 'PLEASE_TYPE_OLD_PASSWORD'.tr
                                                  : null,
                              obsecure: hideOldPass,
                              trailingIcon: IconButton(onPressed: (){
                                setState(() {
                                  hideOldPass=!hideOldPass;
                                });
                              }, icon: !hideOldPass? Icon(Icons.visibility):Icon(Icons.visibility_off)),
                            ),
                            SizedBox(height: 20.h),
                            FormFieldTitle(title: "New Password".tr),
                            SizedBox(height: 4.h),
                            CustomFormField(
                              controller: profileController.newPasswordController,
                                    validator: (value) => value!.isEmpty
                                                  ? 'PLEASE_TYPE_NEW_PASSWORD'.tr
                                                  : null,
                              obsecure: hideNewPass,
                              trailingIcon: IconButton(onPressed: (){
                                setState(() {
                                  hideNewPass=!hideNewPass;
                                });
                              }, icon: !hideNewPass? Icon(Icons.visibility):Icon(Icons.visibility_off)),
                            ),
                            
                            SizedBox(height: 30.h),
                            PrimaryButton(
                              text: "Save Changes".tr,
                              width: 153.w,
                              onTap: () {
                                validateAndSave(context);
                                              (context as Element).markNeedsBuild();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            profileController.isLoading.value
                  ? LoaderCircle()
                  : SizedBox(),
          ],
        ),
      ),
    );
  }

  void validateAndSave(context) {
  final FormState? form = _formKey.currentState;
  if (form!.validate()) {
    FocusManager.instance.primaryFocus?.unfocus();

    profileController.updateUserPassword(
      profileController.oldPasswordController.value.text,
      profileController.newPasswordController.value.text,
    );
    validate = true;
  } else {
    validate = false;
  }
}

}
