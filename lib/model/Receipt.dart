// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'package:nelayanpos/model/Item.dart';

class Receipt {
  final String receiptId;
  final String uid;
  final String name;
  final Timestamp created_at;
  final List<Item> items;
  
  Receipt({
    required this.receiptId,
    required this.uid,
    required this.name,
    required this.created_at,
    required this.items,
  });

  Receipt copyWith({
    String? receiptId,
    String? uid,
    String? name,
    Timestamp? created_at,
    List<Item>? items,
  }) {
    return Receipt(
      receiptId: receiptId ?? this.receiptId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      created_at: created_at ?? this.created_at,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'receiptId': receiptId,
      'uid': uid,
      'name': name,
      'created_at': created_at,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      receiptId: map['receiptId'] as String,
      uid: map['uid'] as String,
      name: map['name'] as String,
      created_at: map['created_at'],
      items: List<Item>.from(
        (map['items'] as List<int>).map<Item>(
          (x) => Item.fromMap(x as Map<String, dynamic>),
        ),
      ), 
    );
  }

  String toJson() => json.encode(toMap());

  factory Receipt.fromJson(String source) =>
      Receipt.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Receipt(receiptId: $receiptId, uid: $uid, name: $name, created_at: $created_at, items: $items)';
  }

  @override
  bool operator ==(covariant Receipt other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.receiptId == receiptId &&
        other.uid == uid &&
        other.name == name &&
        other.created_at == created_at &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return receiptId.hashCode ^
        uid.hashCode ^
        name.hashCode ^
        created_at.hashCode ^
        items.hashCode;
  }
  
}
