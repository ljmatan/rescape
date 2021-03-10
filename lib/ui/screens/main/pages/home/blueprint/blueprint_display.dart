import 'package:flutter/material.dart';
import 'area_display.dart';
import 'bloc/highlighted_area_controller.dart';

class BlueprintDisplay extends StatefulWidget {
  final ScrollController scrollController;

  BlueprintDisplay({@required this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return _BlueprintDisplayState();
  }
}

class _BlueprintDisplayState extends State<BlueprintDisplay> {
  @override
  void initState() {
    super.initState();
    HighlightedAreaController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Builder(
                builder: (context) {
                  final double width = (MediaQuery.of(context).size.width - 32);
                  final double height = width * (20.8 / 9.4);
                  return SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            SizedBox.expand(),
                            AreaDisplay(
                              index: 0,
                              width: width * (2.5 / 4.7),
                              height: height * (1.6 / 10.4),
                              right: 0,
                            ),
                            AreaDisplay(
                              width: width / 2.2,
                              height: height / 3,
                              index: 1,
                              right: 0,
                              top: height * (1.6 / 10.4) - 2,
                            ),
                            AreaDisplay(
                              width: width / 3.3,
                              height: height / 15,
                              index: 2,
                              right: 0,
                              top: height / 3 + height * (1.6 / 10.4) - 4,
                            ),
                            AreaDisplay(
                              width: width / 3.3,
                              height: height -
                                  (height / 3 +
                                      height * (1.6 / 10.4) +
                                      height / 18),
                              index: 3,
                              right: 0,
                              top: height / 3 +
                                  height * (1.6 / 10.4) +
                                  height / 15 -
                                  6,
                            ),
                            AreaDisplay(
                              width: width,
                              height: height / 8,
                              index: 4,
                              bottom: 0,
                              left: width / 3.3 + 10,
                              right: width / 3.3 + 10,
                            ),
                            AreaDisplay(
                              index: 5,
                              width: width / 3.3,
                              height: height * (6.6 / 10.4),
                              left: 0,
                              bottom: 0,
                            ),
                          ],
                        ),
                        SizedBox.expand(
                          child: StreamBuilder(
                            stream: HighlightedAreaController.stream,
                            builder: (context, selected) => IndexedStack(
                              index: selected.data,
                              children: [
                                AreaDisplay(
                                  index: 0,
                                  width: width * (2.5 / 4.7),
                                  height: height * (1.6 / 10.4),
                                  right: 0,
                                  selected: selected.data,
                                ),
                                AreaDisplay(
                                  index: 1,
                                  width: width / 2.2,
                                  height: height / 3,
                                  right: 0,
                                  top: height * (1.6 / 10.4) - 2,
                                  selected: selected.data,
                                ),
                                AreaDisplay(
                                  index: 2,
                                  width: width / 3.3,
                                  height: height / 15,
                                  right: 0,
                                  top: height / 3 + height * (1.6 / 10.4) - 4,
                                  selected: selected.data,
                                ),
                                AreaDisplay(
                                  index: 3,
                                  width: width / 3.3,
                                  height: height -
                                      (height / 3 +
                                          height * (1.6 / 10.4) +
                                          height / 18),
                                  right: 0,
                                  top: height / 3 +
                                      height * (1.6 / 10.4) +
                                      height / 15 -
                                      6,
                                  selected: selected.data,
                                ),
                                AreaDisplay(
                                  index: 4,
                                  width: width,
                                  height: height / 8,
                                  bottom: 0,
                                  left: width / 3.3 + 10,
                                  right: width / 3.3 + 10,
                                  selected: selected.data,
                                ),
                                AreaDisplay(
                                  index: 5,
                                  width: width / 3.3,
                                  height: height * (6.6 / 10.4),
                                  left: 0,
                                  bottom: 0,
                                  selected: selected.data,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    HighlightedAreaController.dispose();
    super.dispose();
  }
}
