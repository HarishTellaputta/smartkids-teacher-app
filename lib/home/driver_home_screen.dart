import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int selectedIndex = 0;

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
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 35,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff00695C), Color(0xff26A69A)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),

                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Good Morning 👋",

                              style: GoogleFonts.poppins(
                                color: Colors.white70,

                                fontSize: 15,
                              ),
                            ),

                            Text(
                              "Ramesh Kumar",

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontSize: 25,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "School Bus Driver",

                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          ],
                        ),

                        const CircleAvatar(
                          radius: 30,

                          backgroundColor: Colors.white,

                          child: Icon(
                            Icons.directions_bus,

                            size: 38,

                            color: Color(0xff00695C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // BUS STATUS CARD
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 55,

                            width: 55,

                            decoration: const BoxDecoration(
                              color: Color(0xffE0F2F1),

                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.directions_bus_filled,

                              color: Color(0xff00695C),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Bus Status",

                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "Ready for Pickup",

                                style: GoogleFonts.poppins(
                                  color: Colors.green,

                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // TRIP CARD
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Today's Route",

                                    style: GoogleFonts.poppins(
                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "Route No: SK-101",

                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              const Icon(
                                Icons.route,

                                size: 35,

                                color: Color(0xff00695C),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                            children: [
                              _infoBox("Students", "42", Icons.people),

                              _infoBox("Stops", "12", Icons.location_on),

                              _infoBox("Distance", "18 KM", Icons.speed),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Quick Actions",

                      style: GoogleFonts.poppins(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisCount: 3,

                      children: [
                        _actionCard(Icons.play_circle, "Start Trip"),

                        _actionCard(Icons.people, "Students"),

                        _actionCard(Icons.location_on, "Live Route"),

                        _actionCard(Icons.call, "Contact"),

                        _actionCard(Icons.history, "Trip History"),

                        _actionCard(Icons.report, "Report"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,

                      height: 55,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00695C),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: () {},

                        child: Text(
                          "Start Today's Trip",

                          style: GoogleFonts.poppins(
                            color: Colors.white,

                            fontSize: 17,

                            fontWeight: FontWeight.w600,
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
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        selectedItemColor: const Color(0xff00695C),

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.route), label: "Trips"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xff00695C)),

        const SizedBox(height: 5),

        Text(
          value,

          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        Text(
          title,

          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Color(0xff00695C), size: 30),

          const SizedBox(height: 8),

          Text(
            title,

            style: GoogleFonts.poppins(
              fontSize: 12,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
