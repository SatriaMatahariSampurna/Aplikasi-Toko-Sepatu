import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/models/response_model.dart';

class ProductController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

//Fungsi untuk menonaktifkan produk
  Future<Response?> deleteProduct({
    required String productId,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {ProductOptionModel().active: false};
    try {
      //update produk menjadi false
      var ref = FirebaseFirestore.instance
          .collection(ProductOptionModel().productCollection)
          .doc(productId)
          .update(newData);

      res.message = "Berhasil menghapus produk";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

//Fngsi untuk update/add produk
  Future<Response?> addProduct({
    String? productId,
    List<String>? deletedVarianId,
    required ProductModel product,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = product.toMap();
    try {
      //cek apakah ada id yg dikirim
      if (productId != null) {
        //jika iya maka akan diupdate
        var ref = FirebaseFirestore.instance
            .collection(ProductOptionModel().productCollection)
            .doc(productId);

        await ref.update(newData);

//jika ada varian yg harus dihapus maka akan dinonaktifkan
        for (var element in deletedVarianId!) {
          if (element != '') {
            await FirebaseFirestore.instance
                .collection(ProductOptionModel().productCollection)
                .doc(ref.id)
                .collection(ProductOptionModel().variant.variantCollection)
                .doc(element)
                .update({ProductOptionModel().variant.active: false});
          }
        }

//fungsi untuk update/create varian
        for (var element in product.variant!) {
          //dicek apakah idnya ada, jika ada maka akan diupdate
          if (element.id == null) {
            await FirebaseFirestore.instance
                .collection(ProductOptionModel().productCollection)
                .doc(ref.id)
                .collection(ProductOptionModel().variant.variantCollection)
                .doc()
                .set(element.toMap());
          } else {
            await FirebaseFirestore.instance
                .collection(ProductOptionModel().productCollection)
                .doc(ref.id)
                .collection(ProductOptionModel().variant.variantCollection)
                .doc(element.id)
                .set(element.toMap());
          }
        }
      } else {
        var ref = FirebaseFirestore.instance
            .collection(ProductOptionModel().productCollection)
            .doc();

        await ref.set(newData);

        for (var element in product.variant!) {
          if (element.id == null) {
            await FirebaseFirestore.instance
                .collection(ProductOptionModel().productCollection)
                .doc(ref.id)
                .collection(ProductOptionModel().variant.variantCollection)
                .doc()
                .set(element.toMap());
          } else {
            await FirebaseFirestore.instance
                .collection(ProductOptionModel().productCollection)
                .doc(ref.id)
                .collection(ProductOptionModel().variant.variantCollection)
                .doc(element.id)
                .set(element.toMap());
          }
        }
      }
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
