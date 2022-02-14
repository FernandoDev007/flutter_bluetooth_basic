import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';


void main() {
  const MethodChannel channel = MethodChannel('flutter_bluetooth_basic');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}

