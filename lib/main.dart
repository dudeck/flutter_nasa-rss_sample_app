import 'dart:async';

import 'package:alice/alice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rss/blocs/rss/rss_bloc.dart';
import 'package:flutter_rss/network/api.dart';
import 'package:flutter_rss/ui/homepage.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry/sentry.dart';

final _getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sentry = SentryClient(dsn: 'hPASTE_YOUR_DSN_HERE_FOR_SENTRY');
  registerDI();

  FlutterError.onError = (details, {bool forceReport = false}) {
    sentry.captureException(
      exception: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () {
      runApp(NASARssApp());
    },
    (error, stackTrace) async {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );
}

void registerDI() {
  _getIt.registerSingleton<Alice>(
    Alice(
      showNotification: true,
    ),
  );
  _getIt.registerSingleton<API>(
    API(),
  );
  _getIt.registerSingleton<RssBloc>(
    RssBloc(),
  );
}

class NASARssApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _getIt<Alice>().getNavigatorKey(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('pl', ''),
      ],
      title: 'Flutter RSS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
