
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/sign_in_with_email_password_form.dart';
import '../../utils/app_theme.dart';
import '../widgets/app_bar.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = "/sign_in";

  final Widget? nextScreen;

  const SignInScreen(this.nextScreen, {super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: widget.nextScreen != null ? buildAppBar(context, '') : null,
      body: SignInWithEmailPasswordForm(widget.nextScreen),
    );
  }
}
