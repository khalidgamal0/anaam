import 'package:an3am/domain/controllers/auth_cubit/auth_cubit.dart';
import 'package:an3am/domain/controllers/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterTypeRadioGroup extends StatefulWidget {
  const RegisterTypeRadioGroup({super.key});

  @override
  RegisterTypeRadioGroupState createState() => RegisterTypeRadioGroupState();
}

class RegisterTypeRadioGroupState extends State<RegisterTypeRadioGroup> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        cubit.changeRegisterType("vendor");
        return const SizedBox();
      },
    );
  }
}
