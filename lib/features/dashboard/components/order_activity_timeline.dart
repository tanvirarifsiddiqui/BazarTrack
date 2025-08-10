/*
// Title: Order Activity Timeline
// Description: Timeline for showing owners and assistants activity.
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 11:02 AM
*/

// 4. Order Activity Timeline
import 'package:flutter/material.dart';

class OrderActivityTimeline extends StatelessWidget {
  final ThemeData theme;
  const OrderActivityTimeline(this.theme);

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'time': '10:00 AM', 'event': 'Order #123 created'},
      {'time': '10:30 AM', 'event': 'Assigned to Assistant #45'},
      {'time': '11:00 AM', 'event': 'Item #456 marked purchased'},
      {'time': '12:00 PM', 'event': 'Order #123 completed'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Activity', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Column(
              children:
              activities.map((act) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (act != activities.last)
                          Container(
                            width: 2,
                            height: 40,
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act['time']!,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(act['event']!),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}