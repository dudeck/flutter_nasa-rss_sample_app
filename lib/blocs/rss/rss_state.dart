import 'package:flutter_rss/model/item.dart';

abstract class RssState {}

class RssFetching extends RssState {
  @override
  String toString() => 'RssFetching';
}

class RssError extends RssState {
  RssError({this.errorDescription});

  final String? errorDescription;

  @override
  String toString() => 'RssError';
}

class RssLoaded extends RssState {
  RssLoaded({this.items});

  final List<Item>? items;

  @override
  String toString() => 'PostLoaded { posts: ${items!.length}}';
}
