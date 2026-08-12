import 'package:flutter/material.dart';

class CustomerActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerActionButtons({
    super.key,
    required this.status,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status.trim().toLowerCase() == 'active';

    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800), // Green for resolve, Orange for reactivate
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(isActive ? Icons.check_circle_outline_rounded : Icons.replay_rounded, size: 18),
          label: Text(
            isActive ? 'Resolve Alert Status' : 'Reactivate Incident Alert',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: onToggleStatus,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF5722)),
                  foregroundColor: const Color(0xFFFF5722),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
