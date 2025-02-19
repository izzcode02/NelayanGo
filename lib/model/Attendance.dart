// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  String id;
  String uid;
  String name;
  String email;
  Timestamp loginTime;
  Timestamp logoutTime;

  Attendance({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.loginTime,
    required this.logoutTime,
  });

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      loginTime: data['login_time'] ?? '',
      logoutTime: data['login_time'] ?? '',
    );
  }

  Attendance copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    Timestamp? loginTime,
    Timestamp? logoutTime,
  }) {
    return Attendance(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      loginTime: loginTime ?? this.loginTime,
      logoutTime: logoutTime ?? this.logoutTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'loginTime': loginTime,
      'logoutTime': logoutTime,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Attendance(id: $id, uid: $uid, name: $name, email: $email, loginTime: $loginTime, logoutTime: $logoutTime)';
  }

  @override
  bool operator ==(covariant Attendance other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.loginTime == loginTime &&
        other.logoutTime == logoutTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        loginTime.hashCode ^
        logoutTime.hashCode;
  }

  static fromMap(Map<String, dynamic> x) {}

  factory Attendance.fromJson(String source) =>
      Attendance.fromMap(json.decode(source) as Map<String, dynamic>);
}
