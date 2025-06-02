// lib/features/pet_care/screens/pet_care_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/features/settings/providers/day_night_cycle_provider.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/active_pet.dart';
import 'package:petverse/shared/models/shop_item.dart';
import 'package:petverse/shared/providers/app_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/currency_display.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

// lib/features/pet_care/screens/pet_care_screen.dart
class PetCareScreen extends ConsumerWidget {
  const PetCareScreen({super.key});

  Widget _buildStatBar(BuildContext context, int value, String label,
      Color color, IconData icon) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: $value%',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5)),
      ])),
    ]);
  }

  Widget _buildXpBar(BuildContext context, int level, int xp, int xpForNext) {
    return Row(children: [
      const Icon(Icons.military_tech, color: AppColors.xpColor, size: 20),
      const SizedBox(width: 8),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nível $level',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
            value: xpForNext > 0 ? xp / xpForNext : 1.0,
            backgroundColor: AppColors.xpColor.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5)),
        Align(
            alignment: Alignment.centerRight,
            child: Text("$xp / $xpForNext XP",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface))),
      ])),
    ]);
  }

  void _showItemSelectionDialog(BuildContext context, WidgetRef ref,
      ItemCategory category, String title, Function(ShopItem) onItemSelected) {
    final user = ref.read(userProvider);
    final allShopItems =
        GameData.getShopItems(ref.read(eventManagerProvider).getActiveEvent());
    final itemsToShow = allShopItems
        .where((item) =>
            item.category == category && user.getItemQuantity(item.id) > 0)
        .toList();

    if (itemsToShow.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Você não tem itens de ${category.name.toLowerCase()} no inventário."),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: itemsToShow.length,
              itemBuilder: (BuildContext context, int index) {
                final item = itemsToShow[index];
                final quantity = user.getItemQuantity(item.id);
                return ListTile(
                  leading:
                      Text(item.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(item.name),
                  subtitle: Text("(Qtd: $quantity)"),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    onItemSelected(item);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop()),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ActivePet?>(activePetProvider, (previous, next) {
      if (previous != null &&
          next != null &&
          next.stats.level > previous.stats.level) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("🎉 Nível Acima! 🎉"),
                  content: Text(
                      "${next.definition.name} alcançou o Nível ${next.stats.level}!\n\nVocê ganhou 🪙 ${50 * next.stats.level} moedas e 💎 5 gemas!\nSua UXP aumentou em ${25 * next.stats.level}!"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Oba!"))
                  ],
                ));
      }
    });

    final activePet = ref.watch(activePetProvider);
    final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;

    if (activePet == null || firebaseUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userProfile = ref.watch(userProvider);
    final pet = activePet.definition;
    final stats = activePet.stats;
    ShopItem? equippedShopItem;
    final allShopItems =
        GameData.getShopItems(ref.read(eventManagerProvider).getActiveEvent());
    ShopItem? activeWallpaper;
    if (userProfile.activeWallpaperId != null) {
      try {
        activeWallpaper = allShopItems.firstWhere((item) =>
            item.id == userProfile.activeWallpaperId &&
            item.category == ItemCategory.environment);
      } catch (e) {/* não encontrado */}
    }
    ShopItem? activeFloor;
    if (userProfile.activeFloorId != null) {
      try {
        activeFloor = allShopItems.firstWhere((item) =>
            item.id == userProfile.activeFloorId &&
            item.category == ItemCategory.environment);
      } catch (e) {/* não encontrado */}
    }
    if (userProfile.equippedItemId != null) {
      try {
        equippedShopItem = allShopItems
            .firstWhere((item) => item.id == userProfile.equippedItemId);
      } catch (e) {/* Item não encontrado */}
    }

    final List<ShopItem> inventoryToys = [];
    for (String id in userProfile.itemQuantities.keys) {
      if ((userProfile.itemQuantities[id] ?? 0) > 0) {
        try {
          final item = allShopItems.firstWhere((shopItem) => shopItem.id == id);
          if (item.category == ItemCategory.toy) {
            inventoryToys.add(item);
          }
        } catch (e) {/* Ignora */}
      }
    }

    String petAppBarEmoji = pet.emoji;
    List<Effect<dynamic>> petAnimations = [];

    if (stats.isVeryHappy) {
      petAppBarEmoji = "🥳";
      petAnimations = [
        ScaleEffect(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 800.ms,
            curve: Curves.easeInOutBack),
        ShakeEffect(hz: 3, duration: 500.ms, curve: Curves.easeInOut),
        ShimmerEffect(
            delay: 300.ms,
            duration: 1000.ms,
            color: Colors.yellow.withOpacity(0.5)),
      ];
    } else if (stats.isInBadMood) {
      petAppBarEmoji = "😠";
      petAnimations = [
        ScaleEffect(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.9, 0.9),
            duration: 1500.ms,
            curve: Curves.elasticIn),
        ShakeEffect(
            hz: 1,
            duration: 1000.ms,
            rotation: 0.05,
            curve: Curves.easeInOutCubic),
      ];
    } else if (stats.isVeryHungry) {
      petAppBarEmoji = "🥺";
      petAnimations = [
        ScaleEffect(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: 1000.ms,
            curve: Curves.elasticOut),
        ShakeEffect(
            hz: 0.5,
            duration: 1500.ms,
            curve: Curves.linear,
            offset: const Offset(0, 2)),
      ];
    } else if (stats.isSad) {
      petAppBarEmoji = "😟";
      petAnimations = [
        ScaleEffect(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.98, 0.98),
            duration: 2000.ms,
            curve: Curves.easeIn),
        FadeEffect(end: 0.6, duration: 1500.ms, curve: Curves.easeInOut),
      ];
    } else {
      petAppBarEmoji = "😊";
      petAnimations = [
        ScaleEffect(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 1200.ms,
            curve: Curves.easeInOutSine),
        ShakeEffect(hz: 2, duration: 300.ms, curve: Curves.easeInOutCubic),
      ];
    }

    final theme = Theme.of(context);
    final petDisplayCircleBg = theme.brightness == Brightness.dark
        ? AppColors.petDisplayCircleBgDark
        : AppColors.petDisplayCircleBgLight;

    // Lógica para Ciclo Dia/Noite
    final dayNightCycleEnabled =
        ref.watch(dayNightCycleProvider); // NOVO: Lê a preferência
    BoxDecoration backgroundDecoration;

    if (dayNightCycleEnabled) {
      final currentTime = DateTime.now();
      final currentHour = currentTime.hour;
      Color? overlayColor;

      if (activeWallpaper?.assetPath != null) {
        if (currentHour >= 5 && currentHour < 8) {
          overlayColor = AppColors.morningOverlay;
        } else if (currentHour >= 8 && currentHour < 17) {
          overlayColor = AppColors.afternoonOverlay;
        } else if (currentHour >= 17 && currentHour < 20) {
          overlayColor = AppColors.eveningOverlay;
        } else {
          overlayColor = AppColors.nightOverlay;
        }
        backgroundDecoration = BoxDecoration(
          color: activeFloor?.itemColor,
          image: DecorationImage(
              image: AssetImage(activeWallpaper!.assetPath!),
              fit: BoxFit.cover,
              colorFilter: overlayColor != null
                  ? ColorFilter.mode(overlayColor, BlendMode.multiply)
                  : null,
              onError: (e, s) =>
                  debugPrint("Erro ao carregar papel de parede: $e")),
        );
      } else {
        Gradient currentGradient;
        if (currentHour >= 5 && currentHour < 12) {
          currentGradient = AppColors.morningSkyGradient;
        } else if (currentHour >= 12 && currentHour < 18) {
          currentGradient = AppColors.afternoonSkyGradient;
        } else if (currentHour >= 18 && currentHour < 21) {
          currentGradient = AppColors.eveningSkyGradient;
        } else {
          currentGradient = AppColors.nightSkyGradient;
        }
        backgroundDecoration = BoxDecoration(
            gradient: currentGradient, color: activeFloor?.itemColor);
      }
    } else {
      // Ciclo desligado: usa um fundo padrão (ex: céu da tarde) ou o wallpaper/piso sem overlay de tempo
      if (activeWallpaper?.assetPath != null) {
        backgroundDecoration = BoxDecoration(
          color: activeFloor?.itemColor,
          image: DecorationImage(
              image: AssetImage(activeWallpaper!.assetPath!),
              fit: BoxFit.cover,
              onError: (e, s) =>
                  debugPrint("Erro ao carregar papel de parede: $e")),
        );
      } else {
        backgroundDecoration = BoxDecoration(
            gradient: AppColors.afternoonSkyGradient,
            color: activeFloor?.itemColor);
      }
    }

    return Scaffold(
      appBar: StyledAppBar(
        title: 'Cuidando de ${pet.name} $petAppBarEmoji',
        actions: [
          GestureDetector(
            onTap: () => context.go('/main/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 6, bottom: 6),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                backgroundImage: firebaseUser.photoURL != null &&
                        firebaseUser.photoURL!.isNotEmpty
                    ? NetworkImage(firebaseUser.photoURL!)
                    : null,
                child: firebaseUser.photoURL == null ||
                        firebaseUser.photoURL!.isEmpty
                    ? Icon(Icons.person,
                        size: 20,
                        color:
                            theme.appBarTheme.foregroundColor ?? Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CurrencyDisplay(),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildStatBar(context, stats.happiness, "Felicidade",
                    AppColors.happinessColor, Icons.sentiment_satisfied_alt)),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                child: _buildStatBar(context, 100 - stats.hunger, "Saciado",
                    AppColors.hungerColor, Icons.restaurant)),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                child: _buildXpBar(
                    context, stats.level, stats.xp, stats.xpForNextLevel)),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: petDisplayCircleBg,
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.8), width: 4),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2)
                ],
              ),
              child: Center(
                child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Text(pet.emoji, style: const TextStyle(fontSize: 80))
                          .animate(
                              onPlay: (c) => c.repeat(reverse: true),
                              effects: petAnimations),
                      if (equippedShopItem != null)
                        Positioned(
                          top: -10,
                          right: -5,
                          child: Text(equippedShopItem.emoji,
                                  style: const TextStyle(fontSize: 30))
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .scale(
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1.0, 1.0),
                                  duration: 300.ms,
                                  curve: Curves.easeOutBack),
                        ),
                    ]),
              ),
            ),
            const SizedBox(height: 10),
            if (stats.isInBadMood && stats.isVeryHungry)
              Text("${pet.name} está com MUITA fome e de mau humor!",
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center)
            else if (stats.isInBadMood)
              Text("${pet.name} não parece muito feliz...",
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center)
            else if (stats.isVeryHungry)
              Text("${pet.name} está faminto!",
                  style: TextStyle(
                      color: AppColors.hungerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center)
            else if (stats.isSad)
              Text("${pet.name} parece um pouco triste.",
                  style: TextStyle(
                      color: AppColors.happinessColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center)
            else if (stats.isVeryHappy)
              Text("${pet.name} está radiante de felicidade!",
                  style: TextStyle(
                      color: AppColors.happinessColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center),
            const SizedBox(height: 10),
            if (equippedShopItem != null)
              Text("${pet.name} está usando ${equippedShopItem.name}!",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (inventoryToys.isNotEmpty) ...[
              Text("Brinquedos:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: inventoryToys.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final toy = inventoryToys[index];
                      final quantity = userProfile.getItemQuantity(toy.id);
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(toy.emoji,
                                  style: const TextStyle(fontSize: 30)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.toyColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    textStyle: const TextStyle(fontSize: 10)),
                                onPressed: () {
                                  if (stats.isInBadMood) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${pet.name} não quer brincar com ${toy.name} agora."),
                                            backgroundColor: AppColors.error));
                                    return;
                                  }
                                  if (ref
                                          .read(activePetProvider.notifier)
                                          .useToy(toy) &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Você brincou com ${pet.name} usando ${toy.name}!"),
                                            backgroundColor:
                                                AppColors.success));
                                  }
                                },
                                child: Text("${toy.name} (x$quantity)"),
                              )
                            ],
                          ));
                    },
                  )),
              const SizedBox(height: 10),
            ],
            Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.fastfood),
                      label: const Text('Alimentar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        if (stats.isSatiated) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("${pet.name} já está satisfeito!"),
                              backgroundColor: AppColors.accent));
                          return;
                        }
                        _showItemSelectionDialog(
                            context,
                            ref,
                            ItemCategory.food,
                            "Escolha uma Comida", (selectedFood) {
                          final success = ref
                              .read(activePetProvider.notifier)
                              .feedPetWithItem(selectedFood);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "${pet.name} comeu ${selectedFood.name}!"),
                                backgroundColor: AppColors.success));
                          } else if (context.mounted && !stats.isSatiated) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Não foi possível alimentar com ${selectedFood.name}."),
                                backgroundColor: AppColors.error));
                          }
                        });
                      }),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.sports_soccer),
                      label: const Text('Brincar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        if (stats.isInBadMood) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("${pet.name} não quer brincar agora."),
                              backgroundColor: AppColors.error));
                          return;
                        }
                        if (ref
                                .read(activePetProvider.notifier)
                                .playWithPet() &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Você brincou com ${pet.name}!'),
                              backgroundColor: AppColors.success));
                        }
                      }),
                ]),
            const SizedBox(height: 16),
            Text("Cuidados:",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.medical_services_outlined),
                      label: const Text("Remédio"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.medicineColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5)),
                      onPressed: () => _showItemSelectionDialog(
                              context,
                              ref,
                              ItemCategory.medicine,
                              "Escolha um Remédio", (item) {
                            if (ref
                                    .read(activePetProvider.notifier)
                                    .useMedicine(item) &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "${pet.name} usou ${item.name} e se sente melhor!"),
                                  backgroundColor: AppColors.success));
                            }
                          })),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.bathtub_outlined),
                      label: const Text("Banho"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bathColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5)),
                      onPressed: () => _showItemSelectionDialog(
                              context,
                              ref,
                              ItemCategory.bath,
                              "Escolha um Item de Banho", (item) {
                            if (ref
                                    .read(activePetProvider.notifier)
                                    .giveBath(item) &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "${pet.name} tomou um banho refrescante!"),
                                  backgroundColor: AppColors.success));
                            }
                          })),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.content_cut_outlined),
                      label: const Text("Tosa"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.groomingColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5)),
                      onPressed: () => _showItemSelectionDialog(
                              context,
                              ref,
                              ItemCategory.grooming,
                              "Escolha um Item de Tosa", (item) {
                            if (ref
                                    .read(activePetProvider.notifier)
                                    .groomPet(item) &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "${pet.name} está com um novo visual!"),
                                  backgroundColor: AppColors.success));
                            }
                          })),
                ]),
            const SizedBox(height: 16),
            Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  TextButton.icon(
                      icon: const Icon(Icons.store_outlined),
                      label: const Text('Loja'),
                      onPressed: () => context.go('/main/shop')),
                  TextButton.icon(
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Inventário'),
                      onPressed: () => context.go('/main/inventory')),
                ]),
          ]),
        ),
      ),
    );
  }
}
