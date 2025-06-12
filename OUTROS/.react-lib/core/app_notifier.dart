import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';
import '../data/mock_data.dart';
import '../models/adoption_request.dart';
import '../models/ai_config.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/feed_post.dart';
import '../models/particle.dart';
import '../models/pet.dart';
import '../models/shop_item.dart';
import '../models/user.dart';
import '../utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provedor para SharedPreferences (carregamento assíncrono)
// Este provedor precisa ser sobrescrito em main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// AppNotifier: Gerencia o estado da aplicação e a lógica de negócio
class AppNotifier extends Notifier<AppState> {
  // Timers para efeitos de lado
  Timer? _deathTimer;
  Timer? _matchingTimer;
  Timer? _particleTimer;

  // O método build é chamado uma vez para inicializar o estado
  @override
  AppState build() {
    // Inicializa com um estado padrão antes de tentar carregar
    state = AppState(missions: List.from(MISSIONS), aiConfig: AIConfig());
    _loadState(); // Carrega o estado persistido (assíncrono)
    _startTimers(); // Inicia os timers

    // Garante que os timers sejam cancelados quando o provedor for descartado
    ref.onDispose(() {
      _deathTimer?.cancel();
      _matchingTimer?.cancel();
      _particleTimer?.cancel();
    });

    return state; // Retorna o estado inicial (padrão ou carregado)
  }

  // Carrega o estado do SharedPreferences
  Future<void> _loadState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final storedState = prefs.getString('appState');
    if (storedState != null) {
      try {
        state = AppState.fromJson(jsonDecode(storedState));
      } catch (e) {
        // Se houver erro na desserialização, inicializa com valores padrão
        print('Erro ao carregar estado do SharedPreferences: $e');
        state = AppState(missions: List.from(MISSIONS), aiConfig: AIConfig());
      }
    } else {
      // Se não houver estado salvo, inicializa com valores padrão
      state = AppState(missions: List.from(MISSIONS), aiConfig: AIConfig());
    }
  }

  // Salva o estado atual no SharedPreferences
  Future<void> _saveState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('appState', jsonEncode(state.toJson()));
  }

  // --- Getters para acessar o estado ---
  // A maioria dos getters não é mais necessária aqui, pois o estado é acessado
  // diretamente via `state.propriedade`. Apenas os que envolvem lógica extra são mantidos.

  int get maxSlots => 2 + ((state.user?.level ?? 1) ~/ 5);
  int get unlockedSlots => min(state.pets.length + 1, maxSlots);
  bool get hasSoloPet => state.pets.any((pet) => !pet.isCollab);
  Pet? get activePet => state.pets.isNotEmpty && state.activePetIndex < state.pets.length
      ? state.pets[state.activePetIndex]
      : null;

  // --- Métodos para modificar o estado ---

  void setIsDark(bool value) {
    state = state.copyWith(isDark: value);
    _saveState();
  }

  void setUser(User? newUser) {
    state = state.copyWith(user: newUser);
    _saveState();
  }

  void setActivePetIndex(int index) {
    if (index >= 0 && index < state.pets.length) {
      state = state.copyWith(activePetIndex: index);
      _saveState();
    }
  }

  void setAIConfig(AIConfig config) {
    state = state.copyWith(aiConfig: config);
    _saveState();
  }

  String _generateAvatar() {
    final avatars = ['👨', '👩', '🧑', '👱', '👨‍💻', '👩‍💻', '🧔', '👴', '👵'];
    return avatars[Random().nextInt(avatars.length)];
  }

  void createParticle(String type, double x, double y) {
    final particle = Particle(
      id: DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000),
      type: type,
      x: x,
      y: y,
      vx: (Random().nextDouble() - 0.5) * 4,
      vy: -Random().nextDouble() * 6 - 2,
    );
    state = state.copyWith(particles: [...state.particles, particle]);
    // Não é necessário salvar partículas no SharedPreferences a cada tick
    // _saveState(); // Descomentar se as partículas precisarem ser persistidas

    // Remover partícula após um tempo
    Timer(const Duration(milliseconds: 2000), () {
      state = state.copyWith(particles: state.particles.where((p) => p.id != particle.id).toList());
      // _saveState(); // Descomentar se as partículas precisarem ser persistidas
    });
  }

  void addFeedPost(String type, String content, {int? petId}) {
    final post = FeedPost(
      id: DateTime.now().millisecondsSinceEpoch,
      type: type,
      content: content,
      petId: petId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: state.user?.id,
    );
    state = state.copyWith(feedPosts: [post, ...state.feedPosts.take(19)]);
    _saveState();
  }

  // Geração de pet único (simplificado para demonstração sem chamada real de API)
  Future<bool> generateUniquePet(String prompt) async {
    if (state.gems < 10) {
      _addNotification('❌ Você não tem gemas suficientes!');
      return false;
    }

    try {
      state = state.copyWith(gems: state.gems - 10);
      _saveState();

      // Simulação de chamada de API
      await Future.delayed(const Duration(seconds: 3));

      final mockPet = Pet(
        id: DateTime.now().millisecondsSinceEpoch,
        name: prompt.isNotEmpty ? prompt.substring(0, min(prompt.length, 15)) : 'Pet Único',
        emoji: '✨',
        imageUrl: 'https://placehold.co/150x150/FFC107/000000?text=AI+Pet',
        rarity: 'único',
        isUnique: true,
        generatedBy: state.user?.username,
        prompt: prompt,
        status: PetStatus.adopted,
        adoptedAt: DateTime.now().millisecondsSinceEpoch,
        lastCared: DateTime.now().millisecondsSinceEpoch,
        category: 'gerado por IA',
        traits: ['Místico', 'Raro', 'IA Generated'],
      );

      state = state.copyWith(
        uniquePets: [...state.uniquePets, mockPet],
        pets: [...state.pets, mockPet],
        activePetIndex: state.pets.length, // Define o novo pet como ativo
      );
      _saveState();

      _addNotification('✨ Pet único gerado com sucesso!');
      addFeedPost('unique_generation',
          '🎨 ${state.user?.username ?? "Um usuário"} gerou um pet único: ${mockPet.name}!',
          petId: mockPet.id);
      _updateMissionProgress(5, 1);

      return true;
    } catch (error) {
      state = state.copyWith(gems: state.gems + 10); // Reembolsar em caso de erro
      _saveState();
      _addNotification('❌ Erro ao gerar pet único. Tente novamente.');
      return false;
    }
  }

  void addPet(Pet petData, String type) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Verificar se o pet já foi adotado/devolvido/morreu
    final isInDeadPets =
        state.deadPets.any((p) => p.name == petData.name && p.emoji == petData.emoji);
    final isInReturnedPets =
        state.returnedPets.any((p) => p.name == petData.name && p.emoji == petData.emoji);
    final isAlreadyOwned =
        state.pets.any((p) => p.name == petData.name && p.emoji == petData.emoji);

    if (isInDeadPets || isInReturnedPets || isAlreadyOwned) {
      _addNotification('❌ Este pet não está mais disponível.');
      return;
    }

    if (type == 'solo') {
      final newPet = petData.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        level: 1,
        xp: 0,
        happiness: 50,
        hunger: 50,
        energy: 50,
        health: 80,
        isCollab: false,
        status: PetStatus.adopted,
        canInteract: true,
        accessories: [],
        lastCared: now,
        adoptedAt: now,
      );
      state = state.copyWith(
        pets: [...state.pets, newPet],
        activePetIndex: state.pets.length, // Define o novo pet como ativo
      );
      _saveState();
      addFeedPost('adoption', '🎉 ${state.user?.username ?? "Um usuário"} adotou ${newPet.name}!',
          petId: newPet.id);
    } else if (type == 'collab') {
      if (!(petData.canInteract == true)) {
        // hasMatch logic from React
        final adoptionRequest = AdoptionRequest(
          id: DateTime.now().millisecondsSinceEpoch,
          pet: petData,
          userId: state.user?.id ?? 0,
          userAvatar: state.user?.avatar ?? _generateAvatar(),
          expiresAt: now + (5 * 24 * 60 * 60 * 1000),
          status: 'waiting',
        );
        state = state.copyWith(pendingAdoptions: [...state.pendingAdoptions, adoptionRequest]);
        _saveState();
        _addNotification('🦄 Solicitação de adoção enviada! Aguardando parceiro...');
      } else {
        final partnerAvatar = _generateAvatar();
        final newPet = petData.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          level: 1,
          xp: 0,
          happiness: 50,
          hunger: 50,
          energy: 50,
          health: 80,
          isCollab: true,
          status: PetStatus.adopted,
          partner: 'Usuário Anônimo',
          partnerAvatar: partnerAvatar,
          userAvatar: state.user?.avatar,
          canInteract: true,
          accessories: [],
          lastCared: now,
          adoptedAt: now,
          revealLevel: 5,
          identityRevealed: false,
        );
        state = state.copyWith(
          pets: [...state.pets, newPet],
          activePetIndex: state.pets.length, // Define o novo pet como ativo
        );
        _saveState();
        _addNotification('🎉 Match encontrado! Vocês adotaram um ${newPet.name}!');
        addFeedPost('collaboration', '🤝 Colaboração iniciada! ${newPet.name} foi adotado em dupla',
            petId: newPet.id);
      }
    }
  }

  void killPet(int petId) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    if (pet != null) {
      final deadPet = pet.copyWith(
          diedAt: DateTime.now().millisecondsSinceEpoch,
          deathReason: 'negligência',
          status: PetStatus.dead);
      state = state.copyWith(
        deadPets: [...state.deadPets, deadPet],
        pets: state.pets.where((p) => p.id != petId).toList(),
      );
      // Reduzir XP do usuário
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(xp: max(0, state.user!.xp - 50)),
        );
      }
      setActivePetIndex(0); // Mudar para o primeiro pet disponível
      _saveState();
      _addNotification('💀 ${pet.name} faleceu por falta de cuidados.');
      addFeedPost('death',
          '😢 ${pet.name} faleceu por negligência. ${state.user?.username ?? "Um usuário"} perdeu 50 XP',
          petId: petId);
    }
  }

  bool returnPet(int petId) {
    if (state.gems < 3) {
      _addNotification('❌ Você não tem gemas suficientes para devolver o pet.');
      return false;
    }
    final pet = state.pets.firstWhere((p) => p.id == petId);
    if (pet != null) {
      state = state.copyWith(gems: state.gems - 3);
      final returnedPet = pet.copyWith(
          returnedAt: DateTime.now().millisecondsSinceEpoch, status: PetStatus.returned);
      state = state.copyWith(
        pets: state.pets.where((p) => p.id != petId).toList(),
        returnedPets: [...state.returnedPets, returnedPet],
      );
      setActivePetIndex(0); // Mudar para o primeiro pet disponível
      _saveState();
      _addNotification('😢 ${pet.name} foi devolvido.');
      addFeedPost('return', '🔄 ${state.user?.username ?? "Um usuário"} devolveu ${pet.name}',
          petId: petId);
      return true;
    }
    return false;
  }

  bool unlockSlot() {
    if (state.gems < 5) {
      _addNotification('❌ Você não tem gemas suficientes para desbloquear o slot.');
      return false;
    }
    // Lógica para slots já está nos getters (maxSlots, unlockedSlots)
    // A ação de "desbloquear" aqui é apenas consumir gemas, o UI deve habilitar mais slots
    state = state.copyWith(gems: state.gems - 5);
    _saveState();
    _addNotification('✨ Novo slot desbloqueado!');
    return true;
  }

  void updatePetStats(int petId, Map<String, dynamic> stats) {
    state = state.copyWith(
      pets: state.pets.map((pet) {
        if (pet.id == petId) {
          return pet.copyWith(
            happiness: stats['happiness'] as int? ?? pet.happiness,
            hunger: stats['hunger'] as int? ?? pet.hunger,
            energy: stats['energy'] as int? ?? pet.energy,
            health: stats['health'] as int? ?? pet.health,
            lastCared: DateTime.now().millisecondsSinceEpoch,
          );
        }
        return pet;
      }).toList(),
    );
    _saveState();
  }

  void addPetXP(int petId, int amount) {
    state = state.copyWith(
      pets: state.pets.map((pet) {
        if (pet.id == petId) {
          final newXP = pet.xp + amount;
          final newLevel = (newXP ~/ 100) + 1;
          if (newLevel > pet.level) {
            _addNotification('🎉 ${pet.name} subiu para nível $newLevel!');
            addFeedPost('level_up', '⭐ ${pet.name} alcançou nível $newLevel!', petId: petId);
            if (pet.isCollab &&
                newLevel >= (pet.revealLevel ?? 0) &&
                !(pet.identityRevealed ?? false)) {
              _addNotification('👁️ Identidade pode ser revelada para ${pet.name}!');
            }
          }
          return pet.copyWith(xp: newXP, level: newLevel);
        }
        return pet;
      }).toList(),
    );
    _saveState();
  }

  void addUserXP(int amount) {
    if (state.user != null) {
      final newXP = state.user!.xp + amount;
      final newLevel = (newXP ~/ 100) + 1;
      if (newLevel > state.user!.level) {
        _addNotification('🎉 Você subiu para nível $newLevel!');
      }
      state = state.copyWith(
        user: state.user!.copyWith(xp: newXP, level: newLevel),
      );
      _saveState();
    }
  }

  bool buyItem(ShopItem item) {
    if (state.coins < item.cost) {
      _addNotification('❌ Você não tem moedas suficientes para comprar ${item.name}.');
      return false;
    }
    state = state.copyWith(coins: state.coins - item.cost);
    final newItem =
        item.copyWith(id: DateTime.now().millisecondsSinceEpoch); // Novo ID para item no inventário
    state = state.copyWith(inventory: [...state.inventory, newItem]);
    _saveState();
    _addNotification('🛍️ ${item.name} comprado!');
    return true;
  }

  bool useItem(ShopItem item, int petId) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    if (pet == null) {
      _addNotification('Pet não encontrado.');
      return false;
    }

    // Remover item do inventário
    state = state.copyWith(
      inventory: state.inventory.where((i) => i.id != item.id).toList(),
    );

    Map<String, dynamic> statUpdates = {};

    switch (item.type) {
      case 'food':
        if (item.name.contains('Premium')) {
          statUpdates = {
            'hunger': min(100, pet.hunger + 25),
            'happiness': min(100, pet.happiness + 10)
          };
        } else if (item.name.contains('Petisco')) {
          statUpdates = {'happiness': min(100, pet.happiness + 20)};
        } else {
          statUpdates = {'hunger': min(100, pet.hunger + 15)};
        }
        break;
      case 'toy':
        statUpdates = {
          'energy': min(100, pet.energy + 20),
          'happiness': min(100, pet.happiness + 15)
        };
        break;
      case 'medicine':
        if (item.name.contains('Poção')) {
          statUpdates = {'health': min(100, pet.health + 40), 'energy': min(100, pet.energy + 10)};
        } else {
          statUpdates = {'health': min(100, pet.health + 25)};
        }
        break;
      case 'accessory':
        // Adiciona o acessório ao pet e aplica um efeito básico
        state = state.copyWith(
          pets: state.pets
              .map(
                (p) => p.id == petId
                    ? p.copyWith(accessories: [...p.accessories, item.toAccessory()])
                    : p,
              )
              .toList(),
        );
        statUpdates = {'happiness': min(100, pet.happiness + 10)};
        break;
    }

    updatePetStats(petId, statUpdates);
    addPetXP(petId, 5);
    addUserXP(3);
    _addNotification('✨ ${item.name} usado em ${pet.name}!');
    _updateMissionProgress(4, 1);
    _saveState();
    return true;
  }

  void _updateMissionProgress(int missionId, int progress) {
    state = state.copyWith(
      missions: state.missions.map((mission) {
        if (mission.id == missionId) {
          return mission.copyWith(progress: min(mission.max, mission.progress + progress));
        }
        return mission;
      }).toList(),
    );
    _saveState();
  }

  void _addNotification(String message) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    state = state.copyWith(notifications: [notification, ...state.notifications.take(4)]);
    _saveState();

    Timer(const Duration(seconds: 5), () {
      state = state.copyWith(
          notifications: state.notifications.where((n) => n.id != notification.id).toList());
      _saveState();
    });
  }

  void sendChatMessage(int petId, String message) {
    final chatId = 'pet_$petId';
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      sender: state.user?.username ?? 'Anônimo',
      senderAvatar: state.user?.avatar ?? _generateAvatar(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final currentMessages = state.chatMessages[chatId] ?? [];
    state = state.copyWith(
      chatMessages: {
        ...state.chatMessages,
        chatId: [...currentMessages, newMessage],
      },
    );
    _saveState();
  }

  void revealIdentity(int petId) {
    state = state.copyWith(
      pets: state.pets.map((pet) {
        if (pet.id == petId) {
          return pet.copyWith(identityRevealed: true);
        }
        return pet;
      }).toList(),
    );
    _saveState();
    _addNotification('🎭 Identidades reveladas!');
  }

  void logout() {
    state = AppState(
      missions: List.from(MISSIONS), // Reset para missões padrão
      aiConfig: AIConfig(), // Reset para config de IA padrão
    );
    _saveState();
    _addNotification('Você foi desconectado.');
  }

  // --- Lógica de Timers (useEffect equivalente) ---
  void _startTimers() {
    // Cancela timers existentes para evitar duplicação
    _deathTimer?.cancel();
    _matchingTimer?.cancel();
    _particleTimer?.cancel();

    // Sistema de morte por negligência (a cada minuto)
    _deathTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final fiveDays = 5 * 24 * 60 * 60 * 1000;

      final petsToKill = state.pets.where((pet) => now - pet.lastCared > fiveDays).toList();
      for (var pet in petsToKill) {
        killPet(pet.id);
      }
    });

    // Sistema de matching (a cada 10 segundos)
    _matchingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      state = state.copyWith(
        pendingAdoptions: state.pendingAdoptions
            .map((adoption) {
              final now = DateTime.now().millisecondsSinceEpoch;
              // Lógica de match aleatória
              if (adoption.status == 'waiting' && Random().nextDouble() < 0.1) {
                final partnerAvatar = _generateAvatar();
                final newPet = adoption.pet.copyWith(
                  id: DateTime.now().millisecondsSinceEpoch,
                  level: 1,
                  xp: 0,
                  happiness: 50,
                  hunger: 50,
                  energy: 50,
                  health: 80,
                  isCollab: true,
                  status: PetStatus.adopted,
                  partner: 'Usuário Anônimo',
                  partnerAvatar: partnerAvatar,
                  userAvatar: adoption.userAvatar,
                  canInteract: true,
                  accessories: [],
                  lastCared: now,
                  adoptedAt: now,
                  revealLevel: 5,
                  identityRevealed: false,
                );

                state = state.copyWith(
                  pets: [...state.pets, newPet],
                  activePetIndex: state.pets.length, // Define o novo pet como ativo
                );
                _addNotification('🎉 Match encontrado! Vocês adotaram ${adoption.pet.name}!');
                addFeedPost(
                    'collaboration', '🤝 Colaboração iniciada! ${newPet.name} foi adotado em dupla',
                    petId: newPet.id);
                _saveState(); // Salva o estado imediatamente após o match

                return adoption.copyWith(status: 'matched');
              }

              // Lógica de expiração
              if (now > adoption.expiresAt && adoption.status == 'waiting') {
                _addNotification('⏰ Solicitação de adoção de ${adoption.pet.name} expirou.');
                return adoption.copyWith(status: 'expired');
              }
              return adoption;
            })
            .where((adoption) => adoption.status != 'matched' && adoption.status != 'expired')
            .toList(),
      );
      _saveState(); // Salva o estado após cada iteração do matching
    });

    // Animação de partículas (a cada 16ms)
    _particleTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (state.particles.isEmpty) return; // Otimização: não faz nada se não houver partículas

      state = state.copyWith(
        particles: state.particles
            .map((particle) {
              return particle.copyWith(
                x: particle.x + particle.vx,
                y: particle.y + particle.vy,
                opacity: particle.opacity - 0.02,
                scale: particle.scale * 0.98,
                vy: particle.vy + 0.1, // gravidade
              );
            })
            .where((p) => p.opacity > 0)
            .toList(),
      );
      // Não salva partículas no SharedPreferences a cada tick, apenas no estado em memória
    });
  }

  void updateMissionProgress(int i, int j) {}
}

// Provedor que expõe o AppNotifier
final appServiceProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});
