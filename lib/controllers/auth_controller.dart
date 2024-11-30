import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toko_sepatu_satria/models/firebase/user_model.dart';
import 'package:toko_sepatu_satria/models/response_model.dart';

class AuthController {
  //inisialisasi variable
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

//controller registrasi
  Future<Response?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      //memanggil fungsi register bawaan firebase auth
      final user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

//Membuat user baru di firestore dengan role user
      Map<String, dynamic> newData = {
        UserOptionModel().role: UserOptionModel().roleUser
      };

      await firestore
          .collection(UserOptionModel().collection)
          .doc(user.user!.uid)
          .set(newData);

      //update username menjadi nama user
      await user.user!.updateDisplayName(name);

//Logout terlebih dahulu, agar login ulang
      await logOut();

//mengirim pengembalian
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//controller login
  Future<Response?> login({
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      //memanggil fungsi signin bawaan dari firebase auth
      final user = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

//Mendapatkan data firestore user
      final userFireStore = await firestore
          .collection(UserOptionModel().collection)
          .doc(user.user!.uid)
          .get();

//mengirimkan dalam bentuk model user
      UserModel userData = UserModel();
      userData.role = userFireStore.get(UserOptionModel().role);

      res.data = userData;

//mengirimkan pengembalian
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  //Logout
  Future logOut() async {
    await FirebaseAuth.instance.signOut();
  }

//ctrl logout
  Future<Response?> logOutRes() async {
    Response res = Response();
    try {
      //memanggil signout bawaan dari firebase auth
      await FirebaseAuth.instance.signOut();
      res.message = "Berhasil Keluar";
//mengembalikan respon
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//ctrl update username user
  Future<Response?> updateUsername(String name) async {
    Response res = Response();
    try {
      //memanggil fungsi update bawaan dari firebase auth
      await auth.currentUser!.updateDisplayName(name);
      res.message = "Berhasil mengupdate nama";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//ctrl update foto user
  Future<Response?> updateImage(File? img) async {
    Response res = Response();
    try {
      //upload file img yg dikirim ke storage firebase
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      UploadTask uploadTask = storageReference.putFile(img!);
      await uploadTask.whenComplete(() => print('File Uploaded'));

      String imageUrl = await storageReference.getDownloadURL();

      //memanggil fungsi update bawaan dari firebase auth
      await auth.currentUser!.updatePhotoURL(imageUrl);
      res.message = "Berhasil mengupdate foto";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
