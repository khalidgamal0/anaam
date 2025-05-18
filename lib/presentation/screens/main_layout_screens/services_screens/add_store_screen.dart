import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/core/network/api_end_points.dart';
import 'package:an3am/core/parameters/store_parameters.dart';
import 'package:an3am/data/models/city_model/city_model.dart';
import 'package:an3am/data/models/country_model/country_model.dart';
import 'package:an3am/data/models/multi_lang_models/store_multi_lang_model.dart';
import 'package:an3am/domain/controllers/services_cubit/services_state.dart';
import 'package:an3am/presentation/screens/map_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/app_theme/app_colors.dart';
import '../../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../widgets/auth_widgets/custom_drop_down_button.dart';
import '../../../widgets/auth_widgets/custom_text_field.dart';
import '../../../widgets/shared_widget/custom_divider.dart';
import '../../../widgets/shared_widget/custom_elevated_button.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';

class addStoreScreen extends StatefulWidget {
  final StoreMultiLangModel? storeMultiLangModel;

  const addStoreScreen({super.key, this.storeMultiLangModel});

  @override
  State<addStoreScreen> createState() => _addStoreScreenState();
}

class _addStoreScreenState extends State<addStoreScreen> {
  final formKey = GlobalKey<FormState>();
  late final ServicesCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = ServicesCubit.get(context);
    cubit.getAllCountries();
    if (widget.storeMultiLangModel != null) {
      cubit.storeNameAr.text = widget.storeMultiLangModel!.name?["ar"] ?? "";
      cubit.trunkTypeAr.text =
          widget.storeMultiLangModel!.truckType?["ar"] ?? "";

      cubit.storePhone.text = widget.storeMultiLangModel!.phone ?? "";

      cubit.chosenCountry = cubit.countriesList.firstWhere(
          (element) => element.id == widget.storeMultiLangModel!.countryId);
      cubit.chosenCity = cubit.citiesList.firstWhere(
          (element) => element.id == widget.storeMultiLangModel!.cityId);

      cubit.mapCoordinates = widget.storeMultiLangModel!.coordinates;
      cubit.storeUploadedImages = widget.storeMultiLangModel!.images ?? [];
      cubit.mapLocation = widget.storeMultiLangModel!.mapLocation;
      cubit.storeEmail.text = widget.storeMultiLangModel!.email ?? "";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ServicesCubit, ServicesState>(
          listener: (context, state) {
            ServicesCubit cubit = ServicesCubit.get(context);
            if (state is UploadStoreLoadingState) {
              showProgressIndicator(context);
            }
            if (state is UploadStoreSuccessState) {
              Navigator.pop(context);
              Navigator.pop(context);
              cubit.storeImage = null;
              cubit.storeNameAr.clear();
              cubit.storePhone.clear();
              cubit.chosenCity = null;
              cubit.chosenCountry = null;
              cubit.storeImages = [];
              cubit.trunkTypeAr.clear();
              cubit.mapCoordinates = null;
              cubit.mapLocation = null;
              cubit.storeEmail.clear();
              cubit.storesList.clear();
              cubit.allStorePageNumber = 1;
              cubit.getAllStore();
            }
            if (state is UploadStoreErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
            if (state is UpdateStoreLoadingState) {
              showProgressIndicator(context);
            }
            if (state is UpdateStoreSuccessState) {
              Navigator.pop(context);
              Navigator.pop(context);
              cubit.storeImage = null;
              cubit.storeNameAr.clear();
              cubit.storePhone.clear();
              cubit.chosenCity = null;
              cubit.chosenCountry = null;
              cubit.storeImages = [];
              cubit.trunkTypeAr.clear();
              cubit.mapCoordinates = null;
              cubit.mapLocation = null;
              cubit.storeEmail.clear();
            }
            if (state is UpdateStoreErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
            if (state is GetPickedImageSuccessState) {
              cubit.storeImage = state.pickedImage;
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 20.r,
                            color: AppColors.greyColor34,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          LocaleKeys.addVan.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontSize: 20.sp),
                        ),
                      ],
                    ),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    const CustomDivider(),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 132.h,
                            width: 132.w,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: cubit.storeImage == null
                                ? null
                                : Image.file(
                                    cubit.storeImage!,
                                    fit: BoxFit.cover,
                                  ),
                            //CachedNetworkImage(
                            //                               imageUrl: cubit.laborerModel!.image!,
                            //                               fit: BoxFit.cover,
                            //                               placeholder: (context, url) {
                            //                                 return Shimmer.fromColors(
                            //                                   baseColor: Colors.grey[200]!,
                            //                                   highlightColor: Colors.grey[300]!,
                            //                                   child: Container(
                            //                                     height: double.infinity,
                            //                                     width: double.infinity,
                            //                                     decoration: BoxDecoration(
                            //                                       color: Colors.black,
                            //                                       borderRadius:
                            //                                       BorderRadius.circular(8.0),
                            //                                     ),
                            //                                   ),
                            //                                 );
                            //                               },
                            //                               errorWidget: (context, url, error) =>
                            //                               const Icon(Icons.error),
                            //                             )
                          ),
                          InkWell(
                            onTap: () {
                              cubit.getImagePick();
                            },
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            splashColor: Colors.transparent,
                            child: Container(
                              height: 132.h,
                              width: 132.w,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_a_photo_outlined,
                                  size: 35.r, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                      cubit.getAllCountriesLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        :CustomDropDownButton<CountryModel>(
                        height: 45,
                        onChanged: (selectedCountry) {
                          setState(() {
                            cubit.chosenCountry = selectedCountry;
                            cubit.chosenCity = null;
                          });
                        },
                        hint: LocaleKeys.pleaseChooseYourCountry.tr(),
                        items: cubit.countriesList
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(fontSize: 14.sp)),
                                ))
                            .toList(),
                        value: cubit.chosenCountry,
                      ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    cubit.getAllCitiesLoading
                        ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                    :CustomDropDownButton<CityModel>(
                          height: 45,
                          onChanged: cubit.chooseCity,
                          hint: LocaleKeys.pleaseChooseYourCity.tr(),
                          items: cubit.citiesList
                                .where((city) => city.country!.id == cubit.chosenCountry?.id)
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(fontSize: 14.sp)),
                                    ))
                                .toList(),
                          value: cubit.chosenCity,
                        ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.productNameAr.tr(),
                      controller: cubit.storeNameAr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.trunkTypeAr.tr(),
                      controller: cubit.trunkTypeAr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150.w,
                          child: CustomDropDownButton<CountryModel>(
                            onChanged: cubit.selectPhoneCountry,
                            hint: 'رمز الدولة (مثال: +966)',
                            items: cubit.countriesList
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        "${e.code} - ${e.name}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(fontSize: 14.sp),
                                      ),
                                    ))
                                .toList(),
                            value: cubit.selectedPhoneCountry,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CustomTextField(
                            hintText: LocaleKeys.phone.tr(),
                            controller: cubit.storePhone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return LocaleKeys.dataMustBeEntered.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.email.tr(),
                      controller: cubit.storeEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    InkWell(
                      onTap: () {
                        cubit.getMultiImagePick();
                      },
                      child: CustomTextField(
                        prefix: Icon(
                          Icons.camera_alt,
                          size: 20.r,
                          color: AppColors.authBorderColor,
                        ),
                        hintText: LocaleKeys.uploadImages.tr(),
                        enabled: false,
                        height: 45,
                      ),
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomSizedBox(
                      height: cubit.storeImages.isEmpty ? 0 : 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cubit.storeImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 36.h,
                            width: 50.w,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Image.file(
                              cubit.storeImages[index],
                              fit: BoxFit.cover,
                            ),
                          ).onlyDirectionalPadding(end: 5);
                        },
                      ),
                    ),
                    const CustomSizedBox(
                      height: 16,
                    ),
                    CustomSizedBox(
                      height: cubit.storeUploadedImages.isEmpty ? 0 : 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cubit.storeUploadedImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 60.h,
                            width: 60.w,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  height: double.infinity,
                                  width: double.infinity,
                                  imageUrl:
                                      "${EndPoints.imagesBaseUrl}/${cubit.storeUploadedImages[index].imageArEn!}",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  color: AppColors.blackColor.withOpacity(0.1),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppColors.whiteColor,
                                    size: 22.sp,
                                  ),
                                ),
                              ],
                            ),
                          ).onlyDirectionalPadding(end: 5);
                        },
                      ),
                    ),
                    CustomSizedBox(
                      height: cubit.storeImages.isEmpty &&
                              cubit.storeUploadedImages.isEmpty
                          ? 0
                          : 16,
                    ),
                    InkWell(
                      onTap: () async {
                        Map<String, dynamic> result = await Navigator.push(
                            context, MaterialPageRoute(builder: (_) {
                          return const MapScreen();
                        }));
                        cubit.getLocation(
                            locationName: result["name"],
                            coordinates: result['coordinates']);
                      },
                      child: CustomTextField(
                        prefix: Icon(
                          Icons.location_on_outlined,
                          size: 20.r,
                          color: AppColors.authBorderColor,
                        ),
                        hintText:
                            cubit.mapLocation ?? LocaleKeys.chooseLocation.tr(),
                        enabled: false,
                        height: 45,
                      ),
                    ),
                    const CustomSizedBox(
                      height: 40,
                    ),
                    CustomElevatedButton(
                      title: LocaleKeys.uploadData.tr(),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (widget.storeMultiLangModel == null) {
                            if (cubit.storeImage == null) {
                              showToast(
                                  errorType: 1,
                                  message:
                                      LocaleKeys.imagesMustBeSelected.tr());
                            } else {
                              if (cubit.mapLocation == null) {
                                showToast(
                                    errorType: 1,
                                    message:
                                        LocaleKeys.locationMustBeSelected.tr());
                              } else {
                                if (cubit.storeImages.isEmpty) {
                                  showToast(
                                      errorType: 1,
                                      message:
                                          LocaleKeys.imagesMustBeSelected.tr());
                                } else {
                                  cubit.uploadStore(
                                    storeParameters: StoreParameters(
                                      image: cubit.storeImage!,
                                      nameAr: cubit.storeNameAr.text,
                                      phone: cubit.storePhone.text,
                                      phone_code: cubit.getCountryCode(),
                                      countryId: cubit.chosenCountry!.id!.toString(),
                                      cityId: cubit.chosenCity!.id!.toString(),
                                      images: cubit.storeImages,
                                      truckTypeAr: cubit.trunkTypeAr.text,
                                      coordinates: cubit.mapCoordinates,
                                      mapLocation: cubit.mapLocation,
                                      email: cubit.storeEmail.text,
                                    ),
                                  );
                                }
                              }
                            }
                          } else {
                            cubit.updateStore(
                                vetParameters: StoreParameters(
                              image: cubit.storeImage,
                              id: widget.storeMultiLangModel!.id!.toString(),
                              nameAr: cubit.storeNameAr.text,
                              phone: cubit.storePhone.text,
                               phone_code: cubit.getCountryCode(),
                              method: "PUT",
                              countryId:cubit.chosenCountry!.id!.toString(),
                              cityId: cubit.chosenCity!.id!.toString(),
                              images: cubit.storeImages,
                              truckTypeAr: cubit.trunkTypeAr.text,
                              coordinates: cubit.mapCoordinates,
                              mapLocation: cubit.mapLocation,
                              email: cubit.storeEmail.text,
                            ));
                          }
                        }
                      },
                      buttonSize: Size(double.infinity, 48.h),
                    ),
                  ],
                ).symmetricPadding(horizontal: 26, vertical: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}
