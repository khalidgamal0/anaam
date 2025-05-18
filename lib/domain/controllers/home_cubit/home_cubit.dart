import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of(context);


  int? selectedServicesCategoryIndex = 0;
  int? selectedCategoryIndex;
  int? selectedSubCategoryIndex;

  void changeCategoriesTabBarWidget(int index, {bool isCategories = true}) {
    if (isCategories) {
      if (index != selectedCategoryIndex) {
        selectedCategoryIndex = index;
        selectedSubCategoryIndex = null;
      } else {
        selectedSubCategoryIndex = null;
        selectedCategoryIndex = null;
      }
    } else {
      if (index != selectedSubCategoryIndex) {
        selectedSubCategoryIndex = index;
      } else {
        selectedSubCategoryIndex = null;
      }
    }
    emit(ChangeCategoriesTabBarWidgetState());
  }

  void changeServicesCategoriesTabBarWidget(int index,) {
    if (index != selectedServicesCategoryIndex) {
      selectedServicesCategoryIndex = index;
    } else {
      selectedServicesCategoryIndex = null;
    }
    emit(ChangeServicesCategoriesTabBarWidgetState());
  }
  void handleLogout() {
    emit(HomeInitial());
  }

  @override
  Future<void> close() {
    handleLogout();
    return super.close();
  }
}
