import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/birthday_chat_message_model.dart';
import '../services/birthday_chat_service.dart';
import '../models/birthday_chat_reaction_model.dart';

class BirthdayChatScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String? className;
  final String? section;

  const BirthdayChatScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.className,
    this.section,
  });

  @override
  State<BirthdayChatScreen> createState() => _BirthdayChatScreenState();
}

class _BirthdayChatScreenState extends State<BirthdayChatScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color darkColor = Color(0xff172033);

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _messageFocusNode = FocusNode();

  BirthdayChatService? _chatService;

  List<BirthdayChatMessageModel> messages = [];

  bool isLoading = true;
  bool isSending = false;

  BirthdayChatMessageModel? _replyingTo;
  BirthdayChatMessageModel? _editingMessage;

  String? _currentUsername;

  Timer? _refreshTimer;

  // =========================================================
  // EMOJI PICKER STATE
  // =========================================================

  bool _showingEmojiPicker = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _initialize();

    _messageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _messageFocusNode.addListener(() {
      if (!mounted) return;

      // When keyboard opens, hide emoji picker.
      if (_messageFocusNode.hasFocus && _showingEmojiPicker) {
        setState(() {
          _showingEmojiPicker = false;
        });
      }

      // When keyboard becomes visible, move chat to bottom.
      if (_messageFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 250),
          () {
            if (mounted) {
              _scrollToBottom();
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();

    super.dispose();
  }

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('jwt_token');

    _currentUsername = _extractUsernameFromToken(token);

    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    _chatService = BirthdayChatService(token);

    await _loadMessages();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) {
        _silentRefresh();
      },
    );
  }

  String? _extractUsernameFromToken(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length < 2) {
        return null;
      }

      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]),
          ),
        ),
      );

      if (payload is Map<String, dynamic>) {
        return payload['sub']?.toString() ??
            payload['username']?.toString() ??
            payload['preferred_username']?.toString();
      }
    } catch (e) {
      debugPrint('JWT username extraction error: $e');
    }

    return null;
  }

  // =========================================================
  // LOAD MESSAGES
  // =========================================================

  Future<void> _loadMessages() async {
    if (_chatService == null) return;

    try {
      final result =
          await _chatService!.getMessages(widget.studentId);

      if (!mounted) return;

      setState(() {
        messages = result;
        isLoading = false;
      });

      _scrollToBottom(animated: false);
    } catch (e) {
      debugPrint('Birthday chat load error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _silentRefresh() async {
    if (_chatService == null) return;

    try {
      final result =
          await _chatService!.getMessages(widget.studentId);

      if (!mounted) return;

      final changed = _messagesChanged(result);

      if (changed) {
        setState(() {
          messages = result;
        });
      }
    } catch (e) {
      debugPrint('Birthday chat refresh error: $e');
    }
  }

  bool _messagesChanged(
    List<BirthdayChatMessageModel> newMessages,
  ) {
    if (newMessages.length != messages.length) {
      return true;
    }

    for (int i = 0; i < newMessages.length; i++) {
      final oldMessage = messages[i];
      final newMessage = newMessages[i];

      if (oldMessage.id != newMessage.id ||
          oldMessage.message != newMessage.message ||
          oldMessage.updatedAt != newMessage.updatedAt ||
          oldMessage.isEdited != newMessage.isEdited ||
          oldMessage.isDeleted != newMessage.isDeleted ||
          oldMessage.reactions.length !=
              newMessage.reactions.length) {
        return true;
      }

      for (int j = 0;
          j < oldMessage.reactions.length;
          j++) {
        final oldReaction = oldMessage.reactions[j];
        final newReaction = newMessage.reactions[j];

        if (oldReaction.reaction != newReaction.reaction ||
            oldReaction.count != newReaction.count ||
            oldReaction.reactedByCurrentUser !=
                newReaction.reactedByCurrentUser) {
          return true;
        }
      }
    }

    return false;
  }

  // =========================================================
  // SEND
  // =========================================================

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    if (_chatService == null) return;

    if (_editingMessage != null) {
      await _updateMessage(text);
      return;
    }

    if (_replyingTo != null) {
      await _sendReply(text);
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final message = await _chatService!.sendMessage(
        studentId: widget.studentId,
        message: text,
      );

      if (!mounted) return;

      setState(() {
        messages.add(message);
        isSending = false;
      });

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      _showError('Unable to send message');
    }
  }

  // =========================================================
  // REPLY
  // =========================================================

  Future<void> _sendReply(String text) async {
    final parent = _replyingTo;

    if (parent == null) return;

    setState(() {
      isSending = true;
    });

    try {
      final message =
          await _chatService!.replyToMessage(
        messageId: parent.id,
        message: text,
      );

      if (!mounted) return;

      setState(() {
        messages.add(message);
        _replyingTo = null;
        isSending = false;
      });

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      _showError('Unable to reply');
    }
  }

  // =========================================================
  // EDIT
  // =========================================================

  Future<void> _updateMessage(String text) async {
    final message = _editingMessage;

    if (message == null) return;

    setState(() {
      isSending = true;
    });

    try {
      final updated =
          await _chatService!.editMessage(
        messageId: message.id,
        message: text,
      );

      if (!mounted) return;

      setState(() {
        final index = messages.indexWhere(
          (item) => item.id == message.id,
        );

        if (index != -1) {
          messages[index] = updated;
        }

        _editingMessage = null;
        isSending = false;
      });

      _messageController.clear();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      _showError('Unable to edit message');
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> _deleteMessage(
    BirthdayChatMessageModel message,
  ) async {
    try {
      await _chatService!.deleteMessage(message.id);

      await _loadMessages();
    } catch (e) {
      debugPrint('Delete message error: $e');

      _showError('Unable to delete message');
    }
  }

  // =========================================================
  // REACTION
  // =========================================================

  Future<void> _toggleReaction(
    BirthdayChatMessageModel message,
    String emoji,
  ) async {
    try {
      final reaction = message.reactions.where(
        (item) => item.reaction == emoji,
      );

      final hasMyReaction =
          reaction.isNotEmpty &&
          reaction.first.reactedByCurrentUser;

      if (hasMyReaction) {
        await _chatService!.removeReaction(
          messageId: message.id,
          reaction: emoji,
        );
      } else {
        await _chatService!.addReaction(
          messageId: message.id,
          reaction: emoji,
        );
      }

      await _loadMessages();
    } catch (e) {
      debugPrint('Reaction error: $e');

      _showError('Unable to update reaction');
    }
  }

  // =========================================================
  // REPLY MODE
  // =========================================================

  void _startReply(
    BirthdayChatMessageModel message,
  ) {
    setState(() {
      _replyingTo = message;
      _editingMessage = null;
      _showingEmojiPicker = false;
    });

    // Open keyboard for reply.
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (mounted) {
          _messageFocusNode.requestFocus();

          Future.delayed(
            const Duration(milliseconds: 250),
            () {
              if (mounted) {
                _scrollToBottom();
              }
            },
          );
        }
      },
    );
  }

  // =========================================================
  // EDIT MODE
  // =========================================================

  void _startEdit(
    BirthdayChatMessageModel message,
  ) {
    setState(() {
      _editingMessage = message;
      _replyingTo = null;
      _showingEmojiPicker = false;
    });

    _messageController.text = message.message;

    _messageController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset: _messageController.text.length,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (mounted) {
          _messageFocusNode.requestFocus();

          Future.delayed(
            const Duration(milliseconds: 250),
            () {
              if (mounted) {
                _scrollToBottom();
              }
            },
          );
        }
      },
    );
  }

  // =========================================================
  // CANCEL
  // =========================================================

  void _cancelComposerMode() {
    setState(() {
      _replyingTo = null;
      _editingMessage = null;
    });

    _messageController.clear();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // IMPORTANT:
      // Allows Scaffold to resize when keyboard appears.
      resizeToAvoidBottomInset: true,

      appBar: _buildAppBar(),

      body: Column(
        children: [
          _buildBirthdayHeader(),

          Expanded(
            child: isLoading
                ? _buildLoading()
                : messages.isEmpty
                    ? _buildEmptyChat()
                    : _buildMessages(),
          ),

          _buildComposer(),

          // Emoji picker remains inside the screen.
          if (_showingEmojiPicker)
            _buildEmojiPicker(),
        ],
      ),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,

      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: darkColor,
          size: 20,
        ),
      ),

      titleSpacing: 0,

      title: Row(
        children: [
          _buildAvatar(
            widget.studentName,
            size: 43,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: darkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _studentSubtitle(),
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
          onPressed: _showSearch,
          icon: const Icon(
            Icons.search_rounded,
            color: darkColor,
          ),
        ),
        IconButton(
          onPressed: _showMoreOptions,
          icon: const Icon(
            Icons.more_vert_rounded,
            color: darkColor,
          ),
        ),
      ],
    );
  }

  String _studentSubtitle() {
    final parts = <String>[];

    if (widget.className != null &&
        widget.className!.isNotEmpty) {
      parts.add(widget.className!);
    }

    if (widget.section != null &&
        widget.section!.isNotEmpty) {
      parts.add('Section ${widget.section}');
    }

    parts.add('Birthday');

    return parts.join(' • ');
  }

  // =========================================================
  // BIRTHDAY HEADER
  // =========================================================

  Widget _buildBirthdayHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        4,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🎂',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Birthday Celebration 🎉',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Send your wishes and make the day special',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
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
  // MESSAGES
  // =========================================================

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,

      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        18,
      ),

      itemCount: messages.length,

      itemBuilder: (context, index) {
        return _buildMessageBubble(
          messages[index],
        );
      },
    );
  }

  Widget _buildMessageBubble(
    BirthdayChatMessageModel message,
  ) {
    final bool isMe = _isMyMessage(message);

    return GestureDetector(
      onLongPress: () {
        _showMessageActions(message);
      },

      child: Align(
        alignment: isMe
            ? Alignment.centerRight
            : Alignment.centerLeft,

        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width *
                    0.80,
          ),

          margin: EdgeInsets.only(
            left: isMe ? 45 : 3,
            right: isMe ? 3 : 45,
            bottom: 12,
          ),

          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,

            children: [
              if (!isMe &&
                  message.senderName != null)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 7,
                    bottom: 4,
                  ),
                  child: Text(
                    message.senderName!,
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              Stack(
                clipBehavior: Clip.none,

                children: [
                  Container(
                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      10,
                      12,
                      8,
                    ),

                    decoration: BoxDecoration(
                      color: isMe
                          ? primaryColor
                          : Colors.white,

                      borderRadius:
                          BorderRadius.only(
                        topLeft:
                            const Radius.circular(18),
                        topRight:
                            const Radius.circular(18),
                        bottomLeft:
                            Radius.circular(
                          isMe ? 18 : 4,
                        ),
                        bottomRight:
                            Radius.circular(
                          isMe ? 4 : 18,
                        ),
                      ),

                      border: isMe
                          ? null
                          : Border.all(
                              color:
                                  const Color(
                                0xffE4EAF1,
                              ),
                            ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(
                            0.025,
                          ),
                          blurRadius: 8,
                          offset:
                              const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [
                        if (message.parentMessageId !=
                            null)
                          _buildReplyReference(
                            message,
                            isMe,
                          ),

                        Text(
                          message.isDeleted
                              ? 'This message was deleted'
                              : message.message,

                          style:
                              GoogleFonts.poppins(
                            color:
                                message.isDeleted
                                    ? (isMe
                                        ? Colors.white70
                                        : Colors.grey
                                            .shade500)
                                    : (isMe
                                        ? Colors.white
                                        : darkColor),

                            fontSize: 12,
                            height: 1.4,

                            fontStyle:
                                message.isDeleted
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            if (message.isEdited)
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .only(right: 5),

                                child: Text(
                                  'edited',
                                  style:
                                      GoogleFonts.poppins(
                                    color: isMe
                                        ? Colors.white60
                                        : Colors.grey
                                            .shade500,
                                    fontSize: 7,
                                  ),
                                ),
                              ),

                            Text(
                              _formatTime(
                                message.createdAt,
                              ),
                              style:
                                  GoogleFonts.poppins(
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey
                                        .shade500,
                                fontSize: 8,
                              ),
                            ),

                            if (isMe) ...[
                              const SizedBox(width: 4),

                              const Icon(
                                Icons
                                    .done_all_rounded,
                                color:
                                    Color(0xffB9E2FF),
                                size: 13,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (message.reactions.isNotEmpty)
                    Positioned(
                      bottom: -10,

                      right: isMe ? 5 : null,
                      left: isMe ? null : 5,

                      child: _buildReactionBadge(
                        message.reactions,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // REPLY REFERENCE
  // =========================================================

  Widget _buildReplyReference(
    BirthdayChatMessageModel message,
    bool isMe,
  ) {
    if (message.replyToMessage == null ||
        message.replyToMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 7),

      padding:
          const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.16)
            : Colors.black.withOpacity(0.06),

        borderRadius:
            BorderRadius.circular(8),

        border: isMe
            ? Border(
                left: BorderSide(
                  color: Colors.white70,
                  width: 3,
                ),
              )
            : null,
      ),

      child: Text(
        message.replyToMessage!,

        maxLines: 2,

        overflow:
            TextOverflow.ellipsis,

        // IMPORTANT:
        // Reply text is WHITE for my message.
        style: GoogleFonts.poppins(
          fontSize: 9,

          color: isMe
              ? Colors.white
              : darkColor,

          fontWeight:
              FontWeight.w500,
        ),
      ),
    );
  }

  // =========================================================
  // REACTION BADGE
  // =========================================================

  Widget _buildReactionBadge(
    List<BirthdayChatReactionModel> reactions,
  ) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade300,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: reactions.map((item) {
          return Padding(
            padding:
                const EdgeInsets.only(
              right: 4,
            ),

            child: Text(
              item.count > 1
                  ? '${item.reaction} ${item.count}'
                  : item.reaction,

              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // COMPOSER
  // =========================================================

  Widget _buildComposer() {
    return SafeArea(
      top: false,

      child: Column(
        children: [
          if (_replyingTo != null ||
              _editingMessage != null)
            _buildComposerMode(),

          Container(
            padding:
                const EdgeInsets.fromLTRB(
              10,
              8,
              10,
              8,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              border: Border(
                top: BorderSide(
                  color:
                      const Color(0xffE7ECF2),
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                Expanded(
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      minHeight: 45,
                      maxHeight: 115,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xffF1F4F8),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [
                        IconButton(
                          onPressed:
                              _toggleEmojiPicker,

                          icon: Icon(
                            _showingEmojiPicker
                                ? Icons
                                    .keyboard_alt_rounded
                                : Icons
                                    .emoji_emotions_outlined,

                            color:
                                const Color(
                              0xff68778B,
                            ),

                            size: 22,
                          ),
                        ),

                        Expanded(
                          child: TextField(
                            controller:
                                _messageController,

                            minLines: 1,
                            maxLines: 5,

                            textCapitalization:
                                TextCapitalization
                                    .sentences,

                            focusNode:
                                _messageFocusNode,

                            style:
                                GoogleFonts.poppins(
                              fontSize: 12,
                              color: darkColor,
                            ),

                            decoration:
                                InputDecoration(
                              hintText:
                                  _editingMessage !=
                                          null
                                      ? 'Edit message...'
                                      : 'Write a birthday wish...',

                              hintStyle:
                                  GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors
                                    .grey
                                    .shade500,
                              ),

                              border:
                                  InputBorder.none,

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                GestureDetector(
                  onTap: isSending
                      ? null
                      : _sendMessage,

                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),

                    width: 46,
                    height: 46,

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
                          BorderRadius.circular(16),
                    ),

                    child: isSending
                        ? const Padding(
                            padding:
                                EdgeInsets.all(13),

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Icon(
                            _editingMessage != null
                                ? Icons
                                    .check_rounded
                                : Icons
                                    .send_rounded,

                            color:
                                Colors.white,

                            size: 20,
                          ),
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
  // EMOJI PICKER
  // =========================================================

  Widget _buildEmojiPicker() {
    const emojis = [
      '😀',
      '😂',
      '😍',
      '🥰',
      '😊',
      '😎',
      '🤩',
      '🥳',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😏',
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💯',
      '💥',
      '💫',
      '✨',
      '🔥',
      '👍',
      '👎',
      '👏',
      '🙏',
      '🙌',
      '🤝',
      '🎉',
      '🎊',
      '🎂',
      '🎈',
      '🥳',
      '💐',
    ];

    return Container(
      height: 260,

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color:
                const Color(0xffE7ECF2),
          ),
        ),
      ),

      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              14,
              8,
              14,
              4,
            ),

            child: Row(
              children: [
                Text(
                  'Emojis',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color: darkColor,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () {
                    setState(() {
                      _showingEmojiPicker =
                          false;
                    });
                  },

                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                4,
                14,
                12,
              ),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
              ),

              itemCount:
                  emojis.length,

              itemBuilder:
                  (context, index) {
                final emoji =
                    emojis[index];

                return GestureDetector(
                  onTap: () {
                    _insertEmoji(emoji);

                    // IMPORTANT:
                    // Do NOT close picker.
                    // Do NOT request keyboard focus.
                  },

                  child: Center(
                    child: Text(
                      emoji,
                      style:
                          const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMOJI TOGGLE
  // =========================================================

  void _toggleEmojiPicker() {
    if (_showingEmojiPicker) {
      // Emoji picker -> keyboard
      setState(() {
        _showingEmojiPicker = false;
      });

      Future.delayed(
        const Duration(milliseconds: 80),
        () {
          if (mounted) {
            _messageFocusNode.requestFocus();

            Future.delayed(
              const Duration(milliseconds: 250),
              () {
                if (mounted) {
                  _scrollToBottom();
                }
              },
            );
          }
        },
      );

      return;
    }

    // Keyboard -> emoji picker
    FocusScope.of(context).unfocus();

    setState(() {
      _showingEmojiPicker = true;
    });

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (mounted) {
          _scrollToBottom();
        }
      },
    );
  }

  // =========================================================
  // INSERT EMOJI
  // =========================================================

  void _insertEmoji(String emoji) {
    final text = _messageController.text;

    final selection =
        _messageController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || start > text.length) {
      start = text.length;
    }

    if (end < 0 || end > text.length) {
      end = text.length;
    }

    final newText =
        text.replaceRange(
      start,
      end,
      emoji,
    );

    final newOffset =
        start + emoji.length;

    _messageController.value =
        TextEditingValue(
      text: newText,

      selection:
          TextSelection.collapsed(
        offset: newOffset,
      ),
    );

    // VERY IMPORTANT:
    // We intentionally DO NOT call:
    //
    // _messageFocusNode.requestFocus();
    //
    // So keyboard will NOT appear.
    // Emoji picker stays open.
  }

  // =========================================================
  // COMPOSER MODE
  // =========================================================

  Widget _buildComposerMode() {
    final isEditing =
        _editingMessage != null;

    final message =
        isEditing
            ? _editingMessage
            : _replyingTo;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        8,
        8,
        8,
      ),

      color: Colors.white,

      child: Row(
        children: [
          Container(
            width: 3,
            height: 38,

            decoration:
                BoxDecoration(
              color: primaryColor,

              borderRadius:
                  BorderRadius.circular(3),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  isEditing
                      ? 'Editing message'
                      : 'Replying to ${message?.senderName ?? 'message'}',

                  style:
                      GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  message?.message ?? '',

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.grey.shade600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                _cancelComposerMode,

            icon: const Icon(
              Icons.close_rounded,
              size: 19,
              color:
                  Color(0xff68778B),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 86,
              height: 86,

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xffE8F1FF),
                shape: BoxShape.circle,
              ),

              child: const Center(
                child: Text(
                  '🎂',
                  style:
                      TextStyle(fontSize: 40),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Start Birthday Conversation',

              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color: darkColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Send ${widget.studentName} a birthday wish.',

              textAlign:
                  TextAlign.center,

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

  Widget _buildLoading() {
    return const Center(
      child:
          CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  // =========================================================
  // MESSAGE ACTIONS
  // =========================================================

  void _showMessageActions(
    BirthdayChatMessageModel message,
  ) {
    if (message.isDeleted) {
      _showDeletedMessageInfo();
      return;
    }

    final isMe =
        _isMyMessage(message);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              10,
              10,
              10,
              15,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Container(
                  width: 42,
                  height: 4,

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                _reactionRow(message),

                const Divider(),

                _actionTile(
                  Icons.reply_rounded,
                  'Reply',
                  () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _startReply(
                      message,
                    );
                  },
                ),

                if (isMe)
                  _actionTile(
                    Icons.edit_rounded,
                    'Edit',
                    () {
                      Navigator.pop(
                        sheetContext,
                      );

                      _startEdit(
                        message,
                      );
                    },
                  ),

                _actionTile(
                  Icons.forward_rounded,
                  'Forward',
                  () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _showForwardInfo(
                      message,
                    );
                  },
                ),

                _actionTile(
                  Icons.copy_rounded,
                  'Copy',
                  () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _copyMessage(
                      message,
                    );
                  },
                ),

                _actionTile(
                  Icons.add_reaction_outlined,
                  'More reactions',
                  () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _showAllReactions(
                      message,
                    );
                  },
                ),

                if (isMe)
                  _actionTile(
                    Icons.delete_outline_rounded,
                    'Delete',
                    () {
                      Navigator.pop(
                        sheetContext,
                      );

                      _confirmDelete(
                        message,
                      );
                    },
                    destructive: true,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // DELETED MESSAGE
  // =========================================================

  void _showDeletedMessageInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (_) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  Icons
                      .delete_outline_rounded,
                  size: 38,
                  color:
                      Colors.grey.shade500,
                ),

                const SizedBox(height: 12),

                Text(
                  'This message was deleted',

                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color: darkColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Deleted messages cannot be replied to or edited.',

                  textAlign:
                      TextAlign.center,

                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // REACTION ROW
  // =========================================================

  Widget _reactionRow(
    BirthdayChatMessageModel message,
  ) {
    const emojis = [
      '❤️',
      '😂',
      '😮',
      '😢',
      '🙏',
      '🎉',
      '🎂',
      '👍',
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,

        children: emojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);

              _toggleReaction(
                message,
                emoji,
              );
            },

            child: Text(
              emoji,
              style:
                  const TextStyle(
                fontSize: 24,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool destructive = false,
  }) {
    return ListTile(
      dense: true,

      leading: Icon(
        icon,
        color: destructive
            ? Colors.red
            : primaryColor,
      ),

      title: Text(
        title,

        style:
            GoogleFonts.poppins(
          fontSize: 12,
          fontWeight:
              FontWeight.w500,
          color: destructive
              ? Colors.red
              : darkColor,
        ),
      ),

      onTap: onTap,
    );
  }

  // =========================================================
  // MORE REACTIONS
  // =========================================================

  void _showAllReactions(
    BirthdayChatMessageModel message,
  ) {
    const reactions = [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '😂',
      '🤣',
      '😍',
      '🥰',
      '😮',
      '😢',
      '😡',
      '🙏',
      '👏',
      '👍',
      '👎',
      '🎉',
      '🎂',
      '🔥',
      '💯',
      '✨',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (_) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Wrap(
              spacing: 20,
              runSpacing: 20,

              children:
                  reactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                    );

                    _toggleReaction(
                      message,
                      emoji,
                    );
                  },

                  child: Text(
                    emoji,
                    style:
                        const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // DELETE CONFIRMATION
  // =========================================================

  void _confirmDelete(
    BirthdayChatMessageModel message,
  ) {
    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: Text(
            'Delete message?',
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: Text(
            'This message will be deleted.',
            style:
                GoogleFonts.poppins(
              fontSize: 12,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child:
                  const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );

                _deleteMessage(
                  message,
                );
              },

              child: const Text(
                'Delete',
                style:
                    TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // COPY
  // =========================================================

  Future<void> _copyMessage(
    BirthdayChatMessageModel message,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: message.message,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Message copied'),
        duration:
            Duration(seconds: 1),
      ),
    );
  }

  // =========================================================
  // FORWARD
  // =========================================================

  void _showForwardInfo(
    BirthdayChatMessageModel message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (_) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Icon(
                  Icons.forward_rounded,
                  size: 40,
                  color: primaryColor,
                ),

                const SizedBox(height: 12),

                Text(
                  'Forward Message',

                  style:
                      GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Forwarding can be connected once the backend forward endpoint is added.',

                  textAlign:
                      TextAlign.center,

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
      },
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _showSearch() {
    showSearch(
      context: context,

      delegate:
          _BirthdayMessageSearchDelegate(
        messages,
      ),
    );
  }

  // =========================================================
  // MORE
  // =========================================================

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              _actionTile(
                Icons.search_rounded,
                'Search',
                () {
                  Navigator.pop(
                    context,
                  );

                  _showSearch();
                },
              ),

              _actionTile(
                Icons.refresh_rounded,
                'Refresh',
                () {
                  Navigator.pop(
                    context,
                  );

                  _loadMessages();
                },
              ),

              _actionTile(
                Icons.notifications_off_outlined,
                'Mute notifications',
                () {
                  Navigator.pop(
                    context,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // AVATAR
  // =========================================================

  Widget _buildAvatar(
    String name, {
    double size = 48,
  }) {
    final initials =
        _initials(name);

    return Container(
      width: size,
      height: size,

      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        shape: BoxShape.circle,
      ),

      child: Center(
        child: Text(
          initials,

          style:
              GoogleFonts.poppins(
            color: Colors.white,
            fontSize:
                size * 0.30,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _initials(
    String name,
  ) {
    final parts =
        name.trim().split(' ');

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(
            0,
            parts.first.length >= 2
                ? 2
                : 1,
          )
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // =========================================================
  // HELPERS
  // =========================================================

  bool _isMyMessage(
    BirthdayChatMessageModel message,
  ) {
    if (_currentUsername == null ||
        _currentUsername!
            .trim()
            .isEmpty) {
      return false;
    }

    final currentUser =
        _currentUsername!
            .trim()
            .toLowerCase();

    final senderUsername =
        message.senderUsername
            ?.trim()
            .toLowerCase();

    if (senderUsername != null &&
        senderUsername.isNotEmpty) {
      return senderUsername ==
          currentUser;
    }

    final senderName =
        message.senderName
            ?.trim()
            .toLowerCase();

    return senderName ==
        currentUser;
  }

  String _formatTime(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return '';
    }

    try {
      final date =
          DateTime.parse(value)
              .toLocal();

      final hour =
          date.hour % 12 == 0
              ? 12
              : date.hour % 12;

      final minute =
          date.minute
              .toString()
              .padLeft(2, '0');

      final period =
          date.hour >= 12
              ? 'PM'
              : 'AM';

      return '$hour:$minute $period';
    } catch (_) {
      return value;
    }
  }

  // =========================================================
  // SCROLL TO BOTTOM
  // =========================================================

  void _scrollToBottom({
    bool animated = true,
  }) {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!_scrollController
            .hasClients) {
          return;
        }

        final position =
            _scrollController
                .position
                .maxScrollExtent;

        if (animated) {
          _scrollController
              .animateTo(
            position,

            duration:
                const Duration(
              milliseconds: 300,
            ),

            curve:
                Curves.easeOut,
          );
        } else {
          _scrollController
              .jumpTo(position);
        }
      },
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  void _showError(
    String message,
  ) {
    _showSnack(
      message,
      error: true,
    );
  }

  void _showSnack(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        backgroundColor:
            error
                ? Colors.red.shade700
                : darkColor,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),

        content: Text(
          message,

          style:
              GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// SEARCH DELEGATE
// =============================================================

class _BirthdayMessageSearchDelegate
    extends SearchDelegate<String?> {
  final List<BirthdayChatMessageModel>
      messages;

  _BirthdayMessageSearchDelegate(
    this.messages,
  );

  @override
  List<Widget>? buildActions(
    BuildContext context,
  ) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
    ];
  }

  @override
  Widget? buildLeading(
    BuildContext context,
  ) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back_rounded,
      ),
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    return _buildResults();
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    return _buildResults();
  }

  Widget _buildResults() {
    final results =
        messages.where(
      (message) => message.message
          .toLowerCase()
          .contains(
            query.toLowerCase(),
          ),
    );

    return ListView.builder(
      itemCount: results.length,

      itemBuilder: (_, index) {
        final message =
            results.elementAt(index);

        return ListTile(
          title:
              Text(message.message),

          subtitle: Text(
            message.senderName ??
                '',
          ),
        );
      },
    );
  }
}