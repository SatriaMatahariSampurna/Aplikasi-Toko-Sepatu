import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:toko_sepatu_satria/models/json/rajaongkir/check_model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/city_model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/model.dart';
import 'package:toko_sepatu_satria/models/json/rajaongkir/prov_model.dart';
import 'package:toko_sepatu_satria/models/response_model.dart';
import 'package:toko_sepatu_satria/settings/intial_settings.dart';

class RajaOngkirController {
  String domainRajaOngkir = 'https://api.rajaongkir.com/starter';
  String apiKey = '9f6d59ac520aa32144263a9da420f904';

//fungsi untuk get provinsi
  Future<Response> getProvince() async {
    Response apiresponse = Response();
    try {
      //memanggil http
      final response = await http.get(Uri.parse("$domainRajaOngkir/province"),
          headers: {
            'Accept': 'application/json',
            'key': apiKey
          }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));

//megembalikan respon http dalam bentuk model dan di validasi statusnya
      switch (response.statusCode) {
        case 200:
          //disini respon json dari http akan di decode
          apiresponse.data = ProvinceRajaOngkirListModel.fromJson(
              jsonDecode(response.body)[RajaOngkirModelOption().payload]);
          break;
        case 401:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        case 400:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }

  Future<Response> getCity({required String provinceId}) async {
    Response apiresponse = Response();
    try {
      //memanggil http
      final response = await http.get(
          Uri.parse("$domainRajaOngkir/city?province=$provinceId"),
          headers: {
            'Accept': 'application/json',
            'key': apiKey
          }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));
//megembalikan respon http dalam bentuk model dan di validasi statusnya
      switch (response.statusCode) {
        case 200:
          //disini respon json dari http akan di decode
          apiresponse.data = CityRajaOngkirListModel.fromJson(
              jsonDecode(response.body)[RajaOngkirModelOption().payload]);
          break;
        case 401:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        case 400:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }

  Future<Response> checkOngkir(
      {required String cityOriginId,
      required String cityDestinationId,
      required int weight,
      required String courier}) async {
    Response apiresponse = Response();
    try {
      //memanggil http namun dalam bentuk post, karena mengikuti dokumentasi
      final response =
          await http.post(Uri.parse("$domainRajaOngkir/cost"), headers: {
        'Accept': 'application/json',
        'key': apiKey
      }, body: {
        'origin': cityOriginId,
        'destination': cityDestinationId,
        'weight': '$weight',
        'courier': courier,
      }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));

//megembalikan respon http dalam bentuk model dan di validasi statusnya
      switch (response.statusCode) {
        case 200:
          //hasilnya akan di decode
          apiresponse.data = CheckOngkirResponseListModel.fromJson(
              jsonDecode(response.body)[RajaOngkirModelOption().payload]);
          break;
        case 401:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        case 400:
          apiresponse.error =
              jsonDecode(response.body)[RajaOngkirModelOption().payload]
                      [RajaOngkirModelOption().status]
                  [RajaOngkirModelOption().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }
}
