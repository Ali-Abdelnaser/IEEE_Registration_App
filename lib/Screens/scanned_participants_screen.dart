import 'package:flutter/material.dart';
import 'package:registration_qr/Server/Response.dart';

class ScannedParticipantsScreen extends StatefulWidget {
  const ScannedParticipantsScreen({super.key});

  @override
  State<ScannedParticipantsScreen> createState() =>
      _ScannedParticipantsScreenState();
}

class _ScannedParticipantsScreenState extends State<ScannedParticipantsScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> participantsList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    try {
      participantsList = await ParticipantsService.fetchConfirmedParticipants();
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

  void _updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredList = participantsList.where(_matchesQuery).toList();
    });
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
      body: participantsList.isEmpty && filteredList.isEmpty
          ? const Center(child: Text("No participants found."))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: _updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                          itemCount: participantsList.length,
                          itemBuilder: (context, index) {
                            final person = participantsList[index];
                            return Card(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          '  Cycle : ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          '   ${person['team'] ?? ''}',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
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
                                                Navigator.of(context).pop(true);
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
                                        await ParticipantsService.unconfirmAttendance(
                                          person['id'],
                                        );

                                        setState(() {
                                          filteredList.removeAt(index);
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
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
