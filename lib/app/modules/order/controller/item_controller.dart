import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopperz/app/apiServices/network_call.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/data/model/item_history_model.dart';
import 'package:shopperz/data/server/app_server.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/custom_snackbar.dart';

class ItemController extends GetxController {

  RxList<ItemHistoryModel> returnReasonMap = <ItemHistoryModel>[].obs;
  

  TextEditingController selectedReason = TextEditingController();

  ScrollController scrollController = ScrollController();

  int paginate = 1;
  final page = 1.obs;
  final itemPerPage = 10.obs;
  final lastPage = 1.obs;

  String selectedReasonId = '';

  int quantity = 0;
  double price = 0.0;
  double total = 0.0;
  double tax = 0.0;
  // ----------------------------
  final  itemHistoryModel = ItemHistoryModel().obs;
  final itemHistoryList = <OrderItemHistory>[].obs;

  final RxBool _isFetching = false.obs;
  final RxBool hasMoreData = true.obs;
  int _currentPage = 1;
  // ------------------------------

  // List<ReturnOrder> returnItems = [];

  // void addItem(
  //     {required int index,
  //     required int id,
  //     required int quantity,
  //     required double price,
  //     required bool has_variation,
  //     required int order_quantity,
  //     required double return_price,
  //     required double tax,
  //     required double total,
  //     required String variation_id,
  //     required String variation_names}) {
  //   for (var item in returnItems) {
  //     if (item.index == index) {
  //       removeFromItem(item);
  //       return;
  //     }
  //   }
  //   returnItems.add(
  //     ReturnOrder(
  //       index: index,
  //       has_variation: has_variation,
  //       id: id,
  //       order_quantity: order_quantity,
  //       price: price,
  //       quantity: quantity,
  //       return_price: return_price,
  //       tax: tax,
  //       total: total,
  //       variation_id: variation_id,
  //       variation_names: variation_names,
  //     ),
  //   );
  // }

  // void incrementItem({required int index}) {
  //   for (var item in returnItems) {
  //     if (item.index == index) {
  //       if (item.quantity < item.order_quantity) {
  //         item.quantity++;
  //       }
  //       return;
  //     }
  //   }
  // }

  // void decrementItem({required int index}) {
  //   for (var item in returnItems) {
  //     if (item.index == index) {
  //       if (item.quantity > 1) {
  //         item.quantity--;
  //       }
  //       return;
  //     }
  //   }
  // }

  // checkItem({required int index}) {
  //   for (var item in returnItems) {
  //     if (item.index == index) {
  //       return true;
  //     }
  //   }
  // }

  // void removeFromItem(ReturnOrder returnOrder) {
  //   returnItems.remove(returnOrder);
  // }

  final isLoading = false.obs;

  final box = GetStorage();

  AppServer server = AppServer();

  @override
  void onInit() {
    super.onInit();
    if (box.read('isLogedIn') == true) {
    getItemhistoryList();
  }
  }

  // getReturnReason() async {
  //   returnReasonModel = await ReturnRepo.getReturnReason();

  //   returnReasonMap.add(returnReasonModel!);

  //   refresh();
  // }

  // // ----customer id
  // Future<String?> getCustomerId() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userData = prefs.getString(SharedPrefrenceData.customerData);
  //   if (userData != null) {
  //     List<dynamic> dataList = json.decode(userData);
  //     List<Customer> customer =
  //         dataList.map((data) => Customer.fromJson(data)).toList();
  //         print("Customer id:  ${customer[0].customerId}");
  //     return customer[0].customerId;
  //   }
  //   return null;
  // }

  // --Load more Data
  void loadMoreData(){
    scrollController.addListener((){
      if(scrollController.position.pixels ==
          scrollController.position.maxScrollExtent){
            if(!_isFetching.value && hasMoreData.value){
              getItemhistoryList();
            }
          }
    });
  }

  // ------Get item history list
  Future<void> getItemhistoryList() async{
    if(_isFetching.value || !hasMoreData.value)return;
    try{
      _isFetching.value=true;
      isLoading(true);

      getAPI(
        methodName: ApiList.orderItemHistory, 
        param: {
          "emailId":box.read('email') ??'',
          "page":_currentPage.toString()
        }, 
        callback: (value){
          try{
            if(value.response.isEmpty)return;
            Map<String, dynamic> tempMap=jsonDecode(value.response);
            ItemHistoryModel result=ItemHistoryModel.fromJson(tempMap);
            itemHistoryModel.value= result;

            if(result.orderItemHistory != null && result.orderItemHistory!.isNotEmpty){
              itemHistoryList.addAll(result.orderItemHistory!);
              _currentPage++;
              if(result.orderItemHistory!.length<10){
                hasMoreData.value=false;
              }
            }else{
              hasMoreData.value=false;
            }
          }catch(e){
            print("Failed to get item history $e");
          }finally {
            isLoading(false);
            _isFetching.value = false;
        }
        }
      );
    }catch(e){
      isLoading(false);
      _isFetching.value = false;
      print('Unexpected error at item history $e');
    }
  }

  
  // ------ logic for adding qty
  Future<void> plusQuantityFromHistory({
    required String productId,
    required String quantity,
  }) async {

    final int index = itemHistoryList.indexWhere(
      (item) => item.nopProductId == productId,
    );
    if (index == -1) return;

    final int currentQty = int.tryParse(itemHistoryList[index].newQty ?? '0') ?? 0;
    final int newQty = currentQty + 1;

    // Optimistic update
    itemHistoryList[index].newQty = newQty.toString();
    itemHistoryList.refresh();

    if (newQty == 1) {
      await _insertWishlistAndRefresh(
        productId: productId,
        index: index,
        rollbackQty: currentQty,
      );
    } else {
      await _plusQtyAndRefresh(
        productId: productId,
        quantity: quantity,
        index: index,
        rollbackQty: currentQty,
      );
    }
  }
    
  // ------ insertWishlist
  Future<void> _insertWishlistAndRefresh ({
  required String productId,
  required int index,
  required int rollbackQty,
}) async {
  postAPI(
    methodName: ApiList.addItemWishlist,
    param: {
      "customerId": box.read('customerId'),
      "productId": productId,
      "quantity": "1",
      "AttributeXml": "0",
    },
    callback: (value) {
      try {
        if (value.response.isEmpty) return;
        Map<String, dynamic> tempMap = jsonDecode(value.response);
        if (tempMap['msg'].toString().toLowerCase() == 'true') {
          customSnackbar('', 'Item added in cart...!', AppColor.activeColor);
        } else {
          // Rollback
          itemHistoryList[index].newQty = rollbackQty.toString();
          itemHistoryList.refresh();
          customSnackbar('Failed', 'Item is not added to cart', AppColor.error);
        }
      } catch (e) {
        itemHistoryList[index].newQty = rollbackQty.toString();
        itemHistoryList.refresh();
        print('Insert wishlist failed $e');
      }
    },
  );
}

  // ------ plus qty item in item history screen
  Future<void> _plusQtyAndRefresh({
    required String productId,
    required String quantity,
    required int index,
    required int rollbackQty,
  }) async {

    // ✅ Re-find the item by productId at call time — don't rely on stale index
    final int safeIndex = itemHistoryList.indexWhere(
      (item) => item.nopProductId == productId,
    );
    if (safeIndex == -1) return;

    postAPI(
      methodName: ApiList.plusQtyItem,
      param: {
        "customerId": box.read('customerId'),
        "productId": productId,
        "quantity": quantity,   // this is '1' — always increment by 1
      },
      callback: (value) {
        try {
          if (value.response.isEmpty) return;
          
          // ✅ Print raw response to see what API actually returns
          print('plusQty raw response: ${value.response}');
          
          Map<String, dynamic> tempMap = jsonDecode(value.response);
          
          // ✅ Print the parsed map to debug
          print('plusQty parsed: $tempMap');

          if (tempMap['Plus'].toString().toLowerCase() == 'true') {
            customSnackbar('', 'Item updated in cart...!', AppColor.activeColor);
          } else {
            // Rollback
            final int rb = itemHistoryList.indexWhere(
              (item) => item.nopProductId == productId,
            );
            if (rb != -1) {
              itemHistoryList[rb].newQty = rollbackQty.toString();
              itemHistoryList.refresh();
            }
            customSnackbar('Failed', 'Item is not added to cart', AppColor.error);
          }
        } catch (e) {
          final int rb = itemHistoryList.indexWhere(
            (item) => item.nopProductId == productId,
          );
          if (rb != -1) {
            itemHistoryList[rb].newQty = rollbackQty.toString();
            itemHistoryList.refresh();
          }
          print('Plus qty failed $e');
        }
      },
    );
  }

  // --------- minus qty in item history screen
  Future<void> minusQtyAndRefresh({
    required String productId,
    required String quantity,
  }) async {

    final int index = itemHistoryList.indexWhere(
    (item) => item.nopProductId == productId,
  );
    if (index == -1) return;

    final int currentQty = int.tryParse(itemHistoryList[index].newQty ?? '0') ?? 0;
    if (currentQty <= 0) return;

    final int rollbackQty = currentQty;
     final int newQty = currentQty - 1;

    // Optimistic update
    itemHistoryList[index].newQty = newQty.toString();
    itemHistoryList.refresh();

    postAPI(
      methodName: ApiList.minusQtyItem,
      param: {
        "customerId": box.read('customerId'),
        "productId": productId,
        "quantity": quantity, 
      },
      callback: (value) {
        try {
          if (value.response.isEmpty) return;
          
          Map<String, dynamic> tempMap = jsonDecode(value.response);

          if (tempMap['Minus'].toString().toLowerCase() == 'false') {
            customSnackbar('', 'Item updated in cart...!', AppColor.activeColor);
          } else {
            // Rollback
            final int rb = itemHistoryList.indexWhere(
              (item) => item.nopProductId == productId,
            );
            if (rb != -1) {
              itemHistoryList[rb].newQty = rollbackQty.toString();
              itemHistoryList.refresh();
            }
            customSnackbar('Failed', 'Item is not added to cart', AppColor.error);
          }
        } catch (e) {
          final int rb = itemHistoryList.indexWhere(
            (item) => item.nopProductId == productId,
          );
          if (rb != -1) {
            itemHistoryList[rb].newQty = rollbackQty.toString();
            itemHistoryList.refresh();
          }
          print('Minus qty failed $e');
        }
      },
    );
  }

  // void loadMoreData() {
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels ==
  //         scrollController.position.maxScrollExtent) {
  //       getReturnOrders();
  //     }
  //   });
  // }


  
  void resetState() {
    // ------
    _currentPage=1;
    itemHistoryList.clear();
    itemHistoryModel.value=ItemHistoryModel();
    hasMoreData.value = true;
    _isFetching.value = false;
  }
}
