import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/controllers/auth_controller.dart';
import 'package:toko_sepatu_satria/layers/auth/register_screen.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/navbar_seller.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/navbar_user.dart';
import 'package:toko_sepatu_satria/models/firebase/user_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.email, this.password});
  //Menerima value dari register
  final String? email;
  final String? password;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Insialisasi variable
  bool obscureTextPassword = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoad = false;
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

//Fungsi menerima value dari register dan di set ke var login
  void setDataFromParam() {
    if (widget.email != null) {
      emailCtrl.text = widget.email ?? "";
    }
    if (widget.password != null) {
      passwordCtrl.text = widget.password ?? "";
    }
  }

//fungsi login
  login() {
    //menjadikan login aktif
    setState(() {
      isLoad = true;
    });
    //Memanggil controller login
    AuthController()
        .login(email: emailCtrl.text, password: passwordCtrl.text)
        .then((value) {
      if (value!.error == null) {
        //menerima pengembalian dari controller
        final data = value.data as UserModel;

//Validasi role
        if (data.role == 'seller') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const NavbarSeller(),
              ),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const NavbarUser(),
              ),
              (route) => false);
        }
      } else {
        setState(() {
          isLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            value.message ?? "Terjadi kesalahan tak diketahui",
          ),
        ));
      }
    });
  }

  @override
  void initState() {
    setDataFromParam();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: fontStyleTitleH1DefaultColor(context),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    final RegExp emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Masukkan email yang valid';
                                    }
                                    return null;
                                  },
                                  decoration:
                                      const InputDecoration(hintText: "Email"),
                                ),
                                TextFormField(
                                  controller: passwordCtrl,
                                  obscureText: obscureTextPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => value!.length < 8
                                      ? "Password harus lebih dari 8 digit"
                                      : null,
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextPassword =
                                                  !obscureTextPassword;
                                            });
                                          },
                                          icon: Icon(obscureTextPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility))),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: isPotrait
                                ? MediaQuery.of(context).size.height * 0.4
                                : MediaQuery.of(context).size.height * 0.2,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 0,
                                  backgroundColor:
                                      GetTheme().primaryColor(context)),
                              child: Text(
                                "Login",
                                style: fontStyleSubtitleSemiBoldWhiteColor(
                                    context),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  )),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 0,
                                  backgroundColor:
                                      GetTheme().cardColorGreyDark(context)),
                              child: Text(
                                "Register",
                                style: fontStyleSubtitleSemiBoldDefaultColor(
                                    context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
    );
  }
}
