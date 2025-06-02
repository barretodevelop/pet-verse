import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';

class RequestHeader extends StatelessWidget {
  final CollaborativeAdoptionRequest activeRequest;

  const RequestHeader({super.key, required this.activeRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(activeRequest.requesterColorTheme).withOpacity(0.1),
            Color(activeRequest.requesterColorTheme).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(activeRequest.requesterColorTheme).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(activeRequest.requesterColorTheme).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(activeRequest.requesterColorTheme),
                  Color(activeRequest.requesterColorTheme).withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      Color(activeRequest.requesterColorTheme).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.schedule,
              size: 40,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 2000.ms),
          SizedBox(height: 20),
          Text(
            'Solicitação Ativa',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Expira em ${activeRequest.daysRemaining.toStringAsFixed(1)} dias',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: activeRequest.isUrgent
                  ? const Color(0xFFEF4444)
                  : Color(activeRequest.requesterColorTheme),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statDisplay('👁️', '${activeRequest.views}', 'Visualizações'),
              _statDisplay('❤️', '${activeRequest.interested}', 'Interessados'),
              _statDisplay(
                  '🎯', '${activeRequest.selectedPetIds.length}', 'Pets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDisplay(
    final String emoji,
    final String value,
    final String label,
  ) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
