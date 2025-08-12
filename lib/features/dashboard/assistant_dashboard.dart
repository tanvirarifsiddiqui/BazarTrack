import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/base/custom_app_bar.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard_details_screen.dart';
import 'package:flutter_boilerplate/features/finance/advance_screen.dart';
import 'package:flutter_boilerplate/features/finance/assistant_finance_screen.dart';
import 'package:flutter_boilerplate/features/profile/profile_screen.dart';
import 'package:get/get.dart';
import '../orders/order_list_screen.dart';

class AssistantDashboard extends StatefulWidget {
  const AssistantDashboard({super.key});

  @override
  State<AssistantDashboard> createState() => _AssistantDashboardState();
}

class _AssistantDashboardState extends State<AssistantDashboard> {
  int _currentIndex = 0;

  // Keep screens in state to avoid recreating them on each build
  late final List<Widget> _screens;

  // Titles for AppBar (use .tr for translations if desired)
  final List<String> _titles = [
    'owners_dashboard',
    'view_orders',
    'finance',
    'history',
  ];

  // preserve scroll / widget state between tabs
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _screens = [
      const OwnerDashboardDetails(),
      const OrderListScreen(),
      const AssistantFinancePage(),
      const AdvanceScreen(),
    ];
  }

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // use your custom app bar but make it a little more functional
      appBar: CustomAppBar(
        title: _titles[_currentIndex].tr,
        // optional actions: search / notifications
        actions: [

          IconButton(
            tooltip: 'profile'.tr,
            icon: const Icon(CupertinoIcons.profile_circled),
            onPressed: () {
              Get.to(
                    () => ProfileScreen(),
                transition: Transition.cupertino, // or try others like fadeIn, zoom, rightToLeft
                duration: const Duration(milliseconds: 400),
              );
            },
          ),

        ],
      ),

      // keep children alive and preserve scroll positions
      body: SafeArea(
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _currentIndex,
            children: _screens
                .asMap()
                .map((i, w) => MapEntry(i, KeyedSubtree(key: PageStorageKey('tab_$i'), child: w)))
                .values
                .toList(),
          ),
        ),
      ),

      // Elevated container for the BottomNavigationBar (rounded + shadow)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed, // ensures labels always visible
            backgroundColor: colorScheme.surface,
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
            elevation: 6,

            // slightly larger icon for better tap target
            selectedIconTheme: IconThemeData(size: 26, color: theme.primaryColor),
            unselectedIconTheme: IconThemeData(size: 22, color: Colors.grey[600]),

            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.space_dashboard_rounded),
                label: 'Dashboard'.tr,
                tooltip: 'dashboard'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list_alt_rounded),
                label: 'Orders'.tr,
                tooltip: 'orders'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.attach_money),
                label: 'finance'.tr,
                tooltip: 'finance'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: 'history'.tr,
                tooltip: 'history'.tr,
              ),
            ],
          ),
        ),
      ),

    );
  }
}
