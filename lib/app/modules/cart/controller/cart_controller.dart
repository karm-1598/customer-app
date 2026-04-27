import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shopperz/app/apiServices/network_call.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/cart/model/cartmodel.dart';
import 'package:shopperz/app/modules/cart/model/product_model.dart';
import 'package:shopperz/app/modules/navbar/views/navbar_view.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/custom_snackbar.dart';
import '../model/cart_model.dart';

class CartController extends GetxController {
  final authController = Get.put(AuthController());
  final cartItems = <CartModel>[].obs;
  final numOfItems = 1.obs;

  // new code
  final box = GetStorage();
  RxList<Product> wishlistProducts = <Product>[].obs;
  RxList<dynamic> addressList=<dynamic>[].obs;
  RxString selectedAddress=''.obs;

  @override
  onInit() {
    // authController.getSetting();
    super.onInit();
    // if (box.read('isLogedIn') == true){
    //   getWishlistProducts();
    // }
    print("stage 1 ${box.read('customerId')}");
  }

  decrement() {
    if (numOfItems.value > 1) {
      numOfItems.value--;
    }
  }
  @override
  void onReady() {
    super.onReady();

    final id = box.read('customerId');
    print("onReady ID: $id");

    if (id != null) {
      getWishlistProducts();
    }else{
      loadGuestCart();
    }
    print("hello");
    print("stage 1 ${box.read('customerId')}");
  }

  void addItem(
      {required ProductModel product,
      int? variationId,
      String? shippingAmount,
      String? finalVariation,
      String? sku,
      dynamic taxJson,
      dynamic stock,
      dynamic shipping,
      double? totalTax,
      double? totalPrice,
      dynamic productVariationPrice,
      dynamic productVariationOldPrice,
      dynamic productVariationCurrencyPrice,
      dynamic productVariationOldCurrencyPrice,
      int? variationStock,
      String? flatShippingCost}) {
    for (var item in cartItems) {
      if (item.product.data?.id == product.data?.id &&
          item.variationId == variationId) {
        item.quantity.value += numOfItems.value;
        return;
      }
    }

    cartItems.add(
      CartModel(
          product: product,
          variationId: variationId ?? 0,
          quantity: numOfItems.value,
          shippingCharge: shippingAmount ?? "0",
          finalVariationString: finalVariation ?? "null",
          sku: sku ?? "null",
          taxObject: taxJson,
          stock: stock,
          variationPrice: productVariationPrice,
          variationOldPrice: productVariationOldPrice,
          variationCurrencyPrice: productVariationCurrencyPrice,
          variationOldCurrencyPrice: productVariationOldCurrencyPrice,
          shippingObject: shipping,
          totalProductTax: totalTax,
          flatShippingCharge: flatShippingCost,
          variationStock: variationStock),
    );
  }
  // ------get wishlist products
  Future<void> getWishlistProducts()async{
    try{
      getAPI(
        methodName: ApiList.getWishlistProducts, 
        param: {
          "id": box.read('customerId'),
        }, 
        callback:(value){
          try{
            if(value.response.isEmpty)return;
            Map<String, dynamic> tempMap=jsonDecode(value.response);
            WishlistProducts wishlistProduct=WishlistProducts.fromJson(tempMap);
            if(wishlistProduct.product != null && wishlistProduct.product!.isNotEmpty){
              wishlistProducts.assignAll(wishlistProduct.product!);
            }else{
              // customSnackbar('Failed', 'Item is not added to cart', AppColor.error);
            }

          }catch(e){
            print('Not able to insert item in wishlist $e');
          }
        }
      );
    }catch(e){
      print('Failed to insert wishlist $e');
      print('Stage 6');
    }
  }
  
  // ------get address by email
  Future<void> getAddressByEmail()async{
    try{
      getAPI(
        methodName: ApiList.getaddressByemail, 
        param: {
          "emailId":box.read('email')
        }, 
        callback: (value){
          try{
            if(value.response.isEmpty)return;
            Map<String, dynamic> temMap=jsonDecode(value.response);
            List<dynamic> address=temMap['address'];
            addressList.assignAll(address);
            if (addressList.isNotEmpty) {
              selectedAddress.value = addressList[0]['company']; 
            }
            box.write('city', temMap['city']);
            print(addressList);
            print(box.read('email'));
          }catch(e){
            print('Failed to get address by email $e');
          }
        });
    }catch(e){
      print('Failed to get address get api $e');
    }
  }
  
  Future<void> addOneItemInWishlist(String cartid)async{
    
    final index = wishlistProducts.indexWhere((p) => p.cartId == cartid);
      if (index != -1) {
        final currentQty = int.tryParse(
          wishlistProducts[index].quantity ?? '0'
        ) ?? 0;
        wishlistProducts[index].quantity = (currentQty + 1).toString();
        wishlistProducts.refresh(); 
      }
    try{
      postAPI(
        methodName: ApiList.addItemQtyWishlist, 
        param: {
          'CartId':cartid,
          'quantity':1
        }, 
        callback:(value){
          Map<String, dynamic> tempMap=jsonDecode(value.response);
          if(tempMap['Plus']== 'True'){
            print('1 QTY is added to your cart');
          }else{
            if (index != -1) {
            final currentQty = int.tryParse(
              wishlistProducts[index].quantity ?? '1'
            ) ?? 1;
            wishlistProducts[index].quantity = (currentQty - 1).toString();
            wishlistProducts.refresh();}
            print('Failed to add qty');
          }
        }
      );
    }catch(e){
      print('Failed to load api for adding item in wishlist $e');
    }
  }

  Future<void> minusOneItemInWishlist(String cartid)async{
    final index = wishlistProducts.indexWhere((p) => p.cartId == cartid);
    if (index == -1) return;
    final currentQty = int.tryParse(
      wishlistProducts[index].quantity ?? '1'
    ) ?? 1;
    if (currentQty <= 1) return;
    wishlistProducts[index].quantity = (currentQty - 1).toString();
    wishlistProducts.refresh();
    try{
      postAPI(
        methodName: ApiList.minusItemQtyWishlist, 
        param: {
          'CartId':cartid,
          'quantity':1
        }, 
        callback:(value){
          Map<String, dynamic> tempMap=jsonDecode(value.response);
          if(tempMap['Minus']== 'True'){
            print('1 QTY is removed from your cart');
          }else{
            if (index != -1) {
            final currentQty = int.tryParse(
              wishlistProducts[index].quantity ?? '1'
            ) ?? 1;
            wishlistProducts[index].quantity = (currentQty - 1).toString();
            wishlistProducts.refresh();}
            print('Failed to minus qty');
          }
        }
      );
    }catch(e){
      print('Failed to load api for minus item in wishlist $e');
    }
  }

  Future<void> deleteItemInWishlist(String cartid)async{
    final index = wishlistProducts.indexWhere((p) => p.cartId == cartid);
    if (index == -1) return;
    final deletedItem = wishlistProducts[index];
    wishlistProducts.removeAt(index);
    try{
      postAPI(
        methodName: ApiList.deleteQtyWishlist, 
        param: {
          'CartId':cartid,
        }, 
        callback:(value){
          Map<String, dynamic> tempMap=jsonDecode(value.response);
          if(tempMap['Delete']== 'True'){
            print('item is deleted from your cart');
          }else{
            wishlistProducts.insert(index, deletedItem);
            print('Failed to delete qty');
          }
        }
      );
    }catch(e){
      print('Failed to load api for deleteing item in wishlist $e');
    }
  }

  Future<void> updateQtyWishlist({
    required String cartId,
    required int newQty,
    required int index
  })async{
    if (index == -1) return;

    wishlistProducts[index].quantity = newQty.toString();
    wishlistProducts.refresh();
    try{
      postAPI(
        methodName: ApiList.updateQtyWishlist, 
        param: {
          'CartId':cartId,
          'Quantity':newQty.toString()
        }, 
        callback: (value){
          Map<String, dynamic> tempMap= jsonDecode(value.response);
          if(tempMap['Update']=='True'){
            print('QTY is updated manually');
          }else{
            print('Failed to update qty manually');
          }
        }
      );
    }catch(e){
      print('Failed to update QTY in cart $e');
    }
  }

  Future<void> addQuatation() async{
    final List<Map<String, dynamic>> cartJson =
      wishlistProducts.map((p) => p.toJson()).toList();
      String custId=box.read('customerId');
      String name=box.read('company');
      String email=box.read('email');
      String mobile=box.read('mobileNo');
      String city = box.read('city') ?? '';
      if (city.isEmpty && selectedAddress.value.isNotEmpty) {
        // Find city from the selected address in addressList
        final selected = addressList.firstWhereOrNull(
          (a) => a['company'] == selectedAddress.value,
        );
        city = selected?['city']?.toString() ?? '';
      }
    postAPI(
      methodName: ApiList.addQuatation, 
      param: {
        'CustomerId':custId,
        'Name':name,
        'MobileNo':mobile,
        'EmailId':email,
        'item':cartJson,
        'ShippingCity':city
      }, 
      callback: (value){
        try{
          Map<String, dynamic> temMap= jsonDecode(value.response);
          if(temMap['update']=='True'){
            wishlistProducts.clear();
            clearWishList(custId);
            customSnackbar('Success', 'Your Quatation is Submitted Successfully',Colors.green);
          }else{
            customSnackbar('Failed', 'Failed to Submit your Quatation',Colors.redAccent);
          }
        }catch(e){
          print('Failed to get response from add quatation api $e');
        }
      }
    );
  }
  Future<void> clearWishList(String custId)async{
    try{
      postAPI(
        methodName: ApiList.clearWhishlist, 
        param: {
          "customerId":custId
        },

        callback: (value){
          try{
            var response= value.response.trim();
            if(response=='True'){
              print('Your wish list is cleared successfully');
            }else{
              print('Failed to clear wishlist');
            }
          }catch(e){
            print('Failed to clear wishlist $e');
          }
        }
      );
    }catch(e){
      print('Failed to load api for clearing wishlist $e');
    }
  }

  Future<void> insertWishlistItem({
  required String customerId,
  required String itemId,
  required int quantity,
  required String attributeXml,
}) async {
  try {
    postAPI(
      methodName: ApiList.insertWishlist, 
      param: {
        'customerId': customerId,
        'productId': itemId,
        'quantity': quantity,
        'AttributeXml': attributeXml,
      },
      callback: (value) {
        try {
          Map<String, dynamic> tempMap = jsonDecode(value.response);
          if (tempMap['msg'] == 'True') {
            getWishlistProducts();
            customSnackbar("SUCCESS".tr, "Product added to cart".tr, AppColor.success);
          } else {
            customSnackbar("ERROR".tr, "Failed to add product".tr, AppColor.error);
          }
        } catch (e) {
          print('insertWishlist parse error: $e');
        }
      },
    );
  } catch (e) {
    print('insertWishlist error: $e');
  }
}

  // code for guset users
  // ---- GUEST CART METHODS (GetStorage based) ----

  final String _guestCartKey = 'guest_cart';

  // Load guest cart from storage into wishlistProducts
  void loadGuestCart() {
    try {
      final String? raw = box.read(_guestCartKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw);
      final products = list.map((e) => Product.fromJson(e)).toList();
      wishlistProducts.assignAll(products);
    } catch (e) {
      print('Failed to load guest cart: $e');
    }
  }

  // Save current wishlistProducts to storage
  void _saveGuestCart() {
    try {
      final list = wishlistProducts.map((p) => p.toJson()).toList();
      box.write(_guestCartKey, jsonEncode(list));
    } catch (e) {
      print('Failed to save guest cart: $e');
    }
  }

  // Add product to guest cart (called from product detail screen)
  void addProductToGuestCart(Product product) {
    final index = wishlistProducts.indexWhere(
      (p) => p.productId == product.productId,
    );

    if (index != -1) {
      // Already exists — increment qty
      final currentQty = int.tryParse(wishlistProducts[index].quantity ?? '1') ?? 1;
      wishlistProducts[index].quantity = (currentQty + 1).toString();
      wishlistProducts.refresh();
    } else {
      // New item — generate a local cartId
      product.cartId = 'guest_${product.productId}_${DateTime.now().millisecondsSinceEpoch}';
      product.quantity ??= '1';
      wishlistProducts.add(product);
    }
    _saveGuestCart();
  }

  // Plus qty for guest
  void addOneItemGuest(String cartId) {
    final index = wishlistProducts.indexWhere((p) => p.cartId == cartId);
    if (index == -1) return;
    final currentQty = int.tryParse(wishlistProducts[index].quantity ?? '1') ?? 1;
    wishlistProducts[index].quantity = (currentQty + 1).toString();
    wishlistProducts.refresh();
    _saveGuestCart();
  }

  // Minus qty for guest
  void minusOneItemGuest(String cartId) {
    final index = wishlistProducts.indexWhere((p) => p.cartId == cartId);
    if (index == -1) return;
    final currentQty = int.tryParse(wishlistProducts[index].quantity ?? '1') ?? 1;
    if (currentQty <= 1) return;
    wishlistProducts[index].quantity = (currentQty - 1).toString();
    wishlistProducts.refresh();
    _saveGuestCart();
  }

  // Delete item for guest
  void deleteItemGuest(String cartId) {
    wishlistProducts.removeWhere((p) => p.cartId == cartId);
    _saveGuestCart();
  }

  // Update qty manually for guest
  void updateQtyGuest({required String cartId, required int newQty, required int index}) {
    if (index == -1) return;
    wishlistProducts[index].quantity = newQty.toString();
    wishlistProducts.refresh();
    print("Kkkkkk: ${wishlistProducts.toList()}");
    _saveGuestCart();
  }

  // Clear guest cart after login or order placed
  void clearGuestCart() {
    wishlistProducts.clear();
    box.remove(_guestCartKey);
  }

  // 
  Future<void> addQuatationByGuest(
    String name,
    int mobile,
    String city,
    String email,
  )async{
    try{
      final List<Map<String, dynamic>> guestUserItem= wishlistProducts.map((p)=>{
        "Id":p.productId.toString(),
        "Quantity": p.quantity.toString(),
        "AttributeXml": null,
        "AttributeName": null,
        "Sku": p.sku,
        "AttributeValueName": null,
        "Name": p.name,
        "PictureUrl": p.image,
        "Unit": p.unit
      }).toList();
      postAPI(
        methodName: ApiList.insertCotaionByGuest, 
        param: {
          "Name": name,
          "MobileNo": mobile,
          "ShippingCity": city,
          "EmailId": email,
          "guestUserItem": guestUserItem
        }, 
        callback: (value){
          try{
            Map<String, dynamic> tempMap= jsonDecode(value.response);
            if(tempMap['update']=='True'){
              clearGuestCart(); 
              customSnackbar('success', 'Your Quatation is sended successfully', AppColor.activeColor);
              print('Guest sended quote successfully');
              Get.offAll(() => const NavBarView());
            }
          }catch(e){
            print('Failed to api for insert cotation by guest user: $e');
          }
        }
      );
    }catch(e){
      print('Failed to insert cotation by guest user: $e');
    }
  }

  // Helper
  bool get isLoggedIn => box.read('isLogedIn') == true;
}
