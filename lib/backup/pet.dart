//  // pet_model.dart
// class Pet {
//   final String id;
//   final String name;
//   final String roomId;
//   final List<String> parentIds;
//   final PetStats stats;
//   final PetProgression progression;
//   final DateTime createdAt;
//   final String petType;
//   final Map<String, dynamic> appearance;

//   const Pet({
//     required this.id,
//     required this.name,
//     required this.roomId,
//     required this.parentIds,
//     required this.stats,
//     this.progression = const PetProgression(),
//     required this.createdAt,
//     this.petType = 'default',
//     this.appearance = const {},
//   });

//   // Getters para compatibilidade com código existente
//   int get hunger => stats.hunger;
//   int get happiness => stats.happiness;
//   int get cleanliness => stats.cleanliness;
//   int get energy => stats.energy;

//   String get mood => PetGameLogic().getPetMood(stats);
//   String get status => PetGameLogic().getPetStatus(stats);

//   // Atualiza o pet com novos stats (aplicando degradação temporal)
//   Pet updateWithCurrentTime() {
//     final updatedStats = stats.calculateTimeDecay();
//     return copyWith(stats: updatedStats);
//   }

//   Pet copyWith({
//     String? id,
//     String? name,
//     String? roomId,
//     List<String>? parentIds,
//     PetStats? stats,
//     PetProgression? progression,
//     DateTime? createdAt,
//     String? petType,
//     Map<String, dynamic>? appearance,
//   }) {
//     return Pet(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       roomId: roomId ?? this.roomId,
//       parentIds: parentIds ?? this.parentIds,
//       stats: stats ?? this.stats,
//       progression: progression ?? this.progression,
//       createdAt: createdAt ?? this.createdAt,
//       petType: petType ?? this.petType,
//       appearance: appearance ?? this.appearance,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'roomId': roomId,
//       'parentIds': parentIds,
//       'stats': stats.toJson(),
//       'progression': progression.toJson(),
//       'createdAt': createdAt.toIso8601String(),
//       'petType': petType,
//       'appearance': appearance,
//     };
//   }

  
//   factory Pet.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Pet(
//       id: doc.id,
//       name: data['name'] ?? 'Pet',
//       roomId: data['roomId'] ?? '',
//       parentIds: List<String>.from(data['parentIds'] ?? []),
//       // hunger: (data['hunger'] as num?)?.toInt() ?? 50,
//       // happiness: (data['happiness'] as num?)?.toInt() ?? 50,
//       // cleanliness: (data['cleanliness'] as num?)?.toInt() ?? 50,
//       // lastFed: (data['lastFed'] as Timestamp).toDate(),
//       // lastPlayed: (data['lastPlayed'] as Timestamp).toDate(),
//       // lastCleaned: (data['lastCleaned'] as Timestamp).toDate(),
//       // lastCaredBy: data['lastCaredBy'],
//       // customization: data['customization'] is Map
//       //     ? Map<String, dynamic>.from(data['customization'])
//       //     : null,
//       // createdAt: (data['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'name': name,
//       'roomId': roomId,
//       'parentIds': parentIds,
//       'hunger': hunger,
//       'happiness': happiness,
//       'cleanliness': cleanliness,
//       // 'lastFed': Timestamp.fromDate(lastFed),
//       // 'lastPlayed': Timestamp.fromDate(lastPlayed),
//       // 'lastCleaned': Timestamp.fromDate(lastCleaned),
//       // // 'lastCaredBy': lastCaredBy,
//       // 'customization': customization,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }
 

//   factory Pet.fromJson(Map<String, dynamic> json) {
//     return Pet(
//       id: json['id'],
//       name: json['name'],
//       roomId: json['roomId'],
//       parentIds: List<String>.from(json['parentIds'] ?? []),
//       stats: PetStats.fromJson(json['stats']),
//       progression: PetProgression.fromJson(json['progression'] ?? {}),
//       createdAt: DateTime.parse(json['createdAt']),
//       petType: json['petType'] ?? 'default',
//       appearance: Map<String, dynamic>.from(json['appearance'] ?? {}),
//     );
//   }
// }

// // // pet_state.dart
// // enum PetActionResult {
// //   success,
// //   cooldown,
// //   insufficientEnergy,
// //   error,
// // }

// class PetActionResultData {
//   final PetActionResult result;
//   final String message;
//   final int? cooldownMinutes;

//   const PetActionResultData({
//     required this.result,
//     required this.message,
//     this.cooldownMinutes,
//   });
// }

// class PetState {
//   final List<Pet> userPets;
//   final Pet? favoritePet;
//   final bool isLoading;
//   final String? error;
//   final PetActionResultData? lastActionResult;

//   const PetState({
//     this.userPets = const [],
//     this.favoritePet,
//     this.isLoading = true,
//     this.error,
//     this.lastActionResult,
//   });

//   PetState copyWith({
//     List<Pet>? userPets,
//     Pet? favoritePet,
//     bool? isLoading,
//     String? error,
//     PetActionResultData? lastActionResult,
//   }) {
//     return PetState(
//       userPets: userPets ?? this.userPets,
//       favoritePet: favoritePet ?? this.favoritePet,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       lastActionResult: lastActionResult,
//     );
//   }
// }

// // pet_stats.dart
// class PetStats {
//   final int hunger;
//   final int happiness;
//   final int cleanliness;
//   final int energy;
//   final DateTime lastUpdate;
//   final Map<String, DateTime> lastActionTimes;

//   const PetStats({
//     this.hunger = 50,
//     this.happiness = 50,
//     this.cleanliness = 50,
//     this.energy = 50,
//     required this.lastUpdate,
//     this.lastActionTimes = const {},
//   });

//   // Configurações de degradação por hora
//   static const Map<String, int> _decayRates = {
//     'hunger': 3, // Fome aumenta 3 pontos por hora
//     'happiness': 2, // Felicidade diminui 2 pontos por hora
//     'cleanliness': 4, // Limpeza diminui 4 pontos por hora
//     'energy': 5, // Energia diminui 5 pontos por hora
//   };

//   // Calcula degradação baseada no tempo passado
//   PetStats calculateTimeDecay() {
//     final now = DateTime.now();
//     final hoursSinceUpdate = now.difference(lastUpdate).inHours.toDouble();

//     if (hoursSinceUpdate < 0.1) return this; // Menos de 6 minutos, não degrada

//     // Aplicar degradação baseada no tempo
//     final newHunger = (hunger - (hoursSinceUpdate * _decayRates['hunger']!))
//         .clamp(0, 100)
//         .toInt();
//     final newHappiness =
//         (happiness - (hoursSinceUpdate * _decayRates['happiness']!))
//             .clamp(0, 100)
//             .toInt();
//     final newCleanliness =
//         (cleanliness - (hoursSinceUpdate * _decayRates['cleanliness']!))
//             .clamp(0, 100)
//             .toInt();
//     final newEnergy = (energy - (hoursSinceUpdate * _decayRates['energy']!))
//         .clamp(0, 100)
//         .toInt();

//     return copyWith(
//       hunger: newHunger,
//       happiness: newHappiness,
//       cleanliness: newCleanliness,
//       energy: newEnergy,
//       lastUpdate: now,
//     );
//   }

//   PetStats copyWith({
//     int? hunger,
//     int? happiness,
//     int? cleanliness,
//     int? energy,
//     DateTime? lastUpdate,
//     Map<String, DateTime>? lastActionTimes,
//   }) {
//     return PetStats(
//       hunger: hunger ?? this.hunger,
//       happiness: happiness ?? this.happiness,
//       cleanliness: cleanliness ?? this.cleanliness,
//       energy: energy ?? this.energy,
//       lastUpdate: lastUpdate ?? this.lastUpdate,
//       lastActionTimes: lastActionTimes ?? this.lastActionTimes,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'hunger': hunger,
//       'happiness': happiness,
//       'cleanliness': cleanliness,
//       'energy': energy,
//       'lastUpdate': lastUpdate.toIso8601String(),
//       'lastActionTimes': lastActionTimes.map(
//         (key, value) => MapEntry(key, value.toIso8601String()),
//       ),
//     };
//   }

//   factory PetStats.fromJson(Map<String, dynamic> json) {
//     return PetStats(
//       hunger: json['hunger'] ?? 50,
//       happiness: json['happiness'] ?? 50,
//       cleanliness: json['cleanliness'] ?? 50,
//       energy: json['energy'] ?? 50,
//       lastUpdate: DateTime.parse(json['lastUpdate']),
//       lastActionTimes: (json['lastActionTimes'] as Map<String, dynamic>?)
//               ?.map((key, value) => MapEntry(key, DateTime.parse(value))) ??
//           {},
//     );
//   }
// }

// // pet_game_logic.dart
// class PetGameLogic {
//   // Constantes de gameplay
//   static const int FEED_RECOVERY = 25;
//   static const int PLAY_HAPPINESS = 20;
//   static const int PLAY_ENERGY_COST = 15;
//   static const int CLEAN_RECOVERY = 30;
//   static const int SLEEP_ENERGY_RECOVERY = 40;

//   // Cooldowns das ações (em minutos)
//   static const Map<String, int> actionCooldowns = {
//     'feed': 120, // 2 horas
//     'play': 30, // 30 minutos
//     'clean': 60, // 1 hora
//     'sleep': 480, // 8 horas
//   };

//   // Verifica se uma ação pode ser executada
//   bool canPerformAction(PetStats stats, String action) {
//     final lastActionTime = stats.lastActionTimes[action];
//     if (lastActionTime == null) return true;

//     final cooldownMinutes = actionCooldowns[action] ?? 0;
//     final timeSinceAction = DateTime.now().difference(lastActionTime).inMinutes;

//     return timeSinceAction >= cooldownMinutes;
//   }

//   // Tempo restante para próxima ação (em minutos)
//   int getCooldownRemaining(PetStats stats, String action) {
//     final lastActionTime = stats.lastActionTimes[action];
//     if (lastActionTime == null) return 0;

//     final cooldownMinutes = actionCooldowns[action] ?? 0;
//     final timeSinceAction = DateTime.now().difference(lastActionTime).inMinutes;

//     return (cooldownMinutes - timeSinceAction).clamp(0, cooldownMinutes);
//   }

//   // Executa ação de alimentar
//   PetStats feedPet(PetStats currentStats) {
//     if (!canPerformAction(currentStats, 'feed')) {
//       throw PetActionException(
//           'Pet ainda está digirindo! Aguarde ${getCooldownRemaining(currentStats, 'feed')} minutos.');
//     }

//     final now = DateTime.now();
//     final newActionTimes =
//         Map<String, DateTime>.from(currentStats.lastActionTimes);
//     newActionTimes['feed'] = now;

//     return currentStats.copyWith(
//       hunger: (currentStats.hunger + FEED_RECOVERY).clamp(0, 100),
//       happiness: (currentStats.happiness + 5)
//           .clamp(0, 100), // Pequeno boost de felicidade
//       lastUpdate: now,
//       lastActionTimes: newActionTimes,
//     );
//   }

//   // Executa ação de brincar
//   PetStats playWithPet(PetStats currentStats) {
//     if (!canPerformAction(currentStats, 'play')) {
//       throw PetActionException(
//           'Pet ainda está cansado! Aguarde ${getCooldownRemaining(currentStats, 'play')} minutos.');
//     }

//     if (currentStats.energy < PLAY_ENERGY_COST) {
//       throw const PetActionException(
//           'Pet está muito cansado para brincar! Deixe-o descansar.');
//     }

//     final now = DateTime.now();
//     final newActionTimes =
//         Map<String, DateTime>.from(currentStats.lastActionTimes);
//     newActionTimes['play'] = now;

//     return currentStats.copyWith(
//       happiness: (currentStats.happiness + PLAY_HAPPINESS).clamp(0, 100),
//       energy: (currentStats.energy - PLAY_ENERGY_COST).clamp(0, 100),
//       hunger: (currentStats.hunger - 5).clamp(0, 100), // Brincar dá fome
//       lastUpdate: now,
//       lastActionTimes: newActionTimes,
//     );
//   }

//   // Executa ação de limpar
//   PetStats cleanPet(PetStats currentStats) {
//     if (!canPerformAction(currentStats, 'clean')) {
//       throw PetActionException(
//           'Pet foi limpo recentemente! Aguarde ${getCooldownRemaining(currentStats, 'clean')} minutos.');
//     }

//     final now = DateTime.now();
//     final newActionTimes =
//         Map<String, DateTime>.from(currentStats.lastActionTimes);
//     newActionTimes['clean'] = now;

//     return currentStats.copyWith(
//       cleanliness: (currentStats.cleanliness + CLEAN_RECOVERY).clamp(0, 100),
//       happiness:
//           (currentStats.happiness + 10).clamp(0, 100), // Pet fica feliz limpo
//       lastUpdate: now,
//       lastActionTimes: newActionTimes,
//     );
//   }

//   // Nova ação: Dormir
//   PetStats sleepPet(PetStats currentStats) {
//     if (!canPerformAction(currentStats, 'sleep')) {
//       throw PetActionException(
//           'Pet dormiu recentemente! Aguarde ${getCooldownRemaining(currentStats, 'sleep')} minutos.');
//     }

//     final now = DateTime.now();
//     final newActionTimes =
//         Map<String, DateTime>.from(currentStats.lastActionTimes);
//     newActionTimes['sleep'] = now;

//     return currentStats.copyWith(
//       energy: (currentStats.energy + SLEEP_ENERGY_RECOVERY).clamp(0, 100),
//       happiness: (currentStats.happiness + 5).clamp(0, 100),
//       lastUpdate: now,
//       lastActionTimes: newActionTimes,
//     );
//   }

//   // Determina o humor do pet baseado nos status
//   String getPetMood(PetStats stats) {
//     final avgStatus =
//         (stats.hunger + stats.happiness + stats.cleanliness + stats.energy) / 4;

//     // Casos especiais primeiro
//     if (stats.hunger < 20) return "Faminto 😣";
//     if (stats.cleanliness < 20) return "Sujo 🤢";
//     if (stats.energy < 15) return "Exausto 😴";

//     // Status geral
//     if (avgStatus >= 80) return "Extasiado 🤩";
//     if (avgStatus >= 60) return "Feliz 😊";
//     if (avgStatus >= 40) return "Normal 😐";
//     if (avgStatus >= 20) return "Triste 😞";

//     return "Muito mal 😰";
//   }

//   // Determina o status geral do pet
//   String getPetStatus(PetStats stats) {
//     final criticalStats = [
//       if (stats.hunger < 30) "Com fome",
//       if (stats.happiness < 30) "Triste",
//       if (stats.cleanliness < 30) "Sujo",
//       if (stats.energy < 30) "Cansado",
//     ];

//     if (criticalStats.isEmpty) {
//       final avgStatus =
//           (stats.hunger + stats.happiness + stats.cleanliness + stats.energy) /
//               4;
//       if (avgStatus >= 80) return "Perfeito";
//       if (avgStatus >= 60) return "Muito bem";
//       return "Bem";
//     }

//     if (criticalStats.length == 1) {
//       return criticalStats.first;
//     }

//     return "Precisa de cuidados";
//   }
// }

// // pet_action_exception.dart
// class PetActionException implements Exception {
//   final String message;

//   const PetActionException(this.message);

//   @override
//   String toString() => message;
// }

// // pet_progression.dart
// class PetProgression {
//   final int level;
//   final int experience;
//   final int experienceToNext;
//   final Map<String, int> actionCounts;
//   final List<String> unlockedFeatures;

//   const PetProgression({
//     this.level = 1,
//     this.experience = 0,
//     this.experienceToNext = 100,
//     this.actionCounts = const {},
//     this.unlockedFeatures = const [],
//   });

//   static const Map<String, int> actionExperience = {
//     'feed': 10,
//     'play': 15,
//     'clean': 12,
//     'sleep': 8,
//   };

//   // Adiciona experiência por ação
//   PetProgression addExperience(String action) {
//     final expGain = actionExperience[action] ?? 5;
//     final newExp = experience + expGain;
//     final newActionCounts = Map<String, int>.from(actionCounts);
//     newActionCounts[action] = (newActionCounts[action] ?? 0) + 1;

//     // Verificar level up
//     if (newExp >= experienceToNext) {
//       return PetProgression(
//         level: level + 1,
//         experience: newExp - experienceToNext,
//         experienceToNext: _calculateExpForLevel(level + 1),
//         actionCounts: newActionCounts,
//         unlockedFeatures: _getUnlockedFeatures(level + 1),
//       );
//     }

//     return PetProgression(
//       level: level,
//       experience: newExp,
//       experienceToNext: experienceToNext,
//       actionCounts: newActionCounts,
//       unlockedFeatures: unlockedFeatures,
//     );
//   }

//   int _calculateExpForLevel(int level) {
//     return 100 + (level * 25); // Progressão linear com incremento
//   }

//   List<String> _getUnlockedFeatures(int level) {
//     final features = <String>[];

//     if (level >= 2) features.add('sleep_action');
//     if (level >= 3) features.add('pet_accessories');
//     if (level >= 5) features.add('mini_games');
//     if (level >= 7) features.add('pet_house_decoration');
//     if (level >= 10) features.add('pet_evolution');

//     return features;
//   }

//   PetProgression copyWith({
//     int? level,
//     int? experience,
//     int? experienceToNext,
//     Map<String, int>? actionCounts,
//     List<String>? unlockedFeatures,
//   }) {
//     return PetProgression(
//       level: level ?? this.level,
//       experience: experience ?? this.experience,
//       experienceToNext: experienceToNext ?? this.experienceToNext,
//       actionCounts: actionCounts ?? this.actionCounts,
//       unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'level': level,
//       'experience': experience,
//       'experienceToNext': experienceToNext,
//       'actionCounts': actionCounts,
//       'unlockedFeatures': unlockedFeatures,
//     };
//   }

//   factory PetProgression.fromJson(Map<String, dynamic> json) {
//     return PetProgression(
//       level: json['level'] ?? 1,
//       experience: json['experience'] ?? 0,
//       experienceToNext: json['experienceToNext'] ?? 100,
//       actionCounts: Map<String, int>.from(json['actionCounts'] ?? {}),
//       unlockedFeatures: List<String>.from(json['unlockedFeatures'] ?? []),
//     );
//   }
// }


// class AnimatedStatusBar extends StatefulWidget {
//   final int value;
//   final int maxValue;
//   final Color color;
//   final IconData icon;
//   final String label;
//   final Duration animationDuration;

//   const AnimatedStatusBar({
//     super.key,
//     required this.value,
//     this.maxValue = 100,
//     required this.color,
//     required this.icon,
//     required this.label,
//     this.animationDuration = const Duration(milliseconds: 800),
//   });

//   @override
//   State<AnimatedStatusBar> createState() => _AnimatedStatusBarState();
// }

// class _AnimatedStatusBarState extends State<AnimatedStatusBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   int _previousValue = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: widget.animationDuration,
//       vsync: this,
//     );
//     _animation = Tween<double>(
//       begin: 0.0,
//       end: widget.value / widget.maxValue,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//     _previousValue = widget.value;
//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(AnimatedStatusBar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.value != widget.value) {
//       _animation = Tween<double>(
//         begin: _previousValue / widget.maxValue,
//         end: widget.value / widget.maxValue,
//       ).animate(CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ));
//       _previousValue = widget.value;
//       _controller.reset();
//       _controller.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Color get _statusColor {
//     final percentage = widget.value / widget.maxValue;
//     if (percentage < 0.3) return Colors.red;
//     if (percentage < 0.7) return Colors.orange;
//     return Colors.green;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return Icon(
//               widget.icon,
//               color: _statusColor,
//               size: 32,
//             );
//           },
//         ),
//         const SizedBox(height: 8),
//         Container(
//           width: 80,
//           height: 12,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(6),
//             color: Colors.grey[300],
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 2,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return LinearProgressIndicator(
//                 value: _animation.value,
//                 backgroundColor: Colors.transparent,
//                 valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
//                 borderRadius: BorderRadius.circular(6),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 4),
//         AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             final displayValue = (_animation.value * widget.maxValue).round();
//             return Text(
//               '$displayValue%',
//               style: TextStyle(
//                 color: _statusColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             );
//           },
//         ),
//         Text(
//           widget.label,
//           style: const TextStyle(
//             fontSize: 10,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // animated_action_button.dart
// class AnimatedActionButton extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback? onPressed;
//   final bool isEnabled;
//   final int? cooldownMinutes;
//   final Color color;

//   const AnimatedActionButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     this.onPressed,
//     this.isEnabled = true,
//     this.cooldownMinutes,
//     this.color = Colors.blue,
//   });

//   @override
//   State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
// }

// class _AnimatedActionButtonState extends State<AnimatedActionButton>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _pulseController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeInOut,
//     ));

//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     if (widget.isEnabled && widget.cooldownMinutes == null) {
//       _pulseController.repeat(reverse: true);
//     }
//   }

//   @override
//   void didUpdateWidget(AnimatedActionButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isEnabled && widget.cooldownMinutes == null) {
//       _pulseController.repeat(reverse: true);
//     } else {
//       _pulseController.stop();
//     }
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   void _handleTap() {
//     if (!widget.isEnabled || widget.cooldownMinutes != null) return;

//     _scaleController.forward().then((_) {
//       _scaleController.reverse();
//     });

//     widget.onPressed?.call();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDisabled = !widget.isEnabled || widget.cooldownMinutes != null;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value * (isDisabled ? 1.0 : _pulseAnimation.value),
//           child: GestureDetector(
//             onTap: _handleTap,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: isDisabled
//                     ? Colors.grey[300]
//                     : widget.color.withOpacity(0.1),
//                 border: Border.all(
//                   color: isDisabled ? Colors.grey : widget.color,
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: isDisabled
//                     ? []
//                     : [
//                         BoxShadow(
//                           color: widget.color.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     widget.icon,
//                     color: isDisabled ? Colors.grey : widget.color,
//                     size: 28,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.label,
//                     style: TextStyle(
//                       color: isDisabled ? Colors.grey : widget.color,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (widget.cooldownMinutes != null)
//                     Text(
//                       '${widget.cooldownMinutes}min',
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 8,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // // pet_action_buttons_improved.dart
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // class PetActionButtonsImproved extends ConsumerWidget {
// //   final Pet pet;

// //   const PetActionButtonsImproved({
// //     super.key,
// //     required this.pet,
// //   });

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final petController = ref.read(petControllerProvider.notifier);
// //     final lastActionResult = ref.watch(lastActionResultProvider);

// //     // Limpar resultado após mostrar
// //     if (lastActionResult != null) {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _showActionResultDialog(context, lastActionResult);
// //         petController.clearLastActionResult();
// //       });
// //     }

// //     return Column(
// //       children: [
// //         // Primeira linha de ações
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           children: [
// //             AnimatedActionButton(
// //               icon: Icons.restaurant,
// //               label: 'Alimentar',
// //               color: Colors.orange,
// //               isEnabled: petController.canPerformAction(pet.id, 'feed'),
// //               cooldownMinutes: petController.canPerformAction(pet.id, 'feed')
// //                   ? null
// //                   : petController.getCooldownRemaining(pet.id, 'feed'),
// //               onPressed: () => petController.feedPet(pet.id),
// //             ),
// //             AnimatedActionButton(
// //               icon: Icons.sports_soccer,
// //               label: 'Brincar',
// //               color: Colors.green,
// //               isEnabled: petController.canPerformAction(pet.id, 'play') &&
// //                   pet.energy >= 15,
// //               cooldownMinutes: petController.canPerformAction(pet.id, 'play')
// //                   ? null
// //                   : petController.getCooldownRemaining(pet.id, 'play'),
// //               onPressed: () => petController.playWithPet(pet.id),
// //             ),
// //             AnimatedActionButton(
// //               icon: Icons.clean_hands,
// //               label: 'Limpar',
// //               color: Colors.blue,
// //               isEnabled: petController.canPerformAction(pet.id, 'clean'),
// //               cooldownMinutes: petController.canPerformAction(pet.id, 'clean')
// //                   ? null
// //                   : petController.getCooldownRemaining(pet.id, 'clean'),
// //               onPressed: () => petController.cleanPet(pet.id),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 16),
// //         // Segunda linha - Ação de dormir (desbloqueada no nível 2)
// //         if (pet.progression.unlockedFeatures.contains('sleep_action'))
// //           AnimatedActionButton(
// //             icon: Icons.bedtime,
// //             label: 'Dormir',
// //             color: Colors.purple,
// //             isEnabled: petController.canPerformAction(pet.id, 'sleep'),
// //             cooldownMinutes: petController.canPerformAction(pet.id, 'sleep')
// //                 ? null
// //                 : petController.getCooldownRemaining(pet.id, 'sleep'),
// //             onPressed: () => petController.sleepPet(pet.id),
// //           ),
// //       ],
// //     );
// //   }

// //   void _showActionResultDialog(BuildContext context, PetActionResultData result) {
// //     final icon = _getResultIcon(result.result);
// //     final color = _getResultColor(result.result);

// //     showDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (context) => AlertDialog(
// //         icon: Icon(icon, color: color, size: 48),
// //         title: Text(
// //           _getResultTitle(result.result),
// //           textAlign: TextAlign.center,
// //         ),
// //         content: Text(
// //           result.message,
// //           textAlign: TextAlign.center,
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(),
// //             child: const Text('OK'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   IconData _getResultIcon(PetActionResult result) {
// //     switch (result) {
// //       case PetActionResult.success:
// //         return Icons.check_circle;
// //       case PetActionResult.cooldown:
// //         return Icons.timer;
// //       case PetActionResult.insufficientEnergy:
// //         return Icons.battery_alert;
// //       case PetActionResult.error:
// //         return Icons.error;
// //     }
// //   }

// //   Color _getResultColor(PetActionResult result) {
// //     switch (result) {
// //       case PetActionResult.success:
// //         return Colors.green;
// //       case PetActionResult.cooldown:
// //         return Colors.orange;
// //       case PetActionResult.insufficientEnergy:
// //         return Colors.red;
// //       case PetActionResult.error:
// //         return Colors.red;
// //     }
// //   }

// //   String _getResultTitle(PetActionResult result) {
// //     switch (result) {
// //       case PetActionResult.success:
// //         return 'Sucesso!';
// //       case PetActionResult.cooldown:
// //         return 'Aguarde um pouco';
// //       case PetActionResult.insufficientEnergy:
// //         return 'Pet cansado';
// //       case PetActionResult.error:
// //         return 'Erro';
// //     }
// //   }
// // }

// // // pet_care_page_improved.dart
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // class PetCarePageImproved extends ConsumerWidget {
// //   const PetCarePageImproved({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final favoritePet = ref.watch(favoritePetProvider);
// //     final otherPets = ref.watch(otherPetsProvider);
// //     final petController = ref.read(petControllerProvider.notifier);

// //     if (favoritePet == null) {
// //       return const Scaffold(
// //         body: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.pets, size: 64, color: Colors.grey),
// //               SizedBox(height: 16),
// //               Text(
// //                 'Nenhum pet encontrado',
// //                 style: TextStyle(fontSize: 18, color: Colors.grey),
// //               ),
// //               Text(
// //                 'Adote um pet para começar!',
// //                 style: TextStyle(color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(favoritePet.name),
// //             const SizedBox(width: 8),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue,
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Text(
// //                 'Nv.${favoritePet.progression.level}',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.info_outline),
// //             onPressed: () => _showPetInfo(context, favoritePet),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Área dos outros pets
// //           if (otherPets.isNotEmpty) ...[
// //             Container(
// //               height: 120,
// //               padding: const EdgeInsets.symmetric(vertical: 8),
// //               child: ListView.builder(
// //                 scrollDirection: Axis.horizontal,
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 itemCount: otherPets.length,
// //                 itemBuilder: (context, index) {
// //                   final pet = otherPets[index];
// //                   return Padding(
// //                     padding: const EdgeInsets.only(right: 12),
// //                     child: PetCardMini(
// //                       pet: pet,
// //                       onTap: () => petController.setFavoritePet(pet),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             const Divider(),
// //           ],

// //           // Conteúdo principal
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   // Status do pet com humor
// //                   _buildPetMoodSection(favoritePet),
// //                   const SizedBox(height: 24),

// //                   // Imagem do pet (placeholder animado)
// //                   _buildPetAvatar(favoritePet),
// //                   const SizedBox(height: 24),

// //                   // Barras de status
// //                   _buildStatusBars(favoritePet),
// //                   const SizedBox(height: 32),

// //                   // Barra de experiência
// //                   _buildExperienceBar(favoritePet),
// //                   const SizedBox(height: 32),

// //                   // Botões de ação
// //                   PetActionButtonsImproved(pet: favoritePet),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPetMoodSection(Pet pet) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [
// //             Colors.blue.withOpacity(0.1),
// //             Colors.purple.withOpacity(0.1),
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: Colors.blue.withOpacity(0.3)),
// //       ),
// //       child: Column(
// //         children: [
// //           Text(
// //             pet.mood,
// //             style: const TextStyle(
// //               fontSize: 24,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Status: ${pet.status}',
// //             style: TextStyle(
// //               fontSize: 16,
// //               color: Colors.grey[600],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPetAvatar(Pet pet) {
// //     return Container(
// //       width: 200,
// //       height: 200,
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         gradient: LinearGradient(
// //           colors: [
// //             Colors.blue.withOpacity(0.2),
// //             Colors.purple.withOpacity(0.2),
// //           ],
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.blue.withOpacity(0.3),
// //             blurRadius: 20,
// //             offset: const Offset(0, 10),
// //           ),
// //         ],
// //       ),
// //       child: const Icon(
// //         Icons.pets,
// //         size: 100,
// //         color: Colors.blue,
// //       ),
// //     );
// //   }

// //   Widget _buildStatusBars(Pet pet) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //       children: [
// //         AnimatedStatusBar(
// //           value: pet.hunger,
// //           icon: Icons.restaurant,
// //           label: 'Fome',
// //           color: Colors.orange,
// //         ),
// //         AnimatedStatusBar(
// //           value: pet.happiness,
// //           icon: Icons.sentiment_satisfied_alt,
// //           label: 'Felicidade',
// //           color: Colors.yellow,
// //         ),
// //         AnimatedStatusBar(
// //           value: pet.cleanliness,
// //           icon: Icons.clean_hands,
// //           label: 'Limpeza',
// //           color: Colors.blue,
// //         ),
// //         AnimatedStatusBar(
// //           value: pet.energy,
// //           icon: Icons.battery_charging_full,
// //           label: 'Energia',
// //           color: Colors.green,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildExperienceBar(Pet pet) {
// //     final progress = pet.progression.experience / pet.progression.experienceToNext;
    
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[100],
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Experiência',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.grey[700],
// //                 ),
// //               ),
// //               Text(
// //                 '${pet.progression.experience}/${pet.progression.experienceToNext}',
// //                 style: TextStyle(color: Colors.grey[600]),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           LinearProgressIndicator(
// //             value: progress,
// //             backgroundColor: Colors.grey[300],
// //             valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
// //             borderRadius: BorderRadius.circular(4),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showPetInfo(BuildContext context, Pet pet) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('${pet.name} - Informações'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _buildInfoRow('Nível', '${pet.progression.level}'),
// //             _buildInfoRow('Experiência', '${pet.progression.experience}/${pet.progression.experienceToNext}'),
// //             _buildInfoRow('Idade', '${DateTime.now().difference(pet.createdAt).inDays} dias'),
// //             const SizedBox(height: 16),
// //             const Text('Recursos Desbloqueados:', style: TextStyle(fontWeight: FontWeight.bold)),
// //             ...pet.progression.unlockedFeatures.map(
// //               (feature) => Text('• ${_getFeatureName(feature)}'),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(),
// //             child: const Text('Fechar'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(label),
// //           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
// //         ],
// //       ),
// //     );
// //   }

// //   String _getFeatureName(String feature) {
// //     switch (feature) {
// //       case 'sleep_action':
// //         return 'Ação de Dormir';
// //       case 'pet_accessories':
// //         return 'Acessórios';
// //       case 'mini_games':
// //         return 'Mini Jogos';
// //       case 'pet_house_decoration':
// //         return 'Decoração da Casa';
// //       case 'pet_evolution':
// //         return 'Evolução do Pet';
// //       default:
// //         return feature;
// //     }
// //   }
// // }


// // // pet_notification_service.dart
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:petverse/backup/pet_provider.dart';

// // enum NotificationPriority { low, medium, high, critical }

// // class PetNotification {
// //   final String id;
// //   final String petId;
// //   final String petName;
// //   final String title;
// //   final String message;
// //   final IconData icon;
// //   final Color color;
// //   final NotificationPriority priority;
// //   final DateTime createdAt;
// //   final String actionType; // 'feed', 'play', 'clean', etc.

// //   const PetNotification({
// //     required this.id,
// //     required this.petId,
// //     required this.petName,
// //     required this.title,
// //     required this.message,
// //     required this.icon,
// //     required this.color,
// //     required this.priority,
// //     required this.createdAt,
// //     required this.actionType,
// //   });
// // }

// // class PetNotificationService {
// //   final StreamController<PetNotification> _notificationController = 
// //       StreamController<PetNotification>.broadcast();

// //   Stream<PetNotification> get notifications => _notificationController.stream;

// //   // Verifica status do pet e gera notificações se necessário
// //   void checkPetStatus(Pet pet) {
// //     final notifications = <PetNotification>[];
// //     final now = DateTime.now();

// //     // Verificar fome crítica
// //     if (pet.hunger < 20) {
// //       notifications.add(PetNotification(
// //         id: '${pet.id}_hunger_${now.millisecondsSinceEpoch}',
// //         petId: pet.id,
// //         petName: pet.name,
// //         title: '${pet.name} está com muita fome!',
// //         message: 'Seu pet precisa ser alimentado urgentemente.',
// //         icon: Icons.restaurant,
// //         color: Colors.red,
// //         priority: NotificationPriority.critical,
// //         createdAt: now,
// //         actionType: 'feed',
// //       ));
// //     }

// //     // Verificar felicidade baixa
// //     if (pet.happiness < 25) {
// //       notifications.add(PetNotification(
// //         id: '${pet.id}_happiness_${now.millisecondsSinceEpoch}',
// //         petId: pet.id,
// //         petName: pet.name,
// //         title: '${pet.name} está triste',
// //         message: 'Que tal brincar um pouco com seu pet?',
// //         icon: Icons.sentiment_dissatisfied,
// //         color: Colors.orange,
// //         priority: NotificationPriority.high,
// //         createdAt: now,
// //         actionType: 'play',
// //       ));
// //     }

// //     // Verificar limpeza
// //     if (pet.cleanliness < 30) {
// //       notifications.add(PetNotification(
// //         id: '${pet.id}_clean_${now.millisecondsSinceEpoch}',
// //         petId: pet.id,
// //         petName: pet.name,
// //         title: '${pet.name} precisa de um banho',
// //         message: 'Seu pet está um pouco sujo.',
// //         icon: Icons.clean_hands,
// //         color: Colors.blue,
// //         priority: NotificationPriority.medium,
// //         createdAt: now,
// //         actionType: 'clean',
// //       ));
// //     }

// //     // Verificar energia baixa
// //     if (pet.energy < 20) {
// //       notifications.add(PetNotification(
// //         id: '${pet.id}_energy_${now.millisecondsSinceEpoch}',
// //         petId: pet.id,
// //         petName: pet.name,
// //         title: '${pet.name} está cansado',
// //         message: 'Deixe seu pet descansar um pouco.',
// //         icon: Icons.bedtime,
// //         color: Colors.purple,
// //         priority: NotificationPriority.medium,
// //         createdAt: now,
// //         actionType: 'sleep',
// //       ));
// //     }

// //     // Notificação de level up
// //     // (Esta seria chamada quando o pet sobe de nível)

// //     // Enviar todas as notificações
// //     for (final notification in notifications) {
// //       _notificationController.add(notification);
// //     }
// //   }

// //   void notifyLevelUp(Pet pet) {
// //     _notificationController.add(PetNotification(
// //       id: '${pet.id}_levelup_${DateTime.now().millisecondsSinceEpoch}',
// //       petId: pet.id,
// //       petName: pet.name,
// //       title: '🎉 ${pet.name} subiu de nível!',
// //       message: 'Agora está no nível ${pet.progression.level}! Novos recursos desbloqueados.',
// //       icon: Icons.star,
// //       color: Colors.amber,
// //       priority: NotificationPriority.high,
// //       createdAt: DateTime.now(),
// //       actionType: 'celebration',
// //     ));
// //   }

// //   void dispose() {
// //     _notificationController.close();
// //   }
// // }

// // // notification_overlay.dart
// // class NotificationOverlay extends StatefulWidget {
// //   final Widget child;

// //   const NotificationOverlay({super.key, required this.child});

// //   @override
// //   State<NotificationOverlay> createState() => _NotificationOverlayState();
// // }

// // class _NotificationOverlayState extends State<NotificationOverlay>
// //     with TickerProviderStateMixin {
// //   final List<PetNotification> _activeNotifications = [];
// //   late AnimationController _slideController;
// //   late Animation<Offset> _slideAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _slideController = AnimationController(
// //       duration: const Duration(milliseconds: 300),
// //       vsync: this,
// //     );
// //     _slideAnimation = Tween<Offset>(
// //       begin: const Offset(0, -1),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(
// //       parent: _slideController,
// //       curve: Curves.easeOut,
// //     ));
// //   }

// //   @override
// //   void dispose() {
// //     _slideController.dispose();
// //     super.dispose();
// //   }

// //   void _showNotification(PetNotification notification) {
// //     setState(() {
// //       _activeNotifications.add(notification);
// //     });
    
// //     _slideController.forward();

// //     // Auto-remover notificação após alguns segundos
// //     Timer(const Duration(seconds: 4), () {
// //       _removeNotification(notification.id);
// //     });
// //   }

// //   void _removeNotification(String notificationId) {
// //     setState(() {
// //       _activeNotifications.removeWhere((n) => n.id == notificationId);
// //     });
    
// //     if (_activeNotifications.isEmpty) {
// //       _slideController.reverse();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         widget.child,
// //         if (_activeNotifications.isNotEmpty)
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 10,
// //             left: 16,
// //             right: 16,
// //             child: SlideTransition(
// //               position: _slideAnimation,
// //               child: Column(
// //                 children: _activeNotifications
// //                     .take(3) // Máximo 3 notificações por vez
// //                     .map((notification) => _buildNotificationCard(notification))
// //                     .toList(),
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }

// //   Widget _buildNotificationCard(PetNotification notification) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: notification.color.withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 8,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: notification.color.withOpacity(0.1),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               notification.icon,
// //               color: notification.color,
// //               size: 20,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   notification.title,
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //                 Text(
// //                   notification.message,
// //                   style: TextStyle(
// //                     color: Colors.grey[600],
// //                     fontSize: 12,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.close, size: 16),
// //             onPressed: () => _removeNotification(notification.id),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // mini_game_feeding.dart
// // class FeedingMiniGame extends StatefulWidget {
// //   final Pet pet;
// //   final VoidCallback onSuccess;
// //   final VoidCallback onFail;

// //   const FeedingMiniGame({
// //     super.key,
// //     required this.pet,
// //     required this.onSuccess,
// //     required this.onFail,
// //   });

// //   @override
// //   State<FeedingMiniGame> createState() => _FeedingMiniGameState();
// // }

// // class _FeedingMiniGameState extends State<FeedingMiniGame>
// //     with TickerProviderStateMixin {
// //   late AnimationController _moveController;
// //   late AnimationController _scaleController;
// //   late Animation<double> _moveAnimation;
// //   late Animation<double> _scaleAnimation;
  
// //   bool _gameActive = true;
// //   int _score = 0;
// //   final int _targetScore = 5;
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _moveController = AnimationController(
// //       duration: const Duration(seconds: 2),
// //       vsync: this,
// //     );
// //     _scaleController = AnimationController(
// //       duration: const Duration(milliseconds: 200),
// //       vsync: this,
// //     );
    
// //     _moveAnimation = Tween<double>(
// //       begin: -1.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _moveController,
// //       curve: Curves.linear,
// //     ));
    
// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.2,
// //     ).animate(CurvedAnimation(
// //       parent: _scaleController,
// //       curve: Curves.elasticOut,
// //     ));
    
// //     _startGame();
// //   }

// //   void _startGame() {
// //     _moveController.repeat();
// //   }

// //   void _feedAttempt() {
// //     if (!_gameActive) return;
    
// //     // Verificar se a comida está na posição certa (centro da tela)
// //     final currentPosition = _moveAnimation.value;
// //     final accuracy = 1.0 - (currentPosition.abs());
    
// //     if (accuracy > 0.7) { // 70% de precisão necessária
// //       _score++;
// //       _scaleController.forward().then((_) => _scaleController.reverse());
      
// //       if (_score >= _targetScore) {
// //         _gameActive = false;
// //         _moveController.stop();
// //         widget.onSuccess();
// //       }
// //     } else {
// //       // Falhou, acabou o jogo
// //       _gameActive = false;
// //       _moveController.stop();
// //       widget.onFail();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _moveController.dispose();
// //     _scaleController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 300,
// //       padding: const EdgeInsets.all(20),
// //       child: Column(
// //         children: [
// //           Text(
// //             'Alimente ${widget.pet.name}!',
// //             style: const TextStyle(
// //               fontSize: 24,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           Text(
// //             'Toque quando a comida estiver no centro: $_score/$_targetScore',
// //             style: const TextStyle(fontSize: 16),
// //           ),
// //           const SizedBox(height: 40),
          
// //           // Área do jogo
// //           Expanded(
// //             child: Stack(
// //               children: [
// //                 // Pet no centro
// //                 Center(
// //                   child: ScaleTransition(
// //                     scale: _scaleAnimation,
// //                     child: Container(
// //                       width: 80,
// //                       height: 80,
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue.withOpacity(0.2),
// //                         shape: BoxShape.circle,
// //                         border: Border.all(color: Colors.blue, width: 2),
// //                       ),
// //                       child: const Icon(
// //                         Icons.pets,
// //                         size: 40,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
                
// //                 // Comida se movendo
// //                 AnimatedBuilder(
// //                   animation: _moveAnimation,
// //                   builder: (context, child) {
// //                     return Positioned(
// //                       left: (MediaQuery.of(context).size.width - 100) * 
// //                              ((_moveAnimation.value + 1) / 2),
// //                       top: 60,
// //                       child: GestureDetector(
// //                         onTap: _feedAttempt,
// //                         child: Container(
// //                           width: 40,
// //                           height: 40,
// //                           decoration: const BoxDecoration(
// //                             color: Colors.orange,
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: const Icon(
// //                             Icons.restaurant,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
                
// //                 // Zona de acerto
// //                 Center(
// //                   child: Container(
// //                     width: 120,
// //                     height: 120,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       border: Border.all(
// //                         color: Colors.green.withOpacity(0.5),
// //                         width: 2,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
          
// //           const Text(
// //             'Toque na comida quando ela estiver na zona verde!',
// //             style: TextStyle(fontSize: 12, color: Colors.grey),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // mini_game_cleaning.dart
// // class CleaningMiniGame extends StatefulWidget {
// //   final Pet pet;
// //   final VoidCallback onSuccess;
// //   final VoidCallback onFail;

// //   const CleaningMiniGame({
// //     super.key,
// //     required this.pet,
// //     required this.onSuccess,
// //     required this.onFail,
// //   });

// //   @override
// //   State<CleaningMiniGame> createState() => _CleaningMiniGameState();
// // }

// // class _CleaningMiniGameState extends State<CleaningMiniGame> {
// //   final List<Offset> _dirtSpots = [];
// //   final List<Offset> _cleanedSpots = [];
// //   bool _gameActive = true;
// //   Timer? _gameTimer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _generateDirtSpots();
// //     _startTimer();
// //   }

// //   void _generateDirtSpots() {
// //     final random = DateTime.now().millisecondsSinceEpoch;
// //     for (int i = 0; i < 8; i++) {
// //       _dirtSpots.add(Offset(
// //         (random % 200 + i * 30).toDouble(),
// //         (random % 150 + i * 20).toDouble(),
// //       ));
// //     }
// //   }

// //   void _startTimer() {
// //     _gameTimer = Timer(const Duration(seconds: 15), () {
// //       if (_gameActive) {
// //         _gameActive = false;
// //         widget.onFail();
// //       }
// //     });
// //   }

// //   void _cleanSpot(Offset spot) {
// //     if (!_gameActive) return;
    
// //     setState(() {
// //       _cleanedSpots.add(spot);
// //     });

// //     if (_cleanedSpots.length >= _dirtSpots.length) {
// //       _gameActive = false;
// //       _gameTimer?.cancel();
// //       widget.onSuccess();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _gameTimer?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 300,
// //       padding: const EdgeInsets.all(20),
// //       child: Column(
// //         children: [
// //           Text(
// //             'Limpe ${widget.pet.name}!',
// //             style: const TextStyle(
// //               fontSize: 24,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           Text(
// //             'Toque nas manchas para limpar: ${_cleanedSpots.length}/${_dirtSpots.length}',
// //             style: const TextStyle(fontSize: 16),
// //           ),
// //           const SizedBox(height: 20),
          
// //           Expanded(
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.blue.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.blue.withOpacity(0.3)),
// //               ),
// //               child: Stack(
// //                 children: [
// //                   // Pet no centro
// //                   const Center(
// //                     child: Icon(
// //                       Icons.pets,
// //                       size: 60,
// //                       color: Colors.blue,
// //                     ),
// //                   ),
                  
// //                   // Manchas de sujeira
// //                   ..._dirtSpots.map((spot) {
// //                     final isClean = _cleanedSpots.contains(spot);
// //                     return Positioned(
// //                       left: spot.dx,
// //                       top: spot.dy,
// //                       child: GestureDetector(
// //                         onTap: () => _cleanSpot(spot),
// //                         child: Container(
// //                           width: 20,
// //                           height: 20,
// //                           decoration: BoxDecoration(
// //                             color: isClean ? Colors.transparent : Colors.brown,
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: isClean
// //                               ? const Icon(Icons.check, 
// //                                   color: Colors.green, size: 16)
// //                               : null,
// //                         ),
// //                       ),
// //                     );
// //                   }),
// //                 ],
// //               ),
// //             ),
// //           ),
          
// //           const Text(
// //             'Toque nas manchas marrons para limpá-las!',
// //             style: TextStyle(fontSize: 12, color: Colors.grey),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // mini_game_dialog.dart
// // class MiniGameDialog extends StatelessWidget {
// //   final Pet pet;
// //   final String gameType;
// //   final VoidCallback onSuccess;
// //   final VoidCallback onCancel;

// //   const MiniGameDialog({
// //     super.key,
// //     required this.pet,
// //     required this.gameType,
// //     required this.onSuccess,
// //     required this.onCancel,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Dialog(
// //       backgroundColor: Colors.transparent,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             // Header
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Colors.blue, Colors.purple],
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                 ),
// //                 borderRadius: BorderRadius.only(
// //                   topLeft: Radius.circular(20),
// //                   topRight: Radius.circular(20),
// //                 ),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(Icons.games, color: Colors.white),
// //                   const SizedBox(width: 8),
// //                   Text(
// //                     'Mini Jogo - ${_getGameTitle(gameType)}',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   IconButton(
// //                     icon: const Icon(Icons.close, color: Colors.white),
// //                     onPressed: onCancel,
// //                   ),
// //                 ],
// //               ),
// //             ),
            
// //             // Game content
// //             _buildGameContent(),
            
// //             // Footer
// //             Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   TextButton(
// //                     onPressed: onCancel,
// //                     child: const Text('Cancelar'),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildGameContent() {
// //     switch (gameType) {
// //       case 'feed':
// //         return FeedingMiniGame(
// //           pet: pet,
// //           onSuccess: onSuccess,
// //           onFail: onCancel,
// //         );
// //       case 'clean':
// //         return CleaningMiniGame(
// //           pet: pet,
// //           onSuccess: onSuccess,
// //           onFail: onCancel,
// //         );
// //       default:
// //         return const SizedBox(
// //           height: 200,
// //           child: Center(
// //             child: Text('Mini jogo não implementado'),
// //           ),
// //         );
// //     }
// //   }

// //   String _getGameTitle(String gameType) {
// //     switch (gameType) {
// //       case 'feed':
// //         return 'Alimentação';
// //       case 'clean':
// //         return 'Limpeza';
// //       case 'play':
// //         return 'Brincadeira';
// //       default:
// //         return 'Desconhecido';
// //     }
// //   }
// // }

// // // pet_controller_with_minigames.dart (adição ao controller existente)
// // extension PetControllerMiniGames on PetController {
  
// //   // Método para iniciar mini-game antes da ação
// //   Future<void> performActionWithMiniGame(
// //     BuildContext context,
// //     String petId,
// //     String actionType,
// //   ) async {
// //     final pet = state.userPets.firstWhere((p) => p.id == petId);
    
// //     // Verificar se mini-games estão desbloqueados
// //     if (!pet.progression.unlockedFeatures.contains('mini_games')) {
// //       // Executar ação normal
// //       switch (actionType) {
// //         case 'feed':
// //           await feedPet(petId);
// //           break;
// //         case 'play':
// //           await playWithPet(petId);
// //           break;
// //         case 'clean':
// //           await cleanPet(petId);
// //           break;
// //       }
// //       return;
// //     }

// //     // Mostrar mini-game
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => MiniGameDialog(
// //         pet: pet,
// //         gameType: actionType,
// //         onSuccess: () {
// //           Navigator.of(context).pop();
// //           // Bonus por completar mini-game
// //           _performActionWithBonus(petId, actionType);
// //         },
// //         onCancel: () {
// //           Navigator.of(context).pop();
// //           // Ação normal sem bonus
// //           _performActionNormal(petId, actionType);
// //         },
// //       ),
// //     );
// //   }

// //   Future<void> _performActionWithBonus(String petId, String actionType) async {
// //     // Implementar bonus para mini-game completado
// //     // Por exemplo, 50% mais eficácia
// //     final pet = state.userPets.firstWhere((p) => p.id == petId);
// //     final currentStats = pet.stats;
    
// //     PetStats bonusStats;
// //     switch (actionType) {
// //       case 'feed':
// //         bonusStats = currentStats.copyWith(
// //           hunger: (currentStats.hunger + 35).clamp(0, 100), // 25 + 10 bonus
// //           happiness: (currentStats.happiness + 8).clamp(0, 100), // 5 + 3 bonus
// //         );
// //         break;
// //       case 'clean':
// //         bonusStats = currentStats.copyWith(
// //           cleanliness: (currentStats.cleanliness + 40).clamp(0, 100), // 30 + 10 bonus
// //           happiness: (currentStats.happiness + 15).clamp(0, 100), // 10 + 5 bonus
// //         );
// //         break;
// //       default:
// //         return _performActionNormal(petId, actionType);
// //     }

// //     final updatedPet = pet.copyWith(
// //       stats: bonusStats,
// //       progression: pet.progression.addExperience(actionType),
// //     );

// //     _updatePetInState(updatedPet);
// //     await _petService.updatePet(updatedPet);
    
// //     state = state.copyWith(
// //       lastActionResult: PetActionResultData(
// //         result: PetActionResult.success,
// //         message: '🎉 ${_getSuccessMessage(actionType)} (Bônus do mini-jogo!)',
// //       ),
// //     );
// //   }

// //   Future<void> _performActionNormal(String petId, String actionType) async {
// //     switch (actionType) {
// //       case 'feed':
// //         await feedPet(petId);
// //         break;
// //       case 'play':
// //         await playWithPet(petId);
// //         break;
// //       case 'clean':
// //         await cleanPet(petId);
// //         break;
// //     }
// //   }
// // }