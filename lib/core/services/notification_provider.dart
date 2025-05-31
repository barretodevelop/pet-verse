// lib/core/providers/notification_provider.dart
// NOVO: Provider para gerenciar notificações do sistema

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/services/firebase_adoption_service.dart';
import 'package:petverse/core/services/notification_service.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// Provider para notificações do usuário
final userNotificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authState = ref.watch(authenticationNotifierProvider);
  if (authState.user?.uid == null) return [];

  return await FirebaseAdoptionService.getUserNotifications(
      authState.user!.uid);
});

// Provider para contagem de notificações não lidas
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);

  return notificationsAsync.when(
    data: (notifications) =>
        notifications.where((n) => n['isRead'] == false).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Notifier para gerenciar ações de notificação
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  NotificationNotifier() : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseAdoptionService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
    }
  }

  Future<void> markAllAsRead(List<String> notificationIds) async {
    try {
      state = const AsyncValue.loading();

      for (final id in notificationIds) {
        await FirebaseAdoptionService.markNotificationAsRead(id);
      }

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      // Usar NotificationService para mostrar notificação local
      final notificationService = NotificationService();

      // Por enquanto usar o método existente, mas pode ser expandido
      await notificationService.showCoParentCareNotification(title, message);
    } catch (e) {
      print('Erro ao mostrar notificação local: $e');
    }
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier();
});

// Provider para tipos específicos de notificações
final adoptionNotificationsProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);

  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) =>
            n['type'] == 'adoption_accepted' ||
            n['type'] == 'adoption_confirmed')
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final missionNotificationsProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);

  return notificationsAsync.when(
    data: (notifications) =>
        notifications.where((n) => n['type'] == 'mission_complete').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider para verificar se há notificações recentes (últimas 24h)
final recentNotificationsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);

  return notificationsAsync.when(
    data: (notifications) {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));

      return notifications.where((n) {
        if (n['createdAt'] == null) return false;

        final createdAt = DateTime.parse(n['createdAt'].toString());
        return createdAt.isAfter(oneDayAgo);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Enum para tipos de notificação
enum NotificationType {
  adoptionAccepted,
  adoptionConfirmed,
  missionComplete,
  petNeedsAttention,
  coParentActivity,
  achievement,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.adoptionAccepted:
        return 'adoption_accepted';
      case NotificationType.adoptionConfirmed:
        return 'adoption_confirmed';
      case NotificationType.missionComplete:
        return 'mission_complete';
      case NotificationType.petNeedsAttention:
        return 'pet_needs_attention';
      case NotificationType.coParentActivity:
        return 'co_parent_activity';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.general:
        return 'general';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.adoptionAccepted:
        return 'Adoção Aceita';
      case NotificationType.adoptionConfirmed:
        return 'Adoção Confirmada';
      case NotificationType.missionComplete:
        return 'Missão Completa';
      case NotificationType.petNeedsAttention:
        return 'Pet Precisa de Atenção';
      case NotificationType.coParentActivity:
        return 'Atividade do Co-Parent';
      case NotificationType.achievement:
        return 'Conquista Desbloqueada';
      case NotificationType.general:
        return 'Notificação';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationType.adoptionAccepted:
        return '🎉';
      case NotificationType.adoptionConfirmed:
        return '🐾';
      case NotificationType.missionComplete:
        return '✅';
      case NotificationType.petNeedsAttention:
        return '⚠️';
      case NotificationType.coParentActivity:
        return '💕';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.general:
        return '📢';
    }
  }
}

// Helper class para criar notificações estruturadas
class NotificationHelper {
  static Map<String, dynamic> createAdoptionAcceptedNotification({
    required String userId,
    required String coParentCodename,
    required String petName,
    required String requestId,
    required String petId,
  }) {
    return {
      'userId': userId,
      'type': NotificationType.adoptionAccepted.value,
      'title':
          '${NotificationType.adoptionAccepted.emoji} ${NotificationType.adoptionAccepted.displayName}',
      'message': '$coParentCodename aceitou cuidar de $petName com você!',
      'data': {
        'requestId': requestId,
        'petId': petId,
        'petName': petName,
        'coParentCodename': coParentCodename,
      },
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> createAdoptionConfirmedNotification({
    required String userId,
    required String petName,
    required String originalRequesterCodename,
    required String requestId,
    required String petId,
  }) {
    return {
      'userId': userId,
      'type': NotificationType.adoptionConfirmed.value,
      'title':
          '${NotificationType.adoptionConfirmed.emoji} ${NotificationType.adoptionConfirmed.displayName}',
      'message': 'Você agora é co-guardião de $petName!',
      'data': {
        'requestId': requestId,
        'petId': petId,
        'petName': petName,
        'originalRequesterCodename': originalRequesterCodename,
      },
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> createPetNeedsAttentionNotification({
    required String userId,
    required String petName,
    required String petId,
    required String reason,
  }) {
    return {
      'userId': userId,
      'type': NotificationType.petNeedsAttention.value,
      'title':
          '${NotificationType.petNeedsAttention.emoji} Pet Precisa de Atenção',
      'message': '$petName precisa de atenção: $reason',
      'data': {
        'petId': petId,
        'petName': petName,
        'reason': reason,
      },
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> createCoParentActivityNotification({
    required String userId,
    required String coParentName,
    required String action,
    required String petName,
    required String petId,
  }) {
    return {
      'userId': userId,
      'type': NotificationType.coParentActivity.value,
      'title':
          '${NotificationType.coParentActivity.emoji} Atividade do Co-Parent',
      'message': '$coParentName $action com $petName',
      'data': {
        'petId': petId,
        'petName': petName,
        'coParentName': coParentName,
        'action': action,
      },
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
