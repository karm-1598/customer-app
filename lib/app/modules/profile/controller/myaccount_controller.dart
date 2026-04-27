import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopperz/app/apiServices/network_call.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/model/signIn_model.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/textwidget.dart';

class MyaccountController extends GetxController {

  RxMap<String, dynamic> myAccountDetails = <String, dynamic>{}.obs;
  RxList<dynamic> designationList = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxString groupValue = 'Male'.obs;
  RxString selectedDesignation = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyAccount();
    getAllDesignation();
  }

  Future<void> loadMyAccount() async {
    String? customerId = await getCustomerId();
    if (customerId != null) {
      myaccount(customerid: customerId);
    } else {
      print("Customer ID not found");
    }
  }

  Future<String?> getCustomerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(SharedPrefrenceData.customerData);
    if (userData != null) {
      List<dynamic> dataList = json.decode(userData);
      List<Customer> customer =
          dataList.map((data) => Customer.fromJson(data)).toList();
      return customer[0].customerId;
    }
    return null;
  }

  Future<void> myaccount({required String customerid}) async {
    isLoading(true);
    try {
      getAPI(
        methodName: ApiList.myAccount,
        param: {"id": customerid},
        callback: (value) {
          try {
            // ✅ UPDATED
            final tempMap = value.response is String
                ? jsonDecode(value.response)
                : value.response as Map<String, dynamic>;

            if (tempMap.containsKey('myAccountDetails') &&
                tempMap['myAccountDetails'] != null &&
                tempMap['myAccountDetails'].isNotEmpty) {
              var tempList = tempMap['myAccountDetails'];
              myAccountDetails.value = tempList[0];
              groupValue.value = tempList[0]['Gender'] ?? 'Male';
            }
            isLoading(false);
          } catch (e) {
            print('Error decoding MyAccount response: $e');
            isLoading(false);
          }
        },
      );
    } catch (e) {
      print("Error calling MyAccount API: $e");
      isLoading(false);
    }
  }

  Future<void> getAllDesignation() async {
    try {
      getAPI(
        methodName: ApiList.designation,
        param: {},
        callback: (value) {
          // ✅ UPDATED
          final tempMap = value.response is String
              ? jsonDecode(value.response)
              : value.response as Map<String, dynamic>;

          if (tempMap.containsKey('Designation')) {
            designationList.value = List<dynamic>.from(tempMap['Designation']);
          }
        },
      );
    } catch (e) {
      print('Failed to get designations in my account $e');
    }
  }

  Future<void> saveUSerData(
  String customerId,
  String firstName,
  String lastName,
  String dateOfBirth,
  String gender,
) async {
  final completer = Completer<void>();
  try {
    postAPI(
      methodName: ApiList.saveuserData,
      param: {
        "CustomerId": customerId,
        "FirstName": firstName,
        "LastName": lastName,
        "DateOfBirth": dateOfBirth,
        "Gender": gender,
      },
      callback: (value) {
        try {
          print('saveUserData raw response: ${value.response}'); // ✅ see what's coming

          final tempMap = value.response is String
              ? jsonDecode(value.response)
              : value.response;

          if (tempMap['update'] == 'True') {
            print('user details updated partially');
          }
        } catch (e) {
          print('saveUserData parse error: $e');      // ✅ won't crash whole app
          print('saveUserData raw value: ${value.response}'); // ✅ see the bad response
        } finally {
          completer.complete(); // ✅ always complete so saveAll can continue
        }
      },
    );
  } catch (e) {
    print('Failed to update my account details: $e');
    completer.complete();
  }
  return completer.future;
}

  Future<void> updateUSerData(
    String customerId,
    String firstName,
    String lastName,
    String dateOfBirth,
    String gender,
    String email,
    String personalEmailId,
    String personalMobileNo,
    String designation,
  ) async {
    var completer = Completer<void>();
    try {
      postAPI(
        methodName: ApiList.updateUserData,
        param: {
          "CustomerId": customerId,
          "FirstName": firstName,
          "LastName": lastName,
          "DateOfBirth": dateOfBirth,
          "Gender": gender,
          "Email": email,
          "PersonalEmailId": personalEmailId,
          "PersonalMobileNo": personalMobileNo,
          "Designation": designation,
        },
        callback: (value) {
          try {
            final tempMap = value.response is String
                ? jsonDecode(value.response)
                : value.response;
            if (tempMap['update'] == 'True') {
              print('user details updated partially');
            }
          } catch (e) {
            print('saveUserData parse error: $e');
          } finally {
            completer.complete(); // ✅ always completes
          }
        },
      );
    } catch (e) {
      print('Failed to update my account details: $e');
      completer.complete();
    }
    return completer.future;
  }

  Future<void> saveAllUsersData({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String gender,
    required String personalEmailId,
    required String personalMobileNo,
  }) async {
    isSaving(true);
    try {
      String? customerId = await getCustomerId();
      if (customerId == null) {
        print('Customer id is null');
        isLoading(false);
        return;
      }

      await saveUSerData(customerId, firstName, lastName, dateOfBirth, gender);

      String email = myAccountDetails['Email'] ?? '';
      String designationName = '';
      if (selectedDesignation.value.isNotEmpty) {
        var match = designationList.firstWhere(
          (item) => item['DesignationID'].toString() == selectedDesignation.value,
          orElse: () => null,
        );
        if (match != null) {
          designationName = match['DesignationName'].toString();
        }
      }

      await updateUSerData(customerId, firstName, lastName, dateOfBirth,
          gender, email, personalEmailId, personalMobileNo, designationName);

      isSaving(false);
      Get.back();
    } catch (e) {
      isSaving(false);
      print('Failed to update users details $e');
    }
  }

  TableRow buildtable(String label, Widget widget) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextWidget(
              text: label.tr,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: widget,
        ),
      ],
    );
  }

  Widget dropdownButton() {
    return Obx(() {
      if (selectedDesignation.value.isEmpty &&
          myAccountDetails.isNotEmpty &&
          designationList.isNotEmpty) {
        String designationName = myAccountDetails['Designation'] ?? '';
        var match = designationList.firstWhere(
          (item) => item['DesignationName'] == designationName,
          orElse: () => null,
        );
        if (match != null) {
          Future.microtask(() {
            selectedDesignation.value = match['DesignationID'].toString();
          });
        }
      }

      return DropdownButton<String>(
        hint: const Text('Select your Designation'),
        value: selectedDesignation.value.isEmpty ? null : selectedDesignation.value,
        isExpanded: true,
        items: designationList.map((item) {
          return DropdownMenuItem<String>(
            value: item['DesignationID'].toString(),
            child: Text(item['DesignationName']),
          );
        }).toList(),
        onChanged: (value) {
          selectedDesignation.value = value!;
        },
      );
    });
  }
}