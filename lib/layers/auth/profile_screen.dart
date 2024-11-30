// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_sepatu_satria/controllers/auth_controller.dart';
import 'package:toko_sepatu_satria/layers/auth/login_screen.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool isLoad = true;

  TextEditingController nameCtrl = TextEditingController();

//mendapatkan user
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
        if (user != null) {
          //jika tidak null maka controller nama akan dirubah
          nameCtrl.text = user!.displayName ?? "";
        }
      });
    });
  }

  void start() async {
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  void updateUname() async {
    setState(() {
      isLoad = true;
    });
    //validasi
    if (nameCtrl.text == "") {
      setState(() {
        isLoad = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "nama tidak boleh kosong",
      )));
    } else {
      setState(() {
        isLoad = false;
      });

      //Memanggil controller update nama
      final res = await AuthController().updateUsername(nameCtrl.text);
      if (res!.error == null) {
        await getUser();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      }
    }
  }

  void logout() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    //Manggil controller logout dan menerima respon yang di berikan
    final res = await AuthController().logOutRes();
    if (res!.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "",
      )));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "Terjadi kesalahan tidak diketahui",
      )));
    }
  }

  //imagepicker
  File? _imageFile;

  void _showPicker(BuildContext context) {
    //Membuka modal
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

//fungsi ambil dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

//fungsi ambil dari kamera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

  void updateimage() async {
    setState(() {
      isLoad = true;
    });
    //memanggil controller update image dan mendapatkan respon
    final res = await AuthController().updateImage(_imageFile);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      res!.message ?? "-",
    )));
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    start();
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
          "Profil kamu",
          style: fontStyleTitleAppbar(context),
        ),
        actions: [
          IconButton(onPressed: updateUname, icon: Icon(Icons.save)),
          IconButton(
              onPressed: user != null ? logout : null,
              icon: Icon(
                Icons.logout,
                color: GetTheme().errorColor(context),
              )),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoad
          ? loadIndicator()
          : Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: Image.network(
                          user!.photoURL ??
                              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                          width: isPotrait
                              ? MediaQuery.of(context).size.width * 0.5
                              : MediaQuery.of(context).size.width * 0.2,
                          height: isPotrait
                              ? MediaQuery.of(context).size.width * 0.5
                              : MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            "${AssetsSetting().imagePath}err.png",
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                          decoration: InputDecoration(hintText: 'nama'),
                        ),
                        Text(
                          user!.email ?? '-',
                          style: fontStyleSubtitleDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
