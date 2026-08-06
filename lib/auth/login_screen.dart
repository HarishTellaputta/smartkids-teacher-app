import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();

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
                padding: const EdgeInsets.only(top: 40, bottom: 45),
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
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Color(0xff1565C0),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "SmartKids",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    Text(
                      "EMPLOYEE PORTAL",
                      style: GoogleFonts.poppins(
                        color: Colors.yellow.shade200,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "One Login for All Employees",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome 👋",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Login using your registered employee mobile number.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "Mobile Number",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,

                          decoration: InputDecoration(
                            counterText: "",

                            prefixIcon: const Icon(
                              Icons.phone_android,
                              color: Color(0xff1565C0),
                            ),

                            prefixText: "+91 ",

                            hintText: "Enter Mobile Number",

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xff1565C0),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        //================ SEND OTP BUTTON =================//
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1565C0),
                              elevation: 5,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            onPressed: () {
                              String mobile = mobileController.text.trim();

                              if (mobile.length != 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please enter valid mobile number",
                                      style: GoogleFonts.poppins(),
                                    ),

                                    backgroundColor: Colors.red,
                                  ),
                                );

                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OtpScreen(mobileNumber: mobile),
                                ),
                              );
                            },

                            child: Text(
                              "Send OTP",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        //================ FEATURES =================//
                        Text(
                          "Why SmartKids?",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        _featureTile(
                          Icons.people_alt_rounded,
                          "Employee Management",
                          "Manage teachers and staff easily",
                        ),

                        _featureTile(
                          Icons.assignment_rounded,
                          "Daily Updates",
                          "Attendance, tasks and reports",
                        ),

                        _featureTile(
                          Icons.notifications_active_rounded,
                          "Instant Notifications",
                          "Stay connected with school activities",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //================ FOOTER =================//
              Text(
                "Powered by SmartKids Technologies",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //================ FEATURE TILE =================//

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            height: 45,

            width: 45,

            decoration: const BoxDecoration(
              color: Color(0xff1565C0),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: Colors.white, size: 23),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,

                    fontSize: 15,
                  ),
                ),

                Text(
                  subtitle,

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mobileController.dispose();

    super.dispose();
  }
}
