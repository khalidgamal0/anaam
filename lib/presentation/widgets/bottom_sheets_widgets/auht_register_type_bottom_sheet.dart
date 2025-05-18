import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/presentation/widgets/auth_widgets/register_type_radio_group.dart';
import 'package:flutter/material.dart';

import '../../../domain/controllers/auth_cubit/auth_cubit.dart';

class AuthRegisterTypeBottomSheet extends StatefulWidget {
  final String socialType;
  const AuthRegisterTypeBottomSheet({super.key, required this.socialType});

  @override
  _AuthRegisterTypeBottomSheetState createState() => _AuthRegisterTypeBottomSheetState();
}

class _AuthRegisterTypeBottomSheetState extends State<AuthRegisterTypeBottomSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      AuthCubit cubit = AuthCubit.get(context);
      cubit.changeRegisterType("vendor");
      widget.socialType=="g"?cubit.googleSignIn():widget.socialType=="t"?cubit.twitterSignIn():cubit.signInWithApple();  
      // widget.socialType == "g" ? cubit.googleSignIn() : cubit.signInWithApple();

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const RegisterTypeRadioGroup(),
        const SizedBox(height: 16),
      ],
    ).symmetricPadding(horizontal: 16);
  }
}
