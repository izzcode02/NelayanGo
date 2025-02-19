import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryList {
  final String summaryId;
  final String uid;
  final String name;
  final Timestamp loginTime;
  final Timestamp logoutTime;
  final Timestamp createdAt;
  final Map<String, int> categoryQuantityMap;
  final Map<String, Map<String, dynamic>> categoryNameMap;
  final int totalTicketSold;

  SummaryList({
    required this.summaryId,
    required this.uid,
    required this.name,
    required this.loginTime,
    required this.logoutTime,
    required this.createdAt,
    required this.categoryQuantityMap,
    required this.categoryNameMap,
    required this.totalTicketSold,
  });

  Map<String, dynamic> toMap() {
    return {
      'summary_id': summaryId,
      'uid': uid,
      'name': name,
      'login_time': loginTime,
      'logout_time': logoutTime,
      'created_at': createdAt,
      'categoryQuantityMap': categoryQuantityMap,
      'categoryNameMap': categoryNameMap,
      'totalTicketSold': totalTicketSold,
    };
  }

  factory SummaryList.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, dynamic>> categoryNameMap = {};
    if (map['categoryNameMap'] != null) {
      (map['categoryNameMap'] as Map<String, dynamic>).forEach((key, value) {
        categoryNameMap[key] = Map<String, dynamic>.from(value);
      });
    }

    return SummaryList(
      summaryId: map['summary_id'],
      uid: map['uid'],
      name: map['name'],
      loginTime: map['login_time'],
      logoutTime: map['logout_time'],
      createdAt: map['created_at'],

      categoryQuantityMap: map['category_quantity_map'] != null
          ? Map<String, int>.from(map['category_quantity_map'])
          : {},
      categoryNameMap: categoryNameMap,
      totalTicketSold: map['totalTicketSold'] ?? 0, 
    );
  }
}
