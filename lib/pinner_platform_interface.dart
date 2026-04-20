import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'pinner_method_channel.dart';

abstract class PinnerPlatform extends PlatformInterface {
  PinnerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PinnerPlatform _instance = MethodChannelPinner();

  static PinnerPlatform get instance => _instance;

  static set instance(PinnerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getSpki({
    required String host,
    required int port,
    required List<String> pins,
  });
}
