import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app/models/khata.dart';
import 'package:todo_app/providers/khata_provider.dart';
import 'package:todo_app/providers/language_provider.dart';

class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key});

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  void _showAddKhataDialog(BuildContext context, LanguageProvider lang) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String phoneNumber = '';
    bool isYouGet = true;

    Future<void> pickContact() async {
      try {
        var status = await Permission.contacts.status;
        if (!status.isGranted) {
          status = await Permission.contacts.request();
        }

        if (status.isGranted) {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null) {
            nameController.text = contact.displayName;
            if (contact.phones.isNotEmpty) {
              String num = contact.phones.first.number.replaceAll(RegExp(r'[^\d]'), '');
              if (num.startsWith('91') && num.length > 10) {
                 num = num.substring(2);
              } else if (num.startsWith('0') && num.length > 10) {
                 num = num.substring(1);
              }
              phoneController.text = num;
              phoneNumber = num;
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected contact has no phone number.')));
              }
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang.translate('contact_permission_denied')),
                action: SnackBarAction(
                  label: lang.translate('open_settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Error picking contact: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      lang.translate('add_person'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: lang.translate('name'),
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.contacts, color: Colors.blue),
                          onPressed: pickContact,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    IntlPhoneField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      initialCountryCode: 'IN', // Defaults to +91
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: lang.translate('amount'),
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        hintText: '${lang.translate('description')} (${lang.translate('optional')})',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: true, label: Text(lang.translate('you_will_get'), style: const TextStyle(fontSize: 12, color: Colors.green))),
                        ButtonSegment(value: false, label: Text(lang.translate('you_will_give'), style: const TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                      selected: {isYouGet},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          isYouGet = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty && phoneNumber.isNotEmpty && amountController.text.isNotEmpty) {
                          double amount = double.parse(amountController.text);
                          if (!isYouGet) {
                            amount = -amount;
                          }
                          final khata = KhataModel(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            phone: phoneNumber,
                            amount: amount,
                            reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                          );
                          Provider.of<KhataProvider>(context, listen: false).addKhata(khata);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(lang.translate('save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final khataProvider = Provider.of<KhataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('due_tracker')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddKhataDialog(context, lang),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    title: lang.translate('you_will_get'),
                    amount: khataProvider.totalOwedToMe,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryBox(
                    title: lang.translate('you_will_give'),
                    amount: khataProvider.totalIOwe,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: khataProvider.allKhatas.isEmpty
                ? Center(child: Text(lang.translate('no_dues'), style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: khataProvider.allKhatas.length,
                    itemBuilder: (context, index) {
                      final khata = khataProvider.allKhatas[index];
                      final isGet = khata.amount > 0;
                      final amountColor = isGet ? Colors.green : Colors.red;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    khata.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: amountColor.withValues(alpha: 0.1),
                                      child: Icon(Icons.person, color: amountColor, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => khataProvider.deleteKhata(khata.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              khata.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            if (khata.reason != null && khata.reason!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                khata.reason!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${khata.amount > 0 ? '+' : ''}₹${khata.amount.abs().toStringAsFixed(0)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: amountColor),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => khataProvider.sendSmsReminder(khata, lang.isBengali),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: const Row(children: [Icon(Icons.message, size: 16, color: Colors.blue), SizedBox(width: 4), Text('SMS', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))]),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => khataProvider.sendWhatsAppReminder(khata, lang.isBengali),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: const Row(children: [FaIcon(FontAwesomeIcons.whatsapp, size: 16, color: Colors.green), SizedBox(width: 4), Text('WhatsApp', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryBox({required String title, required double amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
