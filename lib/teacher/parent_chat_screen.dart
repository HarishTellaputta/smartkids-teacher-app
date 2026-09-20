import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_model.dart';
import '../models/student_chat_model.dart';
import '../services/communication_service.dart';

class ParentChatScreen extends StatefulWidget {
  final int? classId;
  final String? className;
  final String? subject;

  const ParentChatScreen({
    super.key,
    this.classId,
    this.className,
    this.subject,
  });

  @override
  State<ParentChatScreen> createState() => _ParentChatScreenState();
}

class _ParentChatScreenState extends State<ParentChatScreen> {
  CommunicationService? _service;

  List<ConversationModel> _conversations = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Your existing login storage key
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _error = 'Login session expired. Please login again.';
        });
        return;
      }

      _service = CommunicationService(token);

      await _loadConversations();
    } catch (e) {
      debugPrint('Chat initialization error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to initialize chat.';
      });
    }
  }

  Future<void> _loadConversations() async {
    if (_service == null) return;

    try {
      final conversations = await _service!.getConversations();

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Load conversations error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load conversations.';
      });
    }
  }

  Future<void> _openNewChat() async {
    if (_service == null) return;

    final conversation = await Navigator.push<ConversationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => _NewChatScreen(
          service: _service!,
          classId: widget.classId,
          className: widget.className,
          subject: widget.subject,
        ),
      ),
    );

    if (!mounted) return;

    if (conversation != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ConversationScreen(
            service: _service!,
            conversation: conversation,
          ),
        ),
      );

      await _loadConversations();
    }
  }

  Future<void> _openConversation(
    ConversationModel conversation,
  ) async {
    if (_service == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ConversationScreen(
          service: _service!,
          conversation: conversation,
        ),
      ),
    );

    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.className != null &&
            widget.className!.trim().isNotEmpty
        ? '${widget.className} Chat'
        : 'Parent Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _loading ? null : _openNewChat,
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          !_loading && _error == null
              ? FloatingActionButton.extended(
                  onPressed: _openNewChat,
                  icon: const Icon(Icons.chat),
                  label: const Text('New Chat'),
                )
              : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });

                  _loadConversations();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadConversations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            const Icon(
              Icons.chat_bubble_outline,
              size: 70,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Start a conversation with a student\'s parent.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _openNewChat,
                icon: const Icon(Icons.add_comment),
                label: const Text('Start New Chat'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];

          return _ConversationCard(
            conversation: conversation,
            onTap: () => _openConversation(conversation),
          );
        },
      ),
    );
  }
}

// ============================================================
// CONVERSATION CARD
// ============================================================

class _ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount ?? 0;

    String lastMessage = 'No messages';

    if (conversation.messages.isNotEmpty) {
      final message = conversation.messages.last;

      if (message.content.trim().isNotEmpty) {
        lastMessage = message.content;
      }
    }

    final studentName =
        conversation.studentName?.trim().isNotEmpty == true
            ? conversation.studentName!.trim()
            : 'Student';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 25,
          child: Text(
            studentName[0].toUpperCase(),
          ),
        ),
        title: Text(
          studentName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.subject != null &&
                conversation.subject!.isNotEmpty)
              Text(
                conversation.subject!,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: unread > 0
            ? CircleAvatar(
                radius: 12,
                child: Text(
                  unread > 9 ? '9+' : unread.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ============================================================
// NEW CHAT - STUDENT LIST
// ============================================================

class _NewChatScreen extends StatefulWidget {
  final CommunicationService service;
  final int? classId;
  final String? className;
  final String? subject;

  const _NewChatScreen({
    required this.service,
    this.classId,
    this.className,
    this.subject,
  });

  @override
  State<_NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<_NewChatScreen> {
  List<StudentChatModel> _students = [];
  List<StudentChatModel> _filteredStudents = [];

  bool _loading = true;
  String? _error;

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadStudents();

    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final students =
          await widget.service.getTeacherStudents();

      if (!mounted) return;

      final filtered = widget.classId == null
          ? students
          : students
              .where(
                (student) =>
                    student.classId == widget.classId,
              )
              .toList();

      setState(() {
        _students = filtered;
        _filteredStudents = filtered;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Load chat students error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load students.';
      });
    }
  }

  void _filterStudents() {
    final query =
        _searchController.text.trim().toLowerCase();

    final filtered = _students.where((student) {
      final studentName =
          student.studentName.toLowerCase();

      final parentName =
          (student.parentName ?? '').toLowerCase();

      return query.isEmpty ||
          studentName.contains(query) ||
          parentName.contains(query);
    }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  Future<void> _selectStudent(
    StudentChatModel student,
  ) async {
    final conversation =
        await Navigator.push<ConversationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => _StartChatComposerScreen(
          service: widget.service,
          student: student,
          subject: widget.subject,
        ),
      ),
    );

    if (!mounted) return;

    if (conversation != null) {
      Navigator.pop(context, conversation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.className != null &&
            widget.className!.trim().isNotEmpty
        ? 'Students - ${widget.className}'
        : 'Select Student';

    return Scaffold(
      appBar: AppBar(
        title: Text(heading),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });

                  _loadStudents();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search student or parent',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredStudents.isEmpty
              ? const Center(
                  child: Text(
                    'No students available for chat.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: _filteredStudents.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final student =
                        _filteredStudents[index];

                    return Card(
                      child: ListTile(
                        onTap: () =>
                            _selectStudent(student),
                        leading: CircleAvatar(
                          child: Text(
                            student.studentName.isNotEmpty
                                ? student.studentName[0]
                                    .toUpperCase()
                                : 'S',
                          ),
                        ),
                        title: Text(
                          student.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          student.parentName != null &&
                                  student.parentName!
                                      .isNotEmpty
                              ? 'Parent: ${student.parentName}'
                              : 'Parent details unavailable',
                        ),
                        trailing: const Icon(
                          Icons.chat_outlined,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================
// START CHAT COMPOSER
// ============================================================

class _StartChatComposerScreen extends StatefulWidget {
  final CommunicationService service;
  final StudentChatModel student;
  final String? subject;

  const _StartChatComposerScreen({
    required this.service,
    required this.student,
    this.subject,
  });

  @override
  State<_StartChatComposerScreen> createState() =>
      _StartChatComposerScreenState();
}

class _StartChatComposerScreenState
    extends State<_StartChatComposerScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    final message =
        _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message.'),
        ),
      );
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final conversation =
          await widget.service.startConversation(
        studentId: widget.student.studentId,
        initialMessage: message,
        subject: widget.subject,
      );

      if (!mounted) return;

      Navigator.pop(context, conversation);
    } on DioException catch (e) {
      if (!mounted) return;

      String errorMessage =
          'Unable to start chat.';

      if (e.response?.statusCode == 403) {
        errorMessage =
            'You are not authorized to chat with this student.';
      } else if (e.response?.statusCode == 400) {
        errorMessage =
            'Invalid chat request.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      setState(() {
        _sending = false;
      });
    } catch (e) {
      debugPrint('Start chat error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start chat.'),
        ),
      );

      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    student.studentName.isNotEmpty
                        ? student.studentName[0]
                            .toUpperCase()
                        : 'S',
                  ),
                ),
                title: Text(
                  student.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  student.parentName != null &&
                          student.parentName!.isNotEmpty
                      ? 'Parent: ${student.parentName}'
                      : 'Parent',
                ),
              ),
            ),

            if (widget.subject != null &&
                widget.subject!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Subject: ${widget.subject}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              'Message',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                expands: true,
                textAlignVertical:
                    TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText:
                      'Type your first message to the parent...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    _sending ? null : _startChat,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _sending
                      ? 'Starting...'
                      : 'Start Chat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONVERSATION SCREEN
// ============================================================

class _ConversationScreen extends StatefulWidget {
  final CommunicationService service;
  final ConversationModel conversation;

  const _ConversationScreen({
    required this.service,
    required this.conversation,
  });

  @override
  State<_ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<_ConversationScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  late ConversationModel _conversation;

  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _conversation = widget.conversation;

    _loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    try {
      final conversation =
          await widget.service.getConversation(
        _conversation.id,
      );

      if (!mounted) return;

      setState(() {
        _conversation = conversation;
        _loading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Load conversation error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final content =
        _messageController.text.trim();

    if (content.isEmpty || _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await widget.service.sendMessage(
        conversationId: _conversation.id,
        content: content,
      );

      _messageController.clear();

      await _loadConversation();
    } catch (e) {
      debugPrint('Send message error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentName =
        _conversation.studentName?.trim().isNotEmpty ==
                true
            ? _conversation.studentName!.trim()
            : 'Student';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            if (_conversation.subject != null &&
                _conversation.subject!.isNotEmpty)
              Text(
                _conversation.subject!,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _buildMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_conversation.messages.isEmpty) {
      return const Center(
        child: Text('No messages'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _conversation.messages.length,
      itemBuilder: (context, index) {
        final message =
            _conversation.messages[index];

        final isTeacher =
            message.senderRole.toUpperCase() ==
                'TEACHER';

        return _MessageBubble(
          message: message,
          isTeacher: isTeacher,
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          8,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  _sending ? null : _sendMessage,
              icon: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE BUBBLE
// ============================================================

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isTeacher;

  const _MessageBubble({
    required this.message,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isTeacher
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.78,
        ),
        margin:
            const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(16),
          color: isTeacher
              ? Theme.of(context)
                  .colorScheme
                  .primary
              : Colors.grey.shade200,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isTeacher
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}