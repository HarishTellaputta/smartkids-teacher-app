import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/home/teacher_home_screen.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //================ HEADER =================//
              Container(
                width: double.infinity,

                padding: const EdgeInsets.only(top: 45, bottom: 45),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1565C0), Color(0xff42A5F5)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),

                    bottomRight: Radius.circular(40),
                  ),
                ),

                child: Column(
                  children: [
                    Container(
                      height: 90,

                      width: 90,

                      decoration: const BoxDecoration(
                        color: Colors.white,

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.lock_outline_rounded,

                        size: 50,

                        color: Color(0xff1565C0),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Verify OTP",

                      style: GoogleFonts.poppins(
                        color: Colors.white,

                        fontSize: 30,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "SmartKids Employee Portal",

                      style: GoogleFonts.poppins(
                        color: Colors.white70,

                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Card(
                  elevation: 8,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(25),

                    child: Column(
                      children: [
                        Text(
                          "Enter OTP",

                          style: GoogleFonts.poppins(
                            fontSize: 25,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "OTP sent to +91 ${widget.mobileNumber}",

                          style: GoogleFonts.poppins(
                            color: Colors.grey,

                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 35),

                        // OTP BOXES
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (index) => SizedBox(
                              width: 65,
                              height: 70,
                              child: TextField(
                                controller: otpControllers[index],
                                focusNode: focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                maxLength: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xff1565C0),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(focusNodes[index + 1]);
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(focusNodes[index - 1]);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,

                          height: 55,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1565C0),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            onPressed: () {
                              String otp = otpControllers
                                  .map((e) => e.text)
                                  .join();

                              if (otp.length != 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Enter valid OTP"),
                                  ),
                                );

                                return;
                              }

                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TeacherHomeScreen(),
                                ),
                              );
                            },

                            child: Text(
                              "Verify & Continue",

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontSize: 17,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("OTP Resent Successfully"),
                              ),
                            );
                          },

                          child: Text(
                            "Resend OTP",

                            style: GoogleFonts.poppins(
                              color: Color(0xff1565C0),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Secure Login • SmartKids",

                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }

    for (var node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }
}
