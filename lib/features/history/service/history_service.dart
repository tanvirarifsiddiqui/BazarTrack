import 'package:get/get.dart';
import '../model/history_log.dart';
import '../repository/history_repo.dart';

class HistoryService extends GetxService {
  final HistoryRepo historyRepo;
  HistoryService({ required this.historyRepo });

  Future<List<HistoryLog>> fetchAll() => historyRepo.getAll();

  Future<List<HistoryLog>> fetchByEntity(String entity) =>
      historyRepo.getByEntity(entity);

  Future<List<HistoryLog>> fetchByEntityId(String entity, int id) =>
      historyRepo.getByEntityId(entity, id);

  Future<HistoryLog> createLog(HistoryLog log) =>
      historyRepo.create(log);

  Future<bool> deleteLog(int id) =>
      historyRepo.delete(id);
}
