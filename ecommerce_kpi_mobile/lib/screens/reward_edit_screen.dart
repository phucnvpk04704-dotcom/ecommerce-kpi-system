import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/reward_provider.dart';
import '../services/reward_service.dart';

class RewardEditScreen extends StatefulWidget {
  final String rewardId;
  final RewardService? service;

  const RewardEditScreen({
    super.key,
    required this.rewardId,
    this.service,
  });

  @override
  State<RewardEditScreen> createState() => _RewardEditScreenState();
}

class _RewardEditScreenState extends State<RewardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _kpiScoreController = TextEditingController();
  final _amountController = TextEditingController();
  final _typeController = TextEditingController();

  String _selectedPeriod = 'monthly';
  String _selectedDepartment = 'Marketing';
  bool _dataLoaded = false;

  final List<String> _periods = ['monthly', 'weekly'];
  final List<String> _departments = ['Marketing', 'Sales', 'Customer Support', 'Logistics', 'Development', 'Operations'];

  @override
  void dispose() {
    _employeeNameController.dispose();
    _employeeIdController.dispose();
    _kpiScoreController.dispose();
    _amountController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _initFields(dynamic reward) {
    if (_dataLoaded) return;
    _employeeNameController.text = reward.employeeName;
    _employeeIdController.text = reward.employeeId;
    _kpiScoreController.text = reward.kpiScore.toString();
    _amountController.text = reward.rewardAmount.toString();
    _typeController.text = reward.rewardType;
    _selectedPeriod = reward.period.toLowerCase();
    _selectedDepartment = reward.department;
    _dataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<RewardProvider>(
      create: (_) => RewardProvider(service: widget.service)..loadReward(widget.rewardId),
      child: Consumer<RewardProvider>(
        builder: (context, provider, child) {
          final reward = provider.selectedReward;
          if (reward != null) {
            _initFields(reward);
          }

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Edit Reward Proposal'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: provider.loading && reward == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                : provider.error != null
                    ? _buildErrorContent(context, provider)
                    : SingleChildScrollView(
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
                                  'Update Details',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),

                                // Employee Name
                                _buildTextField(
                                  controller: _employeeNameController,
                                  label: 'Employee Full Name',
                                  hint: 'Enter full name',
                                  icon: Icons.person_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter employee name';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Employee ID
                                _buildTextField(
                                  controller: _employeeIdController,
                                  label: 'Employee ID',
                                  hint: 'Enter employee ID',
                                  icon: Icons.badge_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter employee ID';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // KPI Score
                                _buildTextField(
                                  controller: _kpiScoreController,
                                  label: 'KPI Score (%)',
                                  hint: 'Enter KPI score (e.g. 95.0)',
                                  icon: Icons.star_rounded,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter KPI score';
                                    final val = double.tryParse(value);
                                    if (val == null || val < 0 || val > 100) return 'KPI score must be between 0 and 100';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Reward Type
                                _buildTextField(
                                  controller: _typeController,
                                  label: 'Reward Type',
                                  hint: 'Enter type (e.g. Cash Bonus, Gift Voucher)',
                                  icon: Icons.card_giftcard_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter reward type';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Reward Amount
                                _buildTextField(
                                  controller: _amountController,
                                  label: 'Reward Amount (VND)',
                                  hint: 'Enter bonus value amount',
                                  icon: Icons.monetization_on_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Please enter reward amount';
                                    final val = double.tryParse(value);
                                    if (val == null || val <= 0) return 'Reward amount must be a positive number';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Period Dropdown
                                _buildDropdownField(
                                  label: 'Calculation Period',
                                  value: _selectedPeriod,
                                  items: _periods,
                                  icon: Icons.calendar_today_rounded,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedPeriod = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Department Dropdown
                                _buildDropdownField(
                                  label: 'Department',
                                  value: _selectedDepartment,
                                  items: _departments,
                                  icon: Icons.business_rounded,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedDepartment = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Submit
                                provider.loading
                                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF5722),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _submitForm(context, provider, reward!),
                                        child: const Text(
                                          'Update Proposal',
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

  void _submitForm(BuildContext context, RewardProvider provider, dynamic reward) async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'employee_id': _employeeIdController.text.trim(),
        'employee_name': _employeeNameController.text.trim(),
        'kpi_score': double.tryParse(_kpiScoreController.text.trim()) ?? 0.0,
        'reward_amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
        'reward_type': _typeController.text.trim(),
        'period': _selectedPeriod,
        'department': _selectedDepartment,
        'reward_status': reward.rewardStatus,
      };

      final success = await provider.updateReward(reward.id, data);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reward proposal updated successfully!'), backgroundColor: Colors.green),
          );
          context.go('/reward_detail_screen/${reward.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'Failed to update proposal.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildErrorContent(BuildContext context, RewardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadReward(widget.rewardId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
