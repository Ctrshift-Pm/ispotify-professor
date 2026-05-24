import 'package:flutter/material.dart';
import 'package:spotify_with_flutter/presentation/auth/pages/singin.dart';
import 'package:spotify_with_flutter/presentation/auth/pages/signup.dart';
import 'package:spotify_with_flutter/presentation/auth/pages/signup_or_signin.dart';
import 'package:spotify_with_flutter/presentation/choose_mode/pages/choose_mode.dart';
import 'package:spotify_with_flutter/presentation/home/pages/navigation_shell.dart';
import 'package:spotify_with_flutter/presentation/intro/pages/get_started.dart';
import 'package:spotify_with_flutter/presentation/splash/pages/splash.dart';

class AppRoutes {
  static const splash = '/';
  static const getStarted = '/get-started';
  static const chooseMode = '/choose-mode';
  static const signupOrSignin = '/signup-or-signin';
  static const signup = '/signup';
  static const signin = '/signin';
  static const home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        getStarted: (_) => const GetStartedPage(),
        chooseMode: (_) => const ChooseModePage(),
        signupOrSignin: (_) => const SignupOrSignin(),
        signup: (_) => SignupPage(),
        signin: (_) => SigninPage(),
        home: (_) => const NavigationShell(),
      };
}
