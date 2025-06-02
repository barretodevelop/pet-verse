import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';

@immutable
class AppEvent {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> eventItemIds; // IDs dos ShopItems exclusivos do evento
  final List<String> eventQuestIds; // IDs das Quests exclusivas do evento
  final Color themeColor; // Cor temática para banners de evento, etc.
  final String? bannerAssetPath; // Opcional: Caminho para um asset de banner

  const AppEvent({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.eventItemIds = const [],
    this.eventQuestIds = const [],
    this.themeColor = AppColors.secondary, // Usando uma cor padrão
    this.bannerAssetPath,
  });

  bool isActive(DateTime now) {
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}

// lib/data/event_manager.dart (NOVO ou ATUALIZADO)
class EventManager {
  final List<AppEvent> _allEvents = [
    // Exemplo de Evento: Festival de Inverno (Junho/Julho no Hemisfério Sul)
    AppEvent(
      id: 'winter_festival_2025',
      name: '❄️ Festival de Inverno ❄️',
      startDate: DateTime(2025, 6, 15), // Início: 15 de Junho de 2025
      endDate: DateTime(2025, 7, 31, 23, 59, 59), // Fim: 31 de Julho de 2025
      eventItemIds: const [
        'scarf_winter',
        'hot_chocolate'
      ], // IDs de itens fictícios do evento
      eventQuestIds: const [
        'winter_gather_snowflakes'
      ], // ID de missão fictícia do evento
      themeColor: const Color(0xFF74B9FF), // Um azul gelado
      bannerAssetPath: 'assets/images/banner_winter_festival.png', // Exemplo
    ),
    // Adicionar outros eventos aqui (Natal, Páscoa, Verão do H.Norte, etc.)
    // AppEvent(
    //   id: 'summer_fun_2025', name: '☀️ Diversão de Verão ☀️',
    //   startDate: DateTime(2025, 12, 1), endDate: DateTime(2026, 2, 28), // Verão H.Sul
    //   eventItemIds: ['sunglasses_summer', 'beach_ball'],
    //   eventQuestIds: ['summer_play_games'],
    //   themeColor: Colors.orange,
    // ),
  ];

  AppEvent? getActiveEvent() {
    final now = DateTime.now();
    // debugPrint("Checando eventos para data: $now"); // Para depuração
    for (var event in _allEvents) {
      // debugPrint("Checando evento: ${event.name} - Início: ${event.startDate}, Fim: ${event.endDate}, Ativo: ${event.isActive(now)}");
      if (event.isActive(now)) {
        return event;
      }
    }
    return null;
  }
}

// lib/shared/providers/app_providers.dart (ADICIONAR/ATUALIZAR)
// (Presumindo que outros providers como persistenceServiceProvider já existem aqui)
final eventManagerProvider = Provider<EventManager>((ref) => EventManager());

// // lib/data/game_data.dart (ALTERADO)
// class GameData {
//   static final List<PetDefinition> availablePets = [
//     /* ...definições de pets... */
//   ];

//   // Itens base sempre disponíveis
//   static final Map<String, ShopItem> _baseShopItems = {
//     'hat': const ShopItem(
//         id: 'hat',
//         name: 'Chapéu Elegante',
//         emoji: '🎩',
//         coinPrice: 20,
//         category: ItemCategory.accessory,
//         isStackable: false),
//     'apple': const ShopItem(
//         id: 'apple',
//         name: 'Maçã Suculenta',
//         emoji: '🍎',
//         coinPrice: 2,
//         category: ItemCategory.food),
//     'ball': const ShopItem(
//         id: 'ball',
//         name: 'Bola Divertida',
//         emoji: '⚽',
//         coinPrice: 8,
//         category: ItemCategory.toy),
//     // ... outros itens base ...
//   };

//   // Itens que SÓ aparecem durante eventos específicos
//   static final Map<String, ShopItem> _eventOnlyShopItems = {
//     'scarf_winter': const ShopItem(
//         id: 'scarf_winter',
//         name: 'Cachecol de Inverno',
//         emoji: '🧣',
//         coinPrice: 25,
//         category: ItemCategory.accessory,
//         isStackable: false,
//         description: "Quentinho para o frio!"),
//     'hot_chocolate': const ShopItem(
//         id: 'hot_chocolate',
//         name: 'Chocolate Quente',
//         emoji: '☕',
//         coinPrice: 5,
//         category: ItemCategory.food,
//         description: "Para aquecer no inverno."),
//     // ... outros itens de evento ...
//   };

//   // Missões base sempre disponíveis (ou rotacionadas)
//   static final Map<String, Quest> _baseQuests = {
//     'feed_3': const Quest(
//         id: 'feed_3',
//         title: 'Hora do Lanche',
//         description: 'Alimente seu pet 3 vezes',
//         type: QuestType.feed,
//         targetCount: 3,
//         rewardCoins: 10,
//         detail: ''),
//     // ... outras missões base ...
//   };

//   // Missões que SÓ aparecem durante eventos específicos
//   static final Map<String, Quest> _eventOnlyQuests = {
//     'winter_gather_snowflakes': const Quest(
//         id: 'winter_gather_snowflakes',
//         title: 'Flocos de Neve',
//         description: 'Jogue o minijogo do Festival de Inverno 3 vezes.',
//         type: QuestType.playMinigame,
//         targetCount: 3,
//         rewardCoins: 50,
//         rewardGems: 2,
//         detail: "minigame_winter"), // 'detail' pode indicar qual minijogo
//     // ... outras missões de evento ...
//   };

//   // Método ATUALIZADO para obter itens da loja considerando o evento ativo
//   static List<ShopItem> getShopItems(AppEvent? activeEvent) {
//     final items = List<ShopItem>.from(_baseShopItems.values);
//     if (activeEvent != null) {
//       for (var itemId in activeEvent.eventItemIds) {
//         if (_eventOnlyShopItems.containsKey(itemId)) {
//           items.add(_eventOnlyShopItems[itemId]!);
//         }
//       }
//     }
//     // Poderia adicionar lógica para não repetir itens se eles também estiverem em _baseShopItems,
//     // mas a estrutura atual com _eventOnlyShopItems é mais clara para itens exclusivos.
//     return items;
//   }

//   // Método ATUALIZADO para obter missões disponíveis considerando o evento ativo
//   static List<Quest> getAvailableQuests(AppEvent? activeEvent) {
//     final quests =
//         List<Quest>.from(_baseQuests.values); // Começa com as missões base
//     if (activeEvent != null) {
//       for (var questId in activeEvent.eventQuestIds) {
//         if (_eventOnlyQuests.containsKey(questId)) {
//           quests.add(_eventOnlyQuests[questId]!);
//         }
//       }
//     }
//     return quests; // Retorna uma combinação de missões base e de evento
//   }

//   static Quest? getQuestById(String id) {
//     // Agora busca em ambas as listas
//     return _baseQuests[id] ?? _eventOnlyQuests[id];
//   }

//   static PetDefinition? getPetDefinitionById(String? id) {
//     /* ... */ return null;
//   }
// }

// // lib/features/user_profile/notifiers/user_notifier.dart (ALTERADO)
// class UserNotifier extends StateNotifier<UserProfile> {
//   // UserProfile é o seu modelo User
//   final PersistenceService _persistenceService;
//   final AppEvent? _activeEvent; // Agora recebe o evento ativo

//   UserNotifier(this._persistenceService, this._activeEvent)
//       : super(const UserProfile(coins: 100, gems: 10, uxp: 0));

//   Future<void> _saveData() async {/* ... */}

//   Future<void> loadDataAndCheckQuests(String firebaseUserId) async {
//     _currentFirebaseUserId = firebaseUserId;
//     state = await _persistenceService.loadUserProfile(firebaseUserId) ??
//         UserProfile(firebaseUserId: firebaseUserId, uxp: 0);
//     _checkForDailyQuestReset(); // Esta função agora pode usar _activeEvent
//     _initializeMissingAchievements();
//   }

//   void _checkForDailyQuestReset() {
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     if (state.lastQuestResetDate != today) {
//       _generateNewDailyQuests(today); // Passa a data para gerar novas missões
//     }
//   }

//   void _generateNewDailyQuests(String today) {
//     // USA O _activeEvent para buscar missões
//     final allAvailableQuests = GameData.getAvailableQuests(_activeEvent);
//     allAvailableQuests.shuffle();
//     final newQuests = <String, QuestProgress>{};
//     // Pega, por exemplo, 3 missões aleatórias da lista combinada
//     for (var quest in allAvailableQuests.take(3)) {
//       newQuests[quest.id] = QuestProgress(questId: quest.id);
//     }
//     state = state.copyWith(dailyQuests: newQuests, lastQuestResetDate: today);
//     _saveData();
//   }

//   // ... resto dos métodos do UserNotifier (addCoins, buyItem, etc.) não precisam de alteração direta aqui
//   // para o sistema de eventos, pois GameData já filtra os itens/quests.
//   // A inicialização das conquistas e o progresso delas permanecem os mesmos.
// }

// // lib/shared/providers/global_providers.dart (ALTERADO - Definição do userProvider)
// final userProvider = StateNotifierProvider<UserNotifier, UserProfile>((ref) {
//   // Pega o evento ativo do eventManagerProvider
//   final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();
//   return UserNotifier(ref.watch(persistenceServiceProvider),
//       activeEvent // Passa o evento ativo para o UserNotifier
//       );
// });
// // final activePetProvider = StateNotifierProvider<ActivePetNotifier, ActivePet?>( ... ); // Sem alteração aqui

// // lib/features/shop/screens/shop_screen.dart (ALTERADO)
// class ShopScreen extends ConsumerWidget {
//   const ShopScreen({super.key});
//   // _showPurchaseFeedback(...) sem alterações

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userState = ref.watch(userProvider);
//     final activeEvent =
//         ref.watch(eventManagerProvider).getActiveEvent(); // Pega o evento ativo
//     // USA O activeEvent para obter a lista de itens correta
//     final items = GameData.getShopItems(activeEvent);
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: const StyledAppBar(title: 'Loja de Itens'),
//       body: Column(children: [
//         // NOVO: Banner de Evento
//         if (activeEvent != null)
//           Container(
//             width: double.infinity,
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             color: activeEvent.themeColor,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Se tiver um bannerAssetPath, poderia usar Image.asset aqui
//                 // Ex: if (activeEvent.bannerAssetPath != null) Image.asset(activeEvent.bannerAssetPath!, height: 20),
//                 Flexible(
//                   // Para o texto não quebrar mal se for longo
//                   child: Text(
//                     activeEvent.name,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         const CurrencyDisplay(),
//         Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text("Adquira itens para seu pet!",
//                 style: theme.textTheme.titleLarge
//                     ?.copyWith(color: theme.colorScheme.onSurface),
//                 textAlign: TextAlign.center)),
//         Expanded(
//             child: ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//           itemCount: items.length,
//           itemBuilder: (_, index) {
//             // ... lógica de exibição do item e botão de compra (sem alterações significativas aqui) ...
//             final item = items[index];
//             final bool canAfford = userState.canAfford(item);
//             final bool canBuyMore =
//                 item.isStackable || !userState.hasItem(item.id);
//             return const Card(/* ... */);
//           },
//         )),
//       ]),
//     );
//   }
// }

// // lib/features/quests/screens/quests_screen.dart (ALTERADO)
// class QuestsScreen extends ConsumerWidget {
//   const QuestsScreen({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProvider);
//     // As missões no UserProfile já foram geradas considerando o evento ativo
//     final questsEntries = user.dailyQuests.entries.toList();
//     final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: StyledAppBar(title: activeEvent?.name ?? 'Missões Diárias'),
//       body: Column(
//         children: [
//           // NOVO: Pequeno banner se houver evento de missões
//           if (activeEvent != null &&
//               activeEvent.eventQuestIds.isNotEmpty &&
//               user.dailyQuests.keys
//                   .any((id) => activeEvent.eventQuestIds.contains(id)))
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8.0),
//               color: activeEvent.themeColor.withOpacity(0.8),
//               child: Text(
//                 "Missões Especiais do ${activeEvent.name} ativas!",
//                 style:
//                     theme.textTheme.labelLarge?.copyWith(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           Expanded(
//             child: questsEntries.isEmpty
//                 ? Center(
//                     child: Text("Nenhuma missão disponível. Volte amanhã!",
//                         style: TextStyle(color: theme.colorScheme.onSurface)))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: questsEntries.length,
//                     itemBuilder: (context, index) {
//                       // ... lógica de exibição da missão e botão de coletar (sem alterações significativas aqui) ...
//                       final questProgress = questsEntries[index].value;
//                       final questDef =
//                           GameData.getQuestById(questProgress.questId);
//                       if (questDef == null) return const SizedBox.shrink();
//                       return const Card(/* ... */);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
