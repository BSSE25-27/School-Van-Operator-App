import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:operator_app/home.dart';
import 'dart:convert';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );
  bool isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 30;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialOtp(); // Send OTP automatically when screen loads
    });
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendInitialOtp() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(
          'https://lightyellow-owl-629132.hostingersite.com/api/send-otp',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': widget.phoneNumber}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send initial OTP')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startResendTimer();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 5) {
      setState(() => _errorMessage = 'Please enter a complete 5-digit code');
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://lightyellow-owl-629132.hostingersite.com/api/verify-otp',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': widget.phoneNumber, 'otp': otp}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(
          () => _errorMessage = responseData['message'] ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://lightyellow-owl-629132.hostingersite.com/api/resend-otp',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': widget.phoneNumber}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to resend OTP'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    } finally {
      _startResendTimer();
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure background color
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 20),

                    // Header Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verify OTP",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            text: "Enter the 5-digit code sent to ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: widget.phoneNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => SizedBox(
                          width: 56,
                          height: 64,
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 1) {
                                if (index < 4) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_otpFocusNodes[index + 1]);
                                } else {
                                  _verifyOtp();
                                }
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_otpFocusNodes[index - 1]);
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Resend OTP Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Didn't receive the code?",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed:
                                _canResend && !isLoading ? _resendOtp : null,
                            child: Text(
                              _canResend
                                  ? "Resend OTP"
                                  : "Resend in $_resendCountdown",
                              style: TextStyle(
                                color:
                                    _canResend
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "VERIFY & CONTINUE",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print("Error building OTP screen: $e");
              return Center(child: Text("Error loading OTP screen"));
            }
          },
        ),
      ),
    );
  }
}
