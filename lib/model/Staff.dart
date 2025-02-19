// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String uid;
  final String email;
  final String name;
  final String icNo;
  final String phoneNo;
  final String status;

  Staff({
    required this.uid,
    required this.email,
    required this.name,
    required this.icNo,
    required this.phoneNo,
    required this.status,
  });

  Staff copyWith({
    String? uid,
    String? email,
    String? name,
    String? icNo,
    String? phoneNo,
    String? status,
  }) {
    return Staff(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      icNo: icNo ?? this.icNo,
      phoneNo: phoneNo ?? this.phoneNo,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'name': name,
      'icNo': icNo,
      'phoneNo': phoneNo,
      'status': status,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      icNo: map['icNo'] as String,
      phoneNo: map['phoneNo'] as String,
      status: map['status'] as String,
    );
  }

  factory Staff.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Data is null");
    }

    return Staff(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      icNo: data['icNo'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      status: data['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Staff.fromJson(String source) =>
      Staff.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Staff(uid: $uid, email: $email, name: $name, icNo: $icNo, phoneNo: $phoneNo, status: $status)';
  }

  @override
  bool operator ==(covariant Staff other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.icNo == icNo &&
        other.phoneNo == phoneNo &&
        other.status == status;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        icNo.hashCode ^
        phoneNo.hashCode ^
        status.hashCode;
  }
}
