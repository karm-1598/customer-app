import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopperz/app/modules/auth/views/sign_in.dart';
import 'package:shopperz/app/modules/category/model/category_tree.dart';
import 'package:shopperz/app/modules/filter/controller/filter_controller.dart';
import 'package:shopperz/app/modules/home/model/category_model.dart';
import 'package:shopperz/app/modules/search/controller/search_controller.dart';
import 'package:shopperz/app/modules/product_details/views/product_details.dart';
import 'package:shopperz/main.dart';
import 'package:shopperz/utils/images.dart';
import 'package:shopperz/widgets/appbar4.dart';
import 'package:shopperz/widgets/shimmer/trendy_collections_shimmer.dart';
import '../../../../config/theme/app_color.dart';
import '../../../../utils/svg_icon.dart';
import '../../../../widgets/textwidget.dart';
import '../../filter/views/filter_screen.dart';
import '../../product/widgets/product.dart';
import '../controller/category_wise_product_controller.dart';

class CategoryWiseProductScreen extends StatefulWidget {
  const CategoryWiseProductScreen({
    super.key,
    this.categoryTreeModel,
    this.categoryModel,
    this.brandName,
  });

  final CategoryTreeModel? categoryTreeModel;
  final Datum? categoryModel;
  final String? brandName;

  @override
  State<CategoryWiseProductScreen> createState() =>
      _CategoryWiseProductScreenState();
}

class _CategoryWiseProductScreenState
    extends State<CategoryWiseProductScreen> {
  final filterController = Get.put(FilterController());
  final productSearchController =
      Get.put(ProductSearchController());
  final cateWiseProductController =
      Get.put(CategoryWiseProductController());

  @override
  void initState() {
    super.initState();

    cateWiseProductController.resetState();

    final slug =
        widget.categoryTreeModel?.slug ??
        widget.categoryModel?.slug ??
        '';

    cateWiseProductController.fetchCategoryWiseProduct(
      categorySlug: slug,
      sortBy: filterController.selectedOption.value.trim(),
      brands:
          filterController.homeBrands ?? filterController.brands,
      variatons: filterController.encodeVaritionObject,
      name: productSearchController
          .searchTextController.text,
    );
  }

  @override
  void dispose() {
    filterController.resetFilter();
    cateWiseProductController.resetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slug =
        widget.categoryTreeModel?.slug ??
        widget.categoryModel?.slug ??
        '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget4(text: ''),
      body: Column(
        children: [
          SizedBox(height: 10.h),

          /// Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: widget.categoryModel?.name ??
                          widget.categoryTreeModel?.name ??
                          widget.brandName ??
                          'Search Results',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 5.h),
                    Obx(() => TextWidget(
                          text:
                              '(${cateWiseProductController.categoryWiseProductList.length} Products Found)',
                          fontSize: 12.sp,
                        )),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => FilterScreen(
                          cateWiseProductModel:
                              cateWiseProductController
                                  .categoryWiseProductModel
                                  .value
                                  .data,
                        ))!
                        .then((_) {
                      cateWiseProductController
                          .resetState();

                      cateWiseProductController
                          .fetchCategoryWiseProduct(
                        categorySlug: slug,
                        sortBy: filterController
                            .selectedOption.value
                            .trim(),
                        brands: filterController
                                .homeBrands ??
                            filterController.brands,
                        variatons:
                            filterController
                                .encodeVaritionObject,
                        name:
                            productSearchController
                                .searchTextController
                                .text,
                      );
                    });
                  },
                  child: SvgPicture.asset(
                    SvgIcon.filter,
                    height: 24.h,
                  ),
                ),
              ],
            ),
          ),

          /// Product Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                cateWiseProductController.resetState();

                cateWiseProductController
                    .fetchCategoryWiseProduct(
                  categorySlug: slug,
                  sortBy: filterController
                      .selectedOption.value
                      .trim(),
                  brands:
                      filterController.homeBrands ??
                          filterController.brands,
                  variatons: filterController
                      .encodeVaritionObject,
                  name: productSearchController
                      .searchTextController.text,
                );
              },
              child: Obx(() {
                if (cateWiseProductController
                    .categoryWiseProductList.isEmpty) {
                  return const TrendyCollectionShimmer();
                }

                return Padding(
                  padding: EdgeInsets.all(16.r),
                  child: MasonryGridView.builder(
                    controller:
                        cateWiseProductController
                            .scrollController,
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemCount:
                        cateWiseProductController
                                .categoryWiseProductList
                                .length +
                            (cateWiseProductController
                                    .hasMoreData
                                ? 1
                                : 0),
                    itemBuilder: (context, i) {
                      if (i ==
                          cateWiseProductController
                              .categoryWiseProductList
                              .length) {
                        return Shimmer.fromColors(
                          baseColor:
                              Colors.grey[200]!,
                          highlightColor:
                              Colors.grey[300]!,
                          child: Container(
                            height: 200.h,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                      16.r),
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      final product =
                          cateWiseProductController
                                  .categoryWiseProductList[
                              i];

                      return RepaintBoundary(
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() =>
                                ProductDetailsScreen(
                                  categoryWiseProduct:
                                      product,
                                ));
                          },
                          child: ProductWidget(
                            productImage:
                                product.cover
                                    .toString(),
                            title: product.name,
                            currentPrice:
                                product.currencyPrice,
                            discountPrice:
                                product
                                    .discountedPrice,
                            rating:
                                product.ratingStar,
                            textRating:
                                product.ratingStarCount,
                            flashSale:
                                product.flashSale!,
                            isOffer:
                                product.isOffer!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
