import 'package:an3am/bloc_observer.dart';
import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/translations/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'core/app_router/app_router.dart';
import 'core/app_router/screens_name.dart';
import 'core/app_theme/app_theme.dart';
import 'core/cache_helper/shared_pref_methods.dart';
import 'core/network/api_end_points.dart';
import 'core/network/dio_helper.dart';
import 'core/services/services_locator.dart';
import 'domain/controllers/auth_cubit/auth_cubit.dart';
import 'domain/controllers/home_cubit/home_cubit.dart';
import 'domain/controllers/main_layout_cubit/main_layout_cubit.dart';
import 'domain/controllers/map_cubit/map_cubit.dart';
import 'domain/controllers/packages_cubit/packages_cubit.dart';
import 'domain/controllers/products_cubit/products_cubit.dart';
import 'domain/controllers/profile_cubit/profile_cubit.dart';
import 'domain/controllers/services_cubit/services_cubit.dart';
import 'firebase_options.dart';
import 'package:an3am/core/network/api_end_points.dart';

Future<void> fetchCurrenciesAndRates() async {
  // الحصول على عملة المستخدم من الكاش، وإذا لم توجد نستخدم "SAR" افتراضي
  // String userCurrency = CacheHelper.getData(key: 'currency') as String? ?? 'SAR';
  
  // Fetch currencies as before
  final currenciesUrl = '${EndPoints.baseUrl}${EndPoints.currency}';
  final currenciesResponse = await http.get(Uri.parse(currenciesUrl));
  if (currenciesResponse.statusCode == 200) {
    CacheHelper.saveData(key: 'currencies', value: currenciesResponse.body);
    // List<dynamic> currencies = json.decode(currenciesResponse.body);
  }

  // New system: fetch all exchange rates with a single request
  final exchangeRatesUrl = '${EndPoints.baseUrl}/exchange-rates';
  final exchangeRatesResponse = await http.get(Uri.parse(exchangeRatesUrl));
  if (exchangeRatesResponse.statusCode == 200) {
    final responseData = json.decode(exchangeRatesResponse.body);
    // Extract the nested exchange_rates map.
    final Map<String, dynamic> rawRates = responseData["exchange_rates"] ?? {};
    final Map<String, dynamic> transformedRates = {};
    
    // For each base currency, convert each rate string to a double.
    rawRates.forEach((base, rates) {
      if (rates is Map) {
        transformedRates[base] = rates.map((target, rateValue) {
          double value = double.tryParse(rateValue.toString()) ?? 1.0;
          return MapEntry(target, value);
        });
      }
    });
    
    // Cache the transformed exchange rates JSON directly
    CacheHelper.saveData(key: 'exchange_rates', value: json.encode(transformedRates));
  }
}

Future<void> fetchStaticData() async {
  final dio = Dio();
  
  // Helper function to fetch all pages
  Future<List<dynamic>> fetchAllPages(String endpoint) async {
    List<dynamic> allData = [];
    int currentPage = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        final response = await dio.get(
          '${EndPoints.baseUrl}$endpoint',
          queryParameters: {'page': currentPage},
        );

        if (response.statusCode == 200 && response.data['result'] != null) {
          // Extract data from the current page
          final resultData = response.data['result'];
          if (resultData is Map && resultData['data'] != null) {
            allData.addAll(resultData['data']);
            
            // Check if there are more pages
            final lastPage = resultData['last_page'] ?? currentPage;
            hasMorePages = currentPage < lastPage;
            currentPage++;
          } else if (resultData is List) {
            allData.addAll(resultData);
            hasMorePages = false;
          } else {
            hasMorePages = false;
          }
        } else {
          hasMorePages = false;
        }
      } catch (e) {
        hasMorePages = false;
      }
    }
    return allData;
  }

  try {
    // Fetch and cache all countries
      final countriesData = await fetchAllPages(EndPoints.countries);
    if (countriesData.isNotEmpty) {
      final countriesResponse = {'result': countriesData};
      CacheHelper.saveData(
        key: 'all_countries',
        value: json.encode(countriesResponse),
      );
    }

    // Fetch and cache all cities
    final citiesData = await fetchAllPages(EndPoints.cities);
    if (citiesData.isNotEmpty) {
      final citiesResponse = {'result': citiesData};
      CacheHelper.saveData(
        key: 'all_cities',
        value: json.encode(citiesResponse),
      );
    }

    // Fetch and cache all states
    final statesData = await fetchAllPages(EndPoints.states);
    if (statesData.isNotEmpty) {
      final statesResponse = {'result': statesData};
      CacheHelper.saveData(
        key: 'all_states',
        value: json.encode(statesResponse),
      );
    }
  } catch (e) {
  }
}

class PeriodicRefresh extends StatefulWidget {
  final Widget child;
  const PeriodicRefresh({super.key, required this.child});

  @override
  State<PeriodicRefresh> createState() => _PeriodicRefreshState();
}

class _PeriodicRefreshState extends State<PeriodicRefresh> {
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // Refresh every 5 seconds for testing purposes
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) {
    _timer = Timer.periodic(Duration(seconds: 99999), (timer) {
      fetchCurrenciesAndRates();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();
  await DioHelper.init();
  await CacheHelper.init();
  if(CacheHelper.getData(key: 'currencies') == null || CacheHelper.getData(key: 'exchange_rates') == null ){
    await fetchCurrenciesAndRates();
  }else{
    fetchCurrenciesAndRates();
  }
  if (CacheHelper.getData(key: 'all_countries') == null ||
      CacheHelper.getData(key: 'all_cities') == null ||
      CacheHelper.getData(key: 'all_states') == null) {
    // await fetchStaticData();
    fetchStaticData();
  } else {
    fetchStaticData();
  }
  ServicesLocator().init();
  Bloc.observer = MyBlocObserver();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale(
          'ar',
        ),
        Locale(
          'ar',
        ),
      ],
      startLocale:  Locale(CacheHelper.getData(key: CacheKeys.initialLocale)??"ar"),
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      child: Phoenix(
        child: PeriodicRefresh(
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => MainLayoutCubit(),
            ),
            BlocProvider(
              create: (context) => HomeCubit(),
            ),
            BlocProvider(
              create: (context) => PackagesCubit(),
            ),
            BlocProvider(
              create: (context) => AuthCubit()..getAllCountries(),
            ),
            BlocProvider(
              create: (context) => ProfileCubit(),
            ),
            BlocProvider(
              create: (context) => ProductsCubit()

                ..getAllCategories(),
            ),
            BlocProvider(
              create: (context) => MapCubit(),
            ),
            BlocProvider(
              create: (context) => ServicesCubit()
                ..getAllServices()
                ..getAllVet()
                ..getUserFollowingVet()
                ..getAllLaborer()
                ..getUserFollowingLaborer()
                ..getAllStore()
                ..getUserFollowingStore()
                ..getAllCategories()
                ..getAllCities(),
            ),
          ],
          child: MaterialApp(
            title: 'Anaam',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: ScreenName.splashScreen,
          ),
        );
      },
    );
  }
}