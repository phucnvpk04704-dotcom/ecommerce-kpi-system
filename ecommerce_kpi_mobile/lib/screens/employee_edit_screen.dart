import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/custom_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/employee_service.dart';

class EmployeeEditScreen extends StatefulWidget {
  final String employeeId;
  final EmployeeService? service;

  const EmployeeEditScreen({
    super.key,
    required this.employeeId,
    this.service,
  });

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'Employee';
  String _selectedDepartment = 'Marketing';
  String _selectedPlatform = 'Shopee';
  bool _dataLoaded = false;

  final List<String> _roles = ['Employee', 'Manager', 'Admin'];
  final List<String> _departments = ['Marketing', 'Sales', 'Customer Support', 'Logistics', 'Development', 'Operations'];
  final List<String> _platforms = ['Shopee'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFields(dynamic employee) {
    if (_dataLoaded) return;
    _nameController.text = employee.fullName;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone;
    _selectedRole = employee.role;
    _selectedDepartment = employee.department;
    _selectedPlatform = employee.platform;
    _dataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<EmployeeProvider>(
      create: (_) => EmployeeProvider(service: widget.service)..loadEmployeeById(widget.employeeId),
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          final employee = provider.selectedEmployee;
          if (employee != null) {
            _initFields(employee);
          }

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Edit Employee'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: provider.loading && employee == null
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

                                // Full Name
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  hint: 'Enter employee full name',
                                  icon: Icons.person_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter name';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hint: 'Enter email address',
                                  icon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter email';
                                    }
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  hint: 'Enter phone number',
                                  icon: Icons.phone_rounded,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    if (value.trim().length < 9 || value.trim().length > 15) {
                                      return 'Phone number must be between 9 and 15 digits';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Role Dropdown
                                _buildDropdownField(
                                  label: 'Role Position',
                                  value: _selectedRole,
                                  items: _roles,
                                  icon: Icons.work_rounded,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedRole = val;
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
                                const SizedBox(height: 16),

                                // Platform Dropdown
                                _buildDropdownField(
                                  label: 'Platform',
                                  value: _selectedPlatform,
                                  items: _platforms,
                                  icon: Icons.storefront_rounded,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedPlatform = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Submit Button
                                provider.loading
                                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF5722),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _submitForm(context, provider, employee!),
                                        child: const Text(
                                          'Update Employee',
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

  Widget _buildErrorContent(BuildContext context, EmployeeProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading profile details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadEmployeeById(widget.employeeId),
            child: const Text('Retry'),
          ),
        ],
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

  void _submitForm(BuildContext context, EmployeeProvider provider, dynamic employee) async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'department': _selectedDepartment,
        'platform': _selectedPlatform,
        'status': employee.status,
      };

      final success = await provider.updateEmployee(employee.id, data);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee profile updated successfully!'), backgroundColor: Colors.green),
          );
          context.go('/employees/${employee.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? 'Failed to update profile.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
