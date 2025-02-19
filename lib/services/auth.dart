import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nelayanpos/model/Item.dart';
import 'package:nelayanpos/model/Receipt.dart';
import 'package:nelayanpos/model/Staff.dart';
import 'package:nelayanpos/screen/printer/printsummary.dart';
import 'package:nelayanpos/services/firestoreclient.dart';
import 'package:nelayanpos/utils/custom_navigator.dart';

class AuthService {
  // AUTHENTICATOR
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> getUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDataDoc = await FirestoreClient.userDataRef.doc(user.uid).get();
      if (userDataDoc.exists) {
        final name = userDataDoc.get('name');
        Text(name);
      }
    } else {
      Text('Admin');
    }
  }

  Future<void> snackbarUser(BuildContext context) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // User is signed in
      final userDataDoc = await FirestoreClient.userDataRef.doc(user.uid).get();
      if (userDataDoc.exists) {
        final name = userDataDoc.get('name');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Nelayan POS, $name'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // User is not signed in
      print('User is not signed in');
    }
  }

  Future signIn(String email, String password, BuildContext context) async {
    try {
      final user = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError(
        (error) {
          if (error.toString().contains("NETWORK_ERROR")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No internet connection"),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Login Credentials / No connection'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      if (user != null && user.user?.email == 'muziumnelayan@yahoo.com') {
        cNavigate.goToDashboard(context);
      } else if (user != null) {
        cNavigate.goToHomeScreen(context);

        // Log the user's attendance after they log in
        await UserAttendance(true);
      }
    } catch (e) {
      print(e);
    }
  }

  Future signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      //Log out the user attendance
      cNavigate.goToLogin(context);
    } catch (e) {
      print(e);
    }
  }

  Future<void> UserAttendance(bool isLogin) async {
    try {
      final User? user = _auth.currentUser;
      final String uid = user!.uid;
      final String? email = user.email;
      DocumentReference attendanceRef;

      // Retrieve the user's data from the userData collection
      DocumentSnapshot userDataSnapshot =
          await FirestoreClient.userDataRef.doc(uid).get();

      final String? name =
          (userDataSnapshot.data() as Map<String, dynamic>)['name'];

      // Create a timestamp for the current time
      final Timestamp timestampLogin = Timestamp.now();
      final Timestamp timestampLogout = Timestamp.now();

      if (isLogin == true) {
        // Add the attendance record to the Firestore collection
        final attendanceData = {
          'uid': uid,
          'name': name,
          'email': email,
          'login_time': timestampLogin,
          'logout_time': null,
        };
        attendanceRef = FirestoreClient.attendance.doc();
        await attendanceRef.set(attendanceData);
        print("Attendance record added with ID: ${attendanceRef.id}");
      } else {
        // Update the last logout time for the user in the Firestore collection
        final QuerySnapshot attendanceQuery = await FirestoreClient.attendance
            .where('uid', isEqualTo: uid)
            .where('logout_time', isEqualTo: null)
            .get();
        final List<QueryDocumentSnapshot> documents = attendanceQuery.docs;
        if (documents.isNotEmpty) {
          attendanceRef = documents.first.reference;
          final updates = <String, dynamic>{
            "logout_time": timestampLogout,
          };
          await attendanceRef.update(updates);
          print("Attendance record updated with ID: ${attendanceRef.id}");
        } else {
          print('No active attendance records found.');
        }
      }
    } catch (e) {
      print('$e update error');
    }
  }

  Future<void> createUser(String email, String password, String name,
      String icNo, String phoneNo, String status, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = userCredential.user!;
      await FirestoreClient.userDataRef.doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'icNo': icNo,
        'phoneNo': phoneNo,
        'status': status,
        'email': email,
      });
      // Reauthenticate admin user
      final currentUser = _auth.currentUser;
      final credential = EmailAuthProvider.credential(
        email: 'muziumnelayan@yahoo.com',
        password: 'adminnelayan',
      );
      await _auth.signOut();
      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User created'),
          backgroundColor: Colors.green,
        ),
      );
      cNavigate.goToDashboard(context);
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${e.toString()}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Stream<List<Staff>> getStaffData() {
    return FirestoreClient.userDataRef.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateUserData(String email, String name, String icNo,
      String phoneNo, String status, String password) async {
    try {
      var user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Update user data in Firestore
      var data = {
        'name': name,
        'icNo': icNo,
        'phoneNo': phoneNo,
        'status': status,
      };
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(email)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Function to delete the current user and the Firestore collection
  Future<void> deleteUser(BuildContext context) async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      // Delete the Firestore collection associated with the user
      final userRef = FirestoreClient.userDataRef.doc(user!.uid);
      await userRef.delete();

      // Delete the user's account
      await user.delete();

      cNavigate.goToLogin(context);
    } catch (e) {
      print(e);
    }
  }

  //ITEM

  Future<void> createItem(String name, double price, String category,
      String imageUrl, String color) async {
    // Generate a new ID for the item document
    String itemId = FirestoreClient.itemDataRef.doc().id;

    // Create a new item document with the user input data
    return FirestoreClient.itemDataRef.doc(itemId).set({
      'itemId': itemId,
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'color': color,
    });
  }

  Future<String?> uploadImage(File image) async {
    try {
      // Create a unique filename for the image
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

      // Upload the image to Firebase Storage
      Reference ref = _storage.ref().child('images').child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Return the download URL for the image
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot<Object?>> getItemData() {
    return FirestoreClient.itemDataRef.snapshots();
  }

  // Delete an item from Firestore
  Future<void> deleteItem(String itemId) async {
    return FirestoreClient.itemDataRef
        .doc(itemId)
        .delete()
        .then((value) => print("Item Deleted"))
        .catchError((error) => print("Failed to delete item: $error"));
  }

  /// Retrieve data for a specific item document
  Future<DocumentSnapshot> fetchItemData(String itemId) async {
    return await FirestoreClient.itemDataRef.doc(itemId).get();
  }

  // Update the item document in Firestore
  Future<void> updateItem(String itemId, Map<String, dynamic> data) async {
    try {
      await FirestoreClient.itemDataRef.doc(itemId).update(data);
      print('Item updated successfully!');
    } catch (e) {
      print('Error updating item: $e');
    }
  }
}
