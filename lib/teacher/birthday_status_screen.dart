import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_birthday_status_model.dart';
import '../services/student_birthday_status_service.dart';
import 'birthday_chat_screen.dart';

class BirthdayStatusScreen extends StatefulWidget {
  const BirthdayStatusScreen({super.key});

  @override
  State<BirthdayStatusScreen> createState() =>
      _BirthdayStatusScreenState();
}

class _BirthdayStatusScreenState
    extends State<BirthdayStatusScreen> {
  static const Color primaryColor =
      Color(0xff1565C0);

  static const Color backgroundColor =
      Color(0xffF5F8FC);

  List<StudentBirthdayStatusModel>
      birthdays = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadBirthdays();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _loadBirthdays() async {
    try {
      final prefs =
          await SharedPreferences
              .getInstance();

      final token =
          prefs.getString(
        'jwt_token',
      );

      if (token == null ||
          token.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final service =
          StudentBirthdayStatusService(
        token,
      );

      final result =
          await service
              .getTodayBirthdays();

      if (!mounted) return;

      setState(() {
        birthdays = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Birthday status error: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // OPEN CHAT
  // =========================================================

  void _openChat(
    StudentBirthdayStatusModel birthday,
  ) {
    if (birthday.studentId == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BirthdayChatScreen(
          studentId:
              birthday.studentId!,
          studentName:
              birthday.studentName ??
                  'Student',
          className:
              birthday.className,
          section:
              birthday.section,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.white,
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(
            context,
          ),
          icon:
              const Icon(
            Icons
                .arrow_back_ios_new_rounded,
            color:
                Color(0xff172033),
            size: 20,
          ),
        ),
        title: Text(
          'Birthday Status',
          style:
              GoogleFonts.poppins(
            color:
                const Color(
              0xff172033,
            ),
            fontSize: 18,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body:
          RefreshIndicator(
        color:
            primaryColor,
        onRefresh:
            _loadBirthdays,
        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(
                height: 22,
              ),

              _buildStatusSection(),

              const SizedBox(
                height: 26,
              ),

              _buildChatInfo(),

              const SizedBox(
                height: 18,
              ),

              _buildTip(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        21,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          25,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                BoxDecoration(
              color: Colors
                  .white
                  .withOpacity(
                0.14,
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Center(
              child: Text(
                '🎂',
                style:
                    TextStyle(
                  fontSize: 31,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Today’s Birthdays',
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  birthdays.isEmpty
                      ? 'No birthdays today'
                      : '${birthdays.length} students celebrating today',
                  style:
                      GoogleFonts.poppins(
                    color: Colors
                        .white
                        .withOpacity(
                      0.82,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS SECTION
  // =========================================================

  Widget _buildStatusSection() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        15,
        18,
        15,
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xffE6EBF2,
          ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Birthday Status',
            style:
                GoogleFonts.poppins(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
              color:
                  const Color(
                0xff172033,
              ),
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            'Tap a student to open their birthday chat',
            style:
                GoogleFonts.poppins(
              fontSize: 10,
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          if (isLoading)
            const SizedBox(
              height: 110,
              child:
                  Center(
                child:
                    CircularProgressIndicator(
                  color:
                      primaryColor,
                ),
              ),
            )
          else if (birthdays.isEmpty)
            _buildEmpty()
          else
            SizedBox(
              height: 125,
              child:
                  ListView.separated(
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    birthdays.length,
                separatorBuilder:
                    (_, __) =>
                        const SizedBox(
                  width: 17,
                ),
                itemBuilder:
                    (context, index) {
                  return _buildStatusItem(
                    birthdays[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // WHATSAPP STYLE STATUS ITEM
  // =========================================================

  Widget _buildStatusItem(
    StudentBirthdayStatusModel birthday,
  ) {
    return GestureDetector(
      onTap: () =>
          _openChat(birthday),
      child:
          SizedBox(
        width: 76,
        child:
            Column(
          children: [
            Container(
              width: 70,
              height: 70,
              padding:
                  const EdgeInsets.all(
                3,
              ),
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    const SweepGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                    Color(0xff64B5F6),
                    Color(0xff1565C0),
                  ],
                ),
              ),
              child:
                  Container(
                padding:
                    const EdgeInsets.all(
                  3,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Colors.white,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    Container(
                  decoration:
                      const BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        Color(
                          0xffE3F2FD,
                        ),
                        Color(
                          0xffBBDEFB,
                        ),
                      ],
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      Center(
                    child:
                        Text(
                      _initials(
                        birthday
                                .studentName ??
                            '',
                      ),
                      style:
                          GoogleFonts.poppins(
                        color:
                            primaryColor,
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              birthday
                      .studentName ??
                  'Student',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.center,
              style:
                  GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color:
                    const Color(
                  0xff172033,
                ),
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            Text(
              '🎂 Today',
              style:
                  GoogleFonts.poppins(
                fontSize: 8,
                color:
                    Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CHAT INFO
  // =========================================================

  Widget _buildChatInfo() {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xff172033,
        ),
        borderRadius:
            BorderRadius.circular(
          21,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: Colors
                  .white
                  .withOpacity(
                0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                const Icon(
              Icons
                  .chat_rounded,
              color:
                  Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(
            width: 13,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Individual Birthday Chats',
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Every student has a separate conversation.',
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TIP
  // =========================================================

  Widget _buildTip() {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xffE8F1FF,
        ),
        borderRadius:
            BorderRadius.circular(
          17,
        ),
      ),
      child:
          Row(
        children: [
          const Icon(
            Icons
                .info_outline_rounded,
            color:
                primaryColor,
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child:
                Text(
              'Tap a birthday status to chat, reply, react, edit or delete messages.',
              style:
                  GoogleFonts.poppins(
                fontSize: 9,
                color:
                    const Color(
                  0xff36506E,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildEmpty() {
    return SizedBox(
      height: 100,
      child:
          Center(
        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            const Text(
              '🎈',
              style:
                  TextStyle(
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'No birthdays today',
              style:
                  GoogleFonts.poppins(
                fontSize: 10,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INITIALS
  // =========================================================

  String _initials(
    String name,
  ) {
    final parts =
        name.trim().split(' ');

    if (parts.isEmpty ||
        parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(
            0,
            parts.first.length >=
                    2
                ? 2
                : 1,
          )
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}