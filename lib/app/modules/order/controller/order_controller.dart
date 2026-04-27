import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopperz/app/apiServices/network_call.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/data/model/order_history_model.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/custom_snackbar.dart';

class OrderController extends GetxController {

  // ─── Order History ─────────────────────────────────────────────────
  final orderHistoryModel = OrderHistoryModel().obs;
  final orderHistoryList = <OrderHistory>[].obs;
  final isLoading = false.obs;
  final box = GetStorage();

  ScrollController scrollController = ScrollController();
  RxBool hasMoreData = true.obs;
  int _currentPage = 1;
  final RxBool _isFetching = false.obs;

  // ─── Order Details ─────────────────────────────────────────────────
  // ✅ Added back for OrderDetailsScreen
  final orderDetailsMap = <OrderHistory>[].obs;
  OrderHistory? selectedOrder;         // currently viewed order
  List<Items> selectedOrderItems = []; // items of currently viewed order

  @override
  void onInit() {
    super.onInit();
    if (box.read('isLogedIn') == true) {
    getOrderHistory();
  }
  }

  // ─── Load More (scroll listener) ───────────────────────────────────
  void loadMoreData() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!_isFetching.value && hasMoreData.value) {
          getOrderHistory();
        }
      }
    });
  }

  // ─── Fetch Order History ───────────────────────────────────────────
  Future<void> getOrderHistory() async {
  if (_isFetching.value || !hasMoreData.value) return;

  try {
    _isFetching.value = true;
    isLoading(true);

    getAPI(
      methodName: ApiList.orderHistory,
      param: {
        "emailId": box.read('email') ?? '',
        "page": _currentPage.toString(),
      },
      callback: (value) {
        try {
          if (value.response.isEmpty) {
            print("❌ Response is null or empty");
            return;
          }

          Map<String, dynamic> tempMap = jsonDecode(value.response);
          OrderHistoryModel result = OrderHistoryModel.fromJson(tempMap);

          orderHistoryModel.value = result;

          if (result.orderHistory != null && result.orderHistory!.isNotEmpty) {
            orderHistoryList.addAll(result.orderHistory!);
            _currentPage++;
            if (result.orderHistory!.length < 10) {
              hasMoreData.value = false;
            }
          } else {
            hasMoreData.value = false;
          }

        } catch (parseError) {
          print("❌ JSON parse error: $parseError");
        } finally {
          isLoading(false);
          _isFetching.value = false;
        }
      },
    );

  } catch (e) {
    isLoading(false);
    _isFetching.value = false;
    print("❌ Failed to get order history: $e");
  }
}
  // ─── Get Order Details by OrderId ─────────────────────────────────
  void getOrderDetails({required String id}) {
    try {
      isLoading(true);

      // Find the order from already loaded list
      final found = orderHistoryList.firstWhereOrNull(
        (o) => o.orderId == id,
      );

      if (found != null) {
        selectedOrder = found;
        selectedOrderItems = found.items ?? [];
        orderDetailsMap.assignAll([found]);
      }

      isLoading(false);

    } catch (e) {
      isLoading(false);
      print("Failed to get order details: $e");
    }
  }

  //--- Re-Order---------------------------------
  Future<void> reOrder({
    required String orderId
  })async{
    try{
      postAPI(
        methodName: ApiList.reOrder, 
        param: {
          "orderId":orderId,
          "emailId":box.read('email') ?? ''
        }, 
        callback: (value){
          if(value.response.isEmpty){
            print("Response is Empty");
            return;
          }
          Map<String, dynamic> tempMap=jsonDecode(value.response);
          if(tempMap['msg'].toString().toLowerCase() =='true'){
            customSnackbar('Added!', "We’ve added these items to your cart. Ready to checkout?", Colors.green);
          }else{
            print('Failed to re order');
          }
        });
    }catch(e){
      print("Failed to reorder $e");
    }
  }

  // ─── Cancel Order ──────────────────────────────────────────────────
  // ✅ Added back for OrderDetailsScreen
  Future<void> cancelOrder({required String orderId}) async {
    // try {
    //   isLoading(true);

    //   getAPI(
    //     methodName: '${ApiList.orderCancel}$orderId',
    //     param: {"status": "15"},
    //     callback: (value) {
    //       Map<String, dynamic> response = jsonDecode(value.response);

    //       if (value.response == 200) {
    //         isLoading(false);
    //         customSnackbar(
    //           "SUCCESS".tr,
    //           'Order Canceled Successfully!'.tr,
    //           AppColor.success,
    //         );
    //         // ✅ Refresh list and details after cancel
    //         resetState();
    //         getOrderHistory();
    //         getOrderDetails(id: orderId);

    //       } else {
    //         isLoading(false);
    //         customSnackbar(
    //           "ERROR".tr,
    //           response["message"]?.toString() ?? 'Something went wrong',
    //           AppColor.error,
    //         );
    //       }
    //     },
    //   );
    // } catch (e) {
    //   isLoading(false);
    //   print("Failed to cancel order: $e");
    // }
  }

  // ─── Get items of a specific order ────────────────────────────────
  List<Items> getItemsForOrder(String orderId) {
    final order = orderHistoryList.firstWhereOrNull(
      (o) => o.orderId == orderId,
    );
    return order?.items ?? [];
  }

  // ─── Reset ────────────────────────────────────────────────────────
  void resetState() {
    orderHistoryList.clear();
    orderHistoryModel.value = OrderHistoryModel();
    orderDetailsMap.clear();
    selectedOrder = null;
    selectedOrderItems = [];
    _currentPage = 1;
    hasMoreData.value = true;
    _isFetching.value = false;
  }
}