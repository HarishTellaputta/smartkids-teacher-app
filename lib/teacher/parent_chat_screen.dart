import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentChatScreen extends StatefulWidget {
  const ParentChatScreen({super.key});

  @override
  State<ParentChatScreen> createState() => _ParentChatScreenState();
}

class _ParentChatScreenState extends State<ParentChatScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "message": "Good morning teacher. How is Rahul's performance?",
      "sender": "parent",
      "time": "09:15 AM",
    },

    {
      "message": "Good morning. Rahul is doing well in Mathematics.",
      "sender": "teacher",
      "time": "09:18 AM",
    },

    {
      "message": "Thank you teacher. Please guide him for exams.",
      "sender": "parent",
      "time": "09:20 AM",
    },
  ];

  final String parentName = "Rahul Kumar's Parent";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              parentName,

              style: GoogleFonts.poppins(
                color: Colors.white,

                fontSize: 16,

                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              "Student: Rahul Kumar",

              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                var chat = messages[index];

                bool isTeacher = chat["sender"] == "teacher";

                return Align(
                  alignment: isTeacher
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    padding: const EdgeInsets.all(15),

                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),

                    decoration: BoxDecoration(
                      color: isTeacher ? const Color(0xff1565C0) : Colors.white,

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Text(
                          chat["message"],

                          style: GoogleFonts.poppins(
                            color: isTeacher ? Colors.white : Colors.black87,

                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          chat["time"],

                          style: GoogleFonts.poppins(
                            color: isTeacher ? Colors.white70 : Colors.grey,

                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // MESSAGE INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

            color: Colors.white,

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,

                    decoration: InputDecoration(
                      hintText: "Type message...",

                      filled: true,

                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 25,

                  backgroundColor: const Color(0xff1565C0),

                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),

                    onPressed: () {
                      if (messageController.text.trim().isEmpty) {
                        return;
                      }

                      setState(() {
                        messages.add({
                          "message": messageController.text,

                          "sender": "teacher",

                          "time": "Now",
                        });

                        messageController.clear();
                      });
                    },
                  ),
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
    messageController.dispose();

    super.dispose();
  }
}
