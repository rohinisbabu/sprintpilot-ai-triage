import 'package:flutter_test/flutter_test.dart';
import 'package:sprintpilotai/main.dart';

void main() {
  testWidgets('SprintPilot AI renders the landing experience', (tester) async {
    await tester.pumpWidget(const SprintPilotApp());
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.text('AI-Powered Bug Triage & Engineering Workflow Assistant'),
      findsOneWidget,
    );
    expect(find.text('SprintPilot AI'), findsWidgets);
  });
}
