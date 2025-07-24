import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:registration_qr/Cus_Widgits/loder.dart';
import 'package:registration_qr/Screens/main_shell.dart';
import 'package:registration_qr/Server/download_data.dart';
import 'package:registration_qr/Server/firestore_service.dart';
import 'package:registration_qr/Server/navigator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> attendedCounts = {};
  Map<String, int> totalCounts = {};
  int totalAttendance = 0;

  final List<String> teams = [
    'HR',
    'Logistics',
    'Assistant',
    'Business',
    'Media',
  ];

  final Map<String, Color> colors = {
    'HR': const Color.fromARGB(179, 1, 68, 126),
    'Logistics': Colors.green,
    'Assistant': Colors.orange,
    'Business': Colors.purple,
    'Media': Colors.red,
  };

  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final firestoreService = FirestoreService();
      final participants = await firestoreService.fetchAllParticipants();

      Map<String, double> attended = {
        'HR': 0,
        'Logistics': 0,
        'Assistant': 0,
        'Business': 0,
        'Media': 0,
      };

      Map<String, int> totals = {
        'HR': 0,
        'Logistics': 0,
        'Assistant': 0,
        'Business': 0,
        'Media': 0,
      };

      for (var p in participants) {
        final team = (p['team'] ?? '').toString().trim();
        final attendance = (p['attendance'] ?? false) == true;
        if (totals.containsKey(team)) {
          totals[team] = totals[team]! + 1;
          if (attendance) {
            attended[team] = attended[team]! + 1;
          }
        }
      }

      setState(() {
        attendedCounts = attended;
        totalCounts = totals;
        totalAttendance = attended.values.fold(0.0, (a, b) => a + b).toInt();
        filteredList = participants;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to load dashboard data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: 16),
        child: attendedCounts.isEmpty
            ? const Center(child: MyAppLoader())
            : ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => AppNavigator.slideLikePageView(
                          context,
                          MainShell(),
                        ),
                        color: Colors.black54,
                      ),
                      Center(
                        child: Text(
                          'Total Participants: ${totalCounts.values.fold(0, (a, b) => a + b)}            ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attended: $totalAttendance | Absent: ${totalCounts.values.fold(0, (a, b) => a + b) - totalAttendance}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PieChart(
                    dataMap: attendedCounts,
                    colorList: teams.map((t) => colors[t]!).toList(),
                    chartRadius: screenWidth / 1.5,
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.bottom,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      showChartValues: true,
                    ),
                    chartType: ChartType.disc,
                  ),
                  const SizedBox(height: 24),

                  // Export Button (Excel)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await exportParticipantsAsExcel(
                          context,
                          filteredList,
                        );
                      },
                      icon: const Icon(Icons.file_download_outlined,size: 25,),
                      label: const Text(
                        'Download Attendance ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff016da6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cards per team
                  ...teams.map((team) {
                    final attended = attendedCounts[team]?.toInt() ?? 0;
                    final total = totalCounts[team] ?? 0;
                    final absent = total - attended;

                    return Card(
                      color: const Color.fromARGB(207, 211, 210, 210),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$team: $attended Attended',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colors[team],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total in $team: $total | Absent: $absent',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
