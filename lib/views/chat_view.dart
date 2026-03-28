import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/tools/app_localizations%20.dart';

class ChatView extends StatefulWidget {
  final String myId;
  final String otherUserId;
  final String otherUserName;
  final String chatId;
  final bool isFemaleChat;

  const ChatView({
    super.key,
    required this.myId,
    required this.otherUserId,
    required this.otherUserName,
    required this.chatId,
    this.isFemaleChat = false,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  late final DatabaseReference _chatDB;
  late final DatabaseReference _typingDB;
  late final DatabaseReference _lastSeenDB;

  bool _hasText = false;
  bool _sendingImg = false;
  bool _initialScrollDone = false;

  late final AnimationController _sendBtnCtrl;
  late final Animation<double> _sendScale;
  late final AnimationController _appBarCtrl;
  late final Animation<double> _appBarFade;

  Color get _accent =>
      widget.isFemaleChat ? const Color(0xFFD81B60) : const Color(0xFF1565C0);
  Color get _accent2 =>
      widget.isFemaleChat ? const Color(0xFF880E4F) : const Color(0xFF0D47A1);
  Color get _bg =>
      widget.isFemaleChat ? const Color(0xFF0F0812) : const Color(0xFF080E18);
  Color get _bgMid =>
      widget.isFemaleChat ? const Color(0xFF1A0C1A) : const Color(0xFF0B1628);
  Color get _surface =>
      widget.isFemaleChat ? const Color(0xFF1F0E20) : const Color(0xFF0E1F38);

  @override
  void initState() {
    super.initState();
    _chatDB = FirebaseDatabase.instance.ref('chats');
    _typingDB = FirebaseDatabase.instance.ref('typing');
    _lastSeenDB = FirebaseDatabase.instance.ref('lastSeen');

    _lastSeenDB.child(widget.myId).set(DateTime.now().millisecondsSinceEpoch);

    _sendBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _sendScale = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _sendBtnCtrl, curve: Curves.easeInOut));

    _appBarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _appBarFade = CurvedAnimation(parent: _appBarCtrl, curve: Curves.easeOut);
    _appBarCtrl.forward();

    _msgCtrl.addListener(() {
      final has = _msgCtrl.text.isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
        if (has) {
          _typingDB.child(widget.chatId).child(widget.myId).set(true);
        } else {
          _typingDB.child(widget.chatId).child(widget.myId).remove();
        }
      }
    });
  }

  @override
  void dispose() {
    _sendBtnCtrl.dispose();
    _appBarCtrl.dispose();
    _msgCtrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    _typingDB.child(widget.chatId).child(widget.myId).remove();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(max);
      }
    });
  }

  void _sendText() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _msgCtrl.clear();
    _typingDB.child(widget.chatId).child(widget.myId).remove();
    _sendToDB(message: text, isImage: false);
  }

  Future<void> _sendImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _sendingImg = true);
    try {
      final file = File(picked.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('curly_images').upload(fileName, file);
      final url = _supabase.storage
          .from('curly_images')
          .getPublicUrl(fileName);
      _sendToDB(message: url, isImage: true);
    } catch (_) {}
    if (mounted) setState(() => _sendingImg = false);
  }

  void _sendToDB({required String message, required bool isImage}) {
    final id = _chatDB.push().key!;
    final time = DateTime.now().millisecondsSinceEpoch;
    _chatDB.child(widget.chatId).child(id).set({
      'chatId': id,
      'senderId': widget.myId,
      'message': message,
      'isImage': isImage,
      'isDeleted': false,
      'time': time,
      'seen': false,
    });
    final root = _chatDB.parent!;
    root
        .child('chatList')
        .child(widget.myId)
        .child(widget.otherUserId)
        .set(widget.chatId);
    root
        .child('chatList')
        .child(widget.otherUserId)
        .child(widget.myId)
        .set(widget.chatId);
    _scrollToBottom(animate: true);
  }

  void _showDeleteDlg(String msgId) {
    final local = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .75),
      builder: (_) => Dialog(
        backgroundColor: Color.lerp(_bg, const Color(0xFF1E2840), .95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: .1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF5350).withValues(alpha: .3),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF5350),
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                local.translate('delete_message'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                local.translate('delete_message_confirmation'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DlgBtn(
                      label: local.translate('delete'),
                      danger: true,
                      onTap: () {
                        _chatDB.child(widget.chatId).child(msgId).remove();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DlgBtn(
                      label: local.translate('cancel'),
                      onTap: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bgMid, _bg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, .55, 1],
                ),
              ),
            ),
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withValues(alpha: .07),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withValues(alpha: .045),
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _DotGrid(_accent))),

            SafeArea(
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _appBarFade,
                    child: _buildAppBar(local),
                  ),

                  Expanded(
                    child: StreamBuilder(
                      stream: _chatDB
                          .child(widget.chatId)
                          .orderByChild('time')
                          .onValue,
                      builder: (ctx, snap) {
                        if (!snap.hasData ||
                            snap.data!.snapshot.value == null) {
                          return _emptyState(local);
                        }

                        final raw =
                            snap.data!.snapshot.value as Map<dynamic, dynamic>;
                        final msgs = raw.entries.toList()
                          ..sort((a, b) {
                            final ta = (a.value['time'] as num?)?.toInt() ?? 0;
                            final tb = (b.value['time'] as num?)?.toInt() ?? 0;
                            return ta.compareTo(tb);
                          });

                        for (final m in msgs) {
                          if (m.value['senderId'] != widget.myId &&
                              m.value['seen'] == false) {
                            _chatDB
                                .child(widget.chatId)
                                .child(m.key as String)
                                .update({'seen': true});
                          }
                        }

                        if (!_initialScrollDone) {
                          _initialScrollDone = true;
                          _scrollToBottom();
                        } else {
                          if (_scroll.hasClients) {
                            final pos = _scroll.position;
                            if (pos.maxScrollExtent - pos.pixels < 150) {
                              _scrollToBottom(animate: true);
                            }
                          }
                        }

                        final items = <Widget>[];
                        String? lastDateKey;

                        for (final m in msgs) {
                          final v = m.value as Map<dynamic, dynamic>;
                          final id = m.key as String;
                          final isMe = v['senderId'] == widget.myId;
                          final ts = (v['time'] as num?)?.toInt() ?? 0;
                          final dt = DateTime.fromMillisecondsSinceEpoch(ts);
                          final dk = '${dt.year}-${dt.month}-${dt.day}';

                          if (dk != lastDateKey) {
                            items.add(_dateSeparator(ts));
                            lastDateKey = dk;
                          }

                          final isImg = v['isImage'] == true;
                          final isDeleted = v['isDeleted'] == true;
                          final seen = v['seen'] == true;
                          final msg = (v['message'] ?? '').toString();

                          if (isImg) {
                            items.add(
                              _imageBubble(msg, isMe, id, ts: ts, seen: seen),
                            );
                          } else {
                            items.add(
                              _textBubble(
                                msg,
                                isMe,
                                id,
                                ts: ts,
                                isDeleted: isDeleted,
                                seen: seen,
                              ),
                            );
                          }
                        }

                        return ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                          children: items,
                        );
                      },
                    ),
                  ),

                  _buildInput(local),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations local) => Container(
    padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
    decoration: BoxDecoration(
      color: _bg.withValues(alpha: .97),
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: .05)),
      ),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 16),
      ],
    ),
    child: Row(
      children: [
        _BarBtn(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_accent, _accent2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: .5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.otherUserName.isNotEmpty
                      ? widget.otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A),
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder(
            stream: _lastSeenDB.child(widget.otherUserId).onValue,
            builder: (_, snap) {
              String sub = local.translate('last_seen_unknown');
              if (snap.hasData && snap.data!.snapshot.value != null) {
                final dt = DateTime.fromMillisecondsSinceEpoch(
                  snap.data!.snapshot.value as int,
                );
                final now = DateTime.now();
                final diff = now.difference(dt);
                if (diff.inMinutes < 1) {
                  sub = 'متصل الآن';
                } else if (diff.inHours < 1) {
                  sub = 'آخر ظهور منذ ${diff.inMinutes} د';
                } else if (diff.inDays < 1) {
                  sub =
                      'آخر ظهور الساعة ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                } else {
                  sub = 'آخر ظهور ${dt.day}/${dt.month}';
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .38),
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _BarBtn(
          color: _accent.withValues(alpha: .12),
          border: _accent.withValues(alpha: .25),
          onTap: _sendImage,
          child: Icon(Icons.camera_alt_rounded, color: _accent, size: 18),
        ),
      ],
    ),
  );

  Widget _textBubble(
    String msg,
    bool isMe,
    String id, {
    required int ts,
    bool isDeleted = false,
    bool seen = false,
  }) {
    final local = AppLocalizations.of(context);
    final time = _formatTime(ts);

    return GestureDetector(
      onLongPress: isMe ? () => _showDeleteDlg(id) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: isMe ? 60 : 12,
            right: isMe ? 12 : 60,
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .75,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [_accent, _accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isMe ? null : Colors.white.withValues(alpha: .09),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 3),
              bottomRight: Radius.circular(isMe ? 3 : 18),
            ),
            border: isMe
                ? null
                : Border.all(color: Colors.white.withValues(alpha: .07)),
            boxShadow: isMe
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: .35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: isDeleted
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            color: Colors.white.withValues(alpha: .3),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            local.translate('message_deleted'),
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: .35),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        msg,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : Colors.white.withValues(alpha: .92),
                          fontSize: 15,
                          height: 1.42,
                        ),
                      ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withValues(alpha: .55)
                          : Colors.white.withValues(alpha: .3),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isMe && !isDeleted) ...[
                    const SizedBox(width: 3),
                    Icon(
                      seen ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14,
                      color: seen
                          ? const Color(0xFF64B5F6)
                          : Colors.white.withValues(alpha: .45),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageBubble(
    String url,
    bool isMe,
    String id, {
    required int ts,
    bool seen = false,
  }) {
    final time = _formatTime(ts);
    return GestureDetector(
      onLongPress: isMe ? () => _showDeleteDlg(id) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: isMe ? 60 : 12,
            right: isMe ? 12 : 60,
          ),
          width: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 3),
              bottomRight: Radius.circular(isMe ? 3 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Image.network(
                url,
                width: 220,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : Container(
                        width: 220,
                        height: 180,
                        color: Colors.white.withValues(alpha: .06),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accent,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          seen ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13,
                          color: seen
                              ? const Color(0xFF64B5F6)
                              : Colors.white.withValues(alpha: .7),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateSeparator(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final isYesterday =
        DateTime(now.year, now.month, now.day - 1) ==
        DateTime(dt.year, dt.month, dt.day);
    final label = isToday
        ? 'اليوم'
        : isYesterday
        ? 'أمس'
        : '${dt.day}/${dt.month}/${dt.year}';

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .35),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInput(AppLocalizations local) {
    return StreamBuilder(
      stream: _typingDB.child(widget.chatId).onValue,
      builder: (_, snap) {
        final typing = <dynamic, dynamic>{};
        if (snap.hasData && snap.data!.snapshot.value != null) {
          final all = Map<dynamic, dynamic>.from(
            snap.data!.snapshot.value as Map,
          );
          all.remove(widget.myId);
          typing.addAll(all);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (typing.isNotEmpty) _typingIndicator(local),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: BoxDecoration(
                color: _surface.withValues(alpha: .97),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .04)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .3),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _BarBtn(
                    onTap: _sendingImg ? null : _sendImage,
                    color: _accent.withValues(alpha: .1),
                    border: _accent.withValues(alpha: .2),
                    child: _sendingImg
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          )
                        : Icon(Icons.image_rounded, color: _accent, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      constraints: const BoxConstraints(maxHeight: 130),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _hasText
                              ? _accent.withValues(alpha: .55)
                              : Colors.white.withValues(alpha: .07),
                          width: _hasText ? 1.4 : 1,
                        ),
                        boxShadow: _hasText
                            ? [
                                BoxShadow(
                                  color: _accent.withValues(alpha: .1),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: Scrollbar(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _focus,
                          maxLines: null,
                          minLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          cursorColor: _accent,
                          cursorWidth: 1.8,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: local.translate('type_a_message'),
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: .22),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTapDown: (_) => _sendBtnCtrl.forward(),
                    onTapUp: (_) {
                      _sendBtnCtrl.reverse();
                      _sendText();
                    },
                    onTapCancel: () => _sendBtnCtrl.reverse(),
                    child: ScaleTransition(
                      scale: _sendScale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: _hasText
                              ? LinearGradient(
                                  colors: [_accent, _accent2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _hasText
                              ? null
                              : Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(15),
                          border: _hasText
                              ? null
                              : Border.all(
                                  color: Colors.white.withValues(alpha: .08),
                                ),
                          boxShadow: _hasText
                              ? [
                                  BoxShadow(
                                    color: _accent.withValues(alpha: .5),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: _hasText
                              ? Colors.white
                              : Colors.white.withValues(alpha: .22),
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _typingIndicator(AppLocalizations local) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(0, _accent),
            const SizedBox(width: 4),
            _Dot(180, _accent),
            const SizedBox(width: 4),
            _Dot(360, _accent),
            const SizedBox(width: 8),
            Text(
              local.translate('typing'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .35),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState(AppLocalizations local) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accent.withValues(alpha: .06),
            border: Border.all(color: _accent.withValues(alpha: .15)),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: _accent.withValues(alpha: .4),
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          local.translate('no_messages_yet'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: .25),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'ابدأ المحادثة الآن 👋',
          style: TextStyle(color: _accent.withValues(alpha: .4), fontSize: 12),
        ),
      ],
    ),
  );

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BarBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color, border;
  const _BarBtn({required this.child, this.onTap, this.color, this.border});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border ?? Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Center(child: child),
    ),
  );
}

class _DlgBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _DlgBtn({
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: danger
            ? const Color(0xFFEF5350).withValues(alpha: .1)
            : Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: danger
              ? const Color(0xFFEF5350).withValues(alpha: .4)
              : Colors.white.withValues(alpha: .1),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: danger
                ? const Color(0xFFEF5350)
                : Colors.white.withValues(alpha: .5),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _Dot extends StatefulWidget {
  final int delay;
  final Color color;
  const _Dot(this.delay, this.color);
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _a = Tween<double>(
      begin: 0,
      end: -7,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Transform.translate(
      offset: Offset(0, _a.value),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: .65),
        ),
      ),
    ),
  );
}

class _DotGrid extends CustomPainter {
  final Color c;
  const _DotGrid(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = c.withValues(alpha: .016)
      ..style = PaintingStyle.fill;
    for (double x = 20; x < s.width; x += 28)
      for (double y = 20; y < s.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
  }

  @override
  bool shouldRepaint(_) => false;
}
