import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage service untuk upload/download files
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file
  static Future<String?> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Upload multiple files
  static Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String basePath,
    Function(int completed, int total)? onProgress,
  }) async {
    final urls = <String>[];
    int completed = 0;

    for (var file in files) {
      final fileName = file.path.split('/').last;
      final path = '$basePath/$fileName';

      final url = await uploadFile(file: file, path: path);

      if (url != null) {
        urls.add(url);
      }

      completed++;
      onProgress?.call(completed, files.length);
    }

    return urls;
  }

  /// Delete file
  static Future<bool> deleteFile({required String path}) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Delete file by URL
  static Future<bool> deleteFileByUrl({required String url}) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file by URL: $e');
      return false;
    }
  }

  /// Get download URL
  static Future<String?> getDownloadUrl({required String path}) async {
    try {
      final url = await _storage.ref().child(path).getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists({required String path}) async {
    try {
      await _storage.ref().child(path).getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  static Future<FullMetadata?> getMetadata({required String path}) async {
    try {
      final metadata = await _storage.ref().child(path).getMetadata();
      return metadata;
    } catch (e) {
      print('Error getting metadata: $e');
      return null;
    }
  }

  /// List files in directory
  static Future<List<String>> listFiles({required String path}) async {
    try {
      final result = await _storage.ref().child(path).listAll();
      final urls = <String>[];

      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  // Helper methods untuk path generation

  /// Generate user avatar path
  static String getUserAvatarPath(String userId) {
    return 'users/$userId/avatar.jpg';
  }

  /// Generate course thumbnail path
  static String getCourseThumbnailPath(String courseId) {
    return 'courses/$courseId/thumbnail.jpg';
  }

  /// Generate lesson content path
  static String getLessonContentPath(String lessonId, String fileName) {
    return 'lessons/$lessonId/$fileName';
  }

  /// Generate achievement icon path
  static String getAchievementIconPath(String achievementId) {
    return 'achievements/$achievementId/icon.png';
  }
}
