import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/models/response_model.dart';

class OrderController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

//fungsi order
  Future<Response?> order({
    required OrderModel order,
  }) async {
    Response res = Response();
    //mengambil data order yang dikirim dalam bentuk model dan mengkonversi dalam bentuk map
    Map<String, dynamic> newData = order.toMap();
    try {
      await FirebaseFirestore.instance
          .collection(OrderOptionsFireStore().collection)
          .doc()
          .set(newData);

//Melooping data varian untuk mengupdate data variant yg di order
      for (var element in order.product!.variant!) {
        var variant = FirebaseFirestore.instance
            .collection(ProductOptionModel().productCollection)
            .doc(order.product!.id)
            .collection(ProductOptionModel().variant.variantCollection)
            .doc(element.id);

        var variantSnapshot = await variant.get();

        int quanty = variantSnapshot.get(ProductOptionModel().variant.stock) -
            element.quantity;

        await variant.update({ProductOptionModel().variant.stock: quanty});
      }

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
