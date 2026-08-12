import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/custom_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/employee_service.dart';
import '../../widgets/employee_avatar.dart';
import '../../widgets/employee_status_badge.dart';
import '../../widgets/employee_information.dart';
import '../../widgets/employee_statistics.dart';
import '../../widgets/employee_action_buttons.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;
  final EmployeeService? service;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
    this.service,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}


class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<EmployeeProvider>(
      create: (_) => EmployeeProvider(service: widget.service)..loadEmployeeById(widget.employeeId),
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          final employee = provider.selectedEmployee;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Employee Details'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: provider.loading && employee == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : provider.error != null
                      ? _buildErrorContent(context, provider)
                      : employee == null
                          ? _buildEmptyContent(context)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth >= 600;
                                return SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header Info
                                      _buildHeaderSection(context, employee),
                                      const SizedBox(height: 24),

                                      // Main split details
                                      if (isTablet)
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: EmployeeInformation(employee: employee),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  EmployeeStatistics(employee: employee),
                                                  const SizedBox(height: 24),
                                                  EmployeeActionButtons(
                                                    status: employee.status,
                                                    onEdit: () {
                                                      context.go('/employees/${employee.id}/edit');
                                                    },
                                                    onToggleStatus: () => _toggleEmployeeStatus(context, provider, employee),
                                                    onDelete: () => _confirmDelete(context, provider, employee),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Column(
                                          children: [
                                            EmployeeStatistics(employee: employee),
                                            const SizedBox(height: 20),
                                            EmployeeInformation(employee: employee),
                                            const SizedBox(height: 24),
                                            EmployeeActionButtons(
                                              status: employee.status,
                                              onEdit: () {
                                                context.go('/employees/${employee.id}/edit');
                                              },
                                              onToggleStatus: () => _toggleEmployeeStatus(context, provider, employee),
                                              onDelete: () => _confirmDelete(context, provider, employee),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                );
                              },
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

  Widget _buildEmptyContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Employee profile not found'),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, dynamic employee) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          EmployeeAvatar(
            avatar: employee.avatar,
            fullName: employee.fullName,
            radius: 40,
          ),
          const SizedBox(height: 12),
          Text(
            employee.fullName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            employee.role,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          EmployeeStatusBadge(status: employee.status),
        ],
      ),
    );
  }

  void _toggleEmployeeStatus(BuildContext context, EmployeeProvider provider, dynamic employee) async {
    final newStatus = employee.status.toLowerCase() == 'active' ? 'Inactive' : 'Active';
    final success = await provider.changeStatus(employee.id, newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Employee is now $newStatus.' : 'Failed to update employee status.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, EmployeeProvider provider, dynamic employee) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Employee'),
          content: Text('Are you sure you want to permanently delete ${employee.fullName}? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await provider.deleteEmployee(employee.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Employee deleted.' : 'Failed to delete employee.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) {
                    context.go('/employees');
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
