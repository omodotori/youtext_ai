import 'package:flutter_test/flutter_test.dart';

import 'package:streamlit/main.dart';

void main() {
  testWidgets('Landing screen renders header', (tester) async {
    await tester.pumpWidget(const YouTextApp());
    expect(find.textContaining('YouTube to text'), findsOneWidget);
    expect(find.textContaining('Paste a YouTube link'), findsOneWidget);
  });
}
