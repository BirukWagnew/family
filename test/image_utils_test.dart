import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:family/features/common/presentation/utils/image_utils.dart';

void main() {
  group('appImageProvider', () {
    test('returns null for null or empty input', () {
      expect(appImageProvider(null), isNull);
      expect(appImageProvider(''), isNull);
      expect(appImageProvider('   '), isNull);
    });

    test('returns NetworkImage for web URLs', () {
      final providerHttp = appImageProvider('http://example.com/photo.jpg');
      expect(providerHttp, isA<NetworkImage>());
      expect((providerHttp as NetworkImage).url, 'http://example.com/photo.jpg');

      final providerHttps = appImageProvider('https://example.com/photo.jpg');
      expect(providerHttps, isA<NetworkImage>());
      expect((providerHttps as NetworkImage).url, 'https://example.com/photo.jpg');
    });

    test('returns MemoryImage for base64 data URIs', () {
      final sampleBytes = utf8.encode('test image bytes');
      final base64String = base64Encode(sampleBytes);
      final dataUri = 'data:image/jpeg;base64,$base64String';

      final provider = appImageProvider(dataUri);
      expect(provider, isA<MemoryImage>());
      expect((provider as MemoryImage).bytes, sampleBytes);
    });
  });
}
