import 'package:flutter/material.dart';
import 'package:registration_qr/Cus_Widgits/loder.dart';
import 'package:registration_qr/Screens/main_shell.dart';
import 'package:registration_qr/Server/firestore_service.dart';
import 'package:registration_qr/Server/download_data.dart';
import 'package:registration_qr/Server/navigator.dart';

class ScannedParticipantsScreen extends StatefulWidget {
  const ScannedParticipantsScreen({super.key});

  @override
  State<ScannedParticipantsScreen> createState() =>
      _ScannedParticipantsScreenState();
}

class _ScannedParticipantsScreenState extends State<ScannedParticipantsScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String selectedTeam = 'All';
  List<Map<String, dynamic>> participantsList = [];
  List<Map<String, dynamic>> filteredList = [];
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> teams = [
    'All',
    'HR',
    'Logistics',
    'Assistant',
    'Business',
    'Media',
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchParticipants();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchParticipants() async {
    try {
      participantsList = await _firestoreService.fetchConfirmedParticipants();
      setState(() {
        filteredList = participantsList;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  bool _matchesQuery(Map<String, dynamic> participant) {
    final name = participant['name']?.toLowerCase() ?? '';
    final email = participant['email']?.toLowerCase() ?? '';
    return name.contains(searchQuery) || email.contains(searchQuery);
  }

  void _filterList() {
    setState(() {
      filteredList = participantsList.where((participant) {
        final matchesSearch = _matchesQuery(participant);
        final matchesTeam =
            selectedTeam == 'All' || participant['team'] == selectedTeam;
        return matchesSearch && matchesTeam;
      }).toList();
    });
  }

  void _updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      _filterList();
    });
  }

  Widget buildAnimatedChild(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(_fadeAnimation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return participantsList.isEmpty
        ? const Center(child: MyAppLoader())
        : FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: buildAnimatedChild(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => AppNavigator.slideLikePageView(
                            context,
                            MainShell(),
                          ),
                          color: Colors.black54,
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: _updateSearch,
                            decoration: InputDecoration(
                              hintText: 'Search by name or email...',
                              hintStyle: TextStyle(color: Color(0xff016da6)),

                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xff016da6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xff016da6),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xff016da6),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                buildAnimatedChild(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff016da6),
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTeam,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xff016da6),
                          ),
                          items: teams.map((team) {
                            return DropdownMenuItem(
                              value: team,
                              child: Text(
                                team,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff016da6),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeam = value!;
                              _filterList();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text('No matching participants found.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final person = filteredList[index];
                            return buildAnimatedChild(
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: FractionallySizedBox(
                                        heightFactor: 0.6,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "Member Information",
                                                  style: TextStyle(
                                                    color: Color(0xff016da6),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              _infoRow(
                                                "ID",
                                                person['id'],
                                                Icons.assignment_ind,
                                              ),
                                              _infoRow(
                                                "Name",
                                                person['name'],
                                                Icons.person,
                                              ),
                                              _infoRow(
                                                "Email",
                                                person['email'],
                                                Icons.email,
                                              ),
                                              _infoRow(
                                                "Team",
                                                person['team'],
                                                Icons.groups,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },

                                child: Card(
                                  color: const Color(0xff016da6),
                                  margin: const EdgeInsets.all(12),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Expanded(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        person['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                        onPressed: () async {
                                          bool confirmCancel = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                titlePadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.05,
                                                      vertical: 8,
                                                    ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.05,
                                                      vertical: 8,
                                                    ),
                                                actionsPadding: EdgeInsets.only(
                                                  right:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.03,
                                                  bottom: 10,
                                                ),
                                                title: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Color(0xff016DA6),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        "Cancel Attendance?",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                          color: Color(
                                                            0xff016DA6,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to cancel this participant's attendance?",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                          255,
                                                          255,
                                                          0,
                                                          0,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmCancel) {
                                            try {
                                              await _firestoreService
                                                  .unconfirmAttendance(
                                                    person['id'],
                                                  );

                                              setState(() {
                                                participantsList.removeWhere(
                                                  (p) =>
                                                      p['id'] == person['id'],
                                                );
                                                filteredList.removeWhere(
                                                  (p) =>
                                                      p['id'] == person['id'],
                                                );
                                              });

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.white,
                                                  elevation: 4,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  content: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Color(
                                                          0xff016DA6,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Attendance cancelled successfully!',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xff016DA6,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.red.shade50,
                                                  elevation: 4,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Error cancelling attendance: $e',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
  }
}

Widget _infoRow(String title, String? value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: Container(
      height: 85,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xff016da6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: Color(0xff016da6), size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value ?? '',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}
