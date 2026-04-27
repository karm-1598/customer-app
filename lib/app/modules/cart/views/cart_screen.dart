import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/cart/views/guest_cart_confirm.dart';
import 'package:shopperz/app/modules/cart/widgets/cart_item.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/widgets/devider.dart';
import 'package:shopperz/widgets/primary_button.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../widgets/custom_snackbar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartController = Get.isRegistered<CartController>() 
    ? Get.find<CartController>() 
    : Get.put(CartController());

  final authController = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if(cartController.isLoggedIn){
      cartController.getWishlistProducts();
      cartController.getAddressByEmail();
    }else{
      cartController.loadGuestCart();
      print("+++++++ ${cartController.wishlistProducts.map((e) => e.toJson()).toList()}");
    }
  });

    
  }

  @override
  void dispose() {
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.primaryBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.only(left: 16.w, top: 8.h, right: 16.w),
                child: Text(
                  "Shopping Cart".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textColor,
                  ),
                ),
              ),
              leadingWidth: double.infinity,
            ),
          ),
          body: Column(
            children: [
              cartController.isLoggedIn? Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text('Ship to'),
                    Spacer(),
                    Obx(() => SizedBox(
                      height: 50,
                      width: 250,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: cartController.selectedAddress.value.isEmpty 
                        ? null 
                        : cartController.selectedAddress.value,
                        items: cartController.addressList.map((address) => DropdownMenuItem<String>( 
                          value: address['company'] as String, 
                          child: TextWidget(
                            text: address['company'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ), 
                        )).toList(),
                        onChanged: (String? value) {
                          cartController.selectedAddress.value = value as String;
                        },
                      ),
                    )),
                  ],
                ),
              ):SizedBox.shrink(),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w),
                      child: Obx(() {
                        if (cartController.wishlistProducts.isEmpty) {
                          return Center(
                            child: Image.asset(
                              AppImages.emptyIcon,
                              height: 250.h,
                            ),
                          );
                        }
                
                        return ListView.builder(
                          padding: EdgeInsets.only(top: 16.h, bottom: 180.h),
                          itemCount: cartController.wishlistProducts.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: RepaintBoundary(
                                child: CartWidget(item: cartController.wishlistProducts[index], controller: cartController)
                              ),
                            );
                          },
                        );
                      }),
                    ),
                
                    /// Bottom Checkout Section
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w,),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const DeviderWidget(),
                            SizedBox(height: 12.h),
                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     TextWidget(
                            //       text: 'Subtotal'.tr,
                            //       fontSize: 16.sp,
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //     Obx(() => TextWidget(
                            //           text:
                            //               '${authController.currency}${cartController.totalPrice.toStringAsFixed(2)}',
                            //           fontSize: 16.sp,
                            //           fontWeight: FontWeight.w600,
                            //         )),
                            //   ],
                            // ),
                            
                            SizedBox(height: 16.h),
                            PrimaryButton(
                              text: 'Procced to Checkout',
                              onTap: () {
                                if (cartController.wishlistProducts.isEmpty) {
                                  customSnackbar(
                                    "ERROR".tr,
                                    "Your cart is empty",
                                    AppColor.error,
                                  );
                                } else {
                                  if (cartController.isLoggedIn) {
                                    cartController.addQuatation();
                                  } else {
                                    Get.to(() => GuestCartConfirm());
                                  }
                                }
                              },
                            ),
                            // SizedBox(height: 12.h),
                            // TextWidget(
                            //   text:
                            //       'Shipping, Taxes & Discount Calculate at Checkout',
                            //   fontSize: 12.sp,
                            //   fontWeight: FontWeight.w500,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
