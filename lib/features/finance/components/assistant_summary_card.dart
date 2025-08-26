import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../assistant_finance_screen.dart';
import '../controller/assistant_finance_controller.dart';
import '../model/assistant.dart';
import 'assistant_row.dart';

/// A Card that shows the total and list of assistants.
class AssistantSummaryCard extends StatelessWidget {
  final List<Assistant> assistants;
  const AssistantSummaryCard({
    required this.assistants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts    = theme.textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputFieldBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title + count chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Assistants',
                    style: ts.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  label: Text(
                    '${assistants.length}',
                    style: ts.bodyMedium
                        ?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Static list of assistant rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assistants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final a = assistants[i];
                return AssistantRow(
                  assistant: a,
                  onTap: () {
                    Get.to(
                          () => AssistantFinancePage(assistant: a),
                      binding: BindingsBuilder(() {
                        final uid  = a.id;
                        Get.put(AssistantFinanceController(
                          repo:   Get.find(),
                          userId: uid,
                        ));
                      }),
                    );

                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}