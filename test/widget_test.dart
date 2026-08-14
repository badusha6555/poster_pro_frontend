import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posterpro/main.dart';

void main() {
  testWidgets('App boots to the login screen when logged out', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PosterProApp()));
    await tester.pump();

    expect(find.text('PosterPro'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
