import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/blacklist_provider.dart';
import '../services/blacklist_service.dart';

class BlacklistCreateScreen extends StatefulWidget {
  final BlacklistService? service;

  const BlacklistCreateScreen({
    super.key,
    this.service,
  });

  @override
  State<BlacklistCreateScreen> createState() => _BlacklistCreateScreenState();
}

class _BlacklistCreateScreenState extends State<BlacklistCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cancelCountController = TextEditingController(text: '0');
  final _returnCountController = TextEditingController(text: '0');
  final _complaintCountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  String _selectedRisk = 'Warning';
  String _selectedPlatform = 'Shopee';

  final List<String> _riskLevels = ['High', 'Warning', 'Safe'];
  final List<String> _platforms = ['Shopee', 'Lazada', 'TikTok'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cancelCountController.dispose();
    _returnCountController.dispose();
    _complaintCountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<BlacklistProvider>(
      create: (_) => BlacklistProvider(service: widget.service),
      child: Consumer<BlacklistProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Add Blacklist Customer'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1D0308) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Profile Details',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Customer Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Customer Full Name',
                        hint: 'Enter customer name',
                        icon: Icons.person_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter customer name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Platform Dropdown
                      _buildDropdownField(
                        label: 'Platform Origin',
                        value: _selectedPlatform,
                        items: _platforms,
                        icon: Icons.store_rounded,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPlatform = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Risk Level Dropdown
                      _buildDropdownField(
                        label: 'Risk Level Assessment',
                        value: _selectedRisk,
                        items: _riskLevels,
                        icon: Icons.gavel_rounded,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRisk = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text('Violation Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // Cancellation Count
                      _buildTextField(
                        controller: _cancelCountController,
                        label: 'Cancel Orders Count',
                        hint: '0',
                        icon: Icons.cancel_presentation_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter count';
                          final val = int.tryParse(value);
                          if (val == null || val < 0) return 'Must be 0 or positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Return Count
                      _buildTextField(
                        controller: _returnCountController,
                        label: 'Refunds / Returns Count',
                        hint: '0',
                        icon: Icons.replay_circle_filled_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter count';
                          final val = int.tryParse(value);
                          if (val == null || val < 0) return 'Must be 0 or positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Complaint Count
                      _buildTextField(
                        controller: _complaintCountController,
                        label: 'Complaints Counts',
                        hint: '0',
                        icon: Icons.announcement_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter count';
                          final val = int.tryParse(value);
                          if (val == null || val < 0) return 'Must be 0 or positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Note field
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Admin Description Note',
                          hintText: 'Enter specific details about the behavior or issue...',
                          prefixIcon: const Icon(Icons.note_alt_rounded, color: Color(0xFFFF5722), size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      provider.loading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _submitForm(context, provider),
                              child: const Text(
                                'Save Customer Profile',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFFF5722), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF5722), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submitForm(BuildContext context, BlacklistProvider provider) async {
    if (_formKey.currentState!.validate()) {
      final nowStr = DateTime.now().toIso8601String().substring(0, 10);
      final data = {
        'customer_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'platform': _selectedPlatform,
        'risk_level': _selectedRisk,
        'cancel_count': int.tryParse(_cancelCountController.text.trim()) ?? 0,
        'return_count': int.tryParse(_returnCountController.text.trim()) ?? 0,
        'complaint_count': int.tryParse(_complaintCountController.text.trim()) ?? 0,
        'note': _noteController.text.trim(),
        'status': 'Active',
        'last_order_date': nowStr,
        'last_violation_date': nowStr,
      };

      final success = await provider.createCustomer(data);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added to blacklist successfully!'), backgroundColor: Colors.green),
          );
          context.go('/blacklist_screen');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'Failed to create blacklist customer.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
