class CheckOngkirResponseListModel {
  List<CheckOngkirResponseModel>? results;

  CheckOngkirResponseListModel({this.results});

  CheckOngkirResponseListModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <CheckOngkirResponseModel>[];
      json['results'].forEach((v) {
        results!.add(CheckOngkirResponseModel.fromJson(v));
      });
    }
  }
}

class CheckOngkirResponseModel {
  String? code;
  String? name;
  List<CostsCheckOngkirResponseModel>? costs;

  CheckOngkirResponseModel({this.code, this.name, this.costs});

  CheckOngkirResponseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    if (json['costs'] != null) {
      costs = <CostsCheckOngkirResponseModel>[];
      json['costs'].forEach((v) {
        costs!.add(CostsCheckOngkirResponseModel.fromJson(v));
      });
    }
  }
}

class CostsCheckOngkirResponseModel {
  String? service;
  String? description;
  List<CostCheckOngkirResponseModel>? cost;

  CostsCheckOngkirResponseModel({this.service, this.description, this.cost});

  CostsCheckOngkirResponseModel.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    description = json['description'];
    if (json['cost'] != null) {
      cost = <CostCheckOngkirResponseModel>[];
      json['cost'].forEach((v) {
        cost!.add(CostCheckOngkirResponseModel.fromJson(v));
      });
    }
  }
}

class CostCheckOngkirResponseModel {
  int? value;
  String? etd;
  String? note;

  CostCheckOngkirResponseModel({this.value, this.etd, this.note});

  CostCheckOngkirResponseModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    etd = json['etd'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['etd'] = this.etd;
    data['note'] = this.note;
    return data;
  }
}
