// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String itemId;
  String name;
  double price;
  String category;
  String imageUrl;
  String color;
  int quantity;

  Item({
    required this.itemId,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.color,
    this.quantity = 1,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemId = doc.id;
    final name = data['name'] as String;
    final price = (data['price'] as num).toDouble();
    final category = data['category'] as String;
    final imageUrl = data['imageUrl'] as String;
    final color = data['color'] as String;
    return Item(
      itemId: itemId,
      name: name,
      price: price,
      category: category,
      imageUrl: imageUrl,
      color: color, 
      quantity: 1,
    );
  }

  Item copyWith({
    String? itemId,
    String? name,
    double? price,
    String? category,
    String? imageUrl,
    String? color,
    int? quantity,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemId': itemId,
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'color': color,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String,
      color: map['color'] as String,
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Item(itemId: $itemId, name: $name, price: $price, category: $category, imageUrl: $imageUrl, color: $color, quantity: $quantity)';
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;
  
    return 
      other.itemId == itemId &&
      other.name == name &&
      other.price == price &&
      other.category == category &&
      other.imageUrl == imageUrl &&
      other.color == color &&
      other.quantity == quantity;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
      name.hashCode ^
      price.hashCode ^
      category.hashCode ^
      imageUrl.hashCode ^
      color.hashCode ^
      quantity.hashCode;
  }
}
