import 'package:bloc/bloc.dart';
import 'package:flutter_rss/blocs/rss/rss_event.dart';
import 'package:flutter_rss/blocs/rss/rss_state.dart';
import 'package:flutter_rss/network/api.dart';
import 'package:get_it/get_it.dart';

class RssBloc extends Bloc<RssEvent, RssState> {
  RssBloc() : super(RssFetching());

  final API? client = GetIt.instance<API>();

  @override
  Stream<RssState> mapEventToState(RssEvent event) async* {
    switch (event) {
      case RssEvent.fetch:
        try {
          yield RssFetching();
          final items = await client!.fetchItems();
          yield RssLoaded(items: items);
        } catch (e) {
          if (e is Exception) {
            yield RssError(errorDescription: e.toString());
          }
          yield RssError();
        }
        break;
      case RssEvent.clear:
        yield RssLoaded(items: []);
        break;
    }
  }
}
