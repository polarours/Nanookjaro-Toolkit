
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nanookjaro_frontend/main.dart';
import 'package:nanookjaro_frontend/ui/app_shell.dart';

void main() {
  testWidgets('NanookjaroApp renders AppShell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NanookjaroApp()));

    expect(find.byType(AppShell), findsOneWidget);
  });
}
