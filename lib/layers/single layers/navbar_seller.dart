import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/layers/auth/profile_screen.dart';
import 'package:toko_sepatu_satria/layers/order/order_list.dart';
import 'package:toko_sepatu_satria/layers/product/seller/brand_list.dart';
import 'package:toko_sepatu_satria/layers/product/seller/product_list.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';

class NavbarSeller extends StatefulWidget {
  const NavbarSeller({super.key});

  @override
  State<NavbarSeller> createState() => _NavbarSellerState();
}

class _NavbarSellerState extends State<NavbarSeller> {
  int screenindex = 0;
  final screen = [
    const OrderList(
      isSeller: true,
    ),
    const ProductListSeller(),
    const BrandList(),
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
              icon: const Icon(Icons.history),
              label: "Order",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.store),
              label: "Produk",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.branding_watermark),
              label: "Brand",
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
