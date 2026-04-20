import 'pinner_platform_interface.dart';

class Pinner {
  Future<bool> verify({
    required String host,
    int port = 443,
    required List<String> pins,
  }) async {
    final spki = await PinnerPlatform.instance.getSpki(
      host: host,
      port: port,
      pins: pins,
    );

    if (spki == null) return false;

    return pins.contains(spki);
  }
}
