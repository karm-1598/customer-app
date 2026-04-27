class ItemHistoryModel {
  List<OrderItemHistory>? orderItemHistory;

  ItemHistoryModel({this.orderItemHistory});

  ItemHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['orderItemHistory'] != null) {
      orderItemHistory = <OrderItemHistory>[];
      json['orderItemHistory'].forEach((v) {
        orderItemHistory!.add(new OrderItemHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderItemHistory != null) {
      data['orderItemHistory'] =
          this.orderItemHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderItemHistory {
  String? itemName;
  String? itemCode;
  String? lastTime;
  String? salePrice;
  String? itemQty;
  String? unit;
  String? company;
  String? newQty;
  String? orgImage;
  String? nopProductId;
  String? image;

  OrderItemHistory(
      {this.itemName,
      this.itemCode,
      this.lastTime,
      this.salePrice,
      this.itemQty,
      this.unit,
      this.company,
      this.newQty,
      this.orgImage,
      this.nopProductId,
      this.image});

  OrderItemHistory.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    itemCode = json['ItemCode'];
    lastTime = json['LastTime'];
    salePrice = json['SalePrice'];
    itemQty = json['ItemQty'];
    unit = json['Unit'];
    company = json['Company'];
    newQty = json['newQty'];
    orgImage = json['orgImage'];
    nopProductId = json['NopProductId'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemName'] = this.itemName;
    data['ItemCode'] = this.itemCode;
    data['LastTime'] = this.lastTime;
    data['SalePrice'] = this.salePrice;
    data['ItemQty'] = this.itemQty;
    data['Unit'] = this.unit;
    data['Company'] = this.company;
    data['newQty'] = this.newQty;
    data['orgImage'] = this.orgImage;
    data['NopProductId'] = this.nopProductId;
    data['image'] = this.image;
    return data;
  }
}