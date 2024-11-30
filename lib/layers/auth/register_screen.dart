import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/controllers/auth_controller.dart';
import 'package:toko_sepatu_satria/layers/auth/login_screen.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //inisialisasi variable
  bool obscureTextPassword = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  bool isLoad = false;

//fungsi register
  void register() {
    //mengakitfkan login
    setState(() {
      isLoad = true;
    });

    //Memanggil controller register
    AuthController()
        .register(
            name: nameCtrl.text,
            email: emailCtrl.text,
            password: passwordCtrl.text)
        .then((value) {
      //validasi error pengembalian dari ctrl register
      if (value!.error == null) {
        setState(() {
          isLoad = false;
        });
        //navigasi ke login
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                email: emailCtrl.text,
                password: passwordCtrl.text,
              ),
            ));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registrasi berhasil",
          ),
        ));
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
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Halo, Selamat Datang",
          overflow: TextOverflow.ellipsis,
          style: fontStyleTitleH1DefaultColor(context),
        ),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: Flex(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: isPotrait ? Axis.vertical : Axis.horizontal,
                  children: [
                    SizedBox(
                      height: isPotrait
                          ? MediaQuery.of(context).size.height * 0.55
                          : MediaQuery.of(context).size.height,
                      width: !isPotrait
                          ? MediaQuery.of(context).size.width * 0.55
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  keyboardType: TextInputType.name,
                                  validator: (value) => value!.isEmpty
                                      ? "nama tidak boleh kosong"
                                      : null,
                                  decoration:
                                      const InputDecoration(hintText: "Nama"),
                                ),
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
                          const Spacer(),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isPotrait,
                      child: SizedBox(
                        width: ScreenSetting().paddingScreen,
                      ),
                    ),
                    Expanded(
                        child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: isPotrait
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      register();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      elevation: 0,
                                      backgroundColor:
                                          GetTheme().primaryColor(context)),
                                  child: Text(
                                    "Register",
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
                                            const LoginScreen(),
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      elevation: 0,
                                      backgroundColor: GetTheme()
                                          .cardColorGreyDark(context)),
                                  child: Text(
                                    "Login",
                                    style:
                                        fontStyleSubtitleSemiBoldDefaultColor(
                                            context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                  ]),
            ),
    );
  }
}
