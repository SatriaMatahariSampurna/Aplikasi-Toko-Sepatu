import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/layers/auth/profile_screen.dart';
import 'package:toko_sepatu_satria/layers/home/home_user.dart';
import 'package:toko_sepatu_satria/layers/order/order_list.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';

class NavbarUser extends StatefulWidget {
  const NavbarUser({super.key});

  @override
  State<NavbarUser> createState() => _NavbarUserState();
}

class _NavbarUserState extends State<NavbarUser> {
  int screenindex = 0;
  final screen = [
    const HomeUser(),
    const OrderList(
      isSeller: false,
    ),
    const Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[screenindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: GetTheme().backgroundGrey(context),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.shopify_rounded),
              label: "Sepatu",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: "Order Saya",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: "Akun",
              backgroundColor: GetTheme().backgroundGrey(context)),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: GetTheme().fontColor(context),
        elevation: 0,
        showUnselectedLabels: true,
        unselectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        selectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        currentIndex: screenindex,
        onTap: (value) {
          setState(() {
            screenindex = value;
          });
        },
      ),
    );
  }
}
