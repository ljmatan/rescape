import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/pdf/pdf_generation.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';

class CustomTableCell extends StatelessWidget {
  final String label;

  CustomTableCell(this.label);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}

class PDFDocDisplay extends StatefulWidget {
  final CurrentOrderModel order;
  final double screenWidth;

  PDFDocDisplay({this.order, @required this.screenWidth});

  @override
  State<StatefulWidget> createState() {
    return _PDFDocDisplayState();
  }
}

class _PDFDocDisplayState extends State<PDFDocDisplay> {
  final _pageController = PageController();

  Future<void> _goToPage(int page) async =>
      await _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);

  static final Set<String> _columnLabels = const {
    'ŠIFRA',
    'NAZIV ARTIKLA',
    'J.M.',
    'KOLIČINA'
  };

  List _itemsList;
  List _splitLists;
  List<GlobalKey> _pageKeys;

  int _rowsPerPage;

  @override
  void initState() {
    super.initState();
    final double pageHeight = widget.screenWidth * (297 / 210);
    _rowsPerPage = ((pageHeight - 56) / 16).floor();
    if ((pageHeight - 56 - (_rowsPerPage * 16)) < 10) _rowsPerPage--;
    _itemsList = [
      if (widget.order != null)
        for (var item in widget.order.items) item
      else
        for (var item in ProductList.instance) item,
    ];

    List _removalList;
    if (widget.order == null) {
      _removalList = [];
      for (var toCompare in _itemsList)
        for (var comparisonItem in _itemsList)
          if (toCompare.id == comparisonItem.id &&
              toCompare.barcode != comparisonItem.barcode &&
              _removalList.firstWhere((e) => e.id == toCompare.id,
                      orElse: () => null) ==
                  null) {
            _removalList.add(ProductModel(
              id: toCompare.id,
              name: toCompare.name,
              barcode: toCompare.barcode,
              available: toCompare.available,
              measureType: toCompare.measureType,
            ));
            break;
          }
      for (var toRemove in _removalList)
        for (var product in _itemsList
            .where((e) => e.id == toRemove.id && e.barcode != toRemove.barcode))
          toRemove.available += product.available;
      for (var toRemove in _removalList) {
        _itemsList.removeWhere((e) => e.id == toRemove.id);
        _itemsList.add(toRemove);
      }
    }

    if (widget.order == null) _itemsList.sort((a, b) => a.id.compareTo(b.id));

    if (_itemsList.length > _rowsPerPage) {
      _splitLists = [];
      for (var i = 0; i < (_itemsList.length / _rowsPerPage).floor() + 1; i++) {
        List splitList = [];
        for (var j = 0; j < _rowsPerPage; j++)
          if (i == 0 || _itemsList.length > (i * _rowsPerPage) + j)
            splitList.add(_itemsList[(i * _rowsPerPage) + j]);
        _splitLists.add(splitList);
      }
    }

    _pageKeys = [
      if (_splitLists != null)
        // ignore: unused_local_variable
        for (var list in _splitLists) GlobalKey()
      else
        GlobalKey(),
    ];
  }

  List<Uint8List> _pages;

  Future<void> _saveAsPDF() async {
    if (_pages == null) {
      if (_pageController.page != 0) await _goToPage(0);
      _pages = [];
    }
    Size size;
    for (int i = 0; i < _pageKeys.length; i++) {
      final RenderRepaintBoundary boundary =
          _pageKeys[i].currentContext.findRenderObject();
      await Future.delayed(const Duration(seconds: 1));
      ui.Image _image = await boundary.toImage(pixelRatio: 3);
      await Future.delayed(const Duration(seconds: 1));
      if (_image != null) {
        if (size == null)
          size = Size(_image.width.toDouble(), _image.height.toDouble());
        final imageByteData =
            await _image.toByteData(format: ui.ImageByteFormat.png);
        _pages.add(imageByteData.buffer.asUint8List());
        await _goToPage(i + 1);
      }
    }
    await PDFGeneration.createPDF(_pages, size);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime time =
        widget.order != null ? widget.order.time : DateTime.now();
    return Material(
      color: Colors.grey.shade200,
      textStyle: const TextStyle(
        fontFamily: 'CenturyGothic',
        color: Colors.black87,
      ),
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: [
              for (int i = 0; i < (_splitLists?.length ?? 1); i++)
                SizedBox.expand(
                  child: Center(
                    child: RepaintBoundary(
                      key: _pageKeys[i],
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height:
                              MediaQuery.of(context).size.width * (297 / 210),
                          child: Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 10),
                                  child: Text(
                                    (widget.order != null
                                            ? widget.order.location.companyName
                                            : 'Stanje') +
                                        (' ' +
                                            time.day.toString() +
                                            '.' +
                                            time.month.toString() +
                                            '.' +
                                            time.year.toString() +
                                            '.') +
                                        (_splitLists != null &&
                                                _splitLists.length > 1
                                            ? ' - ${i + 1}/${_splitLists.length}'
                                            : ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Table(
                                    border: TableBorder.all(
                                      color: Colors.black45,
                                      width: 1 / 3,
                                    ),
                                    columnWidths: {
                                      0: FractionColumnWidth(.125),
                                      1: FractionColumnWidth(.55),
                                      2: FractionColumnWidth(.125),
                                      3: FractionColumnWidth(.2),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          for (var label in _columnLabels)
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Text(
                                                  label,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      for (dynamic item in _splitLists != null
                                          ? _splitLists[i]
                                          : _itemsList)
                                        TableRow(
                                          children: [
                                            CustomTableCell(
                                                (widget.order != null
                                                        ? item.product.id
                                                        : item.id)
                                                    .toString()),
                                            CustomTableCell(widget.order != null
                                                ? item.product.name
                                                : item.name),
                                            CustomTableCell(
                                                (widget.order != null
                                                                ? item.product
                                                                : item)
                                                            .measureType ==
                                                        Measure.kg
                                                    ? 'kg'
                                                    : 'kom'),
                                            CustomTableCell((widget.order !=
                                                        null
                                                    ? item.measure
                                                    : item.available)
                                                .toString()
                                                .split((widget.order != null
                                                                ? item.product
                                                                : item)
                                                            .measureType ==
                                                        Measure.kg
                                                    ? 'none'
                                                    : '.')
                                                .first),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.order != null)
            Positioned(
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      child: Center(
                        child: Text(
                          widget.order != null ? 'CONFIRM' : 'CLOSE',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    onTap: widget.order != null
                        ? () async {}
                        : () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Center(
                          child: Text(
                            'SAVE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      BlockingDialog.show(context);
                      try {
                        await _saveAsPDF();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('File saved')));
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$e')));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
