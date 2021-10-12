import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rss/model/item.dart';
import 'package:flutter_rss/pdf/pdf_printer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsPage extends StatelessWidget {
  final Item? item;

  ItemDetailsPage({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final pdfPrinter = PDFPrinter();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[800],
        title: Text(item!.title!),
        actions: [
          IconButton(
            color: Colors.red,
            icon: Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 24.0,
            ),
            onPressed: () => {
              pdfPrinter.saveAndOpen(
                context,
                item!,
              )
            },
          ),
          IconButton(
            color: Colors.red,
            icon: Icon(
              Icons.print,
              color: Colors.red,
              size: 24.0,
            ),
            onPressed: () => {
              pdfPrinter.printPDF(
                context,
                item!,
              )
            },
          ),
        ],
      ),
      body: ItemDetailsContent(
        item: item,
      ),
    );
  }
}

class ItemDetailsContent extends StatelessWidget {
  const ItemDetailsContent({
    this.item,
  });

  final Item? item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10.0,
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: item!.enclosureUrl!,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item!.title!,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SvgPicture.asset(
                        'assets/svg/astronaut.svg',
                        width: 30,
                        height: 30,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      item!.pubDate!,
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item!.description!),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RaisedButton(
                  color: Colors.lightBlue[800],
                  textColor: Colors.white,
                  child: Text(AppLocalizations.of(context)!.readMore),
                  onPressed: _launchURL,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _launchURL() async {
    if (await canLaunch(item!.link!)) {
      await launch(item!.link!, statusBarBrightness: Brightness.dark);
    } else {
      throw 'Could not launch $item.link';
    }
  }
}
