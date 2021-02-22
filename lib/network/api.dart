import 'package:alice/alice.dart';
import 'package:flutter_rss/model/item.dart';
import 'package:flutter_rss/storage/firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

class API {
  static const String URL = 'https://www.nasa.gov/rss/dyn/breaking_news.rss';

  final http.Client httpClient = http.Client();
  final FirestoreApi firestoreApi = FirestoreApi();
  final _alice = GetIt.instance<Alice>();

  Future<List<Item>> fetchItems() async {
    try {
      final response = await httpClient.get(URL);
      _alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        var itemsList = _convertXML(response.body);
        itemsList.forEach((item) {
          firestoreApi.addItem(item);
        });

        return itemsList;
      } else {
        throw Exception('error fetching news from feeds');
      }
    } on Exception catch (_) {
      return await fetchDataOffline();
    }
  }

  Future<List<Item>> fetchDataOffline() async {
    final firestoreItemsList = await firestoreApi.getAllItems();
    if (firestoreItemsList.isNotEmpty) {
      return firestoreItemsList;
    } else {
      throw Exception('error fetching news from Firestore');
    }
  }

  List<Item> _convertXML(final String data) {
    final document = XmlDocument.parse(data);
    final items = document.findAllElements('item');

    return items.map((f) {
      return _convertXMLToItem(f);
    }).toList();
  }

  Item _convertXMLToItem(xml.XmlElement element) {
    final id = element.findElements('dc:identifier').single.text;
    final title = element.findElements('title').single.text;
    final link =
        element.findElements('link').single.text.replaceAll('http', 'https');
    final description = element.findElements('description').single.text;
    final enclosureUrl = element
        .findElements('enclosure')
        .single
        .getAttribute('url')
        .replaceAll('http', 'https');
    final pubDate = element.findElements('pubDate').single.text;

    return Item(
      id: id,
      title: title,
      link: link,
      description: description,
      enclosureUrl: enclosureUrl,
      pubDate: pubDate,
    );
  }
}
