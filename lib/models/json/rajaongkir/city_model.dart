class CityRajaOngkirListModel {
  List<CityRajaOngkirModel>? results;

  CityRajaOngkirListModel({this.results});

  CityRajaOngkirListModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <CityRajaOngkirModel>[];
      json['results'].forEach((v) {
        results!.add(CityRajaOngkirModel.fromJson(v));
      });
    }
  }

}


class CityRajaOngkirModel {
  String? cityId;
  String? provinceId;
  String? province;
  String? type;
  String? cityName;
  String? postalCode;

  CityRajaOngkirModel(
      {this.cityId,
      this.provinceId,
      this.province,
      this.type,
      this.cityName,
      this.postalCode});

  CityRajaOngkirModel.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    provinceId = json['province_id'];
    province = json['province'];
    type = json['type'];
    cityName = json['city_name'];
    postalCode = json['postal_code'];
  }


}
