

class ProductVariants {

  final int productVariantId;
  final String baseProduct;
  final String size;
  final double unitValue;
  final String color;
  final double surcharge;
  final double price;
  final int quantity;

  ProductVariants(
      {this.productVariantId,
      this.baseProduct,
      this.size,
      this.unitValue,
      this.color,
      this.surcharge,
      this.price,
      this.quantity});

  factory ProductVariants.fromMap(Map<String, dynamic> map) {
    return new ProductVariants(
      productVariantId: map['productVariantId'] as int,
      baseProduct: map['baseProduct'] as String,
      size: map['size'] as String,
      unitValue: map['unitValue'] as double,
      color: map['color'] as String,
      surcharge: map['surcharge'] as double,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'productVariantId': this.productVariantId,
      'baseProduct': this.baseProduct,
      'size': this.size,
      'unitValue': this.unitValue,
      'color': this.color,
      'surcharge': this.surcharge,
      'price': this.price,
      'quantity': this.quantity,
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariants &&
          runtimeType == other.runtimeType &&
          productVariantId == other.productVariantId &&
          baseProduct == other.baseProduct &&
          size == other.size &&
          unitValue == other.unitValue &&
          color == other.color &&
          surcharge == other.surcharge &&
          price == other.price &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      productVariantId.hashCode ^
      baseProduct.hashCode ^
      size.hashCode ^
      unitValue.hashCode ^
      color.hashCode ^
      surcharge.hashCode ^
      price.hashCode ^
      quantity.hashCode;

  @override
  String toString() {
    return 'ProductVariants{productVariantId: $productVariantId, baseProduct: $baseProduct, size: $size, unitValue: $unitValue, color: $color, surcharge: $surcharge, price: $price, quantity: $quantity}';
  }
}

