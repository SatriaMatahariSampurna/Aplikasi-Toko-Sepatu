class ProductOptionModel {
  String productCollection = "product";
  String description = "description";
  String brand = "brandId";
  String imageUrl = "imageUrl";
  String active = "active";
  String name = "name";
  String type = "type";
  VariantTypeValOptionModel typeValue = VariantTypeValOptionModel();
  String price = "price";
  String weight = "weight";

  VariantProductOptionModel variant = VariantProductOptionModel();
}

class VariantProductOptionModel {
  String active = "active";
  String variantCollection = "variant";
  String additionalPrice = "additional_price";
  String stock = "stock";
  String color = "color";
  String size = "size";
}

class VariantTypeValOptionModel {
  String man = "man";
  String woman = "woman";
}

class ProductSelected {
  final String idVariant;
  int quantity;
  int additionalPrice;

  ProductSelected({
    required this.idVariant,
    required this.quantity,
    required this.additionalPrice,
  });
}

class ProductModel {
  bool? active;
  String? desc;
  String? type;
  String? brandID;
  String? imageURL;
  String? name;
  int? price;
  int? weight;
  List<VariantProductModel>? variant;

  ProductModel({
    required this.active,
    required this.desc,
    required this.type,
    required this.brandID,
    required this.imageURL,
    required this.name,
    required this.weight,
    required this.price,
    required this.variant,
  });

  Map<String, dynamic> toMap() {
    return {
      ProductOptionModel().active: active,
      ProductOptionModel().description: desc,
      ProductOptionModel().name: name,
      ProductOptionModel().imageUrl: imageURL,
      ProductOptionModel().name: name,
      ProductOptionModel().price: price,
      ProductOptionModel().weight: weight,
      ProductOptionModel().brand: brandID,
      ProductOptionModel().type: type,
    };
  }
}

class VariantProductModel {
  String? id;
  String? color;
  bool? active;
  int? addPrice;
  int? size;
  int? stock;

  VariantProductModel(
      {required this.addPrice,
      required this.stock,
      required this.color,
      required this.size,
      required this.active,
      this.id});
  Map<String, dynamic> toMap() {
    return {
      ProductOptionModel().variant.size: size,
      ProductOptionModel().variant.color: color,
      ProductOptionModel().variant.stock: stock,
      ProductOptionModel().variant.active: active,
      ProductOptionModel().variant.additionalPrice: addPrice,
    };
  }
}

class OrderOptionsFireStore {
  String collection = 'order';
  String dataCol = 'data';
  String amount = 'amount';
  String amountFinal = 'amountFinal';

  String uid = 'uid';
  String weight = 'weight';
  OrderProductOptionsFireStore product = OrderProductOptionsFireStore();
  OrderClientOptionsFireStore client = OrderClientOptionsFireStore();
}

class OrderProductOptionsFireStore {
  String initial = 'Product';

  String id = 'id';
  String initialVariant = 'variant';
  String idvariant = 'id_variant';
  String quantity = 'quantity';
}

class ProductVariantOrderModel {
  String? id;
  int? quantity;

  ProductVariantOrderModel({required this.id, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().product.idvariant: id,
      OrderOptionsFireStore().product.quantity: quantity,
    };
  }
}

//PRODUCT
class ProductOrderModel {
  String? id;
  List<ProductVariantOrderModel>? variant;

  ProductOrderModel({required this.id, required this.variant});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().product.id: id,
      OrderOptionsFireStore().product.initialVariant:
          variant!.map((v) => v.toMap()).toList()
    };
  }
}

class OrderClientOptionsFireStore {
  String initial = 'address';

  String cityId = 'city_id';
  String code = 'code';
  //Mungkin formatnya nanti service-serviceDesc
  String service = 'service';
  String serviceDesc = 'serviceDesc';
  String ongkir = 'ongkir';
  String address = 'detail'; //alamat lengkap
  String name = 'name'; //nama permbeli
  String phone = 'phone'; //telepon permbeli
  String weight = 'weight'; //berat total barang
}

class ClientModel {
  String? cityId;
  String? code;
  int? ongkir;
  String? detail;
  String? name;
  String? phone;
  String? service;
  String? serviceDesc;
  int? weight;

  ClientModel({
    required this.cityId,
    required this.code,
    required this.ongkir,
    required this.detail,
    required this.name,
    required this.phone,
    required this.service,
    required this.serviceDesc,
  });

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().client.cityId: cityId,
      OrderOptionsFireStore().client.code: code,
      OrderOptionsFireStore().client.ongkir: ongkir,
      OrderOptionsFireStore().client.address: detail,
      OrderOptionsFireStore().client.name: name,
      OrderOptionsFireStore().client.phone: phone,
      OrderOptionsFireStore().client.service: service,
      OrderOptionsFireStore().client.serviceDesc: serviceDesc,
    };
  }
}

class OrderModel {
  String? uid;
  int? weight;
  int? amount;
  int? amountFinal;
  ProductOrderModel? product;
  ClientModel? client;

  OrderModel(
      {required this.uid,
      required this.weight,
      required this.product,
      required this.client,
      required this.amountFinal,
      required this.amount});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().uid: uid,
      OrderOptionsFireStore().weight: weight,
      OrderOptionsFireStore().amount: amount,
      OrderOptionsFireStore().amountFinal: amountFinal,
      OrderOptionsFireStore().product.initial: product!.toMap(),
      OrderOptionsFireStore().client.initial: client!.toMap(),
    };
  }
}
