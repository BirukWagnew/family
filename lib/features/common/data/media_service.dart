import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Contract for media selection and storage operations (OOP Abstraction & ISP).
abstract class IMediaService {
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery});
  Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery});
  Future<String> uploadMedia({
    required XFile file,
    required String path,
  });
}

/// Concrete implementation of [IMediaService] using ImagePicker & Firebase Storage (OOP Polymorphism).
class MediaService implements IMediaService {
  final ImagePicker _picker;
  final FirebaseStorage _storage;

  MediaService({
    ImagePicker? picker,
    FirebaseStorage? storage,
  })  : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
    } catch (e) {
      // If camera is unsupported on current platform (e.g. Windows desktop), fall back to gallery/files
      if (source == ImageSource.camera) {
        try {
          return await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 80,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  @override
  Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> uploadMedia({
    required XFile file,
    required String path,
  }) async {
    final bytes = await file.readAsBytes();
    final isVideo = file.name.toLowerCase().endsWith('.mp4') ||
        file.name.toLowerCase().endsWith('.mov') ||
        file.name.toLowerCase().endsWith('.avi');
    final mimeType = file.mimeType ?? (isVideo ? 'video/mp4' : 'image/jpeg');

    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: mimeType);
      final uploadTask = await ref.putData(bytes, metadata).timeout(
        const Duration(seconds: 12),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL().timeout(
        const Duration(seconds: 8),
      );
      return downloadUrl;
    } catch (e) {
      // Graceful fallback for images: data URI if Firebase Storage fails or is unavailable
      if (!isVideo && bytes.lengthInBytes < 1500000) {
        final base64String = base64Encode(bytes);
        return 'data:$mimeType;base64,$base64String';
      }
      rethrow;
    }
  }
}

final mediaServiceProvider = Provider<IMediaService>((ref) {
  return MediaService();
});
