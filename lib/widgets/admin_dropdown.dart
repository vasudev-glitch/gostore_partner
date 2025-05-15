import 'package:flutter/material.dart';
import 'package:gostore_partner/utils/ui_config.dart';

class AdminDropdown extends StatelessWidget {
  final String? current;
  final List<Map<String, String>> admins;
  final ValueChanged<String?> onChanged;

  const AdminDropdown({
    super.key,
    required this.current,
    required this.admins,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: current,
      hint: Text("Assign Admin", style: AppTextStyle.caption(context)),
      items: admins.map((admin) {
        final uid = admin['uid']!;
        final name = admin['name']!;
        return DropdownMenuItem<String>(
          value: uid,
          child: Text(name),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
