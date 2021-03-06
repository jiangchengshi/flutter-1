// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ExpansionPanelList test', (WidgetTester tester) async {
    int index;
    bool isExpanded;

    await tester.pumpWidget(
      new MaterialApp(
        home: new SingleChildScrollView(
          child: new ExpansionPanelList(
            expansionCallback: (int _index, bool _isExpanded) {
              index = _index;
              isExpanded = _isExpanded;
            },
            children: <ExpansionPanel>[
              new ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return new Text(isExpanded ? 'B' : 'A');
                },
                body: const SizedBox(height: 100.0),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    RenderBox box = tester.renderObject(find.byType(ExpansionPanelList));
    final double oldHeight = box.size.height;
    expect(find.byType(ExpandIcon), findsOneWidget);
    await tester.tap(find.byType(ExpandIcon));
    expect(index, 0);
    expect(isExpanded, isFalse);
    box = tester.renderObject(find.byType(ExpansionPanelList));
    expect(box.size.height, equals(oldHeight));

    // now expand the child panel
    await tester.pumpWidget(
      new MaterialApp(
        home: new SingleChildScrollView(
          child: new ExpansionPanelList(
            expansionCallback: (int _index, bool _isExpanded) {
              index = _index;
              isExpanded = _isExpanded;
            },
            children: <ExpansionPanel>[
              new ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return new Text(isExpanded ? 'B' : 'A');
                },
                body: const SizedBox(height: 100.0),
                isExpanded: true, // this is the addition
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    box = tester.renderObject(find.byType(ExpansionPanelList));
    expect(box.size.height - oldHeight, greaterThanOrEqualTo(100.0)); // 100 + some margin
  });

  testWidgets('Multiple Panel List test', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: new ListView(
          children: <ExpansionPanelList>[
            new ExpansionPanelList(
              children: <ExpansionPanel>[
                new ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return new Text(isExpanded ? 'B' : 'A');
                  },
                  body: const SizedBox(height: 100.0),
                  isExpanded: true,
                ),
              ],
            ),
            new ExpansionPanelList(
              children: <ExpansionPanel>[
                new ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return new Text(isExpanded ? 'D' : 'C');
                  },
                  body: const SizedBox(height: 100.0),
                  isExpanded: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsNothing);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('Open/close animations', (WidgetTester tester) async {
    const Duration kSizeAnimationDuration = Duration(milliseconds: 1000);
    // The MaterialGaps animate in using kThemeAnimationDuration (hardcoded),
    // which should be less than our test size animation length. So we can assume that they
    // appear immediately. Here we just verify that our assumption is true.
    expect(kThemeAnimationDuration, lessThan(kSizeAnimationDuration ~/ 2));

    Widget build(bool a, bool b, bool c) {
      return new MaterialApp(
        home: new Column(
          children: <Widget>[
            new ExpansionPanelList(
              animationDuration: kSizeAnimationDuration,
              children: <ExpansionPanel>[
                new ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) => const Placeholder(
                    fallbackHeight: 12.0,
                  ),
                  body: const SizedBox(height: 100.0, child: Placeholder(
                    fallbackHeight: 12.0,
                  )),
                  isExpanded: a,
                ),
                new ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) => const Placeholder(
                    fallbackHeight: 12.0,
                  ),
                  body: const SizedBox(height: 100.0, child: Placeholder()),
                  isExpanded: b,
                ),
                new ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) => const Placeholder(
                    fallbackHeight: 12.0,
                  ),
                  body: const SizedBox(height: 100.0, child: Placeholder()),
                  isExpanded: c,
                ),
              ],
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(build(false, false, false));
    expect(tester.renderObjectList(find.byType(AnimatedSize)), hasLength(3));
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), new Rect.fromLTWH(0.0, 113.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), new Rect.fromLTWH(0.0, 170.0, 800.0, 0.0));

    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), new Rect.fromLTWH(0.0, 113.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), new Rect.fromLTWH(0.0, 170.0, 800.0, 0.0));

    await tester.pumpWidget(build(false, true, false));
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), new Rect.fromLTWH(0.0, 113.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), new Rect.fromLTWH(0.0, 170.0, 800.0, 0.0));

    await tester.pump(kSizeAnimationDuration ~/ 2);
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    final Rect rect1 = tester.getRect(find.byType(AnimatedSize).at(1));
    expect(rect1.left, 0.0);
    expect(rect1.top, inExclusiveRange(113.0, 113.0 + 16.0 + 32.0)); // 16.0 material gap, plus 16.0 top and bottom margins added to the header
    expect(rect1.width, 800.0);
    expect(rect1.height, inExclusiveRange(0.0, 100.0));
    final Rect rect2 = tester.getRect(find.byType(AnimatedSize).at(2));
    expect(rect2, new Rect.fromLTWH(0.0, rect1.bottom + 16.0 + 56.0, 800.0, 0.0)); // the 16.0 comes from the MaterialGap being introduced, the 56.0 is the header height.

    await tester.pumpWidget(build(false, false, false));
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), rect1);
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), rect2);

    await tester.pumpWidget(build(false, false, true));
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), rect1);
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), rect2);

    // a few no-op pumps to make sure there's nothing fishy going on
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), rect1);
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), rect2);

    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(AnimatedSize).at(0)), new Rect.fromLTWH(0.0, 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(1)), new Rect.fromLTWH(0.0, 56.0 + 1.0 + 56.0, 800.0, 0.0));
    expect(tester.getRect(find.byType(AnimatedSize).at(2)), new Rect.fromLTWH(0.0, 56.0 + 1.0 + 56.0 + 16.0 + 16.0 + 48.0 + 16.0, 800.0, 100.0));
  });

  testWidgets('Single Panel Open Test',  (WidgetTester tester) async {

    final List<ExpansionPanel> _demoItemsRadio = <ExpansionPanelRadio>[
      new ExpansionPanelRadio(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'B' : 'A');
        },
        body: const SizedBox(height: 100.0),
        value: 0,
      ),
      new ExpansionPanelRadio(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'D' : 'C');
        },
        body: const SizedBox(height: 100.0),
        value: 1,
      ),
      new ExpansionPanelRadio(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'F' : 'E');
        },
        body: const SizedBox(height: 100.0),
        value: 2,
      ),
    ];

    final ExpansionPanelList _expansionListRadio = ExpansionPanelList.radio(
      children: _demoItemsRadio,
    );

    await tester.pumpWidget(
      new MaterialApp(
        home: new SingleChildScrollView(
          child: _expansionListRadio,
        ),
      ),
    );

    // Initializes with all panels closed
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsNothing);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('F'), findsNothing);

    RenderBox box = tester.renderObject(find.byType(ExpansionPanelList));
    double oldHeight = box.size.height;

    expect(find.byType(ExpandIcon), findsNWidgets(3));

    await tester.tap(find.byType(ExpandIcon).at(0));

    box = tester.renderObject(find.byType(ExpansionPanelList));
    expect(box.size.height, equals(oldHeight));

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Now the first panel is open
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsNothing);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('F'), findsNothing);

    box = tester.renderObject(find.byType(ExpansionPanelList));
    expect(box.size.height - oldHeight, greaterThanOrEqualTo(100.0)); // 100 + some margin

    await tester.tap(find.byType(ExpandIcon).at(1));

    box = tester.renderObject(find.byType(ExpansionPanelList));
    oldHeight = box.size.height;

    await tester.pump(const Duration(milliseconds: 200));

    // Now the first panel is closed and the second should be opened
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('F'), findsNothing);

    expect(box.size.height, greaterThanOrEqualTo(oldHeight));

    _demoItemsRadio.removeAt(0);

    await tester.pumpAndSettle();

    // Now the first panel should be opened
    expect(find.text('C'), findsNothing);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('F'), findsNothing);


    final List<ExpansionPanel> _demoItems = <ExpansionPanel>[
      new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'B' : 'A');
        },
        body: const SizedBox(height: 100.0),
        isExpanded: false,
      ),
      new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'D' : 'C');
        },
        body: const SizedBox(height: 100.0),
        isExpanded: false,
      ),
      new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new Text(isExpanded ? 'F' : 'E');
        },
        body: const SizedBox(height: 100.0),
        isExpanded: false,
      ),
    ];

    final ExpansionPanelList _expansionList = new ExpansionPanelList(
      children: _demoItems,
    );

    await tester.pumpWidget(
      new MaterialApp(
        home: new SingleChildScrollView(
          child: _expansionList,
        ),
      ),
    );

    // We've reinitialized with a regular expansion panel so they should all be closed again
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsNothing);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('F'), findsNothing);
  });

  testWidgets('Panel header has semantics', (WidgetTester tester) async {
    const Key expandedKey = Key('expanded');
    const Key collapsedKey = Key('collapsed');
    const DefaultMaterialLocalizations localizations = DefaultMaterialLocalizations();
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<ExpansionPanel> _demoItems = <ExpansionPanel>[
      new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return const Text('Expanded', key: expandedKey);
        },
        body: const SizedBox(height: 100.0),
        isExpanded: true,
      ),
      new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return const Text('Collapsed', key: collapsedKey);
        },
        body: const SizedBox(height: 100.0),
        isExpanded: false,
      ),
    ];

    final ExpansionPanelList _expansionList = new ExpansionPanelList(
      children: _demoItems,
    );

    await tester.pumpWidget(
      new MaterialApp(
        home: new SingleChildScrollView(
          child: _expansionList,
        ),
      ),
    );

    expect(tester.getSemanticsData(find.byKey(expandedKey)), matchesSemanticsData(
      label: 'Expanded',
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      hasTapAction: true,
      onTapHint: localizations.expandedIconTapHint,
    ));

    expect(tester.getSemanticsData(find.byKey(collapsedKey)), matchesSemanticsData(
      label: 'Collapsed',
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      hasTapAction: true,
      onTapHint: localizations.collapsedIconTapHint,
    ));

    handle.dispose();
  });
}
