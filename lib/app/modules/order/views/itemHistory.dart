import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/order/controller/item_controller.dart';
import 'package:shopperz/app/modules/order/widgets/item_history_widget.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/textwidget.dart';
 
import '../../../../config/theme/app_color.dart';

class ItemHistoryScreen extends StatefulWidget {
  const ItemHistoryScreen({super.key});

  @override
  State<ItemHistoryScreen> createState() => _ItemHistoryScreenState();
}

class _ItemHistoryScreenState extends State<ItemHistoryScreen> {
  ItemController itemController = Get.put(ItemController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    itemController.loadMoreData();
  });
  }

  @override
  void dispose() {
    itemController.resetState();
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
        backgroundColor: AppColor.primaryBackgroundColor,
        appBar: const AppBarWidget3(text: ''),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: TextWidget(
              text: 'Item History',
              color: AppColor.primaryColor,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: () async {
                if (box.read('isLogedIn') != false) {
                  itemController.resetState();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.h,
                    ),
                    Expanded(
                      child: Obx(
                        () => itemController.itemHistoryList.isNotEmpty
                            ? ListView.builder(
                                controller: itemController.scrollController,
                                itemCount:
                                    itemController.itemHistoryList.length +
                                        (itemController.hasMoreData == true
                                            ? 1
                                            : 0),
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (index ==itemController.itemHistoryList.length) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 40.h,
                                          width: 40.w,
                                          child:
                                              const CircularProgressIndicator(
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: ItemHistoryWidget(
                                      item: itemController.itemHistoryList[index], 
                                      controller: itemController
                                    )
                                  );
                                },
                              )
                            : Padding(
                                padding: EdgeInsets.only(top: 100.h),
                                child: Center(
                                  child: Image.asset(
                                    AppImages.emptyIcon,
                                    height: 300.h,
                                    width: 300.w,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
