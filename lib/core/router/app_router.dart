// app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/feature/auth/presentation/login_page.dart';
import 'package:petverse/feature/auth/providers/auth_provider.dart';
import 'package:petverse/feature/games/presentation/catch_food_game.dart';
import 'package:petverse/feature/games/presentation/pet_jump_game.dart';
import 'package:petverse/feature/home/presentation/home_screen.dart';
import 'package:petverse/feature/missions/presentation/missions_page.dart';
import 'package:petverse/feature/pet/presentation/pet_adoption_screen.dart';
import 'package:petverse/feature/room/presentation/room_chat_page.dart';
import 'package:petverse/feature/shop/presentation/shop_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) {
        return '/auth/login';
      }

      if (isAuth && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // Salas
          GoRoute(
            path: 'rooms/chat/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return RoomChatPage(roomId: roomId);
            },
          ),
          // Pet
          GoRoute(
            path: 'pet/adopt/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return PetAdoptionPage(roomId: roomId);
            },
          ),
          // Loja
          GoRoute(
            path: 'shop',
            builder: (context, state) => const ShopPage(),
          ),
          // Missões
          GoRoute(
            path: 'missions',
            builder: (context, state) => const MissionsPage(),
          ),
          // Games
          GoRoute(
            path: 'games/catch-food',
            builder: (context, state) => const CatchFoodGame(),
          ),
          GoRoute(
            path: 'games/pet-jump',
            builder: (context, state) => const PetJumpGame(),
          ),
        ],
      ),
    ],
  );
});
