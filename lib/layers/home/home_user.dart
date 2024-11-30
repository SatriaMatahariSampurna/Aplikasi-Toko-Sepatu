import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/layers/product/user/product_detail.dart';
import 'package:toko_sepatu_satria/models/firebase/brand_model.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedGender = '';
  TextEditingController searchCtrl = TextEditingController();
  //membuat list untuk dropdown gender
  List<Map<String, String>> type = [
    {'val': '', 'display': '- Pilih Gender -'},
    {'val': ProductOptionModel().typeValue.man, 'display': 'Pria'},
    {'val': ProductOptionModel().typeValue.woman, 'display': 'Perempuan'},
  ];
  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Eksplor produk",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ScreenSetting().paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  //jika submit maka query untuk filter diubah menjadi value textfield
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
              const SizedBox(
                height: 20,
              ),
              DropdownButton<String>(
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                hint: Text(
                  "Pilih tipe jenis kelamin",
                  style: fontStyleParagraftDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                isExpanded: true,
                items: type
                    .map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value['val'].toString(),
                    child: Text(
                      value['display'].toString(),
                      style: fontStyleParagraftDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  //melakukan get produk yang aktif
                  stream: firestore
                      .collection(BrandOptionModel().col)
                      .where('active', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshotBrand) {
                    if (snapshotBrand.connectionState ==
                        ConnectionState.waiting) {
                      return loadIndicator();
                    }

                    if (snapshotBrand.hasError) {
                      return Text('Error: ${snapshotBrand.error}');
                    }

                    if (!snapshotBrand.hasData) {
                      return const Text('Data tidak ditemukan');
                    }

                    if (snapshotBrand.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Produk tidak ditemukan, atau kosong'));
                    }

                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshotBrand.data!.docs.length,
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshotBrand.data!.docs[index]
                                    .get(BrandOptionModel().nameField),
                                style: fontStyleSubtitleSemiBoldDefaultColor(
                                    context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: isPotrait
                                    ? MediaQuery.of(context).size.height * 0.2
                                    : MediaQuery.of(context).size.width * 0.2,
                                width: MediaQuery.of(context).size.width,
                                child: StreamBuilder(
                                  stream: firestore
                                      .collection(ProductOptionModel()
                                          .productCollection)
                                      .where(ProductOptionModel().brand,
                                          isEqualTo: snapshotBrand
                                              .data!.docs[index].id)
                                      .where('active', isEqualTo: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
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
                                          child: Text(
                                              'Produk tidak ditemukan, atau kosong'));
                                    }

                                    List<DocumentSnapshot> filteredDocs =
                                        snapshot.data!.docs.where((doc) {
                                      String itemName =
                                          doc[ProductOptionModel().name]
                                              .toString()
                                              .toLowerCase();
                                      String itemGender =
                                          doc[ProductOptionModel().type]
                                              .toString();
                                      if (_selectedGender.isEmpty) {
                                        return itemName.contains(_searchQuery);
                                      } else {
                                        return itemName
                                                .contains(_searchQuery) &&
                                            itemGender == _selectedGender;
                                      }
                                    }).toList();

                                    return ListView.separated(
                                      itemCount: filteredDocs.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const SizedBox(
                                          width: 20,
                                        );
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        // index = 0;
                                        return InkWell(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Product(
                                                    productId:
                                                        filteredDocs[index].id),
                                              )),
                                          child: SizedBox(
                                            width: isPotrait
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45,
                                            child: Card(
                                              color: Colors.white,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: Image.network(
                                                      filteredDocs[index].get(
                                                          ProductOptionModel()
                                                              .imageUrl),
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        "${AssetsSetting().imagePath}err.png",
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    title: Text(
                                                      filteredDocs[index].get(
                                                          ProductOptionModel()
                                                              .name),
                                                      style:
                                                          fontStyleSubtitleSemiBoldDefaultColor(
                                                              context),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    subtitle: Text(
                                                      NumberHelper
                                                          .convertToIdrWithSymbol(
                                                              count: filteredDocs[
                                                                      index]
                                                                  .get(ProductOptionModel()
                                                                      .price),
                                                              decimalDigit: 0),
                                                      style:
                                                          fontStyleSubtitleSemiBoldPrimaryColor(
                                                              context),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        });
                  }),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Semua Produk : ",
                style: fontStyleSubtitleSemiBoldDefaultColor(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 10,
              ),
              //melakukan get produk yang aktif
              StreamBuilder(
                stream: firestore
                    .collection(ProductOptionModel().productCollection)
                    .where('active', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  //Validasi datanya dalam status apa
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

//Melakukan filtering data
                  List<DocumentSnapshot> filteredDocs =
                      snapshot.data!.docs.where((doc) {
                    String itemName =
                        doc[ProductOptionModel().name].toString().toLowerCase();
                    String itemGender =
                        doc[ProductOptionModel().type].toString();
                    if (_selectedGender.isEmpty) {
                      return itemName.contains(_searchQuery);
                    } else {
                      return itemName.contains(_searchQuery) &&
                          itemGender == _selectedGender;
                    }
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
                              builder: (context) =>
                                  Product(productId: filteredDocs[index].id),
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    "${AssetsSetting().imagePath}err.png",
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  filteredDocs[index]
                                      .get(ProductOptionModel().name),
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  NumberHelper.convertToIdrWithSymbol(
                                      count: filteredDocs[index]
                                          .get(ProductOptionModel().price),
                                      decimalDigit: 0),
                                  style: fontStyleSubtitleSemiBoldPrimaryColor(
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
    );
  }
}
