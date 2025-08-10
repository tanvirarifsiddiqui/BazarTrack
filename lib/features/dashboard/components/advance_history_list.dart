/*
// Title: Advance History
// Description: Advance History for Owner
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 10:48 AM
*/

import 'package:flutter/material.dart';

/// 3. Advance History List
class AdvanceHistory extends StatelessWidget {
  final ThemeData theme;
  const AdvanceHistory(this.theme);

  @override
  Widget build(BuildContext context) {
    final advances = [
      {'date': '2025-08-10', 'amt': '৳150'},
      {'date': '2025-08-08', 'amt': '৳200'},
      {'date': '2025-08-05', 'amt': '৳100'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advance History', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ListView.separated(
              itemCount: advances.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, idx) {
                final adv = advances[idx];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(adv['amt']!),
                  subtitle: Text(adv['date']!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}