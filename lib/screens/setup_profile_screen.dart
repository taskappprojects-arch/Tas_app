import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/user_profile.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/main_layout.dart';

class SetupProfileScreen extends StatefulWidget {
  final String phoneNumber;
  
  const SetupProfileScreen({super.key, required this.phoneNumber});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _saveProfile(BuildContext context) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final profile = UserProfile(
      name: _nameController.text,
      phone: widget.phoneNumber,
    );

    Provider.of<UserProvider>(context, listen: false).saveProfile(profile);
    Provider.of<TaskProvider>(context, listen: false).completeOnboarding();

    // Reset navigation stack to MainLayout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainLayout()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('setup_profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.account_circle, size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 40),
            Text(
              'Verified: ${widget.phoneNumber}',
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: lang.translate('name'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(lang.translate('save'), style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
