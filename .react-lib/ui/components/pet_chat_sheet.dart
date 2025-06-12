import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para LucideIcons
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../../models/pet.dart';
import 'bottom_sheet.dart'; // Para o modelo Pet

class PetChatSheet extends ConsumerStatefulWidget {
  final bool show;
  final VoidCallback onClose;
  final Pet? pet; // O pet em questão

  const PetChatSheet({
    super.key,
    required this.show,
    required this.onClose,
    required this.pet,
  });

  @override
  ConsumerState<PetChatSheet> createState() => _PetChatSheetState();
}

class _PetChatSheetState extends ConsumerState<PetChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scrolla para o final da lista de mensagens
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(appServiceProvider.select((state) => state.chatMessages));
    final appService = ref.read(appServiceProvider.notifier);
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    if (widget.pet == null) return const SizedBox.shrink();

    final messages = chatMessages['pet_${widget.pet!.id}'] ?? [];
    final canReveal = widget.pet!.level >= (widget.pet!.revealLevel ?? 0) &&
        !(widget.pet!.identityRevealed ?? false);

    // Efeito para rolar para o final quando novas mensagens chegam
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return AppBottomSheet(
      show: widget.show,
      onClose: widget.onClose,
      title: 'Chat - ${widget.pet!.name}',
      fullHeight: true,
      children: Column(
        children: [
          // Informações de Colaboração (Avatares)
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade100,
                  Colors.blue.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade500,
                      child: Text(
                        widget.pet!.userAvatar ?? '❓',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Você', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Text(widget.pet!.emoji, style: const TextStyle(fontSize: 48)),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade400, // Corrected
                      child: Text(
                        widget.pet!.identityRevealed == true
                            ? widget.pet!.partnerAvatar ?? '❓'
                            : '❓',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.pet!.identityRevealed == true ? 'Parceiro' : 'Anônimo',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botão Revelar Identidades
          if (canReveal)
            GestureDetector(
              onTap: () {
                appService.revealIdentity(widget.pet!.id);
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.shade100,
                      Colors.orange.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.yellow.shade300, width: 2.0), // Corrected
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.eye, size: 32, color: Colors.yellow.shade800), // Corrected
                    const SizedBox(height: 8),
                    Text(
                      'Revelar Identidades',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow.shade800, // Corrected
                      ),
                    ),
                    Text(
                      'Nível ${widget.pet!.revealLevel}+ alcançado!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.yellow.shade700, // Corrected
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de Mensagens
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageCircle,
                            size: 64,
                            color:
                                isDark ? Colors.grey.shade600 : Colors.grey.shade400), // Corrected
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma mensagem ainda.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.sender == (appService.state.user?.username ?? 'Anônimo');
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.purple.shade400 // Sua mensagem
                                : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200), // Corrected
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.message,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Formata a data e hora
                                '${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).toLocal().toString().split('.')[0]}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white70
                                      : (isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600), // Corrected
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Campo de Entrada de Mensagem
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400), // Corrected
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    onSubmitted: (_) {
                      if (_messageController.text.trim().isNotEmpty) {
                        appService.sendChatMessage(widget.pet!.id, _messageController.text.trim());
                        _messageController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      appService.sendChatMessage(widget.pet!.id, _messageController.text.trim());
                      _messageController.clear();
                      _scrollToBottom();
                    }
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.purple.shade500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
