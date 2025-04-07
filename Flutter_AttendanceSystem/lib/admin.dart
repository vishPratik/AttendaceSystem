import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();
  final TextEditingController _ipController = TextEditingController(text: "your_IP_address");
  bool _isGenerating = false;
  int _remainingTime = 0;
  Timer? _qrTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showIpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: 'app-logo',
              child: Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Generate Attendance QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.menu_book),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _classController,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      prefixIcon: Icon(Icons.groups),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lecturerController,
                    decoration: const InputDecoration(
                      labelText: 'Lecturer (Optional)',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.qr_code),
                      label: Text(
                        _isGenerating ? 'GENERATING...' : 'GENERATE QR ON TFT',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _isGenerating ? null : _generateQR,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    _qrTimer?.cancel();
    _remainingTime = 60;
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _generateQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      final response = await http.post(
        Uri.parse('http://${_ipController.text}/generate'),
        body: {
          'subject': _subjectController.text,
          'class': _classController.text,
          'lecturer': _lecturerController.text,
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'QR Generated: ${response.body}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _showIpDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ESP8266 IP Address'),
        content: TextField(
          controller: _ipController,
          decoration: const InputDecoration(
            hintText: "your_IP_address",
            prefixIcon: Icon(Icons.wifi),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _classController.dispose();
    _lecturerController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}