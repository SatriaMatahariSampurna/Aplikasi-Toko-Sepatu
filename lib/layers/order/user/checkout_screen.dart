// ignore_for_file: use_build_context_synchronously, unnecessary_const

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toko_sepatu_satria/controllers/order_controller.dart';
import 'package:toko_sepatu_satria/controllers/rajaongkir_controller.dart';
import 'package:toko_sepatu_satria/helper/number_helper.dart';
import 'package:toko_sepatu_satria/layers/single%20layers/navbar_user.dart';
import 'package:toko_sepatu_satria/models/firebase/product_model.dart';
import 'package:toko_sepatu_satria/models/firebase/store_model.dart';
import 'package:toko_sepatu_satria/models/json/payment_model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/check_model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/city_model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/prov_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';
import 'package:toko_sepatu_satria/style/font_style.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:toko_sepatu_satria/widget/indicator_widget.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen(
      {super.key, required this.variant, required this.productId});
  final List<ProductSelected> variant;
  final String productId;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoad = false;
  bool isLoadPayment = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  PaymentList? payment;

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();

  List<ProductVariantOrderModel> variantListData = [];

  //RAJA ONGKIR
  ProvinceRajaOngkirListModel provinceData =
      ProvinceRajaOngkirListModel(results: []);
  CityRajaOngkirListModel cityData = CityRajaOngkirListModel(results: []);
  CheckOngkirResponseListModel ongkirData =
      CheckOngkirResponseListModel(results: []);

  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedCourierCode = ''; //code
  String _selectedCourierCost = ''; //service
  String _selectedCourierCostDesc = ''; //serviceDesc

  int amountProduct = 0;
  int amountFinal = 0;
  int ongkir = 0;
  num weightTotal = 0;

  //Mendapatkan list payment dari lokal json
  getPayment() async {
    payment = PaymentList.fromJson(jsonDecode(await rootBundle
        .loadString('${AssetsSetting().jsonPath}payment.json')));
  }

//fungsi Memilih provinsi
  selectProvince() async {
    setState(() {
      isLoad = true;
    });
    await getCity();
  }

//fungsi mendapatkan list kota dengan memanggil controller get city
  getCity() async {
    var res =
        await RajaOngkirController().getCity(provinceId: _selectedProvince);
    if (res.error == null) {
      cityData = CityRajaOngkirListModel(results: []);
      cityData = res.data as CityRajaOngkirListModel;
      _selectedCity = cityData.results![0].cityId ?? '';
      await cekOngkir();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      if (!mounted) return;
      setState(() {
        _selectedCity = '';
        cityData = CityRajaOngkirListModel(results: []);
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

//FUngsi memilih kota
  void selectCity(CityRajaOngkirModel city) async {
    setState(() {
      isLoad = true;
    });
    await cekOngkir();
    if (!mounted) return;
    setState(() {
      address.text =
          'Kab. ${city.cityName}, ${city.province} - ${city.postalCode}';
      isLoad = false;
    });
  }

//fungsi mendapatkan data ongkir dengan memanggil controller cek ongkir
  cekOngkir() async {
    setState(() {
      isLoad = true;
    });

//Mendapatkan lokasi toko
    DocumentSnapshot doc = await firestore
        .collection(StoreInfoFireStoreOptionModel().storeCollection)
        .doc(StoreInfoFireStoreOptionModel().location.locationDoc)
        .get();
    if (!doc.exists) {
      Navigator.pop(context);
    }

    var result = await RajaOngkirController().checkOngkir(
        cityOriginId:
            doc.get(StoreInfoFireStoreOptionModel().location.cityIdRo),
        cityDestinationId: _selectedCity,
        weight: weightTotal.toInt(),
        courier: 'jne');

    if (result.error == null) {
      if (!mounted) return;
      setState(() {
        isLoad = false;

        //Mengupdate data ongkir dengan data dari respon
        ongkirData = result.data as CheckOngkirResponseListModel;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoad = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.error.toString(),
        ),
      ));
    }
  }

//fungsi mendapatkan list provinsi dengan memanggil controller get province
  getProvince() async {
    var res = await RajaOngkirController().getProvince();
    setState(() {
      isLoad = false;
    });
    if (res.error == null) {
      provinceData = res.data as ProvinceRajaOngkirListModel;
      _selectedProvince = provinceData.results![0].provinceId ?? '';
      await getCity();
    } else {
      if (!mounted) return;
      setState(() {
        isLoad = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

//mendapatkan data produk
  DocumentSnapshot<Map<String, dynamic>>? product;

  void start() async {
    setState(() {
      isLoad = true;
    });

    await getPayment();
    await getUser();

    final res = await firestore
        .collection(ProductOptionModel().productCollection)
        .doc(widget.productId)
        .get();
    if (!res.exists) {
      Navigator.pop(context);
    }

    product = res;

//mendapatkan data varian yg dipilih
    for (var element in widget.variant) {
      variantListData.add(ProductVariantOrderModel(
          id: element.idVariant, quantity: element.quantity));
      int total =
          (product!.get(ProductOptionModel().price) + element.additionalPrice) *
              element.quantity;
      weightTotal = weightTotal +
          (product!.get(ProductOptionModel().weight) * element.quantity);
      amountProduct = amountProduct + total;
    }

//memanggil fungsi mendapatkan provinsi
    await getProvince();

    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  User? user;
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

//fungsi untuk demo pembayaran
  void pay() async {
    setState(() {
      isLoadPayment = true;
    });

//Memanggil fungsi create order
    var res = await OrderController().order(
      order: OrderModel(
        amountFinal: amountFinal,
        amount: amountProduct,
        weight: weightTotal.toInt(),
        client: ClientModel(
            cityId: _selectedCity,
            code: _selectedCourierCode,
            ongkir: ongkir,
            detail: address.text,
            name: name.text,
            phone: phone.text,
            service: _selectedCourierCost,
            serviceDesc: _selectedCourierCostDesc),
        product:
            ProductOrderModel(id: widget.productId, variant: variantListData),
        uid: user!.uid,
      ),
    );

//menerima respon
    if (res!.error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NavbarUser(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: const Text(
          "Berhasil membuat order",
        ),
      ));
    } else {
      if (!mounted) return;
      setState(() {
        isLoadPayment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

  @override
  void initState() {
    start();
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
          'CheckOut',
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : isLoadPayment
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Memproses Pembayaran...",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "(ini hanyalah contoh demo pembayaran)",
                        style: fontStyleParagraftDefaultColor(context),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Berat total : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: Text(
                                  "$weightTotal gram",
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Penerima : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: TextFormField(
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  validator: (value) => value!.isEmpty
                                      ? 'isi nama penerima paket'
                                      : null,
                                  controller: name,
                                  decoration: const InputDecoration(
                                      hintText: "Nama Penerima"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Nomor : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: TextFormField(
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value!.isEmpty
                                      ? 'isi nomor penerima paket'
                                      : null,
                                  controller: phone,
                                  decoration: const InputDecoration(
                                      hintText: "Nomor Penerima"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButton<String>(
                              value: _selectedProvince,
                              onChanged: (String? newValue) {
                                _selectedProvince = newValue!;
                                selectProvince();
                              },
                              hint: Text(
                                "Tidak Ditemukan Provinsi",
                                style: fontStyleParagraftDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isExpanded: true,
                              items: provinceData.results!
                                  .map<DropdownMenuItem<String>>(
                                      (ProvinceRajaOngkirModel value) {
                                return DropdownMenuItem<String>(
                                  value: value.provinceId,
                                  child: Text(
                                    value.province!,
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButton<String>(
                              value: _selectedCity,
                              onChanged: (String? newValue) {
                                _selectedCity = newValue!;
                                selectCity(cityData.results!.singleWhere(
                                    (element) =>
                                        element.cityId == _selectedCity));
                              },
                              hint: Text(
                                "Tidak Ditemukan Kota",
                                style: fontStyleParagraftDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isExpanded: true,
                              items: cityData.results!
                                  .map<DropdownMenuItem<String>>(
                                      (CityRajaOngkirModel value) {
                                return DropdownMenuItem<String>(
                                  value: value.cityId,
                                  child: Text(
                                    "${value.cityName} - ${value.postalCode}",
                                    style:
                                        fontStyleParagraftDefaultColor(context),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Alamat : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: TextFormField(
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  maxLines: 2,
                                  validator: (value) => value!.isEmpty
                                      ? 'isi detail alamat lengkap'
                                      : null,
                                  controller: address,
                                  decoration: const InputDecoration(
                                      hintText: "Detail alamat"),
                                ),
                              ),
                            ],
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ongkirData.results!.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return ExpansionTile(
                                title: Text(
                                  ongkirData.results![index].name ?? "",
                                  style: fontStyleParagraftBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: ongkirData
                                        .results![index].costs!.length,
                                    itemBuilder:
                                        (BuildContext context, int iChild) {
                                      return Row(
                                        children: [
                                          Checkbox(
                                            value: _selectedCourierCode ==
                                                    ongkirData
                                                        .results![index].code &&
                                                _selectedCourierCost ==
                                                    ongkirData.results![index]
                                                        .costs![iChild].service,
                                            onChanged: (bool? newValue) {
                                              _selectedCourierCode = ongkirData
                                                      .results![index].code ??
                                                  "";
                                              _selectedCourierCost = ongkirData
                                                      .results![index]
                                                      .costs![iChild]
                                                      .service ??
                                                  "";
                                              _selectedCourierCostDesc =
                                                  ongkirData
                                                          .results![index]
                                                          .costs![iChild]
                                                          .description ??
                                                      "";
                                              ongkir = ongkirData
                                                  .results![index]
                                                  .costs![iChild]
                                                  .cost![0]
                                                  .value!
                                                  .toInt();
                                              amountFinal =
                                                  amountProduct + ongkir;
                                              setState(() {});
                                            },
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${ongkirData.results![index].costs![iChild].service} - ${ongkirData.results![index].costs![iChild].description}',
                                                style:
                                                    fontStyleParagraftBoldDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${NumberHelper.convertToIdrWithSymbol(count: ongkirData.results![index].costs![iChild].cost![0].value, decimalDigit: 0)} | ${ongkirData.results![index].costs![iChild].cost![0].etd} hari',
                                                style:
                                                    fontStyleParagraftBoldDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Harga total pembelian : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: Text(
                                  NumberHelper.convertToIdrWithSymbol(
                                      count: amountProduct, decimalDigit: 0),
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Harga akhir : ",
                                style:
                                    fontStyleParagraftBoldDefaultColor(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(
                                child: Text(
                                  NumberHelper.convertToIdrWithSymbol(
                                      count: amountFinal, decimalDigit: 0),
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Pilih Pembayaran : ",
                            style: fontStyleTitleH3DefaultColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isPotrait ? 2 : 4),
                            itemCount: payment!.listPayment!.length,
                            itemBuilder: (context, index) => InkWell(
                              onTap: user != null
                                  ? _selectedCity == ""
                                      ? null
                                      : _selectedCourierCode == ""
                                          ? null
                                          : _selectedCourierCost == ""
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    pay();
                                                  }
                                                }
                                  : null,
                              child: Card(
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        payment!.listPayment![index].icon ?? '',
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "${AssetsSetting().imagePath}err.png",
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        payment!.listPayment![index].name ??
                                            '-',
                                        style:
                                            fontStyleSubtitleSemiBoldDefaultColor(
                                                context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
