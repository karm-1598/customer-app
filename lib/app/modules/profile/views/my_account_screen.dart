import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopperz/app/modules/order/controller/order_controller.dart';
import 'package:shopperz/app/modules/profile/controller/myaccount_controller.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/model/signIn_model.dart';
import 'package:shopperz/utils/api_list.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/textwidget.dart';

import '../../../../config/theme/app_color.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  ProfileController profile = Get.put(ProfileController());
  OrderController order = Get.put(OrderController());
  MyaccountController myaccountController=Get.put(MyaccountController());
  final birthDateController= TextEditingController();
  final firstnameController=TextEditingController();
  final lastnameController= TextEditingController();
  final emailcontroller=TextEditingController();
  final genderController= TextEditingController();
  final personalEmailController= TextEditingController();
  final personalPhoneController= TextEditingController();
  final designationController= TextEditingController();

  @override
  void initState() {
    super.initState();
    // if (box.read('isLogedIn') != false) {
    //   profile.getProfile();
    //   profile.getTotalOrdersCount();
    //   profile.getTotalCompleteOrdersCount();
    //   profile.getTotalReturnOrdersCount();
    //   profile.getTotalWalletBalance();
    //   order.getOrderHistory();
    // }
  }

  

  @override
  void dispose() {
    order.resetState();
    super.dispose();
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

  DateTime? selectedDate;

Future<void> pickDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    setState(() {
      selectedDate = picked;
    });
  }
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
        body: Obx((){
          if (myaccountController.isLoading.value) {
    return Center(
      child: CircularProgressIndicator(color: AppColor.primaryColor),
    );
  }

          return RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: () async {
            if (box.read('isLogedIn') != false) {
              profile.getProfile();
              order.getOrderHistory();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'MY_ACCOUNT'.tr,
                        color: AppColor.primaryColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Obx(
                        () => profile.profileMap.isNotEmpty &&
                                profile.profileModel!.data != null
                            ? Row(
                                children: [
                                  TextWidget(
                                    text: 'Welcome Back, '.tr,
                                    color: AppColor.textColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  TextWidget(
                                    text:
                                        '${profile.profileModel!.data!.name}!',
                                    color: AppColor.textColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              )
                            : TextWidget(
                                text: 'Welcome Back'.tr,
                                color: AppColor.textColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                        child: Padding(
                          padding: EdgeInsets.all(10),                        
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('General Details',style: TextStyle(color: Colors.grey, fontSize: 17),),
                              Divider(color: Colors.black26,),
                              SizedBox(height: 15,),
                             Obx((){
                              var data= myaccountController.myAccountDetails;
                              if(data.isEmpty){
                                return Center(child: Text('Failed to load Data'),);
                              }
                              birthDateController.text=data['DateOfBirth'];
                              firstnameController.text=data['FirstName'];
                              lastnameController.text=data['LastName'];
                              emailcontroller.text=data['Email'];
                              genderController.text=data['Gender'];             
                        
                              return Table(
                                columnWidths: const{
                                  0:IntrinsicColumnWidth(),
                                  1:FlexColumnWidth()
                                },
                                children: [
                                  myaccountController.buildtable('Birth Date : ', TextFormField(
                                      controller: birthDateController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        // contentPadding: EdgeInsets.zero,
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap: () {
                                        pickDate(context);
                                      },
                                    ),
                                  ),
                        
                                  myaccountController.buildtable('First Name : ',TextFormField(
                                      controller: firstnameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                        
                                  myaccountController.buildtable(
                                    "Last Name : ",
                                    TextFormField(
                                      controller: lastnameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                        
                                  myaccountController.buildtable(
                                    "Gender : ",
                                    RadioGroup<String>(
                                      groupValue: myaccountController.groupValue.value,
                                      onChanged: (value){
                                        setState(() {
                                          myaccountController.groupValue.value=value!;
                                        });
                                      }, child:Row(
                                        children: [
                                          Row(
                                            children: [
                                              Radio(value: 'Male'),
                                              Text('Male')
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Radio(value: 'Female'),
                                              Text('Female')
                                            ],
                                          )
                        
                                        ],
                                      ))
                                  ),
                                
                                ],
                              );
                             }),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 15,),
                    
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                        child: Padding(
                          padding: EdgeInsets.all(10),                        
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Personal Details',style: TextStyle(color: Colors.grey, fontSize: 17),),
                              Divider(color: Colors.black26,),
                              SizedBox(height: 15,),
                             Obx((){
                              var data= myaccountController.myAccountDetails;
                              if(data.isEmpty){
                                return Center(child: Text('Failed to load Data'),);
                              }
                              
                              personalEmailController.text= data['PersonalEmailId'];
                              personalPhoneController.text= data['PersonalMobileno'];
                        
                              return Table(
                                columnWidths: const{
                                  0:IntrinsicColumnWidth(),
                                  1:FlexColumnWidth()
                                },
                                children: [
                                                          
                                  myaccountController.buildtable('Email-Id : ',TextFormField(
                                      controller: personalEmailController,
                                      decoration: const InputDecoration(
                                        hintText: 'Please enter tour EmailId',
                                        border: OutlineInputBorder(),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                        
                                  myaccountController.buildtable(
                                    "MobileNo : ",
                                    TextFormField(
                                      controller: personalPhoneController,
                                      decoration: const InputDecoration(
                                        hintText: 'Please enter your Mobile No.',
                                        border: OutlineInputBorder(),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                        
                                  myaccountController.buildtable(
                                    "Designation : ",
                                    myaccountController.dropdownButton(),
                                  ),
                                
                                ],
                              );
                             }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: myaccountController.isSaving.value
                            ? null: (){
                                myaccountController.saveAllUsersData(
                                  firstName: firstnameController.text, 
                                  lastName: lastnameController.text, 
                                  dateOfBirth: birthDateController.text, 
                                  gender: genderController.text, 
                                  personalEmailId: personalEmailController.text, 
                                  personalMobileNo: personalPhoneController.text);
                              }, child: myaccountController.isSaving.value
                            ? SizedBox( // ✅ loading spinner in button
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),),
                      )
                    
                    ])),
          ),
        );
        })
      ),
    );
  }
}
