import 'package:flutter/material.dart';
import 'package:registration_qr/Server/firestore_service.dart';
import 'package:registration_qr/Server/download_data.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff016da6),
        foregroundColor: Colors.white,
        title: const Text('Scanned Participants'),
        centerTitle: true,
      ),
      body: participantsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: buildAnimatedChild(
                      TextField(
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
                  buildAnimatedChild(
                    ElevatedButton.icon(
                      onPressed: () async {
                        await exportParticipantsAsCSV(context, filteredList);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff016da6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
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
                                Card(
                                  color: const Color(0xff016da6),
                                  margin: const EdgeInsets.all(12),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      person['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '  ${person['email'] ?? ''}',
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '  Team : ',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '   ${person['team'] ?? ''}',
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      onPressed: () async {
                                        bool confirmCancel = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Cancel Attendance?",
                                              ),
                                              content: const Text(
                                                "Are you sure you want to cancel this participant's attendance?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(true);
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(false);
                                                  },
                                                  child: const Text('No'),
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
                                                (p) => p['id'] == person['id'],
                                              );
                                              filteredList.removeWhere(
                                                (p) => p['id'] == person['id'],
                                              );
                                            });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Attendance cancelled successfully!',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error cancelling attendance: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
