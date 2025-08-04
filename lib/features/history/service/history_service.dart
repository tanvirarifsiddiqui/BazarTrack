import 'package:flutter_boilerplate/features/history/model/history_log.dart';
import 'package:flutter_boilerplate/features/history/repository/history_repo.dart';
import 'package:get/get.dart';

class HistoryService extends GetxService {
  final HistoryRepo historyRepo;
  HistoryService({required this.historyRepo});

  final List<HistoryLog> _logs = [];
  List<HistoryLog> get logs => _logs;

  @override
  void onInit() {
    _logs.addAll(historyRepo.getLogs());
    super.onInit();
  }

  Future<void> addLog(HistoryLog log) async {
    _logs.add(log);
    await historyRepo.saveLogs(_logs);
    update();
  }

  List<HistoryLog> logsForEntity(String entityType, String entityId) {
    return _logs
        .where((l) => l.entityType == entityType && l.entityId == entityId)
        .toList();
  }
}
