import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';


void main() {
  const MethodChannel channel = MethodChannel('flutter_bluetooth_basic');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channel.name,
      (message) async => ByteData(42),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channel.name,
      (message) async => null,
    );
  });
}

