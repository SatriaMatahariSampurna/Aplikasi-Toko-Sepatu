import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: GetTheme().primaryColor(context),
          child: Center(
            child: Text(
              "TokoSepatu Satria",
              style: fontStyleTitleH3WhiteColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
