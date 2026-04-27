import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/textwidget.dart';

// ignore: must_be_immutable
class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  // final box = GetStorage();

  // final bool isActive = true;

  // LanguageController language = Get.put(LanguageController());

  @override
  void initState() {
    super.initState();
    // language.getLanguageData();
  }

  @override
  Widget build(BuildContext context) {
    // LanguageController languageController = Get.put(LanguageController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget3(text: '',),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  textAlign: TextAlign.justify,
                  text: 'About Us'.tr,
                  color: AppColor.primaryColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 15,),
                TextWidget(
                  textAlign: TextAlign.justify,
                  fontSize: 14.sp,
                  text: 
                  "LCA Solutions was established in 1980 by having rich experience of the trade promoted them to venture out in wholesale business & decoration unit of ceramic and glassware. The crockery decoration is supported with the latest automatic & semi automatic machines. The associated activities of the firm includes distributing products of leading ceramic companies, customize decal printing & decoration on ceramic crockery, glassware, ceramic tiles."
                ),
                SizedBox(height: 15,),
                Text.rich(
                  textAlign: TextAlign.justify,
                  TextSpan(
                    text: "Hotels, Restaurants & Catering Business are one of the service oriented category to which proper care is taken to ensure the purpose and durability of the products. Proper pricing of the product is another distinct advantage to the Company's customers. The institutional business and proper follow-up is done with the prospective customers and after sales follow-up is carried out for the entire satisfaction of the customers and that's why we enjoy patronage of customers like ",
                    style: TextStyle(fontSize: 14.sp,),
                    children: [
                      TextSpan(
                        text: "The Grand Bhagwati Banquets & Caterers, Havmor Group of Restaurants, Sankalp Group of Restaurants, US Pizza, Pizza Hut Group of Restaurants."
                        ,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14.sp,)
                      )
                    ]
                  )
                ),
                SizedBox(height: 15,),
                TextWidget(
                  fontSize: 14.sp,
                  textAlign: TextAlign.justify,
                  text: 
                  "Our services are not only restricted to Gujarat but we are also serving to all over India, and in some other countries also. All institutions big or small look upon us for our expertise, prompt and reliable services."
                ),
                SizedBox(height: 15,),
                TextWidget(
                  fontSize: 14.sp,
                  textAlign: TextAlign.justify,
                  text: "The phenomenal success of our organization depends solely on the tremendous efforts of our experts and professionals. Their vast knowledge in the Hospitality Industry helped us to provide our clients a flawless range of Products."
                )
              ],
            ),
          ),
        ),
    )
  );
    
    
  }
}

// AnnotatedRegion<SystemUiOverlayStyle>(
//       value:const SystemUiOverlayStyle(
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarColor: Colors.transparent,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//           backgroundColor: AppColor.primaryBackgroundColor,
//           appBar: const AppBarWidget3(
//             text: '',
//           ),
//           body: Padding(
//             padding: EdgeInsets.only(
//               top: 16.h,
//               left: 16.w,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(right: 16.w),
//                       child: CustomText(
//                         text: "CHANGE_LANGUAGE".tr,
//                         size: 22.sp,
//                         weight: FontWeight.w700,
//                         color: AppColor.primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20.h,
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   scrollDirection: Axis.vertical,
//                   itemCount: languageController.languageDataList.length,
//                   itemBuilder: (BuildContext context, index) {
//                     return InkWell(
//                       onTap: () {
//                         languageController.changeLanguage(
//                           languageController.languageDataList[index].code!,
//                           languageController.languageDataList[index].name!,
//                         );
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.only(bottom: 10.h, right: 16.w),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.r),
//                             boxShadow: [
//                               BoxShadow(
//                                   color: AppColor.blackColor.withOpacity(0.10),
//                                   offset: const Offset(0, 0.1),
//                                   blurRadius: 1.r)
//                             ],
//                             color: box.read('languageCode') ==
//                                     languageController
//                                         .languageDataList[index].code!
//                                 ? AppColor.primaryColor.withOpacity(0.08)
//                                 : Colors.white,
//                             border: box.read('languageCode') ==
//                                     languageController
//                                         .languageDataList[index].code!
//                                 ? Border.all(color: AppColor.primaryColor)
//                                 : Border.all(color: Colors.white),
//                           ),
//                           height: 56.h,
//                           width: 328.w,
//                           child: Row(children: [
//                             SizedBox(width: 16.w),
//                             SizedBox(
//                               width: 24.w,
//                               height: 24.h,
//                               child: ClipRRect(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(8.r)),
//                                 child: CachedNetworkImage(
//                                   imageUrl: languageController
//                                       .languageDataList[index].image!,
//                                   imageBuilder: (context, imageProvider) =>
//                                       Container(
//                                     decoration: BoxDecoration(
//                                       image: DecorationImage(
//                                         image: imageProvider,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   placeholder: (context, url) =>
//                                     Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[400]!,
//                                     child: Container(
//                                         width: 24.w,
//                                         height: 24.h,
//                                         color: Colors.grey),
//                                   ),
//                                   errorWidget: (context, url, error) =>
//                                       const Icon(Icons.error),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16.w),
//                             CustomText(
//                               text: languageController
//                                   .languageDataList[index].name!,
//                               size: 16.sp,
//                               weight: FontWeight.w500,
//                               color: AppColor.textColor,
//                             ),
//                             const Spacer(),
//                             box.read('languageCode') ==
//                                     languageController
//                                         .languageDataList[index].code!
//                                 ? Padding(
//                                     padding:
//                                         EdgeInsets.only(right: 18.w, left: 18.w),
//                                     child: SizedBox(
//                                       width: 24.w,
//                                       height: 24.h,
//                                       child: SvgPicture.asset(
//                                         SvgIcon.thikCircle,
//                                         color: AppColor.primaryColor,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                           ]),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           )),
//     );
  
