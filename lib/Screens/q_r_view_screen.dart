import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:registration_qr/Screens/user_info_screen.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({super.key});

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  Future<void> _handleScan(String? scannedId) async {
    if (isScanned || scannedId == null) return;

    setState(() => isScanned = true);
    controller.stop();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('attendees')
          .doc(scannedId)
          .get();

      if (!doc.exists) {
        _showErrorDialog('Invalid QR ⚠️', 'This ID is not found.');
      } else if (doc['attendance'] == true) {
        _showErrorDialog(
          'Already Scanned ✅',
          'This person has already been scanned.',
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserInfoScreen(
              data: {
                'id': doc.id,
                'name': doc['name'],
                'email': doc['email'],
                'team': doc['team'],
                'attendance': doc['attendance'],
              },
              onConfirm: (_) async {
                await FirebaseFirestore.instance
                    .collection('attendees')
                    .doc(doc.id)
                    .update({'attendance': true});
                Navigator.pop(context);
              },
              onDelete: (_) {
                // استخدمها لو عايز تحذف الشخص من الواجهة
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to connect to database.');
    }

    controller.start();
    setState(() => isScanned = false);
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff016da6),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.start();
              setState(() => isScanned = false);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context, double boxSize) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boxLeft = (screenWidth - boxSize) / 2;
    final boxTop = (screenHeight - boxSize) / 2;

    return Stack(
      children: [
        Positioned(
          left: boxLeft,
          top: boxTop,
          width: boxSize,
          height: boxSize,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        _AnimatedScannerLine(
          boxTop: boxTop,
          boxLeft: boxLeft,
          boxSize: boxSize,
        ),
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Text(
            'Place the QR code inside the box to scan',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(179, 0, 0, 0),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xff016da6),
        foregroundColor: Colors.white,
        title: const Text("Scan QR Code"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue;
              _handleScan(code);
            },
          ),
          _buildScannerOverlay(context, boxSize),
        ],
      ),
    );
  }
}

class _AnimatedScannerLine extends StatefulWidget {
  final double boxTop;
  final double boxLeft;
  final double boxSize;

  const _AnimatedScannerLine({
    required this.boxTop,
    required this.boxLeft,
    required this.boxSize,
  });

  @override
  State<_AnimatedScannerLine> createState() => _AnimatedScannerLineState();
}

class _AnimatedScannerLineState extends State<_AnimatedScannerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: widget.boxSize,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: widget.boxTop + _animation.value,
          left: widget.boxLeft,
          width: widget.boxSize,
          child: Container(height: 2, color: Colors.redAccent),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
