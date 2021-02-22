import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String link;
  final String description;
  final String enclosureUrl;
  final String pubDate;

  Item({
    this.id,
    this.title,
    this.link,
    this.description,
    this.enclosureUrl,
    this.pubDate,
  }) : super();

  @override
  String toString() => 'Item { title: $title, description: $description }';

  static List<Item> fromMap(List<DocumentSnapshot> list) {
    return list.map((doc) {
      var data = Map.from(doc.data());
      final id = data['id'];
      final title = data['title'];
      final link = data['link'];
      final description = data['description'];
      final enclosureUrl = data['enclosureUrl'];
      final pubDate = data['pubDate'];

      return Item(
        id: id,
        title: title,
        link: link,
        description: description,
        enclosureUrl: enclosureUrl,
        pubDate: pubDate,
      );
    }).toList();
  }

  static Item fromDocument(DocumentSnapshot doc) {
    var data = Map.from(doc.data());
    final id = data['id'];
    final title = data['title'];
    final link = data['link'];
    final description = data['description'];
    final enclosureUrl = data['enclosureUrl'];
    final pubDate = data['pubDate'];

    return Item(
      id: id,
      title: title,
      link: link,
      description: description,
      enclosureUrl: enclosureUrl,
      pubDate: pubDate,
    );
  }

  static Map<String, dynamic> toMap(Item item) {
    return {
      'id': item.id,
      'title': item.title,
      'link': item.link,
      'description': item.description,
      'enclosureUrl': item.enclosureUrl,
      'pubDate': item.pubDate
    };
  }
}
