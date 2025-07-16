import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:registration_qr/Screens/user_info_screen.dart';
import 'package:registration_qr/Server/Response.dart';

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

    List<Map<String, dynamic>> participants = [];
    try {
      participants = await GoogleSheetService.fetchParticipants();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Cannot connect to Google Sheet"),
          backgroundColor: Colors.red,
        ),
      );
      controller.start();
      setState(() => isScanned = false);
      return;
    }

    final matched = participants.firstWhere(
      (participant) =>
          participant['id']?.toLowerCase().trim() ==
          scannedId.toLowerCase().trim(),
      orElse: () => {},
    );

    if (matched.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserInfoScreen(
            data: matched,
            onConfirm: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      controller.start();
      setState(() => isScanned = false);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xff016da6),
          title: const Text(
            'Invalid QR ⚠️ ',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "This ID is not found in Google Sheet.",
            style: TextStyle(color: Colors.white),
          ),
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
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      _AnimatedScannerLine(boxTop: boxTop, boxLeft: boxLeft, boxSize: boxSize),
      Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Text(
          'Place the QR code inside the box to scan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color.fromARGB(179, 0, 0, 0),
            fontSize: 16,
          ),
        ),
      ),
    ],
  );
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
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final laserTop = widget.boxTop + (widget.boxSize * _animation.value);
        return Positioned(
          top: laserTop,
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
