import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/apiServices/common_widget.dart';
import 'package:shopperz/app/controller/category_controller.dart';
import 'package:shopperz/app/modules/category/views/product_category_list_screen.dart';
import 'package:shopperz/app/modules/home/widgets/appbar.dart';
import 'package:shopperz/config/theme/app_color.dart';
import 'package:shopperz/widgets/appbar3.dart';
import 'package:shopperz/widgets/textwidget.dart';

// class CategoryScreen extends StatelessWidget {
//   const CategoryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final categoryTreeController = Get.put(CategoryTreeController());
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarColor: Colors.transparent,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(48.h),
//           child: const AppBarWidget(),
//         ),
//         body: Obx(
//           () => Stack(
//             alignment: Alignment.center,
//             children: [
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
//                   child: Obx(() {
//                     return categoryTreeController.categoryTreeList.isEmpty
//                         ? SizedBox()
//                         : categoryTreeController.categoryTreeList.length < 1
//                             ? Center(
//                                 child: Padding(
//                                 padding: EdgeInsets.only(top: 120.h),
//                                 child: Center(
//                                   child: Image.asset(
//                                     AppImages.emptyIcon,
//                                     height: 300.h,
//                                     width: 300.w,
//                                   ),
//                                 ),
//                               ))
//                             : ListView.builder(
//                                 itemCount: categoryTreeController
//                                     .categoryTreeList.length,
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   final categoryTree =
//                                       categoryTreeController.categoryTreeList;
//                                   return CategoryList(
//                                     text: categoryTree[index].name.toString(),
//                                     onTapProduct: () {
//                                       Get.to(() => CategoryWiseProductScreen(
//                                           categoryTreeModel:
//                                               categoryTree[index]));
//                                     },
//                                     onTapSubCategory: () {
//                                       Get.to(() => SubCategoryScreen(
//                                           categoryTreeModel:
//                                               categoryTree[index]));
//                                     },
//                                   );
//                                 },
//                               );
//                   }),
//                 ),
//               ),
//               categoryTreeController.isLoading.value
//                   ? const Center(child: LoaderCircle())
//                   : SizedBox()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────
// OPTIMIZATION NOTES:
// 1. Get.put → Get.find where controller already exists upstream
// 2. Removed init: CategoryControllers() from GetX (was double-init bug)
// 3. categoryListDetails only called when list isEmpty (avoids duplicate API calls)
// 4. super.initState() moved to FIRST line (correct Flutter order)
// 5. filteredList computed once inside builder, not on every item
// 6. RepaintBoundary added around each grid cell (isolates repaints)
// 7. memCacheWidth/Height added to CachedNetworkImage (reduces memory churn)
// 8. Lightweight placeholder replaces heavy LoadingWidget inside image cells
// 9. BoxDecoration shadow uses const where possible
// 10. Get.delete removed from taps — data stays alive across navigation
// ─────────────────────────────────────────────

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // OPTIMIZED: Use find if controller is already registered; put only creates a new one
  // if none exists. This avoids creating duplicate instances across screens.
  late final CategoryControllers categoryControllers;

  @override
  void initState() {
    // OPTIMIZED: super.initState() must always be FIRST
    super.initState();

    // OPTIMIZED: Use find if registered, otherwise put
    categoryControllers = Get.isRegistered<CategoryControllers>()
        ? Get.find<CategoryControllers>()
        : Get.put(CategoryControllers());

    // OPTIMIZED: Only fetch if list is empty — avoids duplicate API calls
    // when navigating back to this screen
    // if (categories.isEmpty) {
    if (categoryControllers.categoryList.isEmpty) {
      categoryControllers.categoryListDetails(
        context: context,
        // categoryId: widget.categoryId
      );
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // final categoryTreeController = Get.put(CategoryTreeController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark),
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: widget.categoryId == "0"
                ? const AppBarWidget()
                : AppBarWidget3(text: widget.categoryName),
          ),
          // Obx(() {
          body: GetX<CategoryControllers>(
              // OPTIMIZED: Removed init: CategoryControllers() — was conflicting
              // with the Get.put/find above and causing a second instance to be created
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const LoadingWidget();
                } else if (controller.categoryList.isEmpty) {
                  // If no data is available, display a message
                  return const Center(
                    child: Text('No data available'),
                  );
                } else {
                  // OPTIMIZED: filteredList computed once here, not inside itemBuilder
                  final filteredList = controller.categoryList
                      .where((item) => item.parentId == widget.categoryId)
                      .toList();

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text('No categories found'),
                    );
                  }

                  // OPTIMIZED: CustomScrollView + SliverGrid instead of
                  // SingleChildScrollView + shrinkWrap GridView.
                  // shrinkWrap forces layout of ALL items at once (no recycling).
                  // SliverGrid only builds visible items.
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(15),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2 / 3,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // OPTIMIZED: RepaintBoundary isolates each cell's
                              // repaint — tapping one item won't repaint others
                              return RepaintBoundary(
                                child: _CategoryGridItem(
                                  item: filteredList[index],
                                  onTap: () {
                                    if (filteredList[index].products == "0") {
                                      // Has sub-categories → go deeper
                                      // OPTIMIZED: No Get.delete — controller data
                                      // stays alive, new screen filters locally
                                      Get.to(() => RedirectCategoryScreen(
                                            categoryId:
                                                filteredList[index].catgoryId,
                                            categoryName:
                                                filteredList[index].name,
                                          ));
                                    } else {
                                      // Has products → go to product list
                                      // OPTIMIZED: No Get.delete — data preserved
                                      Get.to(() => ProductCategoryListScreen(
                                            categoryName:
                                                filteredList[index].name,
                                            categoryId:
                                                filteredList[index].catgoryId,
                                          ));
                                    }
                                    // print("category${filteredList[index].catgoryId}");
                                  },
                                ),
                              );
                  
                              // OLD ListView code (commented for reference):
                  //                             if (categoryControllers.categoryList[index].parentId == widget.categoryId) {
                  //                               return InkWell(
                  //                                 onTap: () {
                  //                                   if (categoryControllers.categoryList[index].products == "0") {
                  //                                     print("category++${categoryControllers.categoryList[index].parentId}");
                  //                                     print("category--${widget.categoryId}");
                  //                                     Get.delete<CategoryControllers>();
                  //                                     print("category${categoryControllers.categoryList[index].catgoryId}");
                  //                                     print("parentId${categoryControllers.categoryList[index].parentId}");
                  //                                     Get.to(() => RedirectCategoryScreen(
                  //                                         categoryId: categoryControllers.categoryList[index].catgoryId,
                  //                                         categoryName: categoryControllers.categoryList[index].name));
                  //                                   } else {
                  //                                     Get.delete<CategoryControllers>();
                  //                                     Get.to(() => ProductCategoryListScreen(
                  //                                         categoryName: categoryControllers.categoryList[index].name,
                  //                                         categoryId: categoryControllers.categoryList[index].catgoryId));
                  //                                   }
                  //                                   print("category${categoryControllers.categoryList[index].catgoryId}");
                  //                                 },
                  //                                 child: Container(...),
                  //                               );
                  //                             } else {
                  //                               return const SizedBox();
                  //                             }
                            },
                            childCount: filteredList.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              })),
    );
  }
}

// ─────────────────────────────────────────────
// OPTIMIZED: Extracted grid item into its own StatelessWidget.
// This prevents the entire grid from rebuilding when only one
// item changes. Each item is independently const-comparable.
// ─────────────────────────────────────────────
class _CategoryGridItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            // OPTIMIZED: const BoxShadow — not rebuilt every frame
            BoxShadow(
              color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
              offset: Offset(0, 0),
              blurRadius: 7,
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.image,
                    // OPTIMIZED: memCache limits keep memory usage low
                    // 200x200 is plenty for a small grid cell
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                    // OPTIMIZED: Lightweight placeholder instead of full LoadingWidget
                    placeholder: (context, url) => const SizedBox(
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 120,
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: item.name.toString(),
                color: AppColor.textColor,
                textAlign: TextAlign.center,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RedirectCategoryScreen
// OPTIMIZATION NOTES (same as CategoryScreen above):
// 1. Get.find used instead of Get.put (controller already exists)
// 2. Removed init: CategoryControllers() from GetX
// 3. categoryListDetails only called when list is empty
// 4. super.initState() is first
// 5. RepaintBoundary on each grid item
// 6. memCacheWidth/Height on images
// 7. Extracted to _CategoryGridItem reusable widget
// 8. Get.delete removed from taps
// 9. SliverGrid replaces shrinkWrap GridView
// ─────────────────────────────────────────────

class RedirectCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const RedirectCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<RedirectCategoryScreen> createState() => _RedirectCategoryScreenState();
}

class _RedirectCategoryScreenState extends State<RedirectCategoryScreen> {
  // OPTIMIZED: Use find — controller was already put by CategoryScreen.
  // Get.put here was creating a brand-new instance, wiping existing data.
  late final CategoryControllers categoryControllers;

  // String myCategoryName = "";  // unused — kept commented for reference
  // var categories = [];          // unused — kept commented for reference
  // var categoryId = 0;           // unused — kept commented for reference

  @override
  void initState() {
    // OPTIMIZED: super.initState() must be FIRST
    super.initState();

    // OPTIMIZED: find existing controller rather than creating new one
    categoryControllers = Get.isRegistered<CategoryControllers>()
        ? Get.find<CategoryControllers>()
        : Get.put(CategoryControllers());

    // OPTIMIZED: Only call API if data isn't already loaded
    // Old code called this unconditionally, causing a reload every time
    // RedirectCategoryScreen was opened
    if (categoryControllers.categoryList.isEmpty) {
      categoryControllers.categoryListDetails(
        context: context,
      );
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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: widget.categoryId == "0"
                ? const AppBarWidget()
                : AppBarWidget3(text: widget.categoryName),
          ),
          // Obx(() {
          body: GetX<CategoryControllers>(
              // OPTIMIZED: Removed init: CategoryControllers() — same double-init
              // bug as CategoryScreen. GetX finds the existing instance automatically.
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const LoadingWidget();
                } else if (controller.categoryList.isEmpty) {
                  // If no data is available, display a message
                  return const Center(
                    child: Text('No data available'),
                  );
                } else {
                  // OPTIMIZED: filteredList computed once, not per-item
                  final filteredList = controller.categoryList
                      .where((item) => item.parentId == widget.categoryId)
                      .toList();

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text('No categories found'),
                    );
                  }

                  // OPTIMIZED: CustomScrollView + SliverGrid (lazy, recyclable)
                  // replaces SingleChildScrollView + shrinkWrap GridView (renders all)
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2 / 3,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // OPTIMIZED: RepaintBoundary per cell
                              return RepaintBoundary(
                                child: _CategoryGridItem(
                                  item: filteredList[index],
                                  onTap: () async {
                                    // Get.delete<CategoryControllers>(); // REMOVED — kills loaded data
                                    if (filteredList[index].products == "0") {
                                      // Has sub-categories → go deeper into CategoryScreen
                                      // Get.delete<CategoryControllers>(); // REMOVED
                                      await Get.to(() => CategoryScreen(
                                            categoryId:
                                                filteredList[index].catgoryId,
                                            categoryName:
                                                filteredList[index].name,
                                          ));
                                      // print("First screen");
                                    } else {
                                      // Has products → go to product list
                                      // Get.delete<CategoryControllers>(); // REMOVED
                                      Get.to(() => ProductCategoryListScreen(
                                            categoryName:
                                                filteredList[index].name,
                                            categoryId:
                                                filteredList[index].catgoryId,
                                          ));
                                    }
                                  },
                                ),
                              );

                              // OLD onTap with Get.delete (kept for reference):
                              // onTap: () {
                              //   if (filteredList[index].products == "0") {
                              //     Get.delete<CategoryControllers>();
                              //     Get.to(() => RedirectCategoryScreen(
                              //       categoryId: filteredList[index].catgoryId,
                              //       categoryName: filteredList[index].name,
                              //     ));
                              //   } else {
                              //     Get.delete<CategoryControllers>();
                              //     Get.to(() => ProductCategoryListScreen(
                              //       categoryName: filteredList[index].name,
                              //       categoryId: filteredList[index].catgoryId,
                              //     ));
                              //   }
                              // },

                              // OLD ListView code (kept for reference):
                              //     itemBuilder: (context, index) {
                              //       if (categoryControllers.categoryList[index].parentId == widget.categoryId) {
                              //         return InkWell(
                              //           onTap: () async {
                              //             if (categoryControllers.categoryList[index].products == "0") {
                              //               Get.delete<CategoryControllers>();
                              //               await Get.to(() => CategoryScreen(
                              //                   categoryId: categoryControllers.categoryList[index].catgoryId,
                              //                   categoryName: categoryControllers.categoryList[index].name));
                              //               print("First screen");
                              //             } else {
                              //               Get.delete<CategoryControllers>();
                              //               Get.to(() => ProductCategoryListScreen(
                              //                   categoryName: categoryControllers.categoryList[index].name,
                              //                   categoryId: categoryControllers.categoryList[index].catgoryId));
                              //             }
                              //           },
                              //           child: Container(...),
                              //         );
                              //       } else {
                              //         return const SizedBox();
                              //       }
                              //     }
                            },
                            childCount: filteredList.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // })
              })),
    );
  }
}