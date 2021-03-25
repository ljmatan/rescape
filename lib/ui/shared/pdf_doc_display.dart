import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/logic/pdf/pdf_generation.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/current_orders.dart';
import 'package:rescape/ui/shared/confirm_deletion_dialog.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/previous_orders/previous_orders.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';
import 'package:rescape/ui/shared/result_dialog.dart';
import 'package:decimal/decimal.dart';

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
  final bool processed, returns;

  PDFDocDisplay({
    this.order,
    @required this.screenWidth,
    this.processed: false,
    this.returns: false,
  });

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

  List _itemsList;
  List _splitLists;
  List<GlobalKey> _pageKeys;

  bool _inventoryReport;

  @override
  void initState() {
    super.initState();
    _inventoryReport = widget.order == null;
    final double pageHeight = widget.screenWidth * (297 / 210);
    int _rowsPerPage = ((pageHeight - 56) / 16).floor();
    if ((pageHeight - 56 - (_rowsPerPage * 16)) < 10) _rowsPerPage--;
    _itemsList = [
      if (!_inventoryReport)
        for (var item in widget.order.items) item
      else
        for (var item in ProductList.instance) item,
    ];

    List _removalList;
    if (_inventoryReport) {
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
      for (var toRemove in _removalList) {
        _itemsList.removeWhere((e) => e.id == toRemove.id);
        _itemsList.add(toRemove);
      }
      _itemsList.sort((a, b) => a.id.compareTo(b.id));
    }

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
      } else
        throw Exception('Something went wrong');
    }
    await PDFGeneration.createPDF(_pages, size);
    _pages.clear();
  }

  static final Set<String> _columnLabels = const {
    'ŠIFRA',
    'NAZIV ARTIKLA',
    'J.M.',
    'KOLIČINA'
  };

  Future<int> _delete() async {
    int statusCode = 400;
    try {
      statusCode =
          (await OrdersAPI.deleteProcessed(widget.order.key)).statusCode;
    } catch (e) {
      print('$e');
    }
    return statusCode;
  }

  Future<void> _confirmDeletion() => showDialog(
      context: context,
      barrierColor: Colors.white70,
      builder: (context) => ConfirmDeletionDialog(
            future: _delete,
          )).whenComplete(() => OrdersViewController.change(
      widget.processed ? PreviousOrders() : CurrentOrders()));

  Future<void> _updateInventory() async {
    BlockingDialog.show(context);
    int statusCode = 400;
    try {
      await ProductsAPI.getList();
      final Map productsMap = {
        for (var item in widget.order.items)
          for (var product
              in ProductList.instance.where((e) => e.id == item.product.id))
            product.barcode: {
              'product_id': item.product.id,
              'available': double.parse((Decimal.parse((ProductList.instance
                              .firstWhere((e) =>
                                  item.product.measureType == Measure.qty
                                      ? e.barcode == item.product.barcode
                                      : e.barcode.substring(0, 7) ==
                                          item.product.barcode.substring(0, 7))
                              .available)
                          .toString()) -
                      Decimal.parse(item.measure.toString()))
                  .toString()),
              'name': item.product.name,
              'barcode': item.product.measureType == Measure.kg
                  ? item.product.barcode.substring(0, 7)
                  : item.product.barcode,
              'measure': item.product.measureType == Measure.kg
                  ? 'KG'
                  : 'QTY' + item.product.quantity.toString(),
              'section': item.product.section,
              'category': item.product.category,
            }
      };
      statusCode =
          (await ProductsAPI.massProductAvailabilityUpdate(productsMap))
              .statusCode;
      if (statusCode == 200) {
        for (var item in widget.order.items)
          for (var product
              in ProductList.instance.where((e) => e.id == item.product.id)) {
            product.available = double.parse(
                (Decimal.parse((product.available.toString())) -
                        Decimal.parse(item.measure.toString()))
                    .toString());
            await DB.instance.update(
              'Products',
              {'available': product.available},
              where: 'barcode = ?',
              whereArgs: [item.product.barcode],
            );
          }
        await OrdersAPI.deleteProcessed(widget.order.key);
      }
      await ResultDialog.show(context, statusCode);
      OrdersViewController.change(PreviousOrders());
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime time =
        !_inventoryReport ? widget.order.time : DateTime.now();
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
                                    (!_inventoryReport
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
                                            CustomTableCell((!_inventoryReport
                                                    ? item.product.id
                                                    : item.id)
                                                .toString()),
                                            CustomTableCell(!_inventoryReport
                                                ? item.product.name
                                                : item.name),
                                            CustomTableCell((!_inventoryReport
                                                            ? item.product
                                                            : item)
                                                        .measureType ==
                                                    Measure.kg
                                                ? 'kg'
                                                : 'kom'),
                                            CustomTableCell((!_inventoryReport
                                                    ? item.measure
                                                    : item.available)
                                                .toString()
                                                .split((!_inventoryReport
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
          Positioned(
            right: 0,
            child: Row(
              children: [
                if (widget.processed)
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () async => await _confirmDeletion(),
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
                          !_inventoryReport
                              ? !widget.processed
                                  ? I18N.text('CLOSE')
                                  : I18N.text('CONFIRM')
                              : I18N.text('CLOSE'),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    onTap: !_inventoryReport
                        ? () async => !widget.processed
                            ? Navigator.pop(context)
                            : await _updateInventory()
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
                            I18N.text('SAVE'),
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
                      final PermissionStatus storagePermissionStatus =
                          await Permission.storage.request();
                      if (storagePermissionStatus == PermissionStatus.granted) {
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
                      } else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'You must grant storage permission in order to do this')));
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
