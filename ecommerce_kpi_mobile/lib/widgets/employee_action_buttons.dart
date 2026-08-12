import 'package:flutter/material.dart';

class EmployeeActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const EmployeeActionButtons({
    super.key,
    required this.status,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isActive ? Colors.orange : Colors.green),
                  foregroundColor: isActive ? Colors.orange : Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  isActive ? 'Disable' : 'Enable',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onToggleStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            foregroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text('Delete Employee', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
