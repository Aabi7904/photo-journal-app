//this helps to use files form mobile
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
//instead of print we use logger package
import 'package:logger/logger.dart';

class StorageService {
  final logger = Logger();
  // IMPORTANT: Replace these with your actual Cloudinary credentials
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'djljxq1dhs', // <-- Replace with your Cloud Name
    'ml_default', // <-- Replace with your Upload Preset
    cache: false,
  );

  // Method to upload an image file and return its public URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Upload the file to Cloudinary
      //HERE WE upload the image file to cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        //this will upload your image into a cloudinary accceptable file
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      // Return the secure URL of the uploaded image
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      logger.e("Error uploading image: ${e.message}");
      return null;
    }
  }
}
