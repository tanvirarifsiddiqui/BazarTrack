import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:flutter_boilerplate/features/history/service/history_service.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final HistoryService historyService;
  HistoryController({required this.historyService});

  List<HistoryLog> get logs => historyService.logs;

  Future<void> addLog(HistoryLog log) async {
    await historyService.addLog(log);
    update();
  }

  List<HistoryLog> logsForEntity(String entityType, String entityId) {
    return historyService.logsForEntity(entityType, entityId);
  }
}
