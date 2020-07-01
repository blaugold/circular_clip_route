import 'package:circular_clip_route/circular_clip_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CircularClipRoute golden image', (tester) async {
    final buttonKey = Key('button');
    final buttonFinder = find.byKey(buttonKey);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(50),
          child: Builder(
            builder: (context) {
              return IconButton(
                key: buttonKey,
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    CircularClipRoute<void>(
                      expandFrom: context,
                      builder: (_) => Container(color: Colors.orange),
                      transitionDuration: Duration(seconds: 1),
                      curve: Curves.linear,
                      reverseCurve: Curves.linear,
                      opacity: ConstantTween(.8),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ));

    await tester.tap(buttonFinder);
    await tester.pump();
    await tester.pump(Duration(milliseconds: 500));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/circular_clip_route/transition-half.png'),
    );
  });
}
