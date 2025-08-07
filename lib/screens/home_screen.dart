import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_journal_app/models/journal_entry_model.dart';
import 'package:photo_journal_app/services/auth_service.dart';
import 'package:photo_journal_app/services/firerstore_service.dart';

// We will create this screen in the next step
import 'package:photo_journal_app/screens/add_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AUthService _authService = AUthService();
  final FirerstoreService _firestoreService = FirerstoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Journal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<JournalEntry>>(
        // Listen to the stream of entries from Firestore
        //it will get the userids entry alone
        stream: _firestoreService.getEntries(currentUser!.uid),
        //tis will build the data using snapshot
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Your journal is empty.\nTap the '+' button to add your first entry!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          //stores the data in entries
          //returning as a list od cards using cutom made widget 
          final entries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              //this entry will have the each index data to build seperate cards
              final entry = entries[index];
              return _buildEntryCard(entry);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddEntryScreen(),
          ));
        },
        backgroundColor: Colors.blueGrey.shade700,
        tooltip: 'Add New Entry',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  //custom widget card to show the entry
  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the image if it exists
          if (entry.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                entry.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                // Show a loading indicator while the image loads
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(heightFactor: 4, child: CircularProgressIndicator());
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  // Format the date to be more readable
                  DateFormat('MMMM d, yyyy').format(entry.createdAt.toDate()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  entry.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          // Add a delete button
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => _firestoreService.deleteEntry(entry.id),
              tooltip: 'Delete Entry',
            ),
          )
        ],
      ),
    );
  }
}
