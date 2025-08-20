import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';

import '../../base/empty_state.dart';
import 'components/filter_bar.dart';
import 'components/order_card.dart';

class OrderListScreen extends StatelessWidget {
  final OrderStatus? initialStatus;
  final int? initialAssignedTo;

  const OrderListScreen({
    super.key,
    this.initialStatus,
    this.initialAssignedTo,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final isOwner = auth.currentUser?.role == UserRole.owner;
    final ctrl = Get.find<OrderController>();

    // apply initial filters once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialStatus != null) ctrl.setStatusFilter(initialStatus);
      if (initialAssignedTo != null) ctrl.setAssignedToFilter(initialAssignedTo);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterBarDelegate(
                child: FilterBar(ctrl: ctrl, isOwner: isOwner),
                height: 72,
              ),
            ),

            if (ctrl.isLoading.value)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ctrl.orders.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.inbox,
                  message: 'No orders found.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final order = ctrl.orders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.scaffoldPadding,
                        vertical: 2,
                      ),
                      child: OrderCard(order: order),
                    );
                  },
                  childCount: ctrl.orders.length,
                ),
              ),
          ],
        );
      }),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
        heroTag: 'add_order',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        onPressed: ctrl.onCreateOrderTapped,
      )
          : null,
    );
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _FilterBarDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Material(
      elevation: overlaps ? 4 : 0,
      color: AppColors.background,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _FilterBarDelegate old) {
    return child != old.child || height != old.height;
  }
}

