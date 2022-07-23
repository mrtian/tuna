import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuna3/tuna3.dart';

void main() {
  const MethodChannel channel = MethodChannel('tuna3');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Tuna3.platformVersion, '42');
  });
}
