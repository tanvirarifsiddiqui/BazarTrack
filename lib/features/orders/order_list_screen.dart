import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/features/orders/model/order_status.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import '../../base/empty_state.dart';
import '../../helper/route_helper.dart';
import 'components/filter_bar.dart';
import 'components/order_card.dart';

class OrderListScreen extends StatefulWidget {
  final OrderStatus? initialStatus;
  final int? initialAssignedTo;

  const OrderListScreen({
    super.key,
    this.initialStatus,
    this.initialAssignedTo,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {

  late OrderController orderCtrl ;
  late AuthController authController;


  @override
  void initState() {
     orderCtrl = Get.find<OrderController>();
     orderCtrl.isOwner = true;
     authController = Get.find<AuthController>();
     //function call
     orderCtrl.getAllAssistants();
     orderCtrl.loadInitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = authController.user.value?.role == UserRole.owner;

    // apply initial filters once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStatus != null) orderCtrl.setStatusFilter(widget.initialStatus);
      if (widget.initialAssignedTo != null) orderCtrl.setAssignedToFilter(widget.initialAssignedTo);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ()async{
          orderCtrl.getAllAssistants();
          orderCtrl.loadInitial();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
                !orderCtrl.isLoadingMore.value &&
                orderCtrl.hasMore.value) {
              orderCtrl.loadMore();
            }
            return false;
          },
          child: Obx(() {
            if (orderCtrl.isInitialLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterBarDelegate(
                    child: FilterBar(ctrl: orderCtrl, isOwner: isOwner),
                    height: 72,
                  ),
                ),

                if (orderCtrl.orders.isEmpty)
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
                        final order = orderCtrl.orders[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.scaffoldPadding,
                            vertical: 4,
                          ),
                          child: OrderCard(order: order),
                        );
                      },
                      childCount: orderCtrl.orders.length,
                    ),
                  ),

                // Loader at bottom
                if (orderCtrl.isLoadingMore.value)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
        heroTag: 'add_order',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        onPressed: (){
          orderCtrl.onCreateOrderTapped;
          Get.toNamed(RouteHelper.orderCreate);
        },
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

