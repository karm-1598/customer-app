class WishlistProducts {
  List<Product>? product;

  WishlistProducts({this.product});

  WishlistProducts.fromJson(Map<String, dynamic> json) {
    if (json['product'] != null) {
      product = <Product>[];
      json['product'].forEach((v) {
        product!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.product != null) {
      data['product'] = product!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  String? cartId;
  String? customerId;
  String? categoryId;
  String? productId;
  String? name;
  String? sku;
  String? quantity;
  String? unit;
  String? price;
  String? attributesXml;
  String? attributeName;
  String? attributeValueName;
  String? attributeImageUrl;
  String? image;
  String? totalPrice;

  Product(
      {this.cartId,
      this.customerId,
      this.categoryId,
      this.productId,
      this.name,
      this.sku,
      this.quantity,
      this.unit,
      this.price,
      this.attributesXml,
      this.attributeName,
      this.attributeValueName,
      this.attributeImageUrl,
      this.image,
      this.totalPrice});

  Product.fromJson(Map<String, dynamic> json) {
    cartId = json['CartId'];
    customerId = json['customerId'];
    categoryId = json['categoryId'];
    productId = json['productId'];
    name = json['name'];
    sku = json['sku'];
    quantity = json['quantity'];
    unit = json['unit'];
    price = json['price'];
    attributesXml = json['AttributesXml'];
    attributeName = json['AttributeName'];
    attributeValueName = json['AttributeValueName'];
    attributeImageUrl = json['AttributeImageUrl'];
    image = json['image'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['CartId'] = cartId;
    data['customerId'] = customerId;
    data['categoryId'] = categoryId;
    data['productId'] = productId;
    data['name'] = name;
    data['sku'] = sku;
    data['quantity'] = quantity;
    data['unit'] = unit;
    data['price'] = price;
    data['AttributesXml'] = attributesXml;
    data['AttributeName'] = attributeName;
    data['AttributeValueName'] = attributeValueName;
    data['AttributeImageUrl'] = attributeImageUrl;
    data['image'] = image;
    data['totalPrice'] = totalPrice;
    return data;
  }
}