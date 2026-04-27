class OrderHistoryModel {
  List<OrderHistory>? orderHistory;

  OrderHistoryModel({this.orderHistory});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['orderHistory'] != null) {
      orderHistory = <OrderHistory>[];
      json['orderHistory'].forEach((v) {
        orderHistory!.add(new OrderHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderHistory != null) {
      data['orderHistory'] = this.orderHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderHistory {
  String? orderId;
  String? orderDate;
  String? companyName;
  String? email;
  String? address1;
  String? address2;
  String? address3;
  String? city;
  String? mobileNumber;
  String? totalPrice;
  String? totalVat;
  String? totalAmount;
  List<Items>? items;

  OrderHistory(
      {this.orderId,
      this.orderDate,
      this.companyName,
      this.email,
      this.address1,
      this.address2,
      this.address3,
      this.city,
      this.mobileNumber,
      this.totalPrice,
      this.totalVat,
      this.totalAmount,
      this.items});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    orderId = json['OrderId'];
    orderDate = json['OrderDate'];
    companyName = json['CompanyName'];
    email = json['Email'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    address3 = json['Address3'];
    city = json['City'];
    mobileNumber = json['MobileNumber'];
    totalPrice = json['TotalPrice'];
    totalVat = json['TotalVat'];
    totalAmount = json['TotalAmount'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OrderId'] = this.orderId;
    data['OrderDate'] = this.orderDate;
    data['CompanyName'] = this.companyName;
    data['Email'] = this.email;
    data['Address1'] = this.address1;
    data['Address2'] = this.address2;
    data['Address3'] = this.address3;
    data['City'] = this.city;
    data['MobileNumber'] = this.mobileNumber;
    data['TotalPrice'] = this.totalPrice;
    data['TotalVat'] = this.totalVat;
    data['TotalAmount'] = this.totalAmount;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? nopProductId;
  String? orderDetailID;
  String? itemCode;
  String? itemName;
  String? salePrice;
  String? itemQty;
  String? unit;
  String? newQty;
  String? send;
  String? orgImage;
  String? orderStatus;
  String? image;

  Items(
      {this.nopProductId,
      this.orderDetailID,
      this.itemCode,
      this.itemName,
      this.salePrice,
      this.itemQty,
      this.unit,
      this.newQty,
      this.send,
      this.orgImage,
      this.orderStatus,
      this.image});

  Items.fromJson(Map<String, dynamic> json) {
    nopProductId = json['NopProductId'];
    orderDetailID = json['OrderDetailID'];
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    salePrice = json['SalePrice'];
    itemQty = json['ItemQty'];
    unit = json['Unit'];
    newQty = json['newQty'];
    send = json['send'];
    orgImage = json['orgImage'];
    orderStatus = json['OrderStatus'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NopProductId'] = this.nopProductId;
    data['OrderDetailID'] = this.orderDetailID;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['SalePrice'] = this.salePrice;
    data['ItemQty'] = this.itemQty;
    data['Unit'] = this.unit;
    data['newQty'] = this.newQty;
    data['send'] = this.send;
    data['orgImage'] = this.orgImage;
    data['OrderStatus'] = this.orderStatus;
    data['image'] = this.image;
    return data;
  }
}