import 'package:flutter/material.dart';
import '../../student_data.dart';

class StudentChatTab extends StatelessWidget {
  const StudentChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StudentState.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Percakapan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: state.chats.isEmpty
          ? const Center(
              child: Text('Belum ada obrolan aktif.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final lastMessage = chat.messages.isNotEmpty ? chat.messages.last.text : '';
                final lastTime = chat.messages.isNotEmpty ? chat.messages.last.time : '';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(chat.peerAvatar),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(chat.peerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(lastTime, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            chat.itemName,
                            style: const TextStyle(fontSize: 9, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentChatRoomScreen(chatRoom: chat),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class StudentChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const StudentChatRoomScreen({super.key, required this.chatRoom});

  @override
  State<StudentChatRoomScreen> createState() => _StudentChatRoomScreenState();
}

class _StudentChatRoomScreenState extends State<StudentChatRoomScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;

    StudentState.instance.sendMessage(widget.chatRoom.id, _msgCtrl.text.trim());
    _msgCtrl.clear();
    
    // Smooth scroll down
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
    Future.delayed(const Duration(seconds: 2), () => _scrollToBottom()); // scroll again for auto reply
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StudentState.instance,
      builder: (context, child) {
        // Fetch up-to-date chat room data from singleton state
        final chat = StudentState.instance.chats.firstWhere((c) => c.id == widget.chatRoom.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(chat.peerAvatar),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.peerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('Online', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Item Context Banner
              Container(
                color: const Color(0xFFE3F2FD),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Topik: ${chat.itemName}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      ),
                    ),
                  ],
                ),
              ),
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chat.messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),
              // Input bar
              _buildInputBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xFF64B5F6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 0),
            bottomRight: Radius.circular(msg.isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(color: msg.isMe ? Colors.white : Colors.black87, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  msg.time,
                  style: TextStyle(color: msg.isMe ? Colors.white70 : Colors.grey, fontSize: 8),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _msgCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF64B5F6),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}
