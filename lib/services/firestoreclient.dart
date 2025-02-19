import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nelayanpos/model/Attendance.dart';

class FirestoreClient {
  static final firestore = FirebaseFirestore.instance;
  static final userDataRef = firestore.collection('userData');
  static final itemDataRef = firestore.collection('items');
  static final receiptRef = firestore.collection('receipt');
  static final summaryRef = firestore.collection('summary');
  static final attendance = firestore.collection('attendance');
}
