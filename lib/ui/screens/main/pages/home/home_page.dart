import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/ui/screens/main/pages/home/blueprint/bloc/highlighted_area_controller.dart';
import '../../bloc/main_view_controller.dart';
import 'blueprint/blueprint_display.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final _onError = FlutterError.onError;

  final _itemSearchController = TextEditingController();
  final _itemSearchFocusNode = FocusNode();

  final _scrollController = ScrollController();

  StreamSubscription _viewSubscription;

  final _searchTermController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _itemSearchFocusNode.addListener(() => setState(() {}));
    _viewSubscription = MainViewController.stream.listen((page) {
      if (page != 0) {
        _itemSearchFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _scrollController.jumpTo(0);
        });
      }
    });
    _itemSearchController.addListener(
        () => _searchTermController.add(_itemSearchController.text));
    // Ignore overflow on this screen due to custom view implemented
    FlutterError.onError = (
      FlutterErrorDetails details, {
      bool forceReport = false,
    }) {
      assert(details != null);
      assert(details.exception != null);
      // ---

      bool ifIsOverflowError = false;

      // Detect overflow error.
      var exception = details.exception;
      if (exception is FlutterError)
        ifIsOverflowError = !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"));

      // Ignore if is overflow error.
      if (!ifIsOverflowError)
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    };
  }

  void _scrollTo(double offset) => _scrollController.animateTo(offset,
      duration: const Duration(milliseconds: 200), curve: Curves.ease);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom == 0 &&
        _itemSearchFocusNode.hasFocus)
      Future.delayed(const Duration(seconds: 1), () {
        if (MediaQuery.of(context).viewInsets.bottom == 0 &&
            _itemSearchFocusNode.hasFocus) _itemSearchFocusNode.unfocus();
      });
    return WillPopScope(
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: kElevationToShadow[2],
            ),
            child: AnimatedContainer(
              duration: const Duration(),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).padding.top +
                  (_itemSearchFocusNode.hasFocus
                      ? MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom -
                          MediaQuery.of(context).padding.bottom -
                          MediaQuery.of(context).padding.top
                      : 70),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          focusNode: _itemSearchFocusNode,
                          controller: _itemSearchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            hintText: 'Tap to search',
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 10, 16, 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_itemSearchFocusNode.hasFocus)
                    Expanded(
                      child: StreamBuilder(
                        stream: _searchTermController.stream,
                        initialData: '',
                        builder: (context, searchTerm) => ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            for (var product in (searchTerm.data.isEmpty
                                ? ProductList.instance
                                : ProductList.instance.where((e) =>
                                    e.name.toLowerCase().contains(
                                        searchTerm.data.toLowerCase()) ||
                                    e.id
                                        .toString()
                                        .startsWith(searchTerm.data))))
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: GestureDetector(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: kElevationToShadow[1],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 56,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '${product.id} ${product.name}',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    _itemSearchController.text = product.name;
                                    if (product.section >= 3)
                                      _scrollTo(_scrollController
                                          .position.maxScrollExtent);
                                    else
                                      _scrollTo(0);
                                    HighlightedAreaController.change(
                                      product.section,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          BlueprintDisplay(scrollController: _scrollController),
        ],
      ),
      onWillPop: () async {
        _itemSearchFocusNode.unfocus();
        return false;
      },
    );
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    _itemSearchFocusNode.dispose();
    _viewSubscription.cancel();
    _scrollController.dispose();
    _searchTermController.close();
    FlutterError.onError = _onError;
    super.dispose();
  }
}
