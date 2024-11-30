class BrandOptionModel {
  String col = 'brand';
  String nameField = 'name';
  String active = 'active';
}

class BrandModel {
  String? id;
  bool? active;
  String? name;

  BrandModel({required this.active, required this.name, this.id});

  Map<String, dynamic> toMap() {
    return {
      BrandOptionModel().active: active,
      BrandOptionModel().nameField: name,
    };
  }
}
