import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_journal_app/services/firerstore_service.dart';
import 'package:photo_journal_app/services/storage_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final FirerstoreService _firerstoreService = FirerstoreService();
  final StorageService _storageService = StorageService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  // Method to let the user pick an image from their gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Method to save the journal entry
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? imageUrl;
        // 1. If an image was selected, upload it first
        if (_selectedImage != null) {
          imageUrl = await _storageService.uploadImage(_selectedImage!);
          if (imageUrl == null) {
            // Handle upload failure
            showToast(
              "Error: Image could not be uploaded.",
              position: ToastPosition.bottom,
            );
            setState(() => _isLoading = false);
            return; // Stop the process if upload fails
          }
          showToast("Image Upload Successful! URL: $imageUrl");
        }
        showToast("Firestore save successful!");

        // 2. Save the journal entry to Firestore
        await _firerstoreService.addEntry(
          userId: currentUser!.uid,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          imageUrl: imageUrl, // This will be null if no image was picked
        );

        showToast("Entry Saved!", position: ToastPosition.bottom);

        // 3. Go back to the home screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // If any error occurs in the process, it will be caught here
        showToast("!! AN ERROR OCCURRED: $e");
        showToast(
          "An unexpected error occurred. Please try again.",
          position: ToastPosition.bottom,
        );
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Entry"),
        actions: [
          // The save button is in the app bar
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveEntry,
            tooltip: 'Save Entry',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image preview and selection button
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a title" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: "What's on your mind?",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) =>
                          value!.isEmpty ? "Please write something" : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: _selectedImage != null
            // If an image is selected, show it
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.fitWidth),
              )
            // Otherwise, show an icon and text
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text("Add a photo", style: TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
