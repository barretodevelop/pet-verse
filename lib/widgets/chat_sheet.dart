// ChatSheet
// lib/widgets/chat_sheet.dart - ChatSheet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message_model.dart';
import '../models/pet_model.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
// import 'bottom_sheet_base.dart'; // No longer using BottomSheetBase

class ChatSheet extends ConsumerStatefulWidget {
  // final bool show; // Removed
  // final VoidCallback onClose; // Removed
  final PetModel pet;

  const ChatSheet({
    super.key,
    // required this.show, // Removed
    // required this.onClose, // Removed
    required this.pet,
  });

  @override
  ConsumerState<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<ChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessageModel> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider);

    return Column(
      // Return the content directly
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header (similar to what BottomSheetBase or InventorySheet now has)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Chat - ${widget.pet.name}', // Title
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context), // Closes the modal bottom sheet
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),

        // Original content of the ChatSheet
        // Wrapped in Expanded if it's scrollable content like a ListView
        // For this specific layout, the existing Expanded for messages list is fine.
        // Collaboration header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChatAvatar(user?.avatar ?? '👨', 'Você', true),
              Text(widget.pet.emoji, style: const TextStyle(fontSize: 32)),
              _buildChatAvatar(
                widget.pet.identityRevealed
                    ? widget.pet.partnerAvatar ?? '❓'
                    : '❓',
                widget.pet.identityRevealed ? 'Parceiro' : 'Anônimo',
                false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Messages list
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFD1D5DB),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma mensagem ainda',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message.senderId == user?.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isMe
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF6B7280),
                            child: Text(
                              message.senderAvatar,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatAvatar(String avatar, String label, bool isUser) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              isUser ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
          child: Text(avatar, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: widget.pet.id,
      senderId: user.id,
      senderAvatar: user.avatar,
      message: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
