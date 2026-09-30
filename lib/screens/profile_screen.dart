import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    final profile = userProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: lang.translate('logout'),
          )
        ],
      ),
      body: profile == null ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(profile.phone, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            
            const SizedBox(height: 30),
            
            // Stats Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('🪙', taskProvider.totalCoins.toString(), 'Coins'),
                    _buildStatColumn('✅', taskProvider.completedTasks.length.toString(), 'Tasks'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Language Settings
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text(lang.translate('select_language')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLanguageDialog(context, lang);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: Text(lang.translate('about_us')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("About App"),
                    content: Text("To-Do & Productivity App V4.0"),
                  )
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String icon, String count, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(lang.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: lang.currentLang == 'en' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  lang.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('বাংলা'),
                trailing: lang.currentLang == 'bn' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  lang.setLanguage('bn');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('हिन्दी'),
                trailing: lang.currentLang == 'hi' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  lang.setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }
}
