import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/app/modules/shipping/controller/address_controller.dart';
import 'package:shopperz/app/modules/shipping/controller/show_address_controller.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/utils/constant.dart';
import 'package:shopperz/utils/svg_icon.dart';
import 'package:shopperz/utils/validation_rules.dart';
import 'package:shopperz/widgets/loader/loader.dart';
import '../../../../config/theme/app_color.dart';
import '../../../../widgets/custom_form_field.dart';
import '../../../../widgets/custom_phone_form_field.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/form_field_title.dart';
import '../../../../widgets/secondary_button2.dart';

class AddNewAddressDialog extends StatefulWidget {
  const AddNewAddressDialog({super.key});

  @override
  State<AddNewAddressDialog> createState() => _AddNewAddressDialogState();
}

class _AddNewAddressDialogState extends State<AddNewAddressDialog> {
  AuthController auth = Get.put(AuthController());
  AddressController addressController = Get.put(AddressController());
  final showAddressController = Get.put(ShowAddressController());
  ProfileController profile = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    auth.getSetting();
    auth.getCountryCode();
    addressController.countryCode = auth.countryCode;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 328.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: AppColor.whiteColor,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12.r),
            child: Form(
              key: addressController.formkey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),

                    /// Title
                    CustomText(
                      text: "Add New Address".tr,
                      size: 22.sp,
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: 10.h),

                    /// Name
                    FormFieldTitle(title: "Full Name".tr),
                    SizedBox(height: 4.h),
                    CustomFormField(
                      controller: addressController.nameTextController,
                      validator: (name) =>
                          ValidationRules().normal(name),
                    ),
                    SizedBox(height: 10.h),

                    /// Email
                    FormFieldTitle(title: "Email".tr),
                    SizedBox(height: 4.h),
                    CustomFormField(
                      controller:
                          addressController.emailTextController,
                      validator: (value) {
                        RegExp regExp =
                            RegExp(regularExpressionEmail);
                        if (value!.isNotEmpty &&
                            !regExp.hasMatch(value)) {
                          return 'Enter Valid Email Address'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),

                    /// Phone
                    FormFieldTitle(title: "Phone".tr),
                    SizedBox(height: 4.h),
                    CustomPhoneFormField(
                      phoneController:
                          addressController.phoneTextController,
                      validator: (phone) =>
                          ValidationRules().normal(phone),
                      prefix: Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.r),
                          ),
                          position: PopupMenuPosition.under,
                          itemBuilder: (ctx) => List.generate(
                            auth.countryCodeModel!.data!.length,
                            (index) => PopupMenuItem(
                              height: 32.h,
                              onTap: () {
                                setState(() {
                                  addressController.countryCode =
                                      auth
                                          .countryCodeModel!
                                          .data![index]
                                          .callingCode
                                          .toString();
                                });
                              },
                              child: Text(
                                auth.countryCodeModel!.data![index]
                                    .callingCode
                                    .toString(),
                                style: GoogleFonts.urbanist(
                                  color: AppColor.textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                addressController.countryCode,
                                style: GoogleFonts.urbanist(
                                  color: AppColor.textColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              SvgPicture.asset(SvgIcon.down)
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    /// Country / State / City
                    FormFieldTitle(title: "Address".tr),
                    SizedBox(height: 6.h),

                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(8.r),
                        border: Border.all(
                            color: AppColor.inactiveColor),
                      ),
                      child: SelectState(
  onCountryChanged: (value) {
    addressController.country.value = value;
  },
  onStateChanged: (value) {
    addressController.state.value = value;
  },
  onCityChanged: (value) {
    addressController.city.value = value;
  },
),

                    ),

                    SizedBox(height: 10.h),

                    /// Zip
                    FormFieldTitle(title: "Zip Code".tr),
                    SizedBox(height: 4.h),
                    CustomFormField(
                      controller:
                          addressController.zipTextController,
                    ),
                    SizedBox(height: 10.h),

                    /// Street
                    FormFieldTitle(
                        title: "Street Address".tr),
                    SizedBox(height: 4.h),
                    CustomFormField(
                      controller:
                          addressController.streetTextController,
                      validator: (address) =>
                          ValidationRules().normal(address),
                    ),

                    SizedBox(height: 24.h),

                    /// Buttons
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        SecondaryButton2(
                          height: 48.h,
                          width: 158.w,
                          text: "Add Address".tr,
                          buttonColor:
                              AppColor.primaryColor,
                          textColor: AppColor.whiteColor,
                          onTap: () async {
                            if (addressController
                                .formkey.currentState!
                                .validate()) {
                              if (box.read("token") != null) {
                                await addressController
                                    .submitAddress();
                                await showAddressController
                                    .showAdresses();
                                profile.getAddress();
                                Get.back();
                              } else {
                                Get.off(() =>
                                    const SignInScreen());
                              }
                            }
                          },
                        ),
                        SecondaryButton2(
                          height: 48.h,
                          width: 114.w,
                          text: "Cancel".tr,
                          buttonColor: AppColor.cartColor,
                          textColor: AppColor.textColor,
                          onTap: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// Loader
        Obx(() => addressController.isLoading.value
            ? LoaderCircle()
            : const SizedBox())
      ],
    );
  }
}
