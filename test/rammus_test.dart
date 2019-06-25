import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rammus/rammus.dart';

void main() {
  const MethodChannel channel = MethodChannel('rammus');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await Rammus.platformVersion, '42');
  });
}
