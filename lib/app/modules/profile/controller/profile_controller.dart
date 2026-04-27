import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopperz/app/apiServices/network_call.dart';
import 'package:shopperz/app/modules/auth/controller/auth_controler.dart';
import 'package:shopperz/app/modules/navbar/views/navbar_view.dart';
import 'package:shopperz/data/model/pages_model.dart';
import 'package:shopperz/data/model/profile_address_model.dart';
import 'package:shopperz/data/model/profile_model.dart';
import 'package:shopperz/data/server/app_server.dart';
import 'package:shopperz/model/signIn_model.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/custom_snackbar.dart';
import '../../../../config/theme/app_color.dart';
import '../../navbar/controller/navbar_controller.dart';

class ProfileController extends GetxController {
  ProfileModel? profileModel;
  PagesModel? pagesModel;
  ProfileAddressModel? addressModel;

  RxList<ProfileModel> profileMap = <ProfileModel>[].obs;
  RxList<PagesModel> pagesMap = <PagesModel>[].obs;
  RxList<ProfileAddressModel> addressMap = <ProfileAddressModel>[].obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  AuthController authController = Get.put(AuthController());

  final isLoading = false.obs;

  final accountBalance = 0.0.obs;

  String? imagePath;
  File? file;

  final box = GetStorage();
  RxInt passwordUpdateStatus = 0.obs;

  AppServer server = AppServer();

  // new code
  RxString accountNo=''.obs;
  RxList<dynamic> addressList=<dynamic>[].obs;
  Rx<dynamic> selectedAddressObj = Rx<dynamic>({});
  RxMap<String,dynamic> outstandingMap = <String, dynamic>{}.obs;
  RxBool isOutstandingLoading=false.obs;
  RxInt totalAmountDue= 0.obs;

  @override
  void onInit() {
    
    // getPages();
    super.onInit();
  }

  Future<String?> getCustomerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(SharedPrefrenceData.customerData);
    if (userData != null) {
      List<dynamic> dataList = json.decode(userData);
      List<Customer> customer =
          dataList.map((data) => Customer.fromJson(data)).toList();
          print("Customer id:  ${customer[0].customerId}");
      return customer[0].customerId;
    }
    return null;
  }

  getProfile() async {
    nameController.text = profileModel!.data!.name ?? "";
    emailController.text = profileModel!.data!.email ?? "";
    phoneController.text = profileModel!.data!.phone ?? "";
    countryCodeController.text = profileModel!.data!.countryCode ?? "";
    accountBalance.value = double.parse(profileModel!.data!.balance.toString());

    update();

    profileMap.add(profileModel!);

    refresh();
  }

  // getPages() async {
  //   var page = await ProfileRepo.getPages();

  //   if (page.data != null) {
  //     pagesModel = page;
  //     pagesMap.add(pagesModel!);
  //   }

  //   refresh();
  // }
  

  Future<void> updateUserPassword(String oldPassword, String newPassword) async {
  isLoading(true);
  passwordUpdateStatus(0); 
  String? customerId = await getCustomerId();
  try {
    postAPI(
      methodName: ApiList.changePassword,
      param: {
        "customerId": customerId,
        "oldPassword": oldPassword,
        "newPassword": newPassword
      },
      callback: (value) {
        try {
          final tempMap = jsonDecode(value.response);

          final msg = tempMap['msg'];
          final isSuccess = msg == 'True' || msg == true || msg == 'true';

          isLoading(false);
          passwordUpdateStatus(isSuccess ? 1 : 2); 
        } catch (e) {
          print('changePassword parse error: $e');
          isLoading(false);
          passwordUpdateStatus(2);
        }
      },
    );
  } catch (e) {
    print("error during updating password $e");
    isLoading(false);
    passwordUpdateStatus(2);
  }
}

  Future<void> getAccountNumber()async{
    final completer = Completer<void>();
    try{
      getAPI(
        methodName: ApiList.accountNumber, 
        param: {
          "emailId":box.read('email'),
          "userName":box.read('company')
        }, 
        callback: (value){
         try{
           Map<String,dynamic> tempMap=jsonDecode(value.response);
          if(tempMap.containsKey('account')){
            List<dynamic> tempList=tempMap['account'];
            Map<String, dynamic> compMap=tempList[0];
            accountNo.value=compMap['AccountNo'];
          }
         }catch(e){
          print('Failed to load account number $e');
         }
         finally {
          if (!completer.isCompleted) completer.complete(); // signals done
        }
        }
      );
    }catch(e){
      print('Unexpected error for getting account number $e');
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  // ---------Functions for outstanding
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
            box.write('city', temMap['city']);
            addressList.assignAll(address);
            if (addressList.isNotEmpty) {
              selectedAddressObj.value = addressList[0]; 
              getOutstanding(); 
            }
            
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

  Future<void> getOutstanding()async{
    isOutstandingLoading(true);
    outstandingMap.clear();
    try{
      final selected = selectedAddressObj.value;

       if (selected == null || selected.isEmpty) {
        print("No address selected");
        isOutstandingLoading(false);
        return;
      }
      final companyName = selected['company'];

      getAPI(
        methodName: ApiList.outstanding, 
        param: {
          'user':companyName
        }, 
        callback:(value){
           try {
            Map<String, dynamic> data = jsonDecode(value.response);
            if(data.containsKey('outstanding')){
              Map<String, dynamic> tempMap=data['outstanding'][0];
              outstandingMap.assignAll(tempMap);
              for(var item in outstandingMap['Receivable']){
                totalAmountDue.value+= int.tryParse(item['AmtRemain'].toString()) ?? 0;
              }
              isOutstandingLoading(false);
            }
            
          } catch (e) {
            print("Parsing error during outstanding $e");
          }finally{
            isOutstandingLoading(false);
          }
        }
      );
    }catch(e){
      print('Failed to run api for outstandings $e');
    }
  }
  
  // getAddress() async {
  //   addressModel = await ProfileRepo.getAddress();
  //   addressMap.add(addressModel!);

  //   refresh();
  // }

 
  // getTotalOrdersCount() async {
  //   totalOrdersCount = await ProfileRepo.getTotalOrdersCount();

  //   totalOrdersCountMap.add(totalOrdersCount!);

  //   refresh();
  // }

  // getTotalCompleteOrdersCount() async {
  //   totalCompleteOrdersCount = await ProfileRepo.getTotalCompleteOrdersCount();

  //   totalCompleteOrdersCountMap.add(totalCompleteOrdersCount!);

  //   refresh();
  // }

  

  // getTotalWalletBalance() async {
  //   totalWalletBalance = await ProfileRepo.getTotalWalletBalance();

  //   totalWalletBalanceMap.add(totalWalletBalance!);

  //   refresh();
  // }

  deleteAccount() async {
    isLoading(true);
    server
        .postRequestWithToken(endPoint: ApiList.deleteAccount)
        .then((response) {
      if (response != null && response.statusCode == 200) {
        isLoading(false);
        update();
        final jsonResponse = json.decode(response.body);
        box.write('isLogedIn', false);
        final navController = Get.put(NavbarController());
        Get.offAll(const NavBarView());
        navController.selectPage(0);
        customSnackbar("ACCOUNT".tr, jsonResponse['message'].toString().tr,
            AppColor.success);
      } else if (response != null && response.statusCode == 422) {
        final jsonResponse = json.decode(response.body);
        isLoading(false);
        update();
        String errorMessage = jsonResponse['message'].toString();
        customSnackbar("ERROR".tr, errorMessage, AppColor.error);
        update();
      }
      isLoading(false);
      update();
    });
    return null;
  }
}
