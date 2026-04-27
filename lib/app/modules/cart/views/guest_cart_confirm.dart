import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/custom_form_field.dart';

class GuestCartConfirm extends StatefulWidget {
  const GuestCartConfirm({super.key});

  @override
  State<GuestCartConfirm> createState() => _GuestCartConfirmState();
}

class _GuestCartConfirmState extends State<GuestCartConfirm> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();

  final cartController = Get.isRegistered<CartController>() 
    ? Get.find<CartController>() 
    : Get.put(CartController());

  List suggestions = [];

  final String apiKey = "AIzaSyDSTEJOm7VzWWlOV_Ah6aS9v5s0aW0Fn0Y&sensor=false&libraries=places&language=en";

  Future<void> searchCity(String input) async {
    if (input.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&types=(cities)"
        "&components=country:in"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    setState(() {
      suggestions = data['predictions'] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget3(text: 'Approve'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 50.h),
        child: SingleChildScrollView(
          child: Column(
            children: [

              CustomFormField(
                controller: nameController,
                title: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10.h),

              CustomFormField(
                controller: emailController,
                title: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10.h),

              CustomFormField(
                controller: phoneController,
                title: 'Mobile No.',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10.h),

              CustomFormField(
                controller: cityController,
                title: 'City',
                onChanged: searchCity,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select city';
                  }
                  return null;
                },
              ),

              if (suggestions.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 5.h),
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final item = suggestions[index];

                      return ListTile(
                        title: Text(item['description']),
                        onTap: () {
                          cityController.text = item['description'];
                          setState(() => suggestions = []);
                        },
                      );
                    },
                  ),
                ),

              SizedBox(height: 20.h),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                onPressed: () {
                  cartController.addQuatationByGuest(nameController.text, int.parse(phoneController.text), cityController.text, emailController.text);
                },
                child: const Text('Buy All'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}