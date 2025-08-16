// import 'package:flutter/material.dart';
// import 'package:flutter_boilerplate/features/history/controller/history_controller.dart';
// import 'package:get/get.dart';
//
// class EntityHistoryScreen extends StatelessWidget {
//   final String entityType;
//   final String entityId;
//
//   const EntityHistoryScreen({super.key, required this.entityType, required this.entityId});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<HistoryController>();
//     final logs = controller.loadByEntityId(entityType, int.parse(entityId));
//     print("History Log ===> $logs");
//     return Scaffold(
//       appBar: AppBar(title: Text('history'.tr)),
//       body: ListView.builder(
//         itemCount: logs.length,
//         itemBuilder: (context, index) {
//           final log = logs[index];
//           return ListTile(
//             title: Text(log.action),
//             subtitle: Text(log.timestamp.toIso8601String()),
//             onTap: () => showDialog(
//               context: context,
//               builder: (_) => AlertDialog(
//                 title: Text(log.action),
//                 content: SingleChildScrollView(
//                   child: Text(log.dataSnapshot.toString()),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
