import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/main.dart';
import 'package:hirehub/screens/job_dashboard_screen.dart';

void main() {
  testWidgets('HireHub App Boot Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HireHubApp());

    // Verify that the JobDashboardScreen is loaded.
    expect(find.byType(JobDashboardScreen), findsOneWidget);
  });
}
