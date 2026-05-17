import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized URL construction for Supabase Storage paths.
///
/// The database stores only relative paths (e.g. `avatars/{userId}/avatar.jpg`).
/// Full URLs are constructed at runtime via this utility.
class StorageUtils {
  const StorageUtils._();

  /// Constructs public URL for files in public-assets bucket.
  static String publicUrl(String relativePath) =>
      Supabase.instance.client.storage
          .from('public-assets')
          .getPublicUrl(relativePath);

  /// Constructs signed URL for files in private-files bucket.
  static Future<String> signedUrl(
    String relativePath, {
    Duration expiry = const Duration(hours: 1),
  }) =>
      Supabase.instance.client.storage
          .from('private-files')
          .createSignedUrl(relativePath, expiry.inSeconds);
}
