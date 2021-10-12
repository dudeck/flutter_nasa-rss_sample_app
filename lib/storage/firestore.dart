import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rss/model/item.dart';

class FirestoreApi {
  Future<Map<dynamic, dynamic>> addItem(Item item) async {
    return FirebaseFirestore.instance
        .collection('items')
        .doc(item.id)
        .set(Item.toMap(item))
        .then((result) => {})
        .catchError((err) => print(err));
  }

  Future<Item> getItem(String id) async {
    return FirebaseFirestore.instance
        .collection('items')
        .doc(id)
        .snapshots()
        .map((result) => Item.fromDocument(result))
        .first;
  }

  Future<List<Item>> getAllItems() async {
    return FirebaseFirestore.instance
        .collection('items')
        .snapshots()
        .map((documentSnapshot) => Item.fromMap(documentSnapshot.docs))
        .first;
  }

  Future<Map> removeItem(Item item) async {
    return FirebaseFirestore.instance
        .collection('items')
        .doc(item.id)
        .delete()
        .then((result) => {})
        .catchError((err) => print(err));
  }

  Future<Map> updateItem(Item item) async {
    return FirebaseFirestore.instance
        .collection('items')
        .doc(item.id)
        .update(Item.toMap(item))
        .then((result) => {})
        .catchError((err) => print(err));
  }
}
