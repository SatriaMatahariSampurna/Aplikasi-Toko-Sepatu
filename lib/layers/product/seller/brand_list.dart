import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/controllers/brand_controller.dart';
import 'package:toko_sepatu_satria/models/firebase/brand_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class BrandList extends StatefulWidget {
  const BrandList({super.key});

  @override
  State<BrandList> createState() => _BrandListState();
}

class _BrandListState extends State<BrandList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoad = false;

//memanggil fungsi menonaktifkan brand
  void deleteBrand(String brandId) async {
    setState(() {
      isLoad = true;
    });
    var res = await BrandController().delete(brandId: brandId);
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        res!.message ?? "-",
      ),
    ));
  }

//membuka dialog untuk memanage brand dan akhirnya memanggil controller manage brand
  void brandManage(BrandModel? initialBrand) {
    setState(() {
      isLoad = true;
    });
    TextEditingController name = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    BrandModel brand = BrandModel(active: false, name: '');

    if (initialBrand != null) {
      brand = initialBrand;
      name.text = brand.name ?? '-';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Form(
          key: _formKey,
          child: TextFormField(
            validator: (value) => value!.isEmpty ? 'isikan nama brand' : null,
            controller: name,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal")),
          TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  brand.active = true;
                  brand.name = name.text;
                  var res = await BrandController().manage(brand: brand);
                  if (!mounted) return;
                  setState(() {
                    isLoad = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      res!.message ?? "-",
                    ),
                  ));
                }
              },
              child: Text("Simpan"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          brandManage(null);
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ScreenSetting().paddingScreen),
            child: StreamBuilder(
              //memanggil kategori yg aktif
              stream: firestore
                  .collection(BrandOptionModel().col)
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //Melakukan validasi status
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

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'hapus') {
                            if (snapshot.data!.docs[index].id == '-') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Brand default tidak dapat dihapus",
                                ),
                              ));
                            } else {
                              deleteBrand(snapshot.data!.docs[index].id);
                            }
                          } else {
                            brandManage(BrandModel(
                                active: snapshot.data!.docs[index]
                                    .get(BrandOptionModel().active),
                                id: snapshot.data!.docs[index].id,
                                name: snapshot.data!.docs[index]
                                    .get(BrandOptionModel().nameField)));
                          }
                        },
                        itemBuilder: (context) => (<PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(
                                "edit",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                              )),
                          PopupMenuItem<String>(
                              value: 'hapus',
                              child: Text(
                                "Hapus",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                              )),
                        ]),
                      ),
                      title: Text(
                        snapshot.data!.docs[index]
                            .get(BrandOptionModel().nameField),
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
