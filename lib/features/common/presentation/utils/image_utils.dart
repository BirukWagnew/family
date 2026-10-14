import 'dart:convert';
import 'package:flutter/material.dart';

/// Returns a safe [ImageProvider] for a given [url].
/// Supports both network URLs (http/https) and base64 data URIs (data:image/...).
/// Returns null if the URL is null, empty, or unparseable.
ImageProvider? appImageProvider(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('data:')) {
    try {
      final commaIndex = trimmed.indexOf(',');
      final base64String =
          commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
      return MemoryImage(base64Decode(base64String));
    } catch (_) {
      return null;
    }
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return NetworkImage(trimmed);
  }

  return null;
}
