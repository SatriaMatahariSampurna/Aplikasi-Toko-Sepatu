import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key, required this.isSeller});
  final bool isSeller;

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  //Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  bool isLoad = true;
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  void startScreen() async {
    await getUser();
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    startScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: StreamBuilder(
                    stream: widget.isSeller == true
                        ? firestore
                            .collection(OrderOptionsFireStore().collection)
                            .snapshots()
                        : firestore
                            .collection(OrderOptionsFireStore().collection)
                            .where('uid', isEqualTo: user!.uid)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return loadIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Order kamu masih kosong'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          dynamic productDataOrder = snapshot.data!.docs[index]
                              .get(OrderOptionsFireStore().product.initial);
                          dynamic clientData = snapshot.data!.docs[index]
                              .get(OrderOptionsFireStore().client.initial);
                          return StreamBuilder(
                              stream: firestore
                                  .collection(
                                      ProductOptionModel().productCollection)
                                  .doc(productDataOrder[
                                      OrderOptionsFireStore().product.id])
                                  .snapshots(),
                              builder: (context, productData) {
                                if (productData.connectionState ==
                                    ConnectionState.waiting) {
                                  return Card();
                                }

                                if (productData.hasError) {
                                  return Text('Error: ${productData.error}');
                                }

                                if (!productData.hasData) {
                                  return const Center(
                                      child: Text('Produk tidak ditemukan'));
                                }
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      productData.data!
                                          .get(ProductOptionModel().name),
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Total : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                NumberHelper.convertToIdrWithSymbol(
                                                    count: snapshot
                                                        .data!.docs[index]
                                                        .get(
                                                            OrderOptionsFireStore()
                                                                .amount),
                                                    decimalDigit: 0),
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Ongkir : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                NumberHelper
                                                    .convertToIdrWithSymbol(
                                                        count: clientData[
                                                            OrderOptionsFireStore()
                                                                .client
                                                                .ongkir],
                                                        decimalDigit: 0),
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Harga Akhir : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                NumberHelper.convertToIdrWithSymbol(
                                                    count: snapshot
                                                        .data!.docs[index]
                                                        .get(
                                                            OrderOptionsFireStore()
                                                                .amountFinal),
                                                    decimalDigit: 0),
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          children: [
                                            Text(
                                              "Nama : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                clientData[
                                                    OrderOptionsFireStore()
                                                        .client
                                                        .name],
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Nomor : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                clientData[
                                                    OrderOptionsFireStore()
                                                        .client
                                                        .phone],
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Kurir : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${clientData[OrderOptionsFireStore().client.code]} - ${clientData[OrderOptionsFireStore().client.service]} (${clientData[OrderOptionsFireStore().client.serviceDesc]})',
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Alamat : ",
                                              style:
                                                  fontStyleParagraftBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${clientData[OrderOptionsFireStore().client.address]}',
                                                textAlign: TextAlign.end,
                                                style:
                                                    fontStyleParagraftDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Text(
                                          "Order : ",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: productDataOrder[
                                                  OrderOptionsFireStore()
                                                      .product
                                                      .initialVariant]
                                              .length,
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return SizedBox(
                                              height: 5,
                                            );
                                          },
                                          itemBuilder: (BuildContext context,
                                              int indexVariant) {
                                            return StreamBuilder(
                                                stream: firestore
                                                    .collection(
                                                        ProductOptionModel()
                                                            .productCollection)
                                                    .doc(productDataOrder[
                                                        OrderOptionsFireStore()
                                                            .product
                                                            .id])
                                                    .collection(
                                                        ProductOptionModel()
                                                            .variant
                                                            .variantCollection)
                                                    .doc(productDataOrder[
                                                                OrderOptionsFireStore()
                                                                    .product
                                                                    .initialVariant]
                                                            [indexVariant][
                                                        OrderOptionsFireStore()
                                                            .product
                                                            .idvariant])
                                                    .snapshots(),
                                                builder:
                                                    (context, snapsotVariant) {
                                                  if (snapsotVariant
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Text("Load Variant");
                                                  }

                                                  if (snapsotVariant.hasError) {
                                                    return Text(
                                                        'Error: ${snapsotVariant.error}');
                                                  }

                                                  if (!snapsotVariant.hasData) {
                                                    return const Center(
                                                        child: Text(
                                                            'Produk tidak ditemukan'));
                                                  }

                                                  return Column(
                                                    children: [
                                                      Visibility(
                                                          visible:
                                                              indexVariant > 0,
                                                          child: Divider()),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "- Warna : ",
                                                            style:
                                                                fontStyleParagraftBoldDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${snapsotVariant.data!.get(ProductOptionModel().variant.color)}',
                                                              style:
                                                                  fontStyleSubtitleDefaultColor(
                                                                      context),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "  Ukuran : ",
                                                            style:
                                                                fontStyleParagraftBoldDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${snapsotVariant.data!.get(ProductOptionModel().variant.size)}',
                                                              style:
                                                                  fontStyleSubtitleDefaultColor(
                                                                      context),
                                                              maxLines: 1,
                                                              textAlign:
                                                                  TextAlign.end,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "  Jumlah : ",
                                                            style:
                                                                fontStyleParagraftBoldDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${productDataOrder[OrderOptionsFireStore().product.initialVariant][indexVariant][OrderOptionsFireStore().product.quantity].toString()} item',
                                                              style:
                                                                  fontStyleSubtitleDefaultColor(
                                                                      context),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      );
                    }),
              ),
            ),
    );
  }
}
