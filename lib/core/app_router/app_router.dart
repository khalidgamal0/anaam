import 'package:an3am/core/app_router/screens_name.dart';
import 'package:an3am/data/models/products_model/product_model.dart';
import 'package:an3am/data/models/vendor_data_model.dart';
import 'package:an3am/presentation/screens/intro_screens/splash_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/followers_screen/following_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/details_screens/product_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/details_screens/vendor_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/main_layout.dart';
import 'package:an3am/presentation/screens/main_layout_screens/profile_screens/add_product_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/profile_screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/main_layout_screens/followers_screen/followers_screen.dart';
import '../../presentation/screens/main_layout_screens/notification_screen/notification_screen.dart';
import '../../presentation/screens/main_layout_screens/payment_screen/package_subscriptions_screen.dart';
import '../../presentation/screens/main_layout_screens/profile_screens/personal_data_screen.dart';
import '../../presentation/screens/main_layout_screens/profile_screens/privacy_policy_screen.dart';
import '../../presentation/screens/main_layout_screens/profile_screens/products_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/add_store_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/add_vet_store_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/add_laborer_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/profile_screens/about_us_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case ScreenName.editProfileScreen:
          return SlideRightRoute(
            page: const EditProfileScreen(),
          );
        case ScreenName.addProductScreen:
          return SlideRightRoute(
            page: const AddProductScreen(),
          );
        case ScreenName.productControlScreen:
          return SlideRightRoute(
            page: const ProductsScreen(),
          );
        case ScreenName.privacyPolicyScreen:
          return SlideRightRoute(
            page: const PrivacyPolicyScreen(),
          );
        case ScreenName.notificationsScreen:
          return SlideRightRoute(
            page: const NotificationsScreen(),
          );
        case ScreenName.personalDataScreen:
          return SlideRightRoute(
            page: const PersonalDataScreen(),
          );
        case ScreenName.packageSubscriptionsScreen:
          return SlideRightRoute(
            page: const PackageSubscriptionsScreen(),
          );
        case ScreenName.productDetailsScreen:
          ProductDataModel productDataModel = settings.arguments as ProductDataModel;
          return SlideRightRoute(
            page: ProductDetailsScreen(productDataModel: productDataModel,),
          );
        case ScreenName.vendorDetailsScreen:
          VendorProfileModel vendorProfileModel = settings.arguments as VendorProfileModel;
          return SlideRightRoute(
            page: VendorDetailsScreen(vendorProfileModel: vendorProfileModel,),
          );
        case ScreenName.followersScreen:
          return SlideRightRoute(
            page: const FollowersScreen(),
          );
        case ScreenName.followingScreen:
          return SlideRightRoute(
            page: const FollowingScreen(),
          );
        case ScreenName.mainLayoutScreen:
          return MaterialPageRoute(builder: (_)=>const MainLayoutScreen());
        case ScreenName.splashScreen:
          return MaterialPageRoute(builder: (_)=>const SplashScreen());
        case ScreenName.addStoreScreen:
          return MaterialPageRoute(builder: (_) => const addStoreScreen());
        case ScreenName.addVetScreen:
          return MaterialPageRoute(builder: (_) => const AddVetScreen());
        case ScreenName.addLaborerScreen:
          return MaterialPageRoute(builder: (_) => const AddLaborerScreen());
        case ScreenName.aboutUsScreen: // New Route
          return SlideRightRoute(
            page: const AboutUsScreen(),
          );
        default:
          return _errorRoute();
      }
    } catch (e) {
      return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error when routing to this screen'),
        ),
      );
    });
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return page;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}
