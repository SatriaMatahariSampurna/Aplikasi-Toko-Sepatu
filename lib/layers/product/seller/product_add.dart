import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_sepatu_satria/controllers/product_controller.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/models/firebase/brand_model.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/settings/theme_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class ManageProduct extends StatefulWidget {
  const ManageProduct({super.key, this.productID});
  final String? productID;

  @override
  State<ManageProduct> createState() => _ManageProductState();
}

class _ManageProductState extends State<ManageProduct> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoad = false;
  //inisialisasi varian secara default
  List<VariantProductModel> variantList = [
    VariantProductModel(
      addPrice: 0,
      stock: 0,
      size: 0,
      color: 'default',
      active: true,
    )
  ];

//fungsi cek apakah input text yang dimasukkan itu angka
  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return int.tryParse(str) != null;
  }

  //IMAGE
  File? _imageFile;

//fungsi untuk membuka modal image piker
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  setState(() {
                    isLoad = true;
                  });
                  await _pickImageFromGallery();
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  setState(() {
                    isLoad = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  setState(() {
                    isLoad = true;
                  });
                  await _pickImageFromCamera();
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  setState(() {
                    isLoad = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

//fungsi untuk pick image dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

//fungsi untuk pick image dari kamera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

//form
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //current product

  DocumentSnapshot<Map<String, dynamic>>? currentProduct;
//variant
  String _selectedBrand = '-';
  String _selectedType = ProductOptionModel().typeValue.man;
  List<Map<String, String>> type = [
    {'val': ProductOptionModel().typeValue.man, 'display': 'Pria'},
    {'val': ProductOptionModel().typeValue.woman, 'display': 'Perempuan'},
  ];
  List<String> deletedVarianId = [];

//fungsi submit dan upload image ke storage, submit memanggil controller manage produk
  void submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null ||
          (currentProduct != null &&
              currentProduct!.get(ProductOptionModel().imageUrl) != null)) {
        if (variantList.isNotEmpty) {
          setState(() {
            isLoad = true;
          });
          String imageUrl = '';
          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

            UploadTask uploadTask = storageReference.putFile(_imageFile!);
            await uploadTask.whenComplete(() => print('File Uploaded'));
            imageUrl = await storageReference.getDownloadURL();
          } else {
            imageUrl = currentProduct!.get(ProductOptionModel().imageUrl) ?? '';
          }

          if (imageUrl != '') {
            var res = await ProductController().addProduct(
                productId: widget.productID,
                deletedVarianId: deletedVarianId,
                product: ProductModel(
                    brandID: _selectedBrand,
                    type: _selectedType,
                    active: true,
                    desc: detail.text,
                    imageURL: imageUrl,
                    name: name.text,
                    weight: int.parse(weight.text),
                    price: int.parse(price.text),
                    variant: variantList));

            if (res!.error == null) {
              setState(() {
                isLoad = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  res.error ?? 'Berhasil mengupload produk',
                ),
              ));
            } else {
              setState(() {
                isLoad = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  res.error ?? 'Gagal mengupload produk',
                ),
              ));
            }
          } else {
            setState(() {
              isLoad = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Gagal mengupload image",
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "isi variant minimal 1",
            ),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "pilih gambar",
          ),
        ));
      }
    }
  }

//fungsi untuk menambahkan variant. dengan input ke list variant
  void addVariant(VariantProductModel? initialVariant) {
    TextEditingController variantName = TextEditingController();
    TextEditingController variantPrice = TextEditingController();
    TextEditingController variantSize = TextEditingController();
    TextEditingController variantStock = TextEditingController();

    if (initialVariant != null) {
      variantName.text = initialVariant.color ?? "";
      variantSize.text = '${initialVariant.size ?? 0}';
      variantPrice.text = '${initialVariant.addPrice ?? 0}';
      variantStock.text = '${initialVariant.stock ?? 0}';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: IntrinsicHeight(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Warna : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantName,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Ukuran : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantSize,
                  keyboardType: TextInputType.number,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Harga tambahan : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantPrice,
                  keyboardType: TextInputType.number,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Stok : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantStock,
                  keyboardType: TextInputType.number,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 13,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: fontStyleSubtitleSemiBoldDangerColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        if (isNumeric(variantPrice.text) &&
                            isNumeric(variantStock.text) &&
                            isNumeric(variantSize.text)) {
                          if (initialVariant != null) {
                            variantList.removeWhere((element) =>
                                element.color == initialVariant.color &&
                                element.size == initialVariant.size &&
                                element.stock == initialVariant.stock &&
                                element.addPrice == initialVariant.addPrice &&
                                element.id == initialVariant.id);
                            variantList.add(VariantProductModel(
                                active: true,
                                id: initialVariant.id,
                                size: int.parse(variantSize.text),
                                addPrice: int.parse(variantPrice.text),
                                stock: int.parse(variantStock.text),
                                color: variantName.text));
                          } else {
                            variantList.add(VariantProductModel(
                                active: true,
                                size: int.parse(variantSize.text),
                                addPrice: int.parse(variantPrice.text),
                                stock: int.parse(variantStock.text),
                                color: variantName.text));
                          }
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Ukuran, Stock, harga tambahan harus angka",
                            ),
                          ));
                        }
                      },
                      child: Text(
                        "Submit",
                        style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

//fungsi untuk mendapatkan produk jika ada produk id yg dikirim, jika tidak maka akan dilewatkan
  getCurrentProduct() async {
    setState(() {
      isLoad = true;
    });
    var snapshot = await firestore
        .collection(ProductOptionModel().productCollection)
        .doc(widget.productID)
        .get();
    var variantSnapshot = await firestore
        .collection(ProductOptionModel().productCollection)
        .doc(widget.productID)
        .collection(ProductOptionModel().variant.variantCollection)
        .where('active', isEqualTo: true)
        .get();

    currentProduct = snapshot;

    if (currentProduct != null) {
      name.text = '${currentProduct!.get(ProductOptionModel().name)}';
      price.text = '${currentProduct!.get(ProductOptionModel().price)}';
      weight.text = '${currentProduct!.get(ProductOptionModel().weight)}';
      _selectedBrand = '${currentProduct!.get(ProductOptionModel().brand)}';
      _selectedType = '${currentProduct!.get(ProductOptionModel().type)}';
      detail.text = '${currentProduct!.get(ProductOptionModel().description)}';
      if (variantSnapshot.docs.length > 0) {
        variantList.clear();
        for (var element in variantSnapshot.docs) {
          variantList.add(VariantProductModel(
              active: true,
              id: element.id,
              addPrice:
                  element.get(ProductOptionModel().variant.additionalPrice),
              stock: element.get(ProductOptionModel().variant.stock),
              size: element.get(ProductOptionModel().variant.size),
              color: element.get(ProductOptionModel().variant.color)));
        }
      }
    }
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    if (widget.productID != null) {
      getCurrentProduct();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Tambah Produk",
          style: fontStyleTitleAppbar(context),
        ),
        actions: [
          Visibility(
            visible: !isLoad,
            child: IconButton(
                onPressed: submit,
                icon: Icon(
                  Icons.check,
                  color: GetTheme().primaryColor(context),
                )),
          )
        ],
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showPicker(context),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: MediaQuery.of(context).size.width,
                              height: isPotrait
                                  ? MediaQuery.of(context).size.width * 0.3
                                  : MediaQuery.of(context).size.height * 0.3,
                            )
                          : currentProduct != null
                              ? Image.network(
                                  currentProduct!
                                      .get(ProductOptionModel().imageUrl),
                                  width: MediaQuery.of(context).size.width,
                                  height: isPotrait
                                      ? MediaQuery.of(context).size.width * 0.3
                                      : MediaQuery.of(context).size.height *
                                          0.3,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    "${AssetsSetting().imagePath}err.png",
                                    width: MediaQuery.of(context).size.width,
                                    height: isPotrait
                                        ? MediaQuery.of(context).size.width *
                                            0.3
                                        : MediaQuery.of(context).size.height *
                                            0.3,
                                  ),
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: isPotrait
                                      ? MediaQuery.of(context).size.width * 0.3
                                      : MediaQuery.of(context).size.height *
                                          0.3,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Ketuk untuk upload gambar",
                                      textAlign: TextAlign.center,
                                      style: fontStyleParagraftDefaultColor(
                                          context),
                                    ),
                                  ), // Ganti dengan widget anak yang sesuai
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
                    TextFormField(
                      controller: name,
                      validator: (value) =>
                          value!.isEmpty ? "isi nama produk" : null,
                      style: fontStyleParagraftDefaultColor(context),
                      decoration: InputDecoration(hintText: 'nama Produk'),
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
                    TextFormField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      validator: (value) => !isNumeric(value ?? "")
                          ? "harga produk hanya angka"
                          : null,
                      style: fontStyleParagraftDefaultColor(context),
                      decoration: InputDecoration(hintText: 'harga Produk'),
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
                    StreamBuilder(
                        stream: firestore
                            .collection(BrandOptionModel().col)
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

                          if (snapshot.data == null) {
                            return const Center(
                                child:
                                    Text('Brand tidak ditemukan, atau kosong'));
                          }

                          return SizedBox(
                            width: double.infinity,
                            child: DropdownButton<String>(
                              value: _selectedBrand,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedBrand = newValue!;
                                });
                              },
                              hint: Text(
                                "Pilih Brand",
                                style: fontStyleParagraftDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isExpanded: true,
                              items: snapshot.data!.docs
                                  .map<DropdownMenuItem<String>>(
                                      (QueryDocumentSnapshot value) {
                                return DropdownMenuItem<String>(
                                  value: value.id,
                                  child: Text(
                                    value.get(BrandOptionModel().nameField),
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Tipe :",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: _selectedType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue!;
                          });
                        },
                        hint: Text(
                          "Pilih tipe jenis kelamin",
                          style: fontStyleParagraftDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isExpanded: true,
                        items: type.map<DropdownMenuItem<String>>(
                            (Map<String, String> value) {
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
                    TextFormField(
                      controller: weight,
                      keyboardType: TextInputType.number,
                      validator: (value) => !isNumeric(value ?? "")
                          ? "berat produk hanya angka"
                          : null,
                      style: fontStyleParagraftDefaultColor(context),
                      decoration:
                          InputDecoration(hintText: 'berat produk/gram'),
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
                    TextFormField(
                      controller: detail,
                      style: fontStyleParagraftDefaultColor(context),
                      maxLines: 5,
                      decoration: InputDecoration(hintText: 'detail produk'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Varian : ",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                            onPressed: () => addVariant(null),
                            icon: Icon(Icons.add))
                      ],
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: variantList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'hapus') {
                                setState(() {
                                  if (variantList[index].id != null) {
                                    deletedVarianId
                                        .add(variantList[index].id ?? "");
                                  }
                                  variantList.removeAt(index);
                                });
                              } else {
                                addVariant(variantList[index]);
                              }
                            },
                            itemBuilder: (context) => (<PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text(
                                    "edit",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                  )),
                              PopupMenuItem<String>(
                                  value: 'hapus',
                                  child: Text(
                                    "Hapus",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                  )),
                            ]),
                          ),
                          title: Text(
                            '${variantList[index].color ?? ""}',
                            style:
                                fontStyleSubtitleSemiBoldPrimaryColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Ukuran : ",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: Text(
                                      variantList[index].size.toString(),
                                      style: fontStyleParagraftDefaultColor(
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
                                    "Stok : ",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: Text(
                                      variantList[index].stock.toString(),
                                      style: fontStyleParagraftDefaultColor(
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
                                    "Harga Tambahan : ",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: Text(
                                      NumberHelper.convertToIdrWithSymbol(
                                          count: variantList[index].addPrice,
                                          decimalDigit: 0),
                                      style: fontStyleParagraftDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Visibility(
                      visible: currentProduct != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "*jika anda mengubah harga/berat/harga tambahan, maka data order yg masuk sebelum anda edit akan mengikuti data sebelumnya",
                            style: fontStyleParagraftDefaultColor(context),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                var res = await ProductController()
                                    .deleteProduct(
                                        productId: widget.productID ?? "");
                                if (res!.error == null) {
                                  Navigator.pop(context);
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    res.message ?? "-",
                                  ),
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 0,
                                  backgroundColor:
                                      GetTheme().errorColor(context)),
                              child: Text(
                                "Hapus Produk",
                                style: fontStyleSubtitleSemiBoldWhiteColor(
                                    context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }
}
