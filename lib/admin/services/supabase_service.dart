import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final res = await supabase.storage
          .from('curly_images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      if (res != null) {
        final publicUrl = supabase.storage.from('curly_images').getPublicUrl(fileName);
        return publicUrl;
      }
    } catch (e) {
      }
    return null;
  }
}
