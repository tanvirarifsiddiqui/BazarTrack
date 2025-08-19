import 'package:get/get.dart';
import '../model/assistant_analytics.dart';
import '../service/analytics_service.dart';

class AssistantAnalyticsController extends GetxController {
  final AnalyticsService service;
  final int assistantId;

  AssistantAnalyticsController({
    required this.service,
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
    analytics.value = await service.getAssistantAnalytics(assistantId);
    isLoading.value = false;
  }
}
