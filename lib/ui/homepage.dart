import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rss/blocs/rss/rss_bloc.dart';
import 'package:flutter_rss/blocs/rss/rss_event.dart';
import 'package:flutter_rss/blocs/rss/rss_state.dart';
import 'package:flutter_rss/model/item.dart';
import 'package:flutter_rss/ui/item_details_page.dart';
import 'package:get_it/get_it.dart';
import 'package:tuple/tuple.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RssBloc? _rssBloc = GetIt.I<RssBloc>();
  Completer<void>? _refreshCompleter;

  _HomePageState() {
    _refreshCompleter = Completer<void>();
    _rssBloc!.add(RssEvent.fetch);
  }

  @override
  void dispose() {
    _rssBloc!.add(RssEvent.clear);
    _rssBloc!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[800],
        title: Text(appLocalizations.title),
      ),
      body: Center(
        child: BlocListener(
          listener: (BuildContext context, RssState state) {
            if (state is RssLoaded) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          bloc: _rssBloc,
          child: BlocBuilder(
            bloc: _rssBloc,
            builder: (BuildContext context, RssState state) {
              if (state is RssFetching) {
                return CircularProgressIndicator();
              }

              if (state is RssError) {
                return MessageWidget(
                  message: state.errorDescription ??
                      'Unknown error occurred while fetching items',
                  refresh: refreshData,
                );
              }

              if (state is RssLoaded) {
                if (state.items!.isEmpty) {
                  return MessageWidget(
                    message: 'No items to show',
                    refresh: refreshData,
                  );
                }

                return NASAItemsContent(
                  items: state.items,
                  refresh: refreshData,
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }

  Future<void> refreshData() {
    _rssBloc!.add(RssEvent.fetch);
    return _refreshCompleter!.future;
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    this.message,
    this.refresh,
  });

  final String? message;
  final VoidCallback? refresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh as Future<void> Function(),
      child: SingleChildScrollView(
        child: Text(message!),
      ),
    );
  }
}

class NASAItemsContent extends StatelessWidget {
  const NASAItemsContent({
    this.items,
    this.refresh,
  });

  final List<Item>? items;
  final VoidCallback? refresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh as Future<void> Function(),
      child: Container(
        child: GridView.builder(
            itemCount: items!.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 250,
            ),
            itemBuilder: (BuildContext context, int index) {
              final item = items![index];
              return NASAItem(item: item);
            }),
      ),
    );
  }
}

class NASAItem extends StatelessWidget {
  const NASAItem({
    this.item,
  });

  final Item? item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.black,
        elevation: 8.0,
        child: InkWell(
          onTap: () {
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsPage(
                    item: item,
                  ),
                ),
              );
            }
          },
          child: NasaItemContent(
              data: Tuple2(
            item!.title,
            item!.enclosureUrl,
          )),
        ),
      ),
    );
  }
}

class NasaItemContent extends StatelessWidget {
  const NasaItemContent({
    this.data,
  });

  final Tuple2<String?, String?>? data;

  @override
  Widget build(BuildContext context) {
    final title = data!.item1;
    final link = data!.item2!;

    return Stack(
      children: [
        Center(
          child: Image.network(link),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              8.0,
              8.0,
              8.0,
              20.0,
            ),
            child: Container(
              color: Colors.black12.withAlpha(100),
              child: Text(
                'Item $title',
                style: TextStyle(
                  color: Colors.white,
                ),
                // Comment below 2 lines to get overflow issue.
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Ugly code for pedantic lint warnings.
// void uglyMethod(String a, String c) {
//   String cos = '';
//   if (cos == '') {}
//   print(cos);
//   final list = [];
//   if (list != null && list.length > 0) {
//     final a = new Item();
//   }
// }

}
