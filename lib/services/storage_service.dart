import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:logger/logger.dart';

class StorageService {
  final logger = Logger();
  
  // IMPORTANT: Make sure these credentials are correct
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'djixq1dhs', // <-- Your Cloud Name
    'ml_default', // <-- Your Upload Preset
    cache: false,
  );

  // Method to upload an image file and return its public URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Upload the file to Cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      // Return the secure URL of the uploaded image
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      // Use the logger to print the detailed error
      logger.e("Cloudinary Error: ${e.message}");
      return null;
    }
  }
}

