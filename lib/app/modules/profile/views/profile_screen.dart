import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/language/views/about_us.dart';
import 'package:shopperz/app/modules/navbar/controller/navbar_controller.dart';
import 'package:shopperz/app/modules/navbar/views/navbar_view.dart';
import 'package:shopperz/app/modules/profile/views/pages_screen.dart';
import 'package:shopperz/app/modules/profile/widgets/change_password.dart';
import 'package:shopperz/app/modules/profile/widgets/delete_account_widget.dart';
import 'package:shopperz/app/modules/profile/widgets/ledger.dart';
import 'package:shopperz/app/modules/profile/widgets/menu_widget.dart';
import 'package:shopperz/app/modules/profile/widgets/outstanding.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/utils/svg_icon.dart';
import 'package:shopperz/widgets/devider.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';
import '../../order/views/order_history_screen.dart';
import '../../order/views/itemHistory.dart';
import 'my_account_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ProfileController profile = Get.put(ProfileController());
  // AuthController auth = Get.put(AuthController());
  // OrderController order = Get.put(OrderController());
  // LanguageController language = Get.put(LanguageController());
  // ReturnController returnController = Get.put(ReturnController());

  // @override
  // void initState() {
  //   super.initState();
  //   if (AppConstants.customerId.isNotEmpty) {
  //     profile.getProfile();
  //     profile.getAddress();
  //     profile.getTotalOrdersCount();
  //     profile.getTotalCompleteOrdersCount();
  //     profile.getTotalReturnOrdersCount();
  //     profile.getTotalWalletBalance();
  //     // order.getOrderHistory();
  //     // returnController.getReturnOrders();
  //     returnController.getReturnReason();
  //   }
  //   language.getLanguageData();
  //   profile.getPages();
  // }

  openDeleteAccountDialog() {
    Get.dialog(Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: AccountDeleteWidget(),
    ));
  }

  Future<dynamic> logoutDialog(){
    return Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      onConfirm: () async {
        // 1. Clear GetStorage (login state, email, company, etc.)
        final box = GetStorage();
        await box.erase();

        AppConstants.customerId = "";
        AppConstants.userName = "";
        AppConstants.emailId = "";

        // 2. Clear SharedPreferences (customer data, tokens)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Delete local DB tables (keep this, it's useful)

        // 4. Delete all GetX controllers from memory
        Get.deleteAll(force: true);

        // 5. Navigate to login/home screen
        Get.offAll(() => const NavBarView());
        final navController = Get.put(NavbarController());
        navController.selectPage(0);
      },
    
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            backgroundColor: AppColor.primaryBackgroundColor,
            appBar: AppBar(
              backgroundColor: AppColor.primaryBackgroundColor,
              elevation: 0,
              toolbarHeight: 48.h,
              leadingWidth: 130.w,
              leading: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w),
                child: SvgPicture.asset(
                  SvgIcon.logo,
                  height: 20.h,
                  width: 73.w,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 16.h,
                    ),
                    Column(
                      children: [
                        // AppConstants.customerId.isNotEmpty
                        //     ? Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                        //         Container(
                        //           height: 74.r,
                        //           width: 74.r,
                        //           decoration: BoxDecoration(
                        //             color: AppColor.whiteColor,
                        //             borderRadius: BorderRadius.circular(74.r),
                        //           ),
                        //           child: ClipRRect(
                        //             borderRadius: BorderRadius.circular(74.r),
                        //             child:
                        //                 // profile.profileMap.isNotEmpty
                        //                 //     ? CachedNetworkImage(
                        //                 //         imageUrl: profile
                        //                 //                 .profileModel
                        //                 //                 ?.data
                        //                 //                 ?.image ??
                        //                 //             "",
                        //                 //         imageBuilder: (context,
                        //                 //                 imageProvider) =>
                        //                 //             Container(
                        //                 //           decoration: BoxDecoration(
                        //                 //             image: DecorationImage(
                        //                 //               image: imageProvider,
                        //                 //               fit: BoxFit.cover,
                        //                 //             ),
                        //                 //           ),
                        //                 //         ),
                        //                 //         placeholder:
                        //                 //             (context, url) =>
                        //                 //                 Shimmer.fromColors(
                        //                 //           baseColor:
                        //                 //               Colors.grey[300]!,
                        //                 //           highlightColor:
                        //                 //               Colors.grey[400]!,
                        //                 //           child: Container(
                        //                 //               height: 74.r,
                        //                 //               width: 74.r,
                        //                 //               color: Colors.grey),
                        //                 //         ),
                        //                 //         errorWidget: (context, url,
                        //                 //                 error) =>
                        //                 //             const Icon(Icons.error),
                        //                 //       )
                        //                 //     :
                        //                 Shimmer.fromColors(
                        //               baseColor: Colors.grey[300]!,
                        //               highlightColor: Colors.grey[400]!,
                        //               child: Container(height: 74.r, width: 74.r, color: Colors.grey),
                        //             ),
                        //           ),
                        //         ),
                        //         Positioned(
                        //           bottom: -12.h,
                        //           child: InkWell(
                        //             onTap: () {
                        //               // profile.getImageFromGallary();
                        //             },
                        //             child: Container(
                        //               height: 32.r,
                        //               width: 32.r,
                        //               decoration: BoxDecoration(
                        //                   color: AppColor.textColor,
                        //                   border: Border.all(color: AppColor.whiteColor, width: 2.r),
                        //                   borderRadius: BorderRadius.circular(32.r)),
                        //               child: Center(
                        //                 child: SvgPicture.asset(
                        //                   SvgIcon.menuEdit,
                        //                   colorFilter: const ColorFilter.mode(AppColor.whiteColor, BlendMode.dst),
                        //                   height: 16.h,
                        //                   width: 16.w,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         )
                        //       ])
                        //     :
                        Container(
                          height: 74.r,
                          width: 74.r,
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(74.r),
                            image: DecorationImage(image: AssetImage(AppImages.profilePicture), fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        AppConstants.customerId.isNotEmpty
                            ? Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    TextWidget(
                                      text: AppConstants.userName,
                                      color: AppColor.textColor,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    )
                                  ],
                                ),
                                Column(children: [
                                  TextWidget(
                                    text: AppConstants.emailId,
                                    color: AppColor.textColor1,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  SizedBox(height: 8.h)
                                ]),
                              ])
                            : Column(
                                children: [
                                  TextWidget(
                                    text: 'SING_IN_TO_SEE_YOUR_INFO'.tr,
                                    color: AppColor.textColor,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      
                                      InkWell(
                                        onTap: () {
                                          Get.to(() => SignInScreen()
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(24.r),
                                        child: Ink(
                                          height: 48.h,
                                          width: 156.w,
                                          decoration: BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(24.r)),
                                          child: Center(
                                            child: TextWidget(
                                              text: 'Sign In'.tr,
                                              color: AppColor.whiteColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                      ],
                    ),
                    SizedBox(
                      height: 28.h,
                    ),
                    AppConstants.customerId.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MenuWidget(
                                text: 'MY_ACCOUNT'.tr,
                                icon: SvgIcon.menuProfile,
                                onTap: () {
                                  Get.to(() => const MyAccountScreen());
                                },
                              ),
                              const DeviderWidget(),
                              MenuWidget(
                                text: 'ORDER_HISTORY'.tr,
                                icon: SvgIcon.menuBag,
                                onTap: () {
                                  Get.to(() => const OrderHistoryScreen());
                                },
                              ),
                              const DeviderWidget(),
                              MenuWidget(
                                text: 'Item History'.tr,
                                icon: SvgIcon.menuRefresh,
                                onTap: () {
                                  Get.to(() => const ItemHistoryScreen());
                                },
                              ),
                              const DeviderWidget(),
                              MenuWidget(
                                text: 'Outstanding',
                                icon: SvgIcon.outstanding,
                                onTap: () {
                                  Get.to(() =>const Outstanding()
                                  );
                                },
                              ),
                              const DeviderWidget(),
                              MenuWidget(
                                text: 'Ledger'.tr,
                                icon: SvgIcon.notes,
                                onTap: () {
                                  Get.to(() => const LedgerScreen()
                                  );
                                },
                              ),
                              const DeviderWidget(),
                              MenuWidget(
                                text: 'CHANGE_PASSWORD'.tr,
                                icon: SvgIcon.menuKey,
                                onTap: () {
                                  Get.to(() => const ChangePasswordScreen());
                                },
                              ),
                              const DeviderWidget(),
                              
                            ],
                          )
                        : const SizedBox(),
                    MenuWidget(
                      text:  'About Us',
                      icon: SvgIcon.group,
                      onTap: () {
                        Get.to(() => const AboutUs());
                      },
                    ),
                    const DeviderWidget(),
                    // Obx(
                    //   () => SizedBox(
                    //     child: profile.pagesMap.isNotEmpty && profile.pagesModel?.data != null
                    //         ? ListView.builder(
                    //             shrinkWrap: true,
                    //             physics: const NeverScrollableScrollPhysics(),
                    //             itemCount: profile.pagesModel!.data!.length,
                    //             itemBuilder: (BuildContext context, index) {
                    //               return Column(
                    //                 children: [
                    //                   profileItem("Description", SvgIcon.tc, "Title 1"),
                    //                   DeviderWidget(),
                    //                 ],
                    //               );
                    //             })
                    //         : SizedBox(),
                    //   ),
                    // ),
                    AppConstants.customerId.isNotEmpty
                        ? InkWell(
                            onTap: () async {
                              logoutDialog();
                            },
                            child: MenuWidget(text: 'LOGOUT'.tr, icon: SvgIcon.menuLogout))
                        : SizedBox(),
                    SizedBox(
                      height: 20.h,
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          // auth.isLoading.value ? LoaderCircle() : SizedBox(),
        ],
      ),
    );
  }

  InkWell profileItem(des, icon, textValue) {
    return InkWell(
      onTap: () => Get.to(() => PagesScreen(
            tittle: textValue,
            description: des,
          )),
      child: SizedBox(
        height: 52.h,
        width: double.infinity,
        child: Center(
          child: Row(
            children: [
              SvgPicture.asset(
                '$icon',
                height: 20.h,
                width: 20.w,
              ),
              SizedBox(
                width: 16.w,
              ),
              TextWidget(
                text: '$textValue'.tr,
                color: AppColor.textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
