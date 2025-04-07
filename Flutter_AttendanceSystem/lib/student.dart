import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late final MobileScannerController cameraController;
  final TextEditingController _idController = TextEditingController();
  bool _showScanner = false;
  bool _isLoading = false;

  final String _googleScriptUrl = "https://script.google.com/macros/s/Your_ScriptId/exec";

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
    );
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _handleScanButton() async {
    if (_idController.text.isEmpty) {
      _showToast('Please enter Student ID', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final status = await Permission.camera.request();
      if (!mounted) return;
      
      if (status.isGranted) {
        setState(() => _showScanner = true);
      } else {
        _showToast('Camera permission denied', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAttendance(String qrData) async {
    if (!qrData.startsWith("ATTENDANCE:")) {
      _showToast('Invalid QR format', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_googleScriptUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'studentId': _idController.text.trim(),
          'qrData': qrData.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 302) {
        _showToast('Attendance marked successfully!');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      _showToast('Request timed out', isError: true);
    } on http.ClientException catch (e) {
      _showToast('Network error: ${e.message}', isError: true);
    } catch (e) {
      _showToast('Error: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showScanner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showScanner ? _buildScanner() : _buildIdForm(),
    );
  }

  Widget _buildIdForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Hero(
            tag: 'app-logo',
            child: Icon(
              Icons.school,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your Student ID',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'SCAN QR CODE',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: _handleScanButton,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            if (!mounted) return;
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final qrData = barcodes.first.rawValue;
              if (qrData != null && qrData.startsWith("ATTENDANCE:")) {
                _markAttendance(qrData);
              }
            }
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.4), 
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Scan QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('CANCEL SCAN'),
              onPressed: () => setState(() => _showScanner = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _idController.dispose();
    super.dispose();
  }
}