import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pinner_platform_interface.dart';

class MethodChannelPinner extends PinnerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('pinner');

  @override
  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  }) async {
    final result = await methodChannel.invokeMethod<String>('getSPKI', {
      "host": host,
      "port": port,
      "pins": pins,
    });

    return result;
  }
}
