import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/layers/auth/login_screen.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/navbar_seller.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/navbar_user.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/splash_screen.dart';
import 'package:toko_sepatu_satria/models/firebase/user_model.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoad = true;
  String role = UserOptionModel().roleUser;
  User? user;
  void checkRole() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) async {
      if (!mounted) return;
      user = _user;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        final userFireStore = await firestore
            .collection(UserOptionModel().collection)
            .doc(user!.uid)
            .get();
        if (userFireStore.exists) {
          setState(() {
            role = userFireStore.get(UserOptionModel().role);
            isLoad = false;
          });
        }
      } else {
        setState(() {
          isLoad = false;
        });
        role = UserOptionModel().roleUser;
      }
    });
  }

  @override
  void initState() {
    checkRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
      ),
      home: isLoad
          ? const SplashScreen()
          : user == null
              ? const LoginScreen()
              : role == UserOptionModel().roleSeller
                  ? const NavbarSeller()
                  : const NavbarUser(),
    );
  }
}
