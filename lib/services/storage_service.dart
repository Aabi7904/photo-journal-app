import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  // IMPORTANT: Replace these with your actual Cloudinary credentials
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'YOUR_CLOUD_NAME', // <-- Replace with your Cloud Name
    'YOUR_UPLOAD_PRESET', // <-- Replace with your Upload Preset
    cache: false,
  );

  // Method to upload an image file and return its public URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Upload the file to Cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      // Return the secure URL of the uploaded image
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print("Error uploading image: ${e.message}");
      return null;
    }
  }
}
