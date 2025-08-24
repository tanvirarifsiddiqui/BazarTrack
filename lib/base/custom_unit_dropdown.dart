import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/input_decoration.dart';

class Unit {
  final String short;
  final String full;

  Unit(this.short, this.full);
}

class UnitDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  UnitDropdown({super.key, this.value, required this.onChanged});

  // Units list
  final List<Unit> _units = [
    Unit("pcs", "Pieces"),
    Unit("kg", "KG"),
    Unit("gm", "Gram"),
    Unit("ltr", "Liter"),
    Unit("ml", "mL"),
    Unit("dozen", "Dozen"),
    Unit("packet", "Packet"),
    Unit("bag", "Bag"),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: AppInputDecorations.generalInputDecoration(
        label: "Unit",
        prefixIcon: Icons.straighten,
      ),
      items:
          _units.map((unit) {
            return DropdownMenuItem(
              value: unit.short, // 👈 only short form will be selected
              child: Text(unit.full), // 👈 full form will be displayed
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
