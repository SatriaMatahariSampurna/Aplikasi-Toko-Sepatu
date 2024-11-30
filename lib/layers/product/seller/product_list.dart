import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/layers/product/seller/product_add.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class ProductListSeller extends StatefulWidget {
  const ProductListSeller({super.key});

  @override
  State<ProductListSeller> createState() => _ProductListSellerState();
}

class _ProductListSellerState extends State<ProductListSeller> {
  String _searchQuery = '';
  TextEditingController searchCtrl = TextEditingController();
//Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageProduct(),
            )),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ScreenSetting().paddingScreen),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Warna bayangan
                        spreadRadius: 2, // Radius penyebaran bayangan
                        blurRadius: 7, // Radius blur bayangan
                        offset: const Offset(
                            0, 8), // Perpindahan bayangan, arah bawah 3 pixel
                      ),
                    ],
                  ),
                  child: TextField(
                    onSubmitted: (value) => setState(() {
                      _searchQuery = searchCtrl.text;
                    }),
                    onEditingComplete: () => setState(() {
                      _searchQuery = searchCtrl.text;
                    }),
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search Produk',
                      suffixIcon: InkWell(
                          onTap: () => setState(() {
                                _searchQuery = searchCtrl.text;
                              }),
                          child: const Icon(Icons.search)),
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 8.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                  stream: firestore
                      .collection(ProductOptionModel().productCollection)
                      .where('active', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loadIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return const Text('Data tidak ditemukan');
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Produk tidak ditemukan, atau kosong'));
                    }

                    List<DocumentSnapshot> filteredDocs =
                        snapshot.data!.docs.where((doc) {
                      String itemName = doc[ProductOptionModel().name]
                          .toString()
                          .toLowerCase();
                      return itemName.contains(_searchQuery);
                    }).toList();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPotrait ? 2 : 4),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageProduct(
                                  productID: filteredDocs[index].id,
                                ),
                              )),
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    filteredDocs[index]
                                        .get(ProductOptionModel().imageUrl),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "${AssetsSetting().imagePath}err.png",
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    filteredDocs[index]
                                        .get(ProductOptionModel().name),
                                    style:
                                        fontStyleSubtitleSemiBoldDefaultColor(
                                            context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    NumberHelper.convertToIdrWithSymbol(
                                        count: filteredDocs[index]
                                            .get(ProductOptionModel().price),
                                        decimalDigit: 0),
                                    style:
                                        fontStyleSubtitleSemiBoldPrimaryColor(
                                            context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
