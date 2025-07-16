import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:registration_qr/Server/Response.dart';

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
    'HR': Colors.blue,
    'Logistics': Colors.green,
    'Assistant': Colors.orange,
    'Business': Colors.purple,
    'Media': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final participants = await GoogleSheetService.fetchParticipants();

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
        final attendance = (p['attendance'] ?? '').toString().trim();
        if (totals.containsKey(team)) {
          totals[team] = totals[team]! + 1;
          if (attendance == '✔') {
            attended[team] = attended[team]! + 1;
          }
        }
      }

      setState(() {
        attendedCounts = attended;
        totalCounts = totals;
        totalAttendance = attended.values.fold(0.0, (a, b) => a + b).toInt();
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xff016da6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: 16),
        child: attendedCounts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: totalCounts.values.fold(0, (a, b) => a! + b),
                    ),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Text(
                        'Total Participants: $value',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff016da6),
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: totalAttendance),
                    duration: const Duration(seconds: 2),
                    builder: (context, attended, child) {
                      final absent =
                          totalCounts.values.fold(0, (a, b) => a + b) -
                          attended;
                      return Text(
                        'Attended: $attended | Absent: $absent',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
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
                  const SizedBox(height: 30),
                  ...teams.map((team) {
                    final attended = attendedCounts[team]?.toInt() ?? 0;
                    final total = totalCounts[team] ?? 0;
                    final absent = total - attended;

                    return Card(
                      color: Colors.white,
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
