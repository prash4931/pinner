import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinner/pinner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final Pinner pinner = Pinner();

  testWidgets('SSL Pinning Success Test', (WidgetTester tester) async {
    final bool isSecure = await pinner
        .verify(
          host: "badssl.com",
          pins: [
            "chBKGC2E4cdpgMD2jlsFLLJvoujxm9EUKcSlUiZN6Rc=",
          ],
        )
        .timeout(const Duration(seconds: 10));

    expect(isSecure, true);
  });

  testWidgets('SSL Pinning Failure Test', (WidgetTester tester) async {
    final bool isSecure = await pinner
        .verify(
          host: "badssl.com",
          pins: [
            "INVALID_PIN",
          ],
        )
        .timeout(const Duration(seconds: 10));

    expect(isSecure, false);
  });
}