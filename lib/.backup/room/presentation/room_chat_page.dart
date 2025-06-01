// lib/features/room/pages/room_chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/quick_messages.dart';
import 'package:petverse/core/providers/firebase_providers.dart';
import 'package:petverse/core/widgets/MessageBubble.dart';
import 'package:petverse/.backup/room/provider/room_provider.dart';

class RoomChatPage extends ConsumerStatefulWidget {
  final String roomId;

  const RoomChatPage({super.key, required this.roomId});

  @override
  ConsumerState<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends ConsumerState<RoomChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showQuickMessages = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final service = ref.read(roomServiceProvider);
    await service.sendMessage(widget.roomId, text);
    _messageController.clear();
  }

  Future<void> _sendQuickMessage(String emoji, String text) async {
    final service = ref.read(roomServiceProvider);
    await service.sendQuickMessage(widget.roomId, emoji, text);
    setState(() => _showQuickMessages = false);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomStream = ref.watch(roomStreamProvider(widget.roomId));
    final messagesStream = ref.watch(roomMessagesProvider(widget.roomId));
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: roomStream.when(
          data: (room) => Column(
            children: [
              const Text('Chat da Sala'),
              if (room != null)
                Text(
                  'Código: ${room.code}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          loading: () => const Text('Chat da Sala'),
          error: (_, __) => const Text('Chat da Sala'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status da sala
          roomStream.when(
            data: (room) {
              if (room == null) return const SizedBox.shrink();
              if (room.isWaiting) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange[100],
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, size: 16),
                      SizedBox(width: 8),
                      Text('Aguardando parceiro entrar na sala...'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Lista de mensagens
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nComece a conversa!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                // Auto scroll quando novas mensagens chegam
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Erro ao carregar mensagens: $error'),
              ),
            ),
          ),

          // Quick Messages
          if (_showQuickMessages)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: QuickMessages.messages.length,
                itemBuilder: (context, index) {
                  final quick = QuickMessages.messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text('${quick['emoji']} ${quick['text']}'),
                      onPressed: () => _sendQuickMessage(
                        quick['emoji']!,
                        quick['text']!,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Input de mensagem
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botão de mensagens rápidas
                IconButton(
                  icon: Icon(
                    _showQuickMessages ? Icons.close : Icons.emoji_emotions,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() => _showQuickMessages = !_showQuickMessages);
                  },
                ),

                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Botão enviar
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
