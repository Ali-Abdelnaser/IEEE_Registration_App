// import 'package:flutter/material.dart';

// void _showErrorDialog(String title, String content) {
//   var context;
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       contentPadding: const EdgeInsets.all(20),
//       title: Column(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//       content: Text(
//         content,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 16, color: Colors.black87),
//       ),
//       actionsAlignment: MainAxisAlignment.center,
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//             controller.start();
//             setState(() => isScanned = false);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xff016da6),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: const Text('OK', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }
