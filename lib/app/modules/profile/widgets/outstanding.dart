import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/profile/controller/profile_controller.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/widgets/textwidget.dart';

class Outstanding extends StatefulWidget {
  const Outstanding({super.key});

  @override
  State<Outstanding> createState() => _OutstandingState();
}

class _OutstandingState extends State<Outstanding> {
  final outstandingController = Get.isRegistered<ProfileController>() 
    ? Get.find<ProfileController>() 
    : Get.put(ProfileController());
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    outstandingController.getAddressByEmail();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outstanding"),
        backgroundColor: AppColor.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text('Branch'),
                        Spacer(),
                        Obx(() => SizedBox(
                          height: 50,
                          width: 250,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: outstandingController.selectedAddressObj.value == null
                            ? null
                            : outstandingController.selectedAddressObj.value['company'],
                            items: outstandingController.addressList.map((address) => DropdownMenuItem<String>( 
                              value: address['company'] as String, 
                              child: TextWidget(
                                text: address['company'].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ), 
                            )).toList(),
                            onChanged: (String? value) {
                              final selected = outstandingController.addressList.firstWhere((e) => e['company'] == value);
                              outstandingController.selectedAddressObj.value = selected;
                              outstandingController.getOutstanding();
                            },
                          ),
                        )),
                      ],
                    ),
              ),

              Expanded(
            child: Obx(() {
              if(outstandingController.isOutstandingLoading.value){
                return Center(child: CircularProgressIndicator(color: AppColor.primaryColor,),);
              }
              if (outstandingController.outstandingMap.isEmpty) {
                return const Center(child: Text('No outstanding data found'));
              }
              final outstandingData = outstandingController.outstandingMap['Receivable'];
              if (outstandingData == null || outstandingData is! List) {
                return const Center(child: Text('No receivable data'));
              }

              return  Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.white
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                      
                        children: [
                          TextWidget(
                            text: 'Amount Due:',
                            color: Colors.blueGrey,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          TextWidget(
                            text: "₹ ${outstandingController.totalAmountDue}",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 198, 15, 15),
                          ),
                        ],
                      ),
                  ),
                  SizedBox(height: 15.h,),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: outstandingData.length,
                      itemBuilder: (context, index) {
                        final item = outstandingData[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    TextWidget(
                                      text: 'Order: #${item['OrderId']}',
                                      color: Colors.blueGrey,
                                      fontSize: 13.sp,
                                    ),
                    
                                    SizedBox(width: 10.w,),
                    
                                    TextWidget(
                                      text: 'Trip: #${item['TripId']}',
                                      color: Colors.blueGrey,
                                      fontSize: 13.sp,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    TextWidget(
                                      text: 'BillNo.:- ',
                                      color: Colors.blueGrey,
                                      fontSize: 12.sp,
                                    ),
                                    TextWidget(
                                      text: item['BillNo'],
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    TextWidget(
                                      text: 'Date:- ',
                                      color: Colors.blueGrey,
                                      fontSize: 12.sp,
                                    ),
                                    TextWidget(
                                      text: item['Billdt'],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                    
                                    SizedBox(width: 15.w,),
                    
                                    TextWidget(
                                      text: 'LR:- ',
                                      color: Colors.blueGrey,
                                      fontSize: 12.sp,
                                    ),
                                    TextWidget(
                                      text: item['Lr'],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 15.w,),
                                Divider(color: Colors.grey,),
                                SizedBox(width: 15.w,),
                    
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.values[3],
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Bill Amount',
                                          color: Colors.blueGrey,
                                          fontSize: 12.sp,
                                        ),
                                        SizedBox(height: 5.h,),
                                        TextWidget(
                                          text: "₹ ${item['BillAmt']}",
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Amount Due',
                                          color: Colors.blueGrey,
                                          fontSize: 12.sp,
                                        ),
                                        SizedBox(height: 5.h,),
                                        TextWidget(
                                          text: "₹ ${item['AmtRemain']}",
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 198, 15, 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          )
        
        ],
      ));
  }

}