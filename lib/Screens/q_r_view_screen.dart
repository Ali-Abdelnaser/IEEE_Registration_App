import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:Registration/Screens/user_info_screen.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({super.key});

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;
  double zoom = 0.0;

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
          'Already Scanned ',
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
                Navigator.pop(context, true);
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to connect to database.');
    }
    await Future.delayed(const Duration(milliseconds: 300));
    controller.start();
    setState(() => isScanned = false);
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title.contains('Error') || title.contains('Invalid')
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: title.contains('Error') || title.contains('Invalid')
                    ? Colors.orange
                    : Colors.green,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff016da6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff016da6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                    controller.start();
                    setState(() => isScanned = false);
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
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
        // كاميرا زوم سليدر
        Positioned(
          bottom: 40,
          left: 30,
          right: 30,
          child: Column(
            children: [
              const Text("Zoom", style: TextStyle(color: Colors.white70)),
              Slider(
                value: zoom,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() => zoom = value);
                  controller.setZoomScale(value);
                },
              ),
            ],
          ),
        ),

        // مربع الأربع أركان
        Positioned(
          left: boxLeft,
          top: boxTop,
          width: boxSize,
          height: boxSize,
          child: CustomPaint(painter: CornerPainter()),
        ),

        // خط أحمر متحرك
        _AnimatedScannerLine(
          boxTop: boxTop,
          boxLeft: boxLeft,
          boxSize: boxSize,
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

// ✅ الأربع أركان بتاعة المربع
class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;

    // Top-left
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ✅ خط المسح الأحمر المتحرك
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
