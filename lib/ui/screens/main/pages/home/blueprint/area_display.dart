import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';

class AreaDisplay extends StatelessWidget {
  final double width, height, left, top, right, bottom;
  final int index, selected;
  AreaDisplay({
    @required this.index,
    @required this.width,
    @required this.height,
    this.selected,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: selected != null && selected != index
          ? const SizedBox()
          : GestureDetector(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      selected == index ? Theme.of(context).accentColor : null,
                  border: Border.all(
                    width: 2,
                    color: selected != null && selected == index
                        ? Theme.of(context).accentColor
                        : Colors.grey,
                  ),
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: selected != null && selected == index
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () => showDialog(
                context: context,
                barrierColor: Colors.white,
                builder: (context) => Material(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Section ${index + 1}',
                              style: const TextStyle(fontSize: 21),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      if (ProductList.instance
                              .firstWhere((e) => e.section == index) !=
                          null)
                        for (var product in ProductList.instance
                            .where((e) => e.section == index))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: kElevationToShadow[1],
                                color: Colors.white,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 64,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text('${product.id}'),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(product.name),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        product.measureType == Measure.kg
                                            ? '${product.available}kg'
                                            : '×${product.available.floor()}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
