import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthdayChatScreen extends StatefulWidget {
  final int? studentId;
  final String? studentName;

  const BirthdayChatScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  @override
  State<BirthdayChatScreen> createState() => _BirthdayChatScreenState();
}

class _BirthdayChatScreenState extends State<BirthdayChatScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'message': 'Happy Birthday Rahul! 🎂🎉',
      'sender': 'You',
      'time': '09:15 AM',
      'isMe': true,
      'reaction': '❤️',
    },
    {
      'message': 'Thank you teacher! 😊',
      'sender': 'Rahul Kumar',
      'time': '09:17 AM',
      'isMe': false,
      'reaction': '',
    },
    {
      'message': 'Have a wonderful birthday! 🎈',
      'sender': 'You',
      'time': '09:18 AM',
      'isMe': true,
      'reaction': '🎉',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.studentName ?? 'Birthday Chat';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(title),
      body: Column(
        children: [
          _buildBirthdayBanner(),

          Expanded(
            child: messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      15,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(messages[index]);
                    },
                  ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xff172033),
          size: 20,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff1565C0),
                  Color(0xff42A5F5),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                '🎂',
                style: TextStyle(fontSize: 21),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xff172033),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Birthday Chat',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showMoreOptions,
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Color(0xff172033),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BIRTHDAY BANNER
  // =========================================================

  Widget _buildBirthdayBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                '🎉',
                style: TextStyle(fontSize: 23),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birthday Celebration',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share your wishes and make their day special.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.82),
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
  // MESSAGE
  // =========================================================

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isMe = message['isMe'] == true;
    final String text = message['message'] ?? '';
    final String sender = message['sender'] ?? '';
    final String time = message['time'] ?? '';
    final String reaction = message['reaction'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          left: isMe ? 45 : 0,
          right: isMe ? 0 : 45,
          bottom: 15,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                  bottom: 5,
                ),
                child: Text(
                  sender,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    11,
                    15,
                    9,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(
                        isMe ? 18 : 4,
                      ),
                      bottomRight: Radius.circular(
                        isMe ? 4 : 18,
                      ),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: const Color(0xffE7ECF2),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(
                            color: isMe
                                ? Colors.white
                                : const Color(0xff172033),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              color: isMe
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              fontSize: 8,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.done_all_rounded,
                              color: Color(0xffB9E2FF),
                              size: 13,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                if (reaction.isNotEmpty)
                  Positioned(
                    right: isMe ? -7 : null,
                    left: isMe ? null : -7,
                    bottom: -9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xffE5EAF0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        reaction,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 3),

            if (isMe)
              GestureDetector(
                onLongPress: () {
                  _showMessageOptions(message);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'Delivered',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MESSAGE INPUT
  // =========================================================

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          9,
          12,
          9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xffE8EDF3),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 45,
                  maxHeight: 110,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F6FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _showEmojiPicker,
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Color(0xff718096),
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization:
                            TextCapitalization.sentences,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xff172033),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a birthday wish...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: Color(0xff718096),
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff1565C0),
                      Color(0xff42A5F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY CHAT
  // =========================================================

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xffE8F1FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  '💬',
                  style: TextStyle(fontSize: 38),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Start a Birthday Conversation',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xff172033),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Send your first birthday wish.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SEND
  // =========================================================

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'message': text,
        'sender': 'You',
        'time': _currentTime(),
        'isMe': true,
        'reaction': '',
      });
    });

    _messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  String _currentTime() {
    final now = TimeOfDay.now();

    final hour = now.hourOfPeriod == 0
        ? 12
        : now.hourOfPeriod;

    final minute =
        now.minute.toString().padLeft(2, '0');

    final period = now.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$hour:$minute $period';
  }

  // =========================================================
  // OPTIONS
  // =========================================================

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                _bottomOption(
                  Icons.search_rounded,
                  'Search Messages',
                ),
                _bottomOption(
                  Icons.notifications_off_outlined,
                  'Mute Notifications',
                ),
                _bottomOption(
                  Icons.delete_outline_rounded,
                  'Clear Chat',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomOption(
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showMessageOptions(
    Map<String, dynamic> message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomOption(
                Icons.reply_rounded,
                'Reply',
              ),
              _bottomOption(
                Icons.edit_rounded,
                'Edit Message',
              ),
              _bottomOption(
                Icons.delete_outline_rounded,
                'Delete Message',
              ),
              _bottomOption(
                Icons.add_reaction_outlined,
                'Add Reaction',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmojiPicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Emoji picker will be connected later.',
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Attachments will be available later.',
        ),
      ),
    );
  }
}