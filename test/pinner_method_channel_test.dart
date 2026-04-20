import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinner/pinner_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelPinner platform = MethodChannelPinner();
  const MethodChannel channel = MethodChannel('pinner');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getSPKI') {
        return methodCall.arguments['pins']?.isNotEmpty == true
            ? methodCall.arguments['pins'][0]
            : 'MOCK_SPKI_HASH';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getSpki returns expected value', () async {
    final result = await platform.getSpki(
      host: "example.com",
      port: 443,
      pins: ["MOCK_SPKI_HASH"],
    );

    expect(result, 'MOCK_SPKI_HASH');
  });

  test('getSpki handles null response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });

    final result = await platform.getSpki(
      host: "example.com",
      port: 443,
      pins: [],
    );

    expect(result, null);
  });
}