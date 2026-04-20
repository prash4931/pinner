import 'package:flutter_test/flutter_test.dart';
import 'package:pinner/pinner.dart';
import 'package:pinner/pinner_platform_interface.dart';
import 'package:pinner/pinner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPinnerPlatform
    with MockPlatformInterfaceMixin
    implements PinnerPlatform {

  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    return "MOCK_VALID_PIN";
  }
}

class MockPinnerPlatformFailure
    with MockPlatformInterfaceMixin
    implements PinnerPlatform {

  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    return "WRONG_PIN";
  }
}

class _NullSpkiPlatform
    with MockPlatformInterfaceMixin
    implements PinnerPlatform {

  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    return null;
  }
}

void main() {
  final PinnerPlatform initialPlatform = PinnerPlatform.instance;

  tearDown(() {
    PinnerPlatform.instance = MethodChannelPinner();
  });

  test('MethodChannelPinner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPinner>());
  });

  test('verify returns true when pin matches', () async {
    PinnerPlatform.instance = MockPinnerPlatform();

    final result = await Pinner().verify(
      host: "example.com",
      pins: ["MOCK_VALID_PIN"],
    );

    expect(result, true);
  });

  test('verify returns false when pin does not match', () async {
    PinnerPlatform.instance = MockPinnerPlatformFailure();

    final result = await Pinner().verify(
      host: "example.com",
      pins: ["MOCK_VALID_PIN"],
    );

    expect(result, false);
  });

  test('verify returns false when SPKI is null', () async {
    PinnerPlatform.instance = _NullSpkiPlatform();

    final result = await Pinner().verify(
      host: "example.com",
      pins: ["MOCK_VALID_PIN"],
    );

    expect(result, false);
  });

  test('verify returns false when pins list is empty', () async {
    PinnerPlatform.instance = MockPinnerPlatform();

    final result = await Pinner().verify(
      host: "example.com",
      pins: [],
    );

    expect(result, false);
  });
}