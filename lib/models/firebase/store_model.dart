class StoreInfoFireStoreOptionModel {
  String storeCollection = 'store';
  StoreInfoLocationFireStoreOptionModel location = StoreInfoLocationFireStoreOptionModel();
  StoreInfoDetailFireStoreOptionModel details = StoreInfoDetailFireStoreOptionModel();
}

class StoreInfoLocationFireStoreOptionModel {
  String locationDoc = 'location';
  String address = 'address';
  String cityIdRo = 'cityId_rajaOngkir';
}

class StoreInfoDetailFireStoreOptionModel {
  String detailsDoc = 'details';
  String name = 'name';
}
