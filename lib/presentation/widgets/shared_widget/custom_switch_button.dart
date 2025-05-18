import 'package:an3am/data/models/products_model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../domain/controllers/products_cubit/products_state.dart';

class CustomSwitchButton extends StatelessWidget {
  final ProductDataModel productDataModel;

  const CustomSwitchButton({
    super.key,
    required this.productDataModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ChangeProductStatusSuccessState) {
          showToast(
            errorType: 0,
            message: "تم تغيير حالة المنتج بنجاح"
          );
        }
        if (state is ChangeProductStatusErrorState) {
          showToast(
            errorType: 1,
            message: state.error
          );
        }
      },
      builder: (context, state) {
        var cubit = ProductsCubit.get(context);
        bool isActive = cubit.vendorProducts[productDataModel.id.toString()] ?? productDataModel.inStock ?? false;
        
        return Switch(
          value: isActive,
          onChanged: (value) {
            cubit.changeProductStatus(
              productId: productDataModel.id!,
              status: value ? "active" : "inactive",
              productStatus: value
            );
          },
        );
      },
    );
  }
}
