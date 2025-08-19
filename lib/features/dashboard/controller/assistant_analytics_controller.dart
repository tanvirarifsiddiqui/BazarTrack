import 'package:flutter_boilerplate/features/dashboard/repository/analytics_repo.dart';
import 'package:get/get.dart';
import '../model/assistant_analytics.dart';

class AssistantAnalyticsController extends GetxController {
  final AnalyticsRepo analyticsRepo;
  final int assistantId;

  AssistantAnalyticsController({
    required this.analyticsRepo,
    required this.assistantId,
  });

  var analytics = Rxn<AssistantAnalytics>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    analytics.value = await analyticsRepo.fetchAssistantAnalytics(assistantId);
    isLoading.value = false;
  }
}
