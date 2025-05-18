import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/data/models/vendor_data_model.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_cubit.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_state.dart';
import 'package:an3am/presentation/widgets/bottom_sheets_widgets/add_vendor_review_bottom_sheet.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_divider.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/about_vendor_widget.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/intro_details_container.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/labor_component.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/van_compopnent.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/vet_component.dart';
import 'package:an3am/presentation/widgets/vendor_details_widgets/vendor_reviews_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VendorDetailsScreen extends StatelessWidget {
  final VendorProfileModel vendorProfileModel;

  const VendorDetailsScreen({super.key, required this.vendorProfileModel});

  @override
  Widget build(BuildContext context) {
    // جلب التقييمات عند تحميل الشاشة
    // context.read<ProfileCubit>().fetchVendorReviews(vendorProfileModel.id);
    
    // جلب التقييمات عند تحميل الشاشة إذا كان id غير null
      if (vendorProfileModel.id != null) {
        context.read<ProfileCubit>().fetchVendorReviews(vendorProfileModel.id!);
      }
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: _profileStateListener,
        builder: _profileStateBuilder,
      ),
    );
  }

  void _profileStateListener(BuildContext context, ProfileState state) {
    if (state is VendorReviewsErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error)),
      );
    }
  }

  Widget _profileStateBuilder(BuildContext context, ProfileState state) {
    final cubit = ProfileCubit.get(context);
    return SafeArea(
      bottom: false, // To prevent SafeArea from affecting the bottom of the list if it's inside Column
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 16.0, bottom: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 22, // Slightly larger for better tap target
                    color: Theme.of(context).colorScheme.primary, // Use primary color for emphasis
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                // Optionally, add an expanded title here if needed:
                // Expanded(
                //   child: Text(
                //     LocaleKeys.vendorDetails.tr(), // Assuming you have this key
                //     style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                //     textAlign: TextAlign.center, // Center title if back button takes space
                //   ),
                // ),
                // if you add an Expanded title, you might want a SizedBox to balance the IconButton space:
                // const SizedBox(width: kMinInteractiveDimension), // Balances the IconButton space if title is centered
              ],
            ),
          ),
          Expanded(
            child: cubit.getVendorProfileData
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _buildVendorDetailsList(context, cubit, state),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorDetailsList(
      BuildContext context, ProfileCubit cubit, ProfileState state) {
    return ListView(
      padding: EdgeInsets.zero, // Padding is handled by the header now for the top
      children: [
        IntroDetailsContainer(vendorProfileModel: vendorProfileModel),
        _buildSectionDivider(height: 18),
        AboutVendorWidget(vendorProfileModel: vendorProfileModel),
        _buildSectionDivider(),
        _buildReviewsSection(context, cubit, state),
        _buildSectionDivider(),
        LaborsComponentBuilder(vendorProfileModel: vendorProfileModel),
        _buildSectionDivider(),
        VetComponentBuilder(vendorProfileModel: vendorProfileModel),
        _buildSectionDivider(),
        VanComponentBuilder(vendorProfileModel: vendorProfileModel),
        CustomSizedBox(height: 15),
      ],
    );
  }

  Widget _buildSectionDivider({double height = 15}) {
    return Column(
      children: [
        CustomSizedBox(height: 15),
        CustomDivider(hPadding: 16),
        CustomSizedBox(height: height),
      ],
    );
  }

  Widget _buildReviewsSection(
      BuildContext context, ProfileCubit cubit, ProfileState state) {
    if (state is VendorReviewsLoadingState || cubit.getVendorReviewsLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return VendorReviewsWidget(
      reviews: cubit.vendorReviews,
      onAddPressed: CacheHelper.getData(key: CacheKeys.token) != null
          ? () => _showAddReviewBottomSheet(context)
          : null,
    );
  }

  void _showAddReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          AddVendorReviewBottomSheet(id: vendorProfileModel.id.toString()),
    );
  }
}