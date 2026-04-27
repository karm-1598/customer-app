import 'dart:core';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/model/product_model.dart';
import 'package:shopperz/app/modules/category/controller/category_wise_product_controller.dart';
import 'package:shopperz/app/modules/category/model/category_tree.dart';
import 'package:shopperz/app/modules/category/model/category_wise_product.dart';
import 'package:shopperz/app/modules/home/model/brand_model.dart';
import 'package:shopperz/app/modules/home/model/category_model.dart';
import 'package:shopperz/app/modules/home/model/product_section.dart';
import 'package:shopperz/app/modules/home/model/promotion_model.dart';
import 'package:shopperz/app/modules/product_details/model/children_variation.dart';
import 'package:shopperz/app/modules/product_details/model/initial_variation.dart';
import 'package:shopperz/app/modules/product_details/model/related_product.dart';
import 'package:shopperz/app/modules/search/model/all_product.dart';

import 'package:shopperz/data/server/app_server.dart';
import 'package:shopperz/utils/api_list.dart';

import '../../app/modules/home/model/slider_model.dart';
import '../../main.dart';

class RemoteServices {
  static Future<BaseOptions> getBasseOptions() async {
    BaseOptions options = BaseOptions(
        followRedirects: false,
        validateStatus: (status) {
          // here is 600 for now after during real implement change to 500
          return status! < 600;
        },
        headers: AppServer.getAuthHeaders());

    return options;
  }

  static Future<BaseOptions> getBasseOptionsWithToken() async {
    BaseOptions options = BaseOptions(
        followRedirects: false,
        validateStatus: (status) {
          // here is 600 for now after during real implement change to 500
          return status! < 600;
        },
        headers: AppServer.getHttpHeadersWithToken());

    return options;
  }

  AppServer server = AppServer();

  // static Future<SettingModel> getSetting() async {
  //   var response;
  //   var dio = Dio(
  //     await getBasseOptions(),
  //   );
  //   String url = ApiList.setting.toString();
  //   try {
  //     response = await dio.get(url);
  //     if (response.statusCode == 200) {
  //       return SettingModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return SettingModel.fromJson(response.data);
  // }

  // static Future<CountryCodeModel> getCountryCode() async {
  //   var response;
  //   var dio = Dio(
  //     await getBasseOptions(),
  //   );
  //   String url = ApiList.countryCode.toString();
  //   try {
  //     response = await dio.get(url);
  //     if (response.statusCode == 200) {
  //       return CountryCodeModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return CountryCodeModel.fromJson(response.data);
  // }

  Future<Either<String, SliderModel>> fetchSlider() async {
    final response = await server.getRequest(
        endPoint: ApiList.slider, headers: AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(SliderModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, CategoryModel>> fetchCategory() async {
    final response = await server.getRequest(
        endPoint: ApiList.productCategory, headers: AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(CategoryModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, List<CategoryTreeModel>>> fetchCategoryTree() async {
    final response = await server.getRequest(
        endPoint: ApiList.categoryTree, headers: AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return Right(data.map((e) => CategoryTreeModel.fromJson(e)).toList());
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, ProductSectionModel>> fetchProductSection() async {
    final response = await server.getRequest(
        endPoint: ApiList.productSection + '?order_type=asc&status=5',
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(ProductSectionModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, PromotionModel>> fetchPromotion() async {
    final response = await server.getRequest(
        endPoint: ApiList.promotionCategoryBanner, headers: AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(PromotionModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, PromotionModel>> fetchMultiPromotion() async {
    final response = await server.getRequest(
        endPoint: ApiList.multiPromotion, headers: AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(PromotionModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  final categoryWiseProductController =
      Get.put(CategoryWiseProductController());
  Future<Either<String, CategoryWiseProduct>> fetchCategoryWiseProduct({
    final category,
    String? brands,
    status,
    String? sortBy,
    minPrice,
    maxPrice,
    String? name,
    variations,
    int? page,
  }) async {
    final response = await server.postRequest(
        endPoint: ApiList.categoryWiseProduct,
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders(),
        body: {
          "category": category,
          "brand": brands,
          "status": 5,
          "sort_by": sortBy ?? "",
          "min_price": minPrice,
          "max_price": maxPrice,
          "name": name,
          "variation": variations,
          "page": page,
        });

    if (response.statusCode == 200) {
      final data = response.data;
      categoryWiseProductController.variationsMap = data["data"]["variations"];
      return Right(CategoryWiseProduct.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, ProductModel>> fetchProductDetails(
      {required String slug, required int reviewLimit}) async {
    final response = await server.getRequest(
        endPoint: ApiList.productDetails +
            slug +
            '?slug=$slug&review_limit=$reviewLimit',
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(ProductModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, RelatedProductModel>> fetchRelatedProducts(
      {required String slug}) async {
    final response = await server.getRequest(
        endPoint: ApiList.relatedProducts + slug,
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(RelatedProductModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, InitialVariationModel>> fetchInitialVariation(
      {required String productId}) async {
    final response = await server.getRequest(
        endPoint: ApiList.initialVariation + productId,
        headers: AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(InitialVariationModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, ChildrenVariationModel>> fetchChildrenVariation(
      {required String initialVariationId}) async {
    final response = await server.getRequest(
        endPoint: ApiList.childrenVariation + initialVariationId,
        headers: AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(ChildrenVariationModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  submitAddress({
    required String fullName,
    String? email,
    required String countryCode,
    required String phone,
    required String streetAddress,
    required String country,
    String? state,
    String? city,
    String? zip,
  }) async {
    final response = await server.postRequest(
        endPoint: ApiList.address,
        headers: AppServer.getHttpHeadersWithToken(),
        body: {
          "full_name": fullName,
          "email": email,
          "country_code": countryCode,
          "phone": phone,
          "country": country,
          "address": streetAddress,
          "state": state,
          "city": city,
          "zip_code": zip,
          "latitude": "",
          "longitude": "",
        });

    return response;
  }

  
  Future<Either<String, AllProducts>> fetchAllProduct() async {
    final response = await server.getRequest(
        endPoint: ApiList.allProducts,
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(AllProducts.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, BrandModel>> fetchBrands() async {
    final response = await server.getRequest(
        endPoint: "",
        // "${ApiList.brands}?status=5",
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());
    if (response.statusCode == 200) {
      final data = response.data;
      return Right(BrandModel.fromJson(data));
    } else {
      return const Left("Something went wrong.");
    }
  }

  Future<Either<String, ProductModel>> fetchCartProduct(String slug) async {
    final response = await server.getRequest(
        endPoint: "${ApiList.showCartProduct}/$slug",
        headers: box.read('isLogedIn') == true
    ? AppServer.getHttpHeadersWithToken()
    : AppServer.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = response.data;
      return Right(ProductModel.fromJson(data));
    } else {
      return const Left("Something went wrong");
    }
  }
  
}
