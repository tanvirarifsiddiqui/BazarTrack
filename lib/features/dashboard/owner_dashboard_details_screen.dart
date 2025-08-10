/*
// Title: Owner's Dashboard Screen
// Description: Stats, Assistant's Wallet Summary, Advance History, Order Activity Timeline
// Author: Md. Tanvir Arif Siddiqui
// Date: August 10, 2025
// Time: 9:36 AM
*/

// lib/features/dashboard/screens/owner_dashboard_details.dart

import 'package:flutter/material.dart';
import 'components/advance_history_list.dart';
import 'components/order_activity_timeline.dart';
import 'components/stats_summary.dart';
import 'components/wallet_summary.dart';

class OwnerDashboardDetails extends StatelessWidget {
  const OwnerDashboardDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = SizedBox(height: 16);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatsSummary(theme),
            spacing,
            WalletSummary(
              theme: theme,
              assistants: [
                Assistant(name: 'Zaid Hasan', balance: 1600.0),
                Assistant(name: 'Aisha', balance: 1450.0),
                Assistant(name: 'Omar Faruk',  balance: 2100.0),
              ],
            ),
            spacing,
            AdvanceHistory(theme),
            spacing,
            OrderActivityTimeline(theme),
          ],
        ),
      ),
    );
  }
}

