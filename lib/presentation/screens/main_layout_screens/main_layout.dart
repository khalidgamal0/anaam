import 'package:an3am/presentation/widgets/main_layout_widgets/bottom_nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/controllers/main_layout_cubit/main_layout_cubit.dart';
import '../../../domain/controllers/main_layout_cubit/main_layout_state.dart';
import '../../../presentation/widgets/shared_widget/remote_popup_widget.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    // تهيئة مدير النوافذ المنبثقة
    RemotePopupManager.init();

    // استدعاء النافذة المنبثقة بعد بناء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RemotePopupManager.showPopupIfAvailable(context);
    });
  }

  @override
  void dispose() {
    // إلغاء المؤقتات عند إغلاق الشاشة
    RemotePopupManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainLayoutCubit, MainLayoutState>(
      builder: (context, state) {
        var cubit = MainLayoutCubit.get(context);
        return Scaffold(
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavBarWidget(
            currentIndex: cubit.currentIndex,
            onTap: (index) => cubit.changeNavBarIndex(index, context),
          ),
        );
      },
    );
  }
}
