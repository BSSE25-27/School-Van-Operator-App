import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Controllers for each OTP digit
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );

  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "A digit code has been sent to your Phone number",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => SizedBox(
                    width: 48,
                    height: 48,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF3044CF),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1) {
                          if (index < 5) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_otpFocusNodes[index + 1]);
                          } else {
                            // Last field - remove focus
                            FocusScope.of(context).unfocus();
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

              const SizedBox(height: 24),

              // Resend OTP option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didnt receive code?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement resend OTP functionality
                    },
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF3044CF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            // Check if all OTP fields are filled
                            bool isOtpComplete = _otpControllers.every(
                              (controller) => controller.text.isNotEmpty,
                            );

                            if (isOtpComplete) {
                              setState(() {
                                isLoading = true;
                              });

                              // TODO: Implement OTP verification
                              // For now, just simulate a delay
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  isLoading = false;
                                });
                                // Navigate to next screen after verification
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder:
                                //         (context) => MethodVerificationScreen(),
                                //   ),
                                // );
                              });
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3044CF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}