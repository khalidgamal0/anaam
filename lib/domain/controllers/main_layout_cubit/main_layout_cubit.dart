import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/presentation/screens/main_layout_screens/profile_screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/screens/main_layout_screens/favorite_screens/favorites_screen.dart';
import '../../../presentation/screens/main_layout_screens/home_screen/home_screen.dart';
import 'main_layout_state.dart';
import 'package:an3am/domain/controllers/products_cubit/products_cubit.dart';

class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(MainLayoutInitial());

  static MainLayoutCubit get(context) => BlocProvider.of(context);

  List<Widget> screens = [
    const ProfileScreen(),
    const HomeScreen(),
    const FavoritesScreen(),
  ];


  int currentIndex = 1;
  // void changeNavBarIndex(int index){
  //   currentIndex = index;
  //   emit(ChangeBottomNavBarIndexState());
  // }


  void changeNavBarIndex(int index, BuildContext context) {
    if (index == 1 && currentIndex == 1) {
      final productsCubit = ProductsCubit.get(context);
      productsCubit.allProductsPageNumber = 1;
      productsCubit.productsList.clear();
      productsCubit.searchedProductsList.clear();
      productsCubit.selectedCategoryIndex = null;
      productsCubit.selectedSubCategoryIndex = null;
      productsCubit.showCategoryModel = null;
      productsCubit.searchValue.clear();
      productsCubit.getAllProducts();
    }
    currentIndex = index;
    emit(ChangeBottomNavBarIndexState());
  }

  void handleAuthMethods() {
    // currentIndex = CacheHelper.getData(key: CacheKeys.token)!=null?2:1;
    currentIndex = CacheHelper.getData(key: CacheKeys.token)!=null?1:0;
    screens = [
      const ProfileScreen(),
      const HomeScreen(),
      const FavoritesScreen(),
    ];
    emit(HandleAuthMethodsState());
  }
}
