// lib/features/history/controller/history_controller.dart

import 'package:get/get.dart';
import '../model/history_log.dart';
import '../service/history_service.dart';

class HistoryController extends GetxController {
  final HistoryService historyService;
  HistoryController({ required this.historyService });

  var logs = <HistoryLog>[].obs;
  var isLoading = false.obs;

  Future<void> loadAll() async {
    isLoading.value = true;
    logs.value = await historyService.fetchAll();
    isLoading.value = false;
  }

  Future<void> loadByEntity(String entity) async {
    isLoading.value = true;
    logs.value = await historyService.fetchByEntity(entity);
    isLoading.value = false;
  }

  Future<void> loadByEntityId(String entity, int id) async {
    isLoading.value = true;
    logs.value = await historyService.fetchByEntityId(entity, id);
    isLoading.value = false;
  }
}
