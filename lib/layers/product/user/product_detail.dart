import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/layers/order/user/checkout_screen.dart';
import 'package:toko_sepatu_satria/models/firebase/brand_model.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class Product extends StatefulWidget {
  const Product({super.key, required this.productId});
  final String productId;

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  DocumentSnapshot<Map<String, dynamic>>? product;
  DocumentSnapshot<Map<String, dynamic>>? brand;
  QuerySnapshot<Map<String, dynamic>>? variant;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoad = false;

//list berfungsi semacam cart
  List<ProductSelected> productSelected = [];

  //mendapatkan kuantiti produk dari cart
  int getProductQuantity(String idVariant) {
    int index =
        productSelected.indexWhere((product) => product.idVariant == idVariant);
    if (index != -1) {
      return productSelected[index].quantity;
    } else {
      return 0;
    }
  }

//fungsi untuk mendapatkan seluruh data yang dibutuhkan
  void getData() async {
    setState(() {
      isLoad = true;
    });

    final res = await firestore
        .collection(ProductOptionModel().productCollection)
        .doc(widget.productId)
        .get();
    product = res;
    final resBrand = await firestore
        .collection(BrandOptionModel().col)
        .doc(product!.get(ProductOptionModel().brand))
        .get();
    brand = resBrand;
    final resVariant = await firestore
        .collection(ProductOptionModel().productCollection)
        .doc(widget.productId)
        .collection(ProductOptionModel().variant.variantCollection)
        .where('active', isEqualTo: true)
        .get();

    variant = resVariant;
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

//Fungsi unruk checkout
  void checkout() async {
    productSelected.removeWhere((product) => product.quantity <= 0);
    if (productSelected.isNotEmpty) {
      bool isEligble = true;

      //melakukan validasi apakah produk masih bisa dicheckout dengan ketentuan stok masih ad
      for (var element in productSelected) {
        DocumentSnapshot doc = await firestore
            .collection(ProductOptionModel().productCollection)
            .doc(widget.productId)
            .collection(ProductOptionModel().variant.variantCollection)
            .doc(element.idVariant)
            .get();
        if (!doc.exists) {
          isEligble = false;
        } else {
          if (doc.get(ProductOptionModel().variant.stock) <= 0) {
            isEligble = false;
          }
        }
      }

      //jika aman maka akan di navigasi ke halaman checkout
      if (isEligble) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckOutScreen(
                  variant: productSelected, productId: widget.productId),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Pastikan jumlah produk yang anda pilih sesuai dengan stok",
          ),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Mohon pilih jumlah produk pada salah satu varian",
        ),
      ));
    }
  }

  @override
  void initState() {
    getData();
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
          isLoad ? 'Detail Produk' : product!.get(ProductOptionModel().name),
          overflow: TextOverflow.ellipsis,
          style: fontStyleTitleAppbar(context),
        ),
        actions: [
          IconButton(
              onPressed: checkout, icon: Icon(Icons.shopping_cart_checkout))
        ],
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      product!.get(ProductOptionModel().imageUrl),
                      width: MediaQuery.of(context).size.width,
                      height: isPotrait
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.height * 0.3,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "${AssetsSetting().imagePath}err.png",
                        width: MediaQuery.of(context).size.width,
                        height: isPotrait
                            ? MediaQuery.of(context).size.width * 0.3
                            : MediaQuery.of(context).size.height * 0.3,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Nama Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${product!.get(ProductOptionModel().name)}",
                      style: fontStyleSubtitleDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Harga Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${NumberHelper.convertToIdrWithSymbol(count: product!.get(ProductOptionModel().price), decimalDigit: 0)}",
                      style: fontStyleSubtitleDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Brand :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${brand!.get(BrandOptionModel().nameField)}",
                      style: fontStyleSubtitleDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Tipe Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${product!.get(ProductOptionModel().type) == 'woman' ? 'wanita' : 'pria'}",
                      style: fontStyleSubtitleDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Berat Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${product!.get(ProductOptionModel().weight)} gram",
                      style: fontStyleSubtitleDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Deskripsi Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${product!.get(ProductOptionModel().description)}",
                      style: fontStyleSubtitleDefaultColor(context),
                      // overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Pilih Produk :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: variant!.docs.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var dataVariant = variant!.docs[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${dataVariant.get(ProductOptionModel().variant.color)} (${dataVariant.get(ProductOptionModel().variant.stock)})",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  "Ukuran : ${dataVariant.get(ProductOptionModel().variant.size)}",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  "${NumberHelper.convertToIdrWithSymbol(count: product!.get(ProductOptionModel().price) + dataVariant.get(ProductOptionModel().variant.additionalPrice), decimalDigit: 0)}/item (+ ${NumberHelper.convertToIdrWithSymbol(count: dataVariant.get(ProductOptionModel().variant.additionalPrice), decimalDigit: 0)})",
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    int index = productSelected.indexWhere(
                                        (product) =>
                                            product.idVariant ==
                                            dataVariant.id);

                                    //validasi jika ada
                                    if (index != -1) {
                                      if (productSelected[index].quantity <=
                                          0) {
                                        productSelected.removeWhere((product) =>
                                            product.idVariant ==
                                            dataVariant.id);
                                      } else {
                                        if (dataVariant.get(ProductOptionModel()
                                                .variant
                                                .stock) <
                                            productSelected[index].quantity) {
                                          productSelected[index].quantity =
                                              dataVariant.get(
                                                  ProductOptionModel()
                                                      .variant
                                                      .stock);
                                        } else {
                                          productSelected[index].quantity =
                                              productSelected[index].quantity -
                                                  1;
                                        }
                                      }
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(Icons.remove),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  getProductQuantity(dataVariant.id).toString(),
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    int index = productSelected.indexWhere(
                                        (product) =>
                                            product.idVariant ==
                                            dataVariant.id);

                                    //validasi jika ada
                                    if (index != -1) {
                                      //jika selected dibawah stock maka ditambah 1
                                      if (productSelected[index].quantity <
                                          dataVariant.get(ProductOptionModel()
                                              .variant
                                              .stock)) {
                                        productSelected[index].quantity =
                                            productSelected[index].quantity + 1;
                                      } else {
                                        if (dataVariant.get(ProductOptionModel()
                                                .variant
                                                .stock) >=
                                            1) {
                                          productSelected[index].quantity =
                                              dataVariant.get(
                                                  ProductOptionModel()
                                                      .variant
                                                      .stock);
                                        } else {
                                          productSelected.removeWhere(
                                              (product) =>
                                                  product.idVariant ==
                                                  dataVariant.id);
                                        }
                                      }
                                    } else {
                                      if (dataVariant.get(ProductOptionModel()
                                              .variant
                                              .stock) >=
                                          1) {
                                        ProductSelected newProduct =
                                            ProductSelected(
                                                idVariant: dataVariant.id,
                                                additionalPrice: dataVariant
                                                    .get(ProductOptionModel()
                                                        .variant
                                                        .additionalPrice),
                                                quantity: 1);
                                        productSelected.add(newProduct);
                                      }
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(Icons.add),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
