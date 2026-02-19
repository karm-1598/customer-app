import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopperz/model/home_banner_model.dart';
import 'package:shopperz/config/theme/app_color.dart';

class SliderWidget extends StatefulWidget {
  final List<BannerList> bannerList;
  const SliderWidget({super.key, required this.bannerList});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int dotIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142.h,
      width: 328.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: widget.bannerList.isEmpty
          ? Center(
              child: Text(
                'No banners available',
                style: TextStyle(
                  color: AppColor.textColor,
                  fontSize: 14.sp,
                ),
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: widget.bannerList.length,
                  itemBuilder: (context, index, realIndex) {
                    return CachedNetworkImage(
                      imageUrl: widget.bannerList[index].image.toString(),
                      imageBuilder: (context, imageProvider) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColor.primaryColor.withOpacity(0.1),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColor.primaryColor.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 142.h,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        dotIndex = index;
                      });
                    },
                  ),
                ),
                if (widget.bannerList.length > 1)
                  Positioned(
                    bottom: 10.h,
                    child: DotsIndicator(
                      dotsCount: widget.bannerList.length,
                      position: dotIndex.toDouble(),
                      decorator: DotsDecorator(
                        spacing: EdgeInsets.only(left: 5.w),
                        size: Size.square(8.r),
                        activeSize: Size(20.w, 8.h),
                        shape: CircleBorder(
                          side: BorderSide(
                            color: AppColor.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        color: Colors.white.withOpacity(0.5),
                        activeColor: AppColor.primaryColor,
                        activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      onTap: (position) {
                        _carouselController.animateToPage(position);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // No need to dispose CarouselSliderController in newer versions
    super.dispose();
  }
}