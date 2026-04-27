import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/model/product_details_view_model.dart';
import 'package:shopperz/widgets/custom_text.dart';
import 'package:shopperz/widgets/textwidget.dart';

class ProductOptionScreen extends StatefulWidget {
  final ProductDetails product;
  final CartController cartController;
  final VoidCallback onConfirmAddToCart;

  const ProductOptionScreen({
    super.key,
    required this.product,
    required this.cartController,
    required this.onConfirmAddToCart,
  });

  @override
  State<ProductOptionScreen> createState() => _ProductOptionScreenState();
}

class _ProductOptionScreenState extends State<ProductOptionScreen> {
  // Mirrors Angular's isLock + packing logic
  late bool _isLock;
  late bool _hasPackingDropdown; // true = show dropdown, false = show +/- buttons
  late List<int> _packQuantitySet; // [packing*1, packing*2 ... packing*10]
  int? _selectedPackQty; // currently selected from dropdown

  @override
  void initState() {
    super.initState();

    _isLock = widget.product.isLock == "True";
    final packing = int.tryParse(widget.product.packing) ?? 0;

    if (_isLock) {
      if (packing == 0 || widget.product.packing.isEmpty) {
        // IsLock=True, no packing → manual qty input
        _hasPackingDropdown = false;
        _packQuantitySet = [];
      } else {
        // IsLock=True, has packing → show dropdown with multiples
        _hasPackingDropdown = true;
        _packQuantitySet = List.generate(10, (i) => packing * (i + 1));
        _selectedPackQty = _packQuantitySet[0];
        // Set initial qty to first pack option
        widget.cartController.numOfItems.value = _packQuantitySet[0];
      }
    } else {
      // IsLock=False → manual qty input
      _isLock = false;
      _hasPackingDropdown = false;
      _packQuantitySet = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Product image + name + price
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  widget.product.image.isNotEmpty
                      ? widget.product.image[0]
                      : '',
                  height: 72.h,
                  width: 72.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 72.h,
                    width: 72.w,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: widget.product.brandName,
                      size: 13.sp,
                      weight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 2.h),
                    CustomText(
                      text: widget.product.name,
                      size: 15.sp,
                      weight: FontWeight.w600,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColor.primaryColor)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget(text: 'Master Pack Of :'),
                          SizedBox(width: 5,),
                          TextWidget(
                            text: '${widget.product.packing } ${widget.product.unit}',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 12.h),

          // Quantity section
          CustomText(
              text: 'QUANTITY'.tr, size: 14.sp, weight: FontWeight.w600),
          SizedBox(height: 8.h),

          _hasPackingDropdown
              ? _buildPackingDropdown()   // Angular: hideQuntityDiv=false
              : _buildManualQtySelector(), // Angular: hideQuntityDiv=true

          SizedBox(height: 24.h),

          // Confirm button
          Obx(() {
            final qty = widget.cartController.numOfItems.value;
            final isValid = qty > 0 &&
                (!_hasPackingDropdown || _selectedPackQty != null);
            return SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isValid ? AppColor.primaryColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                onPressed: isValid
                    ? () {
                        Get.back();
                        widget.onConfirmAddToCart();
                      }
                    : null,
                child: CustomText(
                  text: 'Add to Quote'.tr,
                  size: 16.sp,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          }),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // Angular: hideQuntityDiv=false → packing dropdown
  Widget _buildPackingDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Select Pack Quantity',
          size: 12.sp,
          color: Colors.grey,
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedPackQty,
              isExpanded: true,
              items: _packQuantitySet.map((qty) {
                return DropdownMenuItem<int>(
                  value: qty,
                  child: CustomText(
                    text: '$qty ${widget.product.unit}',
                    size: 14.sp,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _selectedPackQty = val;
                });
                // Angular: optionsFn() → storage.set('qtySet', place)
                widget.cartController.numOfItems.value = val;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Angular: hideQuntityDiv=true → manual +/- buttons
  Widget _buildManualQtySelector() {
    return Obx(() {
      final qty = widget.cartController.numOfItems.value;
      return Row(
        children: [
          _QtyButton(
            icon: Icons.remove,
            enabled: qty > 1,
            onTap: () {
              if (qty > 1) widget.cartController.numOfItems.value--;
            },
          ),
          SizedBox(width: 16.w),
          CustomText(
            text: qty.toString(),
            size: 18.sp,
            weight: FontWeight.w700,
          ),
          SizedBox(width: 16.w),
          _QtyButton(
            icon: Icons.add,
            enabled: true,
            onTap: () {
              widget.cartController.numOfItems.value++;
            },
          ),
          SizedBox(width: 12.w),
          CustomText(
            text: widget.product.unit,
            size: 13.sp,
            color: Colors.grey,
          ),
        ],
      );
    });
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 36.r,
        width: 36.r,
        decoration: BoxDecoration(
          color: enabled
              ? AppColor.primaryColor.withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Icon(
          icon,
          size: 20.r,
          color: enabled ? AppColor.primaryColor : Colors.grey,
        ),
      ),
    );
  }
}