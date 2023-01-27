import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login_signup/screens/home_screen.dart';
import 'package:flutter_firebase_login_signup/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_login_signup/screens/profile_settings_screen.dart';
import 'package:flutter_firebase_login_signup/screens/reset_password_screen.dart';
import 'package:flutter_firebase_login_signup/screens/signup_screen.dart';
import 'package:flutter_firebase_login_signup/widgets/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fireInit = Firebase.initializeApp();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          '/login': (context) => const LoginScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile-settings': (context) => const ProfileSettingsScreen(),
        },
        title: 'Flutter Firebase Login Signup',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: FutureBuilder(
          future: _fireInit,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Error!\n\nTry reloading the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 20)),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FirebaseAuth.instance.currentUser == null
                  ? const SignUpScreen()
                  : const HomeScreen();
            }
            return const Scaffold(
              backgroundColor: Color(0xFFFAFAFA),
              body: Loading(),
            );
          },
        ));
  }
}
