import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/orders/controller/order_controller.dart';
import 'package:flutter_boilerplate/base/empty_state.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'components/filter_bar.dart';
import 'components/order_card.dart';

class AssistantOrderListScreen extends StatefulWidget {
  const AssistantOrderListScreen({Key? key}) : super(key: key);

  @override
  _AssistantOrderListScreenState createState() =>
      _AssistantOrderListScreenState();
}

class _AssistantOrderListScreenState extends State<AssistantOrderListScreen>
    with SingleTickerProviderStateMixin {
  late final OrderController orderCtrl;
  late final AuthController authCtrl;
  late final TabController tabCtrl;

  @override
  void initState() {
    super.initState();
    orderCtrl = Get.find<OrderController>();
    authCtrl = Get.find<AuthController>();

    tabCtrl = TabController(length: 2, vsync: this)
      ..addListener(() {
        // Only act when a new index is being selected by the user (start of change)
        if (!tabCtrl.indexIsChanging) return;

        if (tabCtrl.index == 0) {
          orderCtrl.setMyOrdersFilter();
        } else {
          orderCtrl.setUnassignedFilter();
        }
      });

    orderCtrl.getAllAssistants();
    orderCtrl.setMyOrdersFilter();
  }

  @override
  void dispose() {
    tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ─── Custom TabBar at Top ───
          SafeArea(
            bottom: false,
            child: Material(
              color: Colors.white,
              child: TabBar(
                controller: tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'My Orders'),
                  Tab(text: 'Unassigned'),
                ],
              ),
            ),
          ),

          // ─── TabBarView Content ───
          Expanded(
            child: TabBarView(
              controller: tabCtrl,
              children: [
                Column(
                  children: [
                    FilterBar(ctrl: orderCtrl, isOwner: false),
                    Expanded(child: _buildOrderList()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildOrderList(),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: Obx(() {
        final isOwner = authCtrl.user.value?.role == UserRole.owner;
        if (!isOwner) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          heroTag: 'add_order',
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
          onPressed: () {
            orderCtrl.onCreateOrderTapped();
            Get.toNamed(RouteHelper.orderCreate);
          },
        );
      }),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => orderCtrl.loadInitial(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 100 &&
              !orderCtrl.isLoadingMore.value &&
              orderCtrl.hasMore.value) {
            orderCtrl.loadMore();
          }
          return false;
        },
        child: Obx(() {
          if (orderCtrl.isInitialLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final orders = orderCtrl.orders;
          if (orders.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.inbox,
                message: 'No orders found.',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.scaffoldPadding),
            itemCount: orders.length + (orderCtrl.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              if (index >= orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }
              return OrderCard(order: orders[index]);
            },
          );
        }),
      ),
    );
  }
}
