import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_sepatu_satria/models/firebase/brand_model.dart';
import 'package:toko_sepatu_satria/models/response_model.dart';

class BrandController {
  //fungsi menonaktifkan brand
  Future<Response?> delete({
    required String brandId,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {BrandOptionModel().active: false};
    try {
      //update data brand dengan id yang dikirim menjadi false agar tidak muncul saat di get
      var ref = FirebaseFirestore.instance
          .collection(BrandOptionModel().col)
          .doc(brandId)
          .update(newData);

      res.message = "Berhasil menghapus brand";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//fungsi manage brand update/create
  Future<Response?> manage({
    required BrandModel brand,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = brand.toMap();
    try {
      //cek apakah ada brand dengan id yang dikirim, jika ada maka akan diupdate jika tidak akan di buat baru
      if (brand.id != null) {
        // fungsi update
        var ref = FirebaseFirestore.instance
            .collection(BrandOptionModel().col)
            .doc(brand.id);

        await ref.update(newData);

        res.message = 'Berhasil mengupdate brand';
      } else {
        // fungsi buat baru
        var ref =
            FirebaseFirestore.instance.collection(BrandOptionModel().col).doc();

        await ref.set(newData);

        res.message = 'Berhasil menambahkan brand';
      }

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
