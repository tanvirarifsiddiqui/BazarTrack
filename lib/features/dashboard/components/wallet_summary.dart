/*
// Title: Assistant Wallet — Single Card List View
// Description: Show list of assistants and balances inside one full-width card
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 10:22 AM
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/price_format.dart';
import '../../../util/dimensions.dart';
import '../../finance/model/assistant.dart';
import '../assistant_dashboard_details_screen.dart';


// WalletSummary showing ALL assistants inside a single full-width card.
class WalletSummary extends StatelessWidget {
  final ThemeData theme;
  final List<Assistant> assistants;
  final EdgeInsetsGeometry padding;

  const WalletSummary({
    required this.theme,
    required this.assistants,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = theme.textTheme;

    if (assistants.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
          ),
          child: Padding(
            padding: padding,
            child: Text('No assistants found', style: textTheme.bodyMedium),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity, // ensures the card takes maximum available width
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius)),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Assistant Wallets',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${assistants.length} ${assistants.length == 1? 'assistant': 'assistants'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // list of assistants (in same card)
              Column(
                children: List.generate(assistants.length, (i) {
                  final assistant = assistants[i];
                  return Column(
                    children: [
                      _AssistantRow(
                        assistant: assistant,
                        theme: theme,
                        initials: _initials(assistant.name),
                        onPressed: (){
                          Get.to(() => AssistantDashboardDetails(assistant: assistant));
                        }
                      ),
                      if (i < assistants.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Divider(height: 1, color: Colors.grey[300]),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantRow extends StatelessWidget {
  final Assistant assistant;
  final ThemeData theme;
  final String initials;
  final GestureTapCallback onPressed;

  const _AssistantRow({
    required this.assistant,
    required this.theme,
    required this.initials,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = theme.textTheme;
    final avatarColor = theme.primaryColor;

    return InkWell(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: textTheme.titleMedium?.copyWith(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name column now centered vertically so it lines up with the avatar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // name (now visually centered relative to avatar)
                Text(
                  assistant.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(width: 12),

          // Balance (prominent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatPrice(assistant.balance),
                style: textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
