import 'package:an3am/core/parameters/update_profile_parameters.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_cubit.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_state.dart';
import 'package:an3am/presentation/widgets/auth_widgets/first_and_last_name_component.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_divider.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';

import 'package:an3am/data/models/country_model/country_model.dart';
import 'package:an3am/data/models/city_model/city_model.dart';
import 'package:an3am/core/network/api_end_points.dart';
import 'package:an3am/data/models/country_model/get_all_countries_datasource.dart';
import 'package:an3am/data/models/city_model/get_all_cities.dart';
import 'package:an3am/data/models/state_model/state_model.dart';
import 'package:an3am/data/models/state_model/get_all_states_model.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/constants/reg_exp.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../widgets/auth_widgets/custom_text_field.dart';
import '../../../widgets/shared_widget/custom_elevated_button.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  Future<List<CountryModel>> fetchCountries() async {
    final cached = CacheHelper.getData(key: 'all_countries');
    if (cached != null) {
      final model = GetAllCountriesModel.fromJson(json.decode(cached));
      return model.countriesList ?? [];
    }
    final response = await Dio().get('${EndPoints.baseUrl}${EndPoints.countries}');
    CacheHelper.saveData(key: 'all_countries', value: json.encode(response.data));
    final model = GetAllCountriesModel.fromJson(response.data);
    print("Country: ${response}");
    return model.countriesList ?? [];
  }

  Future<List<CityModel>> fetchCities() async {
    final cached = CacheHelper.getData(key: 'all_cities');
    if (cached != null) {
      final model = GetAllCitiesModel.fromJson(json.decode(cached));
      return model.citiesList ?? [];
    }
    final response = await Dio().get('${EndPoints.baseUrl}${EndPoints.cities}');
    CacheHelper.saveData(key: 'all_cities', value: json.encode(response.data));
    final model = GetAllCitiesModel.fromJson(response.data);
    print("Cities: ${response}");
    return model.citiesList ?? [];
  }

  Future<List<StateModel>> fetchStates() async {
    final cached = CacheHelper.getData(key: 'all_states');
    if (cached != null) {
      final model = GetAllStatesModel.fromJson(json.decode(cached));
      return model.statesList ?? [];
    }
    final response = await Dio().get('${EndPoints.baseUrl}${EndPoints.states}');
    CacheHelper.saveData(key: 'all_states', value: json.encode(response.data));
    final model = GetAllStatesModel.fromJson(response.data);
    print("States: ${response}");
    return model.statesList ?? [];
  }

  @override
  void initState() {
    var cubit = ProfileCubit.get(context);
    cubit.firstNameController.text = cubit.profileModel!.firstName!;
    cubit.secondNameController.text = cubit.profileModel!.lastName!;
    cubit.emailController.text = cubit.profileModel!.email!;
    cubit.phoneController.text = cubit.profileModel!.phone ?? "";
    cubit.locationController.text = cubit.profileModel!.location ?? "";
    cubit.addressController.text = cubit.profileModel!.address ?? "";
    cubit.birthdateController.text = cubit.profileModel!.birth_date ?? "";
    cubit.countryIdController.text = cubit.profileModel?.countryId ?? "";
    cubit.cityIdController.text = cubit.profileModel?.cityId ?? "";
    cubit.stateIdController.text = cubit.profileModel?.stateId ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = ProfileCubit.get(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is UpdateProfileLoadingState) {
              showProgressIndicator(context);
            }
            if (state is UpdateProfileSuccessState) {
              Navigator.pop(context);
            }
            if (state is UpdateProfileErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
          },
          builder: (context, state) {
            return cubit.getProfileData
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : ListView(
                    padding:
                        EdgeInsets.symmetric(vertical: 23.h, horizontal: 28.w),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LocaleKeys.personalData.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(fontSize: 20.sp),
                          ),
                        ],
                      ),
                      const CustomDivider(),
                      const CustomSizedBox(
                        height: 24,
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
                              child: cubit.profileImage == null
                                  ? CachedNetworkImage(
                                      imageUrl: cubit.profileModel!.image!,
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
                                    )
                                  : Image.file(
                                      cubit.profileImage!,
                                      fit: BoxFit.cover,
                                    ),
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
                        height: 24,
                      ),
                      FirstLastNameComponent(
                        firstNameController: cubit.firstNameController,
                        secondNameController: cubit.secondNameController,
                      ),
                      const CustomSizedBox(
                        height: 16,
                      ),
                      CustomTextField(
                        hintText: LocaleKeys.email.tr(),
                        controller: cubit.emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.pleaseEnterEmail.tr();
                          } else if (!RegularExp.emailRegex.hasMatch(value)) {
                            return LocaleKeys.pleaseEnterValidateEmail.tr();
                          }
                          return null;
                        },
                        // height: 45,
                      ),
                      const CustomSizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<CountryModel>>(
                              future: fetchCountries(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text("No data");
                                }
                                return DropdownButtonFormField<String>(
                                  value: cubit.countryIdController.text.isNotEmpty
                                      ? cubit.countryIdController.text
                                      : null,
                                  decoration:
                                      InputDecoration(hintText: "الدولة"),
                                  items: snapshot.data!
                                      .map((country) => DropdownMenuItem<String>(
                                            value: country.id.toString(),
                                            child: Text('${country.name ?? ""} ${country.code ?? ""}'),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      cubit.countryIdController.text = value ?? "";
                                      cubit.cityIdController.text = "";
                                      cubit.stateIdController.text = "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'من فضلك ادخل معرف الدولة';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomTextField(
                              hintText: "رقم الهاتف",
                              controller: cubit.phoneController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LocaleKeys.pleaseEnterYourPhone.tr();
                                } else if (value.length < 9) {
                                  return LocaleKeys.invalidPhoneNumber.tr();
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const CustomSizedBox(height: 16),
                      cubit.countryIdController.text.isEmpty
                          ? DropdownButtonFormField<String>(
                              onChanged: null,
                              decoration: InputDecoration(hintText: "المدينة"),
                              items: const [],
                            )
                          : FutureBuilder<List<CityModel>>(
                              future: fetchCities(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  debugPrint("City API returned no data: ${snapshot.data}");
                                  return const Text("No data");
                                }
                                // Debug prints for selected country id and full cities list
                                debugPrint("Selected Country ID: ${cubit.countryIdController.text}");
                                debugPrint("All cities from API: ${snapshot.data}");
                                // Filter cities based on the selected country id
                                final filteredCities = snapshot.data!
                                    .where((city) => city.country != null &&
                                        city.country!.id.toString().trim() ==
                                            cubit.countryIdController.text.trim())
                                    .toList();
                                debugPrint("Filtered cities count: ${filteredCities.length}");
                                if (filteredCities.isEmpty) {
                                  return const Text("لا توجد مدن لهذه الدولة");
                                }
                                return DropdownButtonFormField<String>(
                                  value: cubit.cityIdController.text.isNotEmpty
                                      ? cubit.cityIdController.text
                                      : null,
                                  decoration: InputDecoration(hintText: "المدينة"),
                                  items: filteredCities
                                      .map((city) => DropdownMenuItem<String>(
                                            value: city.id.toString(),
                                            child: Text(city.name ?? ""),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      cubit.cityIdController.text = value ?? "";
                                      cubit.stateIdController.text = "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'من فضلك ادخل معرف المدينة';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                      const CustomSizedBox(height: 16),
                      cubit.cityIdController.text.isEmpty
                          ? DropdownButtonFormField<String>(
                              onChanged: null,
                              decoration: InputDecoration(hintText: "الولاية"),
                              items: const [],
                            )
                          : FutureBuilder<List<StateModel>>(
                              future: fetchStates(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Text("No states data");
                                }
                                // Filter states based on the selected city id
                                final filteredStates = snapshot.data!
                                    .where((state) =>
                                        state.city != null &&
                                        state.city!.id.toString() ==
                                            cubit.cityIdController.text)
                                    .toList();
                                if (filteredStates.isEmpty) {
                                  return const Text("لا توجد ولايات لهذه المدينة");
                                }
                                return DropdownButtonFormField<String>(
                                  value: cubit.stateIdController.text.isNotEmpty
                                      ? cubit.stateIdController.text
                                      : null,
                                  decoration: InputDecoration(hintText: "الولاية"),
                                  items: filteredStates
                                      .map((state) => DropdownMenuItem<String>(
                                            value: state.id.toString(),
                                            child: Text(state.name ?? ""),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      cubit.stateIdController.text = value ?? "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'من فضلك ادخل معرف الولاية';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                      const CustomSizedBox(height: 16),
                      CustomTextField(
                        hintText: "الموقع",
                        controller: cubit.locationController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل الموقع';
                          }
                          return null;
                        },
                        // height: 45,
                      ),
                      const CustomSizedBox(
                        height: 16,
                      ),
                      CustomTextField(
                        hintText: "العنوان",
                        controller: cubit.addressController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل العنوان';
                          }
                          return null;
                        },
                        // height: 45,
                      ),
                      const CustomSizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          DateTime initialDate = DateTime.now()
                              .subtract(Duration(days: 365 * 18)); // 18 years ago
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now()
                                .subtract(Duration(days: 365 * 18)), // 18 years ago
                          );
                          if (pickedDate != null) {
                            setState(() {
                              cubit.birthdateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: 'تاريخ الميلاد',
                            controller: cubit.birthdateController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'من فضلك ادخل تاريخ الميلاد';
                              }
                              return null;
                            },
                            // height: 45,
                          ),
                        ),
                      ),
                      const CustomSizedBox(height: 32),
                      CustomElevatedButton(
                        title: LocaleKeys.saveData.tr(),
                        onPressed: () {
                          cubit.updateProfile(
                              updateProfileParameters: UpdateProfileParameters(
                            birth_date: cubit.birthdateController.text,
                            location: cubit.locationController.text,
                            address: cubit.addressController.text,
                            phone: cubit.phoneController.text,
                            email: cubit.emailController.text,
                            method: "PUT",
                            image: cubit.profileImage,
                            firstName: cubit.firstNameController.text,
                            lastName: cubit.secondNameController.text,
                            country_id: cubit.countryIdController.text,
                            city_id: cubit.cityIdController.text,
                            state_id: cubit.stateIdController.text,
                          ));
                        },
                        buttonSize: Size(double.infinity, 48.h),
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }
}
