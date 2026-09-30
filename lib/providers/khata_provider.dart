import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/khata.dart';

class KhataProvider with ChangeNotifier {
  List<KhataModel> _khatas = [];
  final Box<String> _khataBox = Hive.box<String>('khataBox');

  List<KhataModel> get allKhatas => _khatas;
  
  double get totalOwedToMe => _khatas.where((k) => k.amount > 0).fold(0, (sum, item) => sum + item.amount);
  double get totalIOwe => _khatas.where((k) => k.amount < 0).fold(0, (sum, item) => sum + (item.amount * -1));

  KhataProvider() {
    _loadData();
  }

  void _loadData() {
    final List<String> khataList = _khataBox.values.toList();
    _khatas = khataList.map((kStr) => KhataModel.fromJson(kStr)).toList();
    notifyListeners();
  }

  void _saveData() {
    _khataBox.clear();
    for (var khata in _khatas) {
      _khataBox.add(khata.toJson());
    }
  }

  void addKhata(KhataModel khata) {
    _khatas.add(khata);
    _saveData();
    notifyListeners();
  }

  void deleteKhata(String id) {
    _khatas.removeWhere((k) => k.id == id);
    _saveData();
    notifyListeners();
  }
  
  void updateKhata(String id, double newAmount) {
    final index = _khatas.indexWhere((k) => k.id == id);
    if (index != -1) {
      final updated = KhataModel(
        id: _khatas[index].id,
        name: _khatas[index].name,
        phone: _khatas[index].phone,
        amount: newAmount,
        reason: _khatas[index].reason,
      );
      _khatas[index] = updated;
      _saveData();
      notifyListeners();
    }
  }

  Future<void> sendWhatsAppReminder(KhataModel khata, bool isBengali) async {
    if (khata.phone.isEmpty) return;
    
    // Ensure phone has country code, default to +91 if missing
    String phone = khata.phone;
    if (!phone.startsWith('+')) phone = '+91$phone';
    
    String message = _buildMessage(khata, isBengali);
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final Uri url = Uri.parse("whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}");
    
    try {
      bool launched = await launchUrl(url);
      if (!launched) {
        throw Exception("Failed to launch whatsapp://");
      }
    } catch (e) {
      final Uri webUrl = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> sendSmsReminder(KhataModel khata, bool isBengali) async {
    if (khata.phone.isEmpty) return;
    
    String phone = khata.phone;
    if (!phone.startsWith('+')) phone = '+91$phone';
    
    String message = _buildMessage(khata, isBengali);
    final Uri smsUrl = Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    }
  }

  String _buildMessage(KhataModel khata, bool isBengali) {
    String message = isBengali ? "নমস্কার ${khata.name},\n" : "Hi ${khata.name},\n";
    
    if (khata.amount > 0) {
      if (isBengali) {
        message += "আপনার কাছে আমার ₹${khata.amount} টাকা বাকি আছে।";
      } else {
        message += "You owe me ₹${khata.amount}.";
      }
    } else {
      if (isBengali) {
        message += "আমি আপনার কাছে ₹${khata.amount * -1} টাকা ঋণী, আমি দ্রুত পরিশোধ করবো।";
      } else {
        message += "I owe you ₹${khata.amount * -1}. I will pay you as soon as possible.";
      }
    }

    if (khata.reason != null && khata.reason!.isNotEmpty) {
      if (isBengali) {
        message += "\nকারণ: ${khata.reason}";
      } else {
        message += "\nReason: ${khata.reason}";
      }
    }

    if (khata.amount > 0) {
      if (isBengali) {
        message += "\nদয়া করে দ্রুত পরিশোধ করুন।";
      } else {
        message += "\nPlease pay as soon as possible.";
      }
    }
    
    return message;
  }
}
