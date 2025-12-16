import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatView extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String patientName;
  final String patientId;

  const ChatView({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  late final String currentUserId;
  late final String chatNode;
  late final DatabaseReference chatDB;
  late final DatabaseReference typingDB;
  late final DatabaseReference lastSeenDB;

  bool get isDoctor => currentUserId == widget.doctorId;

  @override
  void initState() {
    super.initState();
    currentUserId = auth.currentUser!.uid;
    chatDB = FirebaseDatabase.instance.ref().child("chats");
    typingDB = FirebaseDatabase.instance.ref().child("typing");
    lastSeenDB = FirebaseDatabase.instance.ref().child("lastSeen");

    chatNode = (widget.doctorId.compareTo(widget.patientId) < 0)
        ? "${widget.doctorId}_${widget.patientId}"
        : "${widget.patientId}_${widget.doctorId}";

    lastSeenDB.child(currentUserId).set(DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> uploadImageToSupabase(File image) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final response = await supabase.storage
          .from("gallery_images")
          .upload(fileName, image);
      if (response.isEmpty) return null;
      return supabase.storage.from("gallery_images").getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  void sendTextMessage() {
    if (messageController.text.trim().isEmpty) return;
    sendMessageToDB(message: messageController.text.trim(), isImage: false);
    messageController.clear();
    typingDB.child(chatNode).child(currentUserId).remove();
  }

  Future<void> sendImageMessage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final url = await uploadImageToSupabase(file);
    if (url != null) {
      sendMessageToDB(message: url, isImage: true);
    }
  }

  void sendMessageToDB({required String message, required bool isImage}) {
    final chatId = chatDB.push().key!;
    final time = DateTime.now().millisecondsSinceEpoch;

    chatDB.child(chatNode).child(chatId).set({
      "chatId": chatId,
      "senderId": currentUserId,
      "message": message,
      "isImage": isImage,
      "isDeleted": false,
      "time": time,
      "seen": false,
    });

    chatDB.parent
        ?.child('chatList')
        .child(widget.doctorId)
        .child(widget.patientId)
        .set(chatNode);
    chatDB.parent
        ?.child('chatList')
        .child(widget.patientId)
        .child(widget.doctorId)
        .set(chatNode);

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showDeleteDialog(String chatId) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(local.translate("delete_message")),
        content: Text(local.translate("delete_message_confirmation")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.translate("cancel")),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(chatId);
              Navigator.pop(context);
            },
            child: Text(local.translate("delete")),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(String chatId) {
    chatDB.child(chatNode).child(chatId).remove();
  }

  Widget _buildTextMessage(
    String msg,
    bool isMe,
    String chatId, {
    bool isDeleted = false,
    bool seen = false,
  }) {
    final local = AppLocalizations.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _showDeleteDialog(chatId) : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF77CDBF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isDeleted
                  ? Text(
                      local.translate("message_deleted"),
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  : Text(
                      msg,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
              if (isMe && !isDeleted)
                Icon(
                  seen ? Icons.done_all : Icons.done,
                  size: 16,
                  color: seen ? Colors.blue : Colors.white70,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessage(
    String url,
    bool isMe,
    String chatId, {
    bool isDeleted = false,
    bool seen = false,
  }) {
    final local = AppLocalizations.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _showDeleteDialog(chatId) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isDeleted
                  ? Text(
                      local.translate("message_deleted"),
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        url,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
              if (isMe && !isDeleted)
                Icon(
                  seen ? Icons.done_all : Icons.done,
                  size: 16,
                  color: seen ? Colors.blue : Colors.white70,
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
    final chatPartner = isDoctor ? widget.patientName : widget.doctorName;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: AppColors.scondaryColor,
        title: StreamBuilder(
          stream: lastSeenDB
              .child(isDoctor ? widget.patientId : widget.doctorId)
              .onValue,
          builder: (context, snapshot) {
            String lastSeen = local.translate("last_seen_unknown");
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final time = snapshot.data!.snapshot.value as int;
              final dt = DateTime.fromMillisecondsSinceEpoch(time);
              lastSeen =
                  "${local.translate("last_seen")}: ${dt.hour}:${dt.minute}";
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chatPartner, style: const TextStyle(color: Colors.white)),
                Text(
                  lastSeen,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatDB.child(chatNode).orderByChild("time").onValue,
              builder: (context, snapshot) {
                if (snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                      child: Text(local.translate("no_messages_yet")));
                }

                final dataMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final data = dataMap.entries.toList();
                data.sort(
                  (a, b) => (a.value["time"] as int)
                      .compareTo(b.value["time"] as int),
                );

                for (var entry in data) {
                  final msgId = entry.key;
                  final msg = entry.value;
                  final senderId = msg["senderId"] as String;
                  if (!isDoctor && senderId == widget.doctorId ||
                      isDoctor && senderId == widget.patientId) {
                    if (msg["seen"] == false) {
                      chatDB.child(chatNode).child(msgId).update({"seen": true});
                    }
                  }
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final chatId = data[index].key;
                    final msg = data[index].value;
                    final isMe = msg["senderId"] == currentUserId;

                    return msg["isImage"] == true
                        ? _buildImageMessage(
                            msg["message"] as String,
                            isMe,
                            chatId,
                            isDeleted: msg["isDeleted"] as bool? ?? false,
                            seen: msg["seen"] as bool? ?? false,
                          )
                        : _buildTextMessage(
                            msg["message"] as String,
                            isMe,
                            chatId,
                            isDeleted: msg["isDeleted"] as bool? ?? false,
                            seen: msg["seen"] as bool? ?? false,
                          );
                  },
                );
              },
            ),
          ),
          StreamBuilder(
            stream: typingDB.child(chatNode).onValue,
            builder: (context, snapshot) {
              Map<dynamic, dynamic> typingMap = {};
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                typingMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                typingMap.remove(currentUserId);
              }
              String typingText =
                  typingMap.isNotEmpty ? local.translate("typing") : "";

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (typingText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          typingText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.image,
                            color: Color(0xFF77CDBF),
                          ),
                          onPressed: sendImageMessage,
                        ),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 150,
                            ),
                            child: Scrollbar(
                              child: TextField(
                                controller: messageController,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: local.translate("type_a_message"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF77CDBF),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: (text) {
                                  if (text.isNotEmpty) {
                                    typingDB
                                        .child(chatNode)
                                        .child(currentUserId)
                                        .set(true);
                                  } else {
                                    typingDB
                                        .child(chatNode)
                                        .child(currentUserId)
                                        .remove();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF77CDBF),
                          radius: 25,
                          child: IconButton(
                            icon:
                                const Icon(Icons.send, color: Colors.white),
                            onPressed: sendTextMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
