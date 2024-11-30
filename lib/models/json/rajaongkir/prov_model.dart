class ProvinceRajaOngkirListModel {
  List<ProvinceRajaOngkirModel>? results;

  ProvinceRajaOngkirListModel({this.results});

  ProvinceRajaOngkirListModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ProvinceRajaOngkirModel>[];
      json['results'].forEach((v) {
        results!.add(ProvinceRajaOngkirModel.fromJson(v));
      });
    }
  }
}

class ProvinceRajaOngkirModel {
  String? provinceId;
  String? province;

  ProvinceRajaOngkirModel({this.provinceId, this.province});

  ProvinceRajaOngkirModel.fromJson(Map<String, dynamic> json) {
    provinceId = json['province_id'];
    province = json['province'];
  }
}
