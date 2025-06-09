// File: lib/presentation/screens/home/pet/reveal_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

class RevealRequestScreen extends ConsumerStatefulWidget {
  final RevealRequestEntity request;

  const RevealRequestScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<RevealRequestScreen> createState() => _RevealRequestScreenState();
}

class _RevealRequestScreenState extends ConsumerState<RevealRequestScreen> {
  bool _isResponding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Solicitação de Reveal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header com animação
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 600),
                      child: _buildHeader(context),
                    ),

                    const SizedBox(height: ThemeConfig.spacing24),

                    // Informações da solicitação
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 700),
                      child: _buildRequestInfo(context),
                    ),

                    const SizedBox(height: ThemeConfig.spacing24),

                    // Explicação do reveal
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 800),
                      child: _buildRevealExplanation(context),
                    ),

                    const SizedBox(height: ThemeConfig.spacing24),

                    // Avisos importantes
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 900),
                      child: _buildImportantNotes(context),
                    ),
                  ],
                ),
              ),
            ),

            // Botões de ação
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 1000),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          children: [
            BounceAnimation(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              '💕 Seu Parceiro Quer\nSe Conhecer!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            Text(
              'Vocês cuidaram tão bem do pet juntos que agora podem se revelar!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Solicitação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildInfoRow('📅 Solicitado em:', _formatDate(widget.request.requestedAt)),
            const SizedBox(height: ThemeConfig.spacing8),
            _buildInfoRow('⏰ Status:', widget.request.status),
            const SizedBox(height: ThemeConfig.spacing8),
            _buildInfoRow('🐾 Pet ID:', widget.request.petId),
            if (widget.request.isExpired) ...[
              const SizedBox(height: ThemeConfig.spacing16),
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacing12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: ThemeConfig.spacing8),
                    Expanded(
                      child: Text(
                        'Esta solicitação expira em 24 horas!',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRevealExplanation(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que acontece no Reveal?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildExplanationItem(
              '👤',
              'Perfis Revelados',
              'Vocês poderão ver os perfis um do outro',
            ),
            _buildExplanationItem(
              '💬',
              'Chat Direto',
              'Poderão conversar diretamente no app',
            ),
            _buildExplanationItem(
              '🤝',
              'Colaboração Continua',
              'Podem continuar cuidando do pet juntos',
            ),
            _buildExplanationItem(
              '🏆',
              'Badge Especial',
              'Ganham badge de "Reveal Bem-sucedido"',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNotes(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: ThemeConfig.spacing8),
                Text(
                  'Importante Saber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildNoteItem('• O reveal só acontece se AMBOS aceitarem'),
            _buildNoteItem('• Você pode recusar e continuar anônimo'),
            _buildNoteItem('• Não há pressão para aceitar'),
            _buildNoteItem('• A decisão é irreversível'),
            _buildNoteItem('• Sempre seja respeitoso com seu parceiro'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeConfig.borderRadius16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isResponding ? null : () => _respondToReveal(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      const Text('❌', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        'Recusar',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'Continuar anônimo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ThemeConfig.spacing16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isResponding ? null : () => _respondToReveal(true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isResponding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          children: [
                            const Text('✅', style: TextStyle(fontSize: 20)),
                            const SizedBox(height: ThemeConfig.spacing4),
                            Text(
                              'Aceitar',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              'Conhecer parceiro',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.spacing12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Decidir depois'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConfig.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: ThemeConfig.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConfig.spacing4),
      child: Text(
        note,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
      ),
    );
  }

  Future<void> _respondToReveal(bool accepted) async {
    setState(() {
      _isResponding = true;
    });

    try {
      // Implementar resposta ao reveal aqui
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop();

        final message = accepted
            ? '✅ Reveal aceito! Aguarde a resposta do seu parceiro.'
            : '❌ Reveal recusado. Vocês continuarão anônimos.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: accepted ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResponding = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao responder reveal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
