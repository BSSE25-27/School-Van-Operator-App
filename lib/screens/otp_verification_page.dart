import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';
import 'dart:async';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  String _currentOtp = '';
  int _resendSeconds = 30;
  Timer? _timer;
  bool _isResendActive = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Send OTP automatically when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _isResendActive = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        setState(() {
          _isResendActive = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // bool success = await authProvider.sendOTP(widget.phoneNumber);
    bool success = true;
    if (!success && mounted) {
      Fluttertoast.showToast(
        msg: authProvider.errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_currentOtp.length != 4) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid 4-digit OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // bool success = await authProvider.verifyOTP(widget.phoneNumber, _currentOtp);
    bool success = true;
    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        Fluttertoast.showToast(
          msg: authProvider.errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onKeypadPressed(String value) {
    if (value == 'backspace') {
      if (_currentOtp.isNotEmpty) {
        setState(() {
          _currentOtp = _currentOtp.substring(0, _currentOtp.length - 1);
          _updateOtpFields();
        });
      }
      return;
    }

    if (_currentOtp.length < 4) {
      setState(() {
        _currentOtp += value;
        _updateOtpFields();
      });

      if (_currentOtp.length == 4) {
        // Auto-verify when all digits are entered
        Future.delayed(const Duration(milliseconds: 300), () {
          _verifyOTP();
        });
      }
    }
  }

  void _updateOtpFields() {
    for (int i = 0; i < 4; i++) {
      if (i < _currentOtp.length) {
        _otpControllers[i].text = _currentOtp[i];
      } else {
        _otpControllers[i].text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Confirm OTP',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Blue asterisk/snowflake icon
                    Icon(
                      Icons.ac_unit,
                      size: 80,
                      color: Colors.blue[300],
                    ),
                    const SizedBox(height: 30),
                    // OTP message
                    Text(
                      'A 4-digit code has been sent to ${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // OTP input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.none,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              style: const TextStyle(fontSize: 20),
                              maxLength: 1,
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Continue button
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed:
                                _currentOtp.length == 4 ? _verifyOTP : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9D7BB0),
                              disabledBackgroundColor:
                                  const Color(0xFF9D7BB0).withOpacity(0.5),
                            ),
                            child: const Text('Continue'),
                          ),
                    const SizedBox(height: 20),
                    // Resend OTP
                    TextButton(
                      onPressed: _isResendActive
                          ? () {
                              _sendOTP();
                              _startResendTimer();
                            }
                          : null,
                      child: Text(
                        _isResendActive
                            ? 'Resend OTP'
                            : 'Resend OTP (0:${_resendSeconds.toString().padLeft(2, '0')})',
                        style: TextStyle(
                          color: _isResendActive
                              ? const Color(0xFF9D7BB0)
                              : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Custom keypad
          Container(
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKeypadButton('1'),
                    _buildKeypadButton('2'),
                    _buildKeypadButton('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadButton('4'),
                    _buildKeypadButton('5'),
                    _buildKeypadButton('6'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadButton('7'),
                    _buildKeypadButton('8'),
                    _buildKeypadButton('9'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    _buildKeypadButton('0'),
                    Expanded(
                      child: InkWell(
                        onTap: () => _onKeypadPressed('backspace'),
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.backspace_outlined,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeypadPressed(number),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.5),
              right: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
