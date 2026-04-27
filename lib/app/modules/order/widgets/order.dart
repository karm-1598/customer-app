import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopperz/app/modules/order/controller/order_controller.dart';
import 'package:shopperz/data/model/order_history_model.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';

class OrderWidget extends StatelessWidget {
  const OrderWidget({super.key,required this.order, required this.controller});
  final OrderHistory? order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Get.to(()=> OrderDetailsScreen(id: order!.id.toString()));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(0, 3),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextWidget(
                    text: '#${order!.orderId}',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColor.primaryColor,
                  ),
                ),
                SizedBox(width: 15,),
                
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16,),
                    SizedBox(width: 3,),
                    TextWidget(text: order!.orderDate),
                  ],
                )
              ],
            ),
            SizedBox(height: 10,),
            AutoSizeText(
              order!.companyName ?? '--',
              softWrap: true,
              maxLines: 2,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 8,),
            ...order!.items!.map((data) => Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CachedNetworkImage(
                        imageUrl: data.image ?? '',
                        fit: BoxFit.cover,
                        memCacheHeight: 100,
                        memCacheWidth: 100,
                        errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: Colors.grey[300]),
                        placeholder: (_, __) => Container(color: Colors.grey[100]),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: data.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextWidget(
                                  text: "QTY: ${data.itemQty} - ${data.unit}",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(
                                  color: data.orderStatus?.toLowerCase() == 'pending'
                                      ? Colors.yellow.withOpacity(0.20)
                                      : Colors.green.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextWidget(
                                  text: data.orderStatus,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: data.orderStatus?.toLowerCase() == 'pending'
                                      ? Colors.amber
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.black12),
              ],
            )),
            
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(onPressed: (){
                controller.reOrder(orderId: order!.orderId!);
              }, child: Text('RE-ORDER'))),
          ],
        ),
      )
    );
  }
}


/**
 * Stack(
        children: [
          Container(
            height: 191.h,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                      color: AppColor.blackColor.withOpacity(0.04),
                      offset: const Offset(0, 0),
                      blurRadius: 10.r)
                ]),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: '#${order!.orderId}',
                    color: AppColor.textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: order!.orderDate.toString(),
                    color: AppColor.deSelectedColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  Row(
                    children: [
                      TextWidget(
                        text: 'Info: '.tr,
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      TextWidget(
                        text: 'Customer :${order!.companyName.toString()} ',
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextWidget(
                        text: 'Delivery Status: '.tr,
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      TextWidget(
                        text: order!.city.toString(),
                        // color: order!.status == 1 ? AppColor
                        //     .pendingColor : order!.status == 5 ? AppColor.primaryColor : order!.status == 7 ? AppColor.onthewayColor : order!.status == 10 ? AppColor.greenColor : order!.status == 15 ? AppColor.redColor2 : order!.status == 20 ? AppColor.redColor2 : null,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextWidget(
                        text: 'Payment Status: '.tr,
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            // color: order!.paymentStatus == 5 ? AppColor
                            //     .paidColor: order!.paymentStatus == 10 ? AppColor.unpaidColor:null,
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Wrap(
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 2.w, right: 2.w),
                                  child: TextWidget(
                                    text: order!.city,//order!.paymentStatus == 5 ? 'Paid'.tr : order!.paymentStatus == 10 ? 'Unpaid'.tr : '',
                                    // color: order!.paymentStatus == 5 ? AppColor
                                    //     .greenColor : order!.paymentStatus == 10 ? AppColor.redColor2 : null, // unpaid color AppColor.redColor2 //refund color AppColor.refundTextColor
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextWidget(
                        text: 'Total: '.tr,
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      TextWidget(
                        text: order!.city.toString(),
                        color: AppColor.textColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: box.read("languageCode") == 'ar' ? null : 16.w,
            left: box.read("languageCode") == 'ar' ? 16.w : null,
            top: 16.h,
            child: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.25),
                        offset: const Offset(0, 6),
                        blurRadius: 15.r)
                  ]),
              child: Center(
                child: SvgPicture.asset(
                  SvgIcon.eye,
                  colorFilter: const ColorFilter.mode(
                      AppColor.whiteColor, BlendMode.srcIn),
                  height: 20.h,
                  width: 20.w,
                ),
              ),
            ),
          )
        ],
      ),
 */