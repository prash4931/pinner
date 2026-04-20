import 'package:flutter_test/flutter_test.dart';
import 'package:pinner/pinner_platform_interface.dart';
import 'package:pinner_example/main.dart';

class MockPinnerPlatformSuccess extends PinnerPlatform {
  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    return pins.first; // simulate valid pin
  }
}

class MockPinnerPlatformFailure extends PinnerPlatform {
  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    return "WRONG_PIN";
  }
}

void main() {
  testWidgets('SSL Pinning Success UI Test', (WidgetTester tester) async {
    PinnerPlatform.instance = MockPinnerPlatformSuccess();

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text("Check SSL Pinning"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Connection Secure"), findsOneWidget);
  });

  testWidgets('SSL Pinning Failure UI Test', (WidgetTester tester) async {
    PinnerPlatform.instance = MockPinnerPlatformFailure();

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text("Check SSL Pinning"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Pin Mismatch"), findsOneWidget);
  });
}