// // main.dart
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;

// // =========================================================================
// // IMPORTS DOS ARQUIVOS SEPARADOS
// // =========================================================================
// // Em um projeto real, você importaria assim:
// // import 'models/pet.dart';
// // import 'models/adoption_request.dart';
// // import 'models/user_currency.dart';
// // import 'providers/theme_provider.dart';
// // import 'providers/currency_provider.dart';
// // import 'providers/pet_providers.dart';
// // import 'screens/splash_screen.dart';
// // import 'screens/login_screen.dart';
// // import 'screens/home_screen.dart';
// // import 'screens/pet_screen.dart';
// // import 'widgets/custom_app_bar.dart';
// // import 'modals/pet_detail_modal.dart';

// // Para este exemplo, como não temos arquivos separados,
// // colocarei um comentário indicando onde cada classe deveria estar

// /* ========================================================================= */
// /* AQUI VÃO AS CLASSES DOS MODELS (pet.dart, adoption_request.dart, etc.)   */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_models]

// /* ========================================================================= */
// /* AQUI VÃO OS PROVIDERS (providers.dart)                                   */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_providers]

// /* ========================================================================= */
// /* AQUI VÃO OS MODALS (modals.dart)                                        */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_modals]

// /* ========================================================================= */
// /* AQUI VÃO AS TELAS BÁSICAS (basic_screens.dart)                          */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_basic_screens]

// /* ========================================================================= */
// /* AQUI VAI A PET SCREEN (pet_screen.dart)                                 */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_pet_screen]

// /* ========================================================================= */
// /* AQUI VAI O HOME SCREEN (home_screen.dart)                               */
// /* ========================================================================= */
// // [Conteúdo do artefato flutter_home_main]

// // =========================================================================
// // MAIN FUNCTION
// // =========================================================================
// void main() {
//   runApp(
//     const ProviderScope(
//       child: MyAppRoot(),
//     ),
//   );
// }

// // Importar todos os componentes (assumindo que estão em arquivos separados)
// // import 'providers.dart';
// // import 'basic_screens.dart';
// // import 'pet_screen.dart';

// // =========================================================================
// // Main App Widget (Flutter specific root)
// // =========================================================================
// class MyAppRoot extends ConsumerStatefulWidget {
//   const MyAppRoot({super.key});

//   @override
//   ConsumerState<MyAppRoot> createState() => _MyAppRootState();
// }

// class _MyAppRootState extends ConsumerState<MyAppRoot> {
//   bool _isLoading = true;
//   bool _isLoggedIn = false; // State to manage login status

//   @override
//   void initState() {
//     super.initState();
//     _simulateInitialLoad();
//   }

//   Future<void> _simulateInitialLoad() async {
//     await Future.delayed(const Duration(seconds: 3));
//     setState(() {
//       _isLoggedIn = true; // Set to true to skip login for game display
//       _isLoading = false;
//     });
//   }

//   void _handleLoginSuccess() {
//     setState(() {
//       _isLoggedIn = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeMode = ref.watch(themeModeProvider);

//     return MaterialApp(
//       title: 'Pet Adote',
//       themeMode: themeMode,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//         brightness: Brightness.light,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Inter',
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.indigo,
//         brightness: Brightness.dark,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Inter',
//         useMaterial3: true,
//       ),
//       home: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: themeMode == ThemeMode.light
//                   ? [const Color(0xFF8A05BE), const Color(0xFF4B0082)]
//                   : [const Color(0xFF1A1A1A), const Color(0xFF000000)],
//             ),
//           ),
//           child: _isLoading
//               ? const SplashScreen()
//               : _isLoggedIn
//                   ? const HomeScreen()
//                   : LoginScreen(onLoginSuccess: _handleLoginSuccess),
//         ),
//       ),
//     );
//   }
// }

// /* ========================================================================= */
// /* Home Screen Widget                                                        */
// /* ========================================================================= */
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _selectedIndex = 0;
//   bool _showSettings = false;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   void _handleSettingsClick() {
//     setState(() {
//       _showSettings = true;
//     });
//   }

//   void _handleBackFromSettings() {
//     setState(() {
//       _showSettings = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Scaffold(
//       appBar: _showSettings
//           ? null
//           : CustomAppBar(onSettingsClick: _handleSettingsClick),
//       body: _showSettings
//           ? SettingsScreen(onBack: _handleBackFromSettings)
//           : IndexedStack(
//               index: _selectedIndex,
//               children: const [
//                 DashboardScreen(),
//                 LojaScreen(),
//                 PetScreen(),
//                 GamesScreen(),
//                 FeedScreen(),
//               ],
//             ),
//       bottomNavigationBar: _showSettings
//           ? null
//           : BottomNavigationBar(
//               items: const <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.dashboard),
//                   label: 'Dashboard',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.store),
//                   label: 'Loja',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.pets),
//                   label: 'Pet',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.games),
//                   label: 'Games',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.article),
//                   label: 'Feed',
//                 ),
//               ],
//               currentIndex: _selectedIndex,
//               selectedItemColor:
//                   isLight ? Colors.purple[700] : Colors.purple[400],
//               unselectedItemColor:
//                   isLight ? Colors.grey[500] : Colors.grey[300],
//               onTap: _onItemTapped,
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: isLight ? Colors.white : Colors.grey[800],
//             ),
//     );
//   }
// }

// // Importar models, providers e modals (assumindo que estão em arquivos separados)
// // import 'models.dart';
// // import 'providers.dart';
// // import 'modals.dart';

// /* ========================================================================= */
// /* Pet Screen Widget                                                         */
// /* ========================================================================= */
// class PetScreen extends ConsumerStatefulWidget {
//   const PetScreen({super.key});

//   @override
//   ConsumerState<PetScreen> createState() => _PetScreenState();
// }

// class _PetScreenState extends ConsumerState<PetScreen> {
//   // Custo para gerar um pet único
//   static const int PET_GENERATION_COST = 20;
//   static const int ADOPTION_REWARD_COINS = 100;

//   // Custos e recompensas para ações do pet
//   static const int FEED_COST = 10;
//   static const int PLAY_COST = 5;
//   static const int REST_COST = 8;
//   static const int PLAY_XP_REWARD = 10;

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     final userCurrency = ref.watch(userCurrencyProvider);
//     final availablePets = ref.watch(availablePetsProvider);
//     final activeAdoptionRequests = ref.watch(activeAdoptionRequestsProvider);

//     final adoptionFlowState = ref.watch(adoptionFlowStateProvider);
//     final newlyGeneratedPet = ref.watch(newlyGeneratedPetProvider);
//     final generationError = ref.watch(generationErrorProvider);
//     final petDetailsModalOpen = ref.watch(petDetailsModalOpenProvider);
//     final petInModal = ref.watch(petInModalProvider);
//     final joinAdoptionModalOpen = ref.watch(joinAdoptionModalOpenProvider);
//     final requestInModal = ref.watch(requestInModalProvider);
//     final myRequestDetailsModalOpen =
//         ref.watch(myRequestDetailsModalOpenProvider);
//     final selectedPetsForFriendAdoptionIds =
//         ref.watch(selectedPetsForFriendAdoptionIdsProvider);
//     final friendAdoptionCode = ref.watch(friendAdoptionCodeProvider);
//     final friendAdoptionMessage = ref.watch(friendAdoptionMessageProvider);
//     final adoptionRequestInfo = ref.watch(adoptionRequestInfoProvider);
//     final selectedPetsForMyRequestIds =
//         ref.watch(selectedPetsForMyRequestIdsProvider);
//     final currentAdoptedPet = ref.watch(currentAdoptedPetProvider);
//     final generatingUniquePet = ref.watch(generatingUniquePetProvider);

//     // Lógica para abrir o modal de detalhes do pet
//     void openPetDetailsModal(Pet pet, String mode) {
//       final petMap = pet.toJson();
//       petMap['mode'] = mode; // Add mode
//       ref.read(petInModalProvider.notifier).state = petMap;
//       ref.read(petDetailsModalOpenProvider.notifier).state = true;
//     }

//     // Lógica para fechar o modal de detalhes do pet
//     void closePetDetailsModal() {
//       ref.read(petDetailsModalOpenProvider.notifier).state = false;
//       ref.read(petInModalProvider.notifier).state = null;
//     }

//     // Lógica para selecionar/desselecionar pets
//     void handleSelectPet(
//         String petId,
//         List<String> targetSelectionState,
//         StateController<List<String>> setTargetSelectionState,
//         int maxSelection) {
//       ref.read(friendAdoptionMessageProvider.notifier).state =
//           ''; // Clear message

//       final petToSelect = availablePets.firstWhere((p) => p.id == petId);

//       if (petToSelect.isAdopted) {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Este pet já foi adotado.';
//         closePetDetailsModal();
//         return;
//       }

//       if (targetSelectionState.contains(petId)) {
//         setTargetSelectionState.state =
//             targetSelectionState.where((id) => id != petId).toList();
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Pet "${petToSelect.name}" removido da seleção.';
//       } else {
//         if (targetSelectionState.length < maxSelection) {
//           setTargetSelectionState.state = [...targetSelectionState, petId];
//           ref.read(friendAdoptionMessageProvider.notifier).state =
//               'Pet "${petToSelect.name}" adicionado à seleção.';
//         } else {
//           ref.read(friendAdoptionMessageProvider.notifier).state =
//               'Você pode selecionar no máximo $maxSelection pets.';
//         }
//       }
//       closePetDetailsModal();
//     }

//     // Handle para pets na criação de solicitação própria
//     void handleSelectPetForMyRequest(String petId) {
//       handleSelectPet(petId, ref.read(selectedPetsForMyRequestIdsProvider),
//           ref.read(selectedPetsForMyRequestIdsProvider.notifier), 3);
//     }

//     // Handle para pets na adoção com amigo
//     void handleSelectPetForFriendAdoption(String petId) {
//       handleSelectPet(petId, ref.read(selectedPetsForFriendAdoptionIdsProvider),
//           ref.read(selectedPetsForFriendAdoptionIdsProvider.notifier), 3);
//     }

//     // Lógica para adotar um pet imediatamente
//     void handleAdoptPetImmediately(String petId) {
//       ref.read(availablePetsProvider.notifier).markPetAsAdopted(petId);
//       final adoptedPetDetails = availablePets.firstWhere((p) => p.id == petId);
//       ref.read(currentAdoptedPetProvider.notifier).state =
//           adoptedPetDetails.copyWith(
//         hunger: 80,
//         happiness: 70,
//         energy: 90,
//         level: 1,
//         xp: 0,
//         xpToNextLevel: 100,
//       );

//       ref.read(adoptionFlowStateProvider.notifier).state =
//           AdoptionFlowStates.hasPet;
//       ref
//           .read(userCurrencyProvider.notifier)
//           .setCoins(userCurrency.coins + ADOPTION_REWARD_COINS);
//       closePetDetailsModal();
//       ref.read(friendAdoptionMessageProvider.notifier).state =
//           'Parabéns! Você adotou o pet e recebeu $ADOPTION_REWARD_COINS Coins!';
//     }

//     // Lógica para abrir o modal de escolha de pet em adoção conjunta
//     void openJoinAdoptionModal(AdoptionRequest request) {
//       ref.read(requestInModalProvider.notifier).state = request.toJson();
//       ref.read(joinAdoptionModalOpenProvider.notifier).state = true;
//     }

//     // Lógica para fechar o modal de escolha de pet em adoção conjunta
//     void closeJoinAdoptionModal() {
//       ref.read(joinAdoptionModalOpenProvider.notifier).state = false;
//       ref.read(requestInModalProvider.notifier).state = null;
//     }

//     // Lógica para o joiner escolher um pet de uma solicitação conjunta
//     void handleChoosePetForJointAdoption(String requestId, String chosenPetId) {
//       ref
//           .read(activeAdoptionRequestsProvider.notifier)
//           .completeRequest(requestId, userCurrency.currentUserId, chosenPetId);
//       ref.read(availablePetsProvider.notifier).markPetAsAdopted(chosenPetId);

//       final adoptedPetDetails =
//           availablePets.firstWhere((p) => p.id == chosenPetId);
//       ref.read(currentAdoptedPetProvider.notifier).state =
//           adoptedPetDetails.copyWith(
//         hunger: 80,
//         happiness: 70,
//         energy: 90,
//         level: 1,
//         xp: 0,
//         xpToNextLevel: 100,
//       );

//       ref.read(adoptionFlowStateProvider.notifier).state =
//           AdoptionFlowStates.hasPet;
//       ref
//           .read(userCurrencyProvider.notifier)
//           .setCoins(userCurrency.coins + ADOPTION_REWARD_COINS);
//       closeJoinAdoptionModal();
//       ref.read(friendAdoptionMessageProvider.notifier).state =
//           'Parabéns! Você adotou um pet em conjunto e recebeu $ADOPTION_REWARD_COINS Coins!';
//     }

//     // Lógica para abrir o modal de detalhes da MINHA solicitação de adoção
//     void openMyRequestDetailsModal() {
//       ref.read(myRequestDetailsModalOpenProvider.notifier).state = true;
//     }

//     // Lógica para fechar o modal de detalhes da MINHA solicitação de adoção
//     void closeMyRequestDetailsModal() {
//       ref.read(myRequestDetailsModalOpenProvider.notifier).state = false;
//     }

//     // Função para gerar o código da adoção com amigo
//     void generateFriendAdoptionCode() {
//       if (selectedPetsForFriendAdoptionIds.length != 3) {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Por favor, selecione exatamente 3 pets antes de gerar o código.';
//         return;
//       }
//       final code = generateRandomString(6); // Generate random code
//       ref.read(friendAdoptionCodeProvider.notifier).state = code;
//       ref.read(friendAdoptionMessageProvider.notifier).state =
//           'Compartilhe este código: $code';
//     }

//     // Função para simular que o amigo usou o código e escolheu um pet
//     void simulateFriendAdoption() {
//       if (selectedPetsForFriendAdoptionIds.length == 3) {
//         final petsChosenForFriendAdoption = availablePets
//             .where((pet) => selectedPetsForFriendAdoptionIds.contains(pet.id))
//             .toList();
//         final chosenByFriend = petsChosenForFriendAdoption[
//             Random().nextInt(petsChosenForFriendAdoption.length)];

//         ref
//             .read(availablePetsProvider.notifier)
//             .markPetAsAdopted(chosenByFriend.id);

//         ref.read(currentAdoptedPetProvider.notifier).state =
//             chosenByFriend.copyWith(
//           hunger: 80,
//           happiness: 70,
//           energy: 90,
//           level: 1,
//           xp: 0,
//           xpToNextLevel: 100,
//         );

//         ref.read(adoptionFlowStateProvider.notifier).state =
//             AdoptionFlowStates.hasPet;
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setCoins(userCurrency.coins + ADOPTION_REWARD_COINS);
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Adoção conjunta com ${chosenByFriend.name} concluída e você recebeu $ADOPTION_REWARD_COINS Coins!';
//         ref.read(selectedPetsForFriendAdoptionIdsProvider.notifier).state = [];
//         ref.read(friendAdoptionCodeProvider.notifier).state = '';
//         ref.read(friendAdoptionMessageProvider.notifier).state = '';
//       } else {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Erro: Selecione 3 pets para simular a adoção.';
//       }
//     }

//     // Function to call Gemini API to generate unique pet and Imagen for image
//     Future<void> generateUniquePet() async {
//       if (userCurrency.gems < PET_GENERATION_COST) {
//         ref.read(generationErrorProvider.notifier).state =
//             'Você precisa de $PET_GENERATION_COST Gems para gerar um pet único. Gems atuais: ${userCurrency.gems}.';
//         return;
//       }

//       ref.read(generatingUniquePetProvider.notifier).state = true;
//       ref.read(generationErrorProvider.notifier).state = '';
//       ref.read(newlyGeneratedPetProvider.notifier).state = null;

//       const promptGemini = '''
// Gere os detalhes para um pet único e inovador para adoção em um jogo. Inclua:
// - nome: (um nome criativo)
// - tipo: (ex: "Gato", "Cachorro", "Dragão de Bolso", "Robô-Hamster")
// - description: (uma breve descrição de 10-15 palavras sobre sua personalidade ou característica especial)
// - image_prompt: (um texto descritivo para gerar uma imagem única e estilo emoji 2D/vetorizado deste pet, com fundo branco simples, por exemplo: "um ícone de cachorro robótico kawaii com olhos grandes, estilo emoji 2D, fundo branco, estilo vetor, minimalista", "emoji de gato com asas de borboleta, estilo desenho animado, fundo branco, estilo vetorizado")
// Retorne a resposta estritamente em formato JSON.
// ''';

//       List<Map<String, dynamic>> chatHistoryGemini = [];
//       chatHistoryGemini.add({
//         "role": "user",
//         "parts": [
//           {"text": promptGemini}
//         ]
//       });

//       try {
//         final payloadGemini = {
//           "contents": chatHistoryGemini,
//           "generationConfig": {
//             "responseMimeType": "application/json",
//             "responseSchema": {
//               "type": "OBJECT",
//               "properties": {
//                 "name": {"type": "STRING"},
//                 "type": {"type": "STRING"},
//                 "description": {"type": "STRING"},
//                 "image_prompt": {"type": "STRING"}
//               },
//               "propertyOrdering": [
//                 "name",
//                 "type",
//                 "description",
//                 "image_prompt"
//               ]
//             }
//           }
//         };
//         const apiKey = ""; // API key is handled by the platform
//         final apiUrlGemini = Uri.parse(
//             'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

//         final responseGemini = await http.post(
//           apiUrlGemini,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(payloadGemini),
//         );

//         if (responseGemini.statusCode != 200) {
//           throw Exception(
//               'Failed to get pet details from Gemini: ${responseGemini.statusCode} ${responseGemini.body}');
//         }

//         final resultGemini = jsonDecode(responseGemini.body);
//         Map<String, dynamic> generatedPetDetails;
//         if (resultGemini['candidates'] != null &&
//             resultGemini['candidates'].isNotEmpty &&
//             resultGemini['candidates'][0]['content'] != null &&
//             resultGemini['candidates'][0]['content']['parts'] != null &&
//             resultGemini['candidates'][0]['content']['parts'].isNotEmpty) {
//           final jsonText =
//               resultGemini['candidates'][0]['content']['parts'][0]['text'];
//           generatedPetDetails = jsonDecode(jsonText);
//         } else {
//           throw Exception(
//               'Erro ao gerar detalhes do pet com Gemini: Estrutura de resposta inesperada.');
//         }

//         // 2. Generate the image of the pet with Imagen
//         final imagePrompt = generatedPetDetails['image_prompt'];
//         final payloadImagen = {
//           "instances": {"prompt": imagePrompt},
//           "parameters": {"sampleCount": 1}
//         };
//         final apiUrlImagen = Uri.parse(
//             'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key=$apiKey');

//         final responseImagen = await http.post(
//           apiUrlImagen,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(payloadImagen),
//         );

//         if (responseImagen.statusCode != 200) {
//           throw Exception(
//               'Failed to generate image from Imagen: ${responseImagen.statusCode} ${responseImagen.body}');
//         }

//         final resultImagen = jsonDecode(responseImagen.body);
//         String imageUrlBase64;
//         if (resultImagen['predictions'] != null &&
//             resultImagen['predictions'].isNotEmpty &&
//             resultImagen['predictions'][0]['bytesBase64Encoded'] != null) {
//           imageUrlBase64 =
//               'data:image/png;base64,${resultImagen['predictions'][0]['bytesBase64Encoded']}';
//         } else {
//           throw Exception(
//               'Erro ao gerar imagem do pet com Imagen: Estrutura de resposta inesperada.');
//         }

//         // 3. Create and add the new pet
//         final newPet = Pet(
//           id: 'ai-p-${DateTime.now().millisecondsSinceEpoch}',
//           name: generatedPetDetails['name'],
//           type: generatedPetDetails['type'],
//           description: generatedPetDetails['description'],
//           imageUrl: imageUrlBase64,
//           isAdopted: false,
//           generatedByUserId: userCurrency.currentUserId,
//         );
//         ref.read(availablePetsProvider.notifier).addPet(newPet);
//         ref.read(newlyGeneratedPetProvider.notifier).state = newPet;
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Pet "${newPet.name}" gerado com sucesso! Clique para selecioná-lo.';
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setGems(userCurrency.gems - PET_GENERATION_COST);
//       } catch (e) {
//         print('Error in unique pet generation flow: $e');
//         ref.read(generationErrorProvider.notifier).state =
//             'Erro: ${e.toString()}';
//       } finally {
//         ref.read(generatingUniquePetProvider.notifier).state = false;
//       }
//     }

//     // Funções de Ações do Pet (Feed, Play, Rest)
//     void updatePetStats(
//         int hungerChange, int happinessChange, int energyChange, int xpChange) {
//       if (currentAdoptedPet == null) return;

//       final newHunger = (currentAdoptedPet.hunger + hungerChange).clamp(0, 100);
//       final newHappiness =
//           (currentAdoptedPet.happiness + happinessChange).clamp(0, 100);
//       final newEnergy = (currentAdoptedPet.energy + energyChange).clamp(0, 100);
//       int newXp = currentAdoptedPet.xp + xpChange;
//       int newLevel = currentAdoptedPet.level;
//       int newXpToNextLevel = currentAdoptedPet.xpToNextLevel;

//       if (newXp >= newXpToNextLevel) {
//         newLevel += 1;
//         newXp = newXp - newXpToNextLevel;
//         newXpToNextLevel = (newXpToNextLevel * 1.5).floor();
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setXp(userCurrency.xp + xpChange);
//       } else {
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setXp(userCurrency.xp + xpChange);
//       }

//       ref.read(currentAdoptedPetProvider.notifier).state =
//           currentAdoptedPet.copyWith(
//         hunger: newHunger,
//         happiness: newHappiness,
//         energy: newEnergy,
//         xp: newXp,
//         level: newLevel,
//         xpToNextLevel: newXpToNextLevel,
//       );
//     }

//     void feedPet() {
//       if (userCurrency.coins >= FEED_COST) {
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setCoins(userCurrency.coins - FEED_COST);
//         updatePetStats(20, 5, 0, 0);
//       } else {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Você não tem Coins suficientes para alimentar seu pet!';
//       }
//     }

//     void playWithPet() {
//       if (userCurrency.coins >= PLAY_COST) {
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setCoins(userCurrency.coins - PLAY_COST);
//         updatePetStats(-10, 25, -15, PLAY_XP_REWARD);
//       } else {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Você não tem Coins suficientes para brincar com seu pet!';
//       }
//     }

//     void restPet() {
//       if (userCurrency.coins >= REST_COST) {
//         ref
//             .read(userCurrencyProvider.notifier)
//             .setCoins(userCurrency.coins - REST_COST);
//         updatePetStats(-5, 5, 30, 0);
//       } else {
//         ref.read(friendAdoptionMessageProvider.notifier).state =
//             'Você não tem Coins suficientes para fazer seu pet descansar!';
//       }
//     }

//     return Stack(
//       children: [
//         Container(
//           color: isLight ? Colors.blue[50] : Colors.blue[900],
//           alignment: Alignment.center,
//           child: Column(
//             children: [
//               // Render content based on adoptionFlowState
//               if (adoptionFlowState == AdoptionFlowStates.noPet)
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Ainda não há um companheiro peludo esperando por você!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: isLight ? Colors.grey[600] : Colors.grey[300],
//                           fontSize: 18,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton.icon(
//                         onPressed: () => ref
//                             .read(adoptionFlowStateProvider.notifier)
//                             .state = AdoptionFlowStates.creatingRequest,
//                         icon: const Icon(Icons.add_circle, size: 24),
//                         label: const Text('Criar Solicitação de Adoção',
//                             style: TextStyle(fontSize: 18)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple[700],
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           elevation: 8,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: () => ref
//                             .read(adoptionFlowStateProvider.notifier)
//                             .state = AdoptionFlowStates.adoptExistingFlow,
//                         icon: const Icon(Icons.pets, size: 24),
//                         label: const Text('Adotar Pet Existente',
//                             style: TextStyle(fontSize: 18)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[600],
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           elevation: 8,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: () => ref
//                             .read(adoptionFlowStateProvider.notifier)
//                             .state = AdoptionFlowStates.adoptWithFriendFlow,
//                         icon: const Icon(Icons.link, size: 24),
//                         label: const Text('Adoção com Amigo',
//                             style: TextStyle(fontSize: 18)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange[500],
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           elevation: 8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               if (adoptionFlowState == AdoptionFlowStates.creatingRequest)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       color: isLight ? Colors.white : Colors.grey[800],
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 20.0,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                       border: Border.all(color: Colors.purple[300]!, width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Crie sua Solicitação de Adoção!',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color: isLight
//                                 ? Colors.purple[800]
//                                 : Colors.purple[400],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Text(
//                             'Sua solicitação será ativa por 5 dias. Escolha 3 pets para que outro adotador selecione um deles.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   isLight ? Colors.grey[700] : Colors.grey[200],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: () => generateUniquePet(),
//                           icon: const Icon(Icons.lightbulb_outline, size: 20),
//                           label: Text(
//                             generatingUniquePet
//                                 ? 'Gerando Pet...'
//                                 : 'Gerar Novo Pet Único! ($PET_GENERATION_COST Gems)',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[500],
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             elevation: 5,
//                           ),
//                         ),
//                         if (generationError.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Text(
//                               generationError,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.red[500], fontSize: 13),
//                             ),
//                           ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Escolha seus Pets (${selectedPetsForMyRequestIds.length}/3)',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 isLight ? Colors.grey[800] : Colors.grey[100],
//                           ),
//                         ),
//                         if (friendAdoptionMessage.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Text(
//                               friendAdoptionMessage,
//                               style: TextStyle(
//                                   color: Colors.red[500], fontSize: 13),
//                             ),
//                           ),
//                         Expanded(
//                           child: GridView.builder(
//                             padding: const EdgeInsets.only(bottom: 16),
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                               childAspectRatio: 0.9,
//                             ),
//                             itemCount: availablePets
//                                 .where((pet) =>
//                                     !pet.isAdopted &&
//                                     (pet.generatedByUserId ==
//                                             userCurrency.currentUserId ||
//                                         pet.generatedByUserId == null))
//                                 .length,
//                             itemBuilder: (context, index) {
//                               final pet = availablePets
//                                   .where((pet) =>
//                                       !pet.isAdopted &&
//                                       (pet.generatedByUserId ==
//                                               userCurrency.currentUserId ||
//                                           pet.generatedByUserId == null))
//                                   .toList()[index];
//                               final isSelected =
//                                   selectedPetsForMyRequestIds.contains(pet.id);
//                               return GestureDetector(
//                                 onTap: () =>
//                                     openPetDetailsModal(pet, 'createRequest'),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: isLight
//                                         ? Colors.white
//                                         : Colors.grey[700],
//                                     borderRadius: BorderRadius.circular(8.0),
//                                     border: Border.all(
//                                       color: isSelected
//                                           ? Colors.purple[500]!
//                                           : Colors.grey[200]!,
//                                       width: isSelected ? 3 : 1,
//                                     ),
//                                     boxShadow: const [
//                                       BoxShadow(
//                                         color: Colors.black12,
//                                         blurRadius: 4.0,
//                                         offset: Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       pet.imageUrl.startsWith('data:image')
//                                           ? Image.memory(
//                                               base64Decode(
//                                                   pet.imageUrl.split(',')[1]),
//                                               fit: BoxFit.contain,
//                                               width: 60,
//                                               height: 60,
//                                               errorBuilder: (context, error,
//                                                       stackTrace) =>
//                                                   const Icon(Icons.broken_image,
//                                                       size: 40),
//                                             )
//                                           : Image.network(
//                                               pet.imageUrl,
//                                               fit: BoxFit.contain,
//                                               width: 60,
//                                               height: 60,
//                                               errorBuilder: (context, error,
//                                                       stackTrace) =>
//                                                   const Icon(Icons.broken_image,
//                                                       size: 40),
//                                             ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         pet.name,
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: isLight
//                                               ? Colors.grey[800]
//                                               : Colors.grey[100],
//                                         ),
//                                       ),
//                                       Text(
//                                         pet.type,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: isLight
//                                               ? Colors.grey[600]
//                                               : Colors.grey[400],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: selectedPetsForMyRequestIds.length != 3
//                               ? null
//                               : () {
//                                   final newRequestId =
//                                       'req-${DateTime.now().millisecondsSinceEpoch}';
//                                   final petsForRequest = availablePets
//                                       .where((pet) =>
//                                           selectedPetsForMyRequestIds
//                                               .contains(pet.id))
//                                       .toList();

//                                   ref
//                                       .read(activeAdoptionRequestsProvider
//                                           .notifier)
//                                       .addRequest(
//                                         AdoptionRequest(
//                                           id: newRequestId,
//                                           creatorUserId:
//                                               userCurrency.currentUserId,
//                                           petsInRequest: petsForRequest,
//                                           daysLeft: 5,
//                                         ),
//                                       );
//                                   ref
//                                       .read(adoptionFlowStateProvider.notifier)
//                                       .state = AdoptionFlowStates.requestActive;
//                                   ref
//                                       .read(
//                                           adoptionRequestInfoProvider.notifier)
//                                       .state = {
//                                     'views': 1,
//                                     'daysLeft': 5,
//                                     'petsSelected': selectedPetsForMyRequestIds,
//                                     'fullPetsSelected': petsForRequest,
//                                   };
//                                   ref
//                                       .read(newlyGeneratedPetProvider.notifier)
//                                       .state = null;
//                                   ref
//                                       .read(friendAdoptionMessageProvider
//                                           .notifier)
//                                       .state = '';
//                                   ref
//                                       .read(selectedPetsForMyRequestIdsProvider
//                                           .notifier)
//                                       .state = [];
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[500],
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 50),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text('Confirmar Solicitação de Adoção',
//                               style: TextStyle(fontSize: 18)),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             ref.read(adoptionFlowStateProvider.notifier).state =
//                                 AdoptionFlowStates.noPet;
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[400],
//                             foregroundColor: Colors.grey[900],
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text('Cancelar',
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               if (adoptionFlowState == AdoptionFlowStates.adoptExistingFlow)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       color: isLight ? Colors.white : Colors.grey[800],
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 20.0,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                       border: Border.all(color: Colors.green[300]!, width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Adoções em Andamento!',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color:
//                                 isLight ? Colors.green[800] : Colors.green[400],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Text(
//                             'Participe de uma solicitação de adoção existente e escolha seu pet!',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   isLight ? Colors.grey[700] : Colors.grey[200],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: activeAdoptionRequests
//                                 .where((req) =>
//                                     req.status == 'pending' &&
//                                     req.creatorUserId !=
//                                         userCurrency.currentUserId)
//                                 .length,
//                             itemBuilder: (context, index) {
//                               final request = activeAdoptionRequests
//                                   .where((req) =>
//                                       req.status == 'pending' &&
//                                       req.creatorUserId !=
//                                           userCurrency.currentUserId)
//                                   .toList()[index];
//                               return Card(
//                                 margin:
//                                     const EdgeInsets.symmetric(vertical: 8.0),
//                                 elevation: 4,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(Icons.people,
//                                               size: 20,
//                                               color: Colors.indigo[500]),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             'Solicitação de Usuário Anônimo',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               color: isLight
//                                                   ? Colors.grey[800]
//                                                   : Colors.grey[100],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceAround,
//                                         children:
//                                             request.petsInRequest.map((pet) {
//                                           return Container(
//                                             width: 60,
//                                             height: 60,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                   color: Colors.grey[300]!,
//                                                   width: 1),
//                                             ),
//                                             child: pet.imageUrl
//                                                     .startsWith('data:image')
//                                                 ? Image.memory(
//                                                     base64Decode(pet.imageUrl
//                                                         .split(',')[1]),
//                                                     fit: BoxFit.contain,
//                                                     errorBuilder: (context,
//                                                             error,
//                                                             stackTrace) =>
//                                                         const Icon(
//                                                             Icons.broken_image,
//                                                             size: 30),
//                                                   )
//                                                 : Image.network(
//                                                     pet.imageUrl,
//                                                     fit: BoxFit.contain,
//                                                     errorBuilder: (context,
//                                                             error,
//                                                             stackTrace) =>
//                                                         const Icon(
//                                                             Icons.broken_image,
//                                                             size: 30),
//                                                   ),
//                                           );
//                                         }).toList(),
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Text(
//                                         'Escolha entre 3 pets incríveis.',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: isLight
//                                               ? Colors.grey[600]
//                                               : Colors.grey[300],
//                                         ),
//                                       ),
//                                       Text(
//                                         'Faltam ${request.daysLeft} dias para a adoção.',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontStyle: FontStyle.italic,
//                                           color: isLight
//                                               ? Colors.grey[500]
//                                               : Colors.grey[400],
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       ElevatedButton(
//                                         onPressed: () =>
//                                             openJoinAdoptionModal(request),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.blue[600],
//                                           foregroundColor: Colors.white,
//                                           minimumSize:
//                                               const Size(double.infinity, 45),
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8.0)),
//                                           elevation: 5,
//                                         ),
//                                         child: const Text(
//                                             'Participar da Adoção',
//                                             style: TextStyle(fontSize: 16)),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () => ref
//                               .read(adoptionFlowStateProvider.notifier)
//                               .state = AdoptionFlowStates.noPet,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[400],
//                             foregroundColor: Colors.grey[900],
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text('Voltar',
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               if (adoptionFlowState == AdoptionFlowStates.adoptWithFriendFlow)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       color: isLight ? Colors.white : Colors.grey[800],
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 20.0,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                       border: Border.all(color: Colors.orange[300]!, width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Crie uma Adoção com Amigo!',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color: isLight
//                                 ? Colors.orange[800]
//                                 : Colors.orange[400],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: () => generateUniquePet(),
//                           icon: const Icon(Icons.lightbulb_outline, size: 20),
//                           label: Text(
//                             generatingUniquePet
//                                 ? 'Gerando Pet...'
//                                 : 'Gerar Novo Pet Único! ($PET_GENERATION_COST Gems)',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[500],
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             elevation: 5,
//                           ),
//                         ),
//                         if (friendAdoptionCode.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16.0),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Código: $friendAdoptionCode',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 24,
//                                     color: isLight
//                                         ? Colors.yellow[800]
//                                         : Colors.yellow[200],
//                                   ),
//                                 ),
//                                 Text(
//                                   'Compartilhe este código com seu amigo!',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: isLight
//                                         ? Colors.yellow[700]
//                                         : Colors.yellow[300],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 ElevatedButton(
//                                   onPressed: simulateFriendAdoption,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blue[500],
//                                     foregroundColor: Colors.white,
//                                     minimumSize:
//                                         const Size(double.infinity, 45),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(8.0)),
//                                     elevation: 5,
//                                   ),
//                                   child: const Text(
//                                       'Simular Adição do Amigo e Adoção',
//                                       style: TextStyle(fontSize: 16)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ElevatedButton(
//                           onPressed:
//                               selectedPetsForFriendAdoptionIds.length != 3 ||
//                                       friendAdoptionCode.isNotEmpty
//                                   ? null
//                                   : generateFriendAdoptionCode,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange[500],
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 50),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text(
//                               'Gerar Código para Adoção com Amigo',
//                               style: TextStyle(fontSize: 18)),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             ref.read(adoptionFlowStateProvider.notifier).state =
//                                 AdoptionFlowStates.noPet;
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[400],
//                             foregroundColor: Colors.grey[900],
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text('Cancelar',
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               if (adoptionFlowState == AdoptionFlowStates.requestActive)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       color: isLight ? Colors.white : Colors.grey[800],
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 20.0,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                       border: Border.all(color: Colors.indigo[300]!, width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Sua Solicitação de Adoção está Ativa!',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color: isLight
//                                 ? Colors.indigo[800]
//                                 : Colors.indigo[400],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Text(
//                             'Aguardando um adotador para se juntar à sua solicitação.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   isLight ? Colors.grey[700] : Colors.grey[200],
//                             ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Column(
//                               children: [
//                                 Text(
//                                   adoptionRequestInfo['views'].toString(),
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: isLight
//                                         ? Colors.blue[600]
//                                         : Colors.blue[300],
//                                   ),
//                                 ),
//                                 Text(
//                                   'Visualizações',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isLight
//                                         ? Colors.grey[600]
//                                         : Colors.grey[400],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 Icon(Icons.calendar_today,
//                                     size: 32,
//                                     color: isLight
//                                         ? Colors.orange[500]
//                                         : Colors.orange[300]),
//                                 Text(
//                                   'Faltam ${adoptionRequestInfo['daysLeft']} dias',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isLight
//                                         ? Colors.grey[600]
//                                         : Colors.grey[400],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: openMyRequestDetailsModal,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[600],
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 50),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text(
//                               'Exibir Detalhes da Minha Solicitação',
//                               style: TextStyle(fontSize: 18)),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             ref.read(adoptionFlowStateProvider.notifier).state =
//                                 AdoptionFlowStates.noPet;
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[400],
//                             foregroundColor: Colors.grey[900],
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text('Cancelar Solicitação (Simular)',
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               if (adoptionFlowState == AdoptionFlowStates.hasPet)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       color: isLight ? Colors.white : Colors.grey[800],
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 20.0,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                       border: Border.all(color: Colors.green[300]!, width: 1),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Meu Pet: ${currentAdoptedPet?.name ?? 'Nome do Pet'}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color:
//                                 isLight ? Colors.green[800] : Colors.green[400],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Pet Avatar with Level Progress
//                         Container(
//                           width: 160,
//                           height: 160,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color:
//                                 isLight ? Colors.grey[200] : Colors.grey[700],
//                             border: Border.all(
//                               color: currentAdoptedPet?.level != null
//                                   ? (currentAdoptedPet!.level % 2 == 0
//                                       ? Colors.purple[500]!
//                                       : Colors.green[500]!)
//                                   : Colors.transparent,
//                               width: currentAdoptedPet?.level != null
//                                   ? (4 + (currentAdoptedPet!.level - 1) * 0.5)
//                                   : 0,
//                             ),
//                           ),
//                           child: ClipOval(
//                             child: currentAdoptedPet?.imageUrl
//                                         .startsWith('data:image') ==
//                                     true
//                                 ? Image.memory(
//                                     base64Decode(currentAdoptedPet!.imageUrl
//                                         .split(',')[1]),
//                                     fit: BoxFit.contain,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             const Icon(Icons.pets, size: 80),
//                                   )
//                                 : Image.network(
//                                     currentAdoptedPet?.imageUrl ??
//                                         'https://placehold.co/128x128/cccccc/000000?text=?',
//                                     fit: BoxFit.contain,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             const Icon(Icons.pets, size: 80),
//                                   ),
//                           ),
//                         ),
//                         if (currentAdoptedPet != null)
//                           Text(
//                             'Lv. ${currentAdoptedPet.level}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color:
//                                   isLight ? Colors.blue[500] : Colors.blue[300],
//                             ),
//                           ),
//                         const SizedBox(height: 16),
//                         // Status Bars
//                         _buildStatusBar(
//                             '🍔 Fome',
//                             currentAdoptedPet?.hunger ?? 0,
//                             Colors.yellow,
//                             isLight),
//                         _buildStatusBar(
//                             '😊 Felicidade',
//                             currentAdoptedPet?.happiness ?? 0,
//                             Colors.pink,
//                             isLight),
//                         _buildStatusBar(
//                             '⚡ Energia',
//                             currentAdoptedPet?.energy ?? 0,
//                             Colors.red,
//                             isLight),
//                         const SizedBox(height: 24),
//                         // Pet Actions
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildActionButton('Alimentar', Icons.restaurant,
//                                 feedPet, FEED_COST),
//                             _buildActionButton('Brincar', Icons.sports_soccer,
//                                 playWithPet, PLAY_COST),
//                             _buildActionButton(
//                                 'Descansar', Icons.bed, restPet, REST_COST),
//                           ],
//                         ),
//                         if (friendAdoptionMessage.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Text(
//                               friendAdoptionMessage,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.red[500]!, fontSize: 13),
//                             ),
//                           ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: () {
//                             ref.read(currentAdoptedPetProvider.notifier).state =
//                                 null;
//                             ref.read(adoptionFlowStateProvider.notifier).state =
//                                 AdoptionFlowStates.noPet;
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[400],
//                             foregroundColor: Colors.grey[900],
//                             minimumSize: const Size(double.infinity, 45),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             elevation: 5,
//                           ),
//                           child: const Text(
//                               'Reiniciar Fluxo (Apenas para Teste)',
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),

//         // Modals
//         if (petDetailsModalOpen && petInModal != null)
//           PetDetailModal(
//             pet: Pet.fromJson(petInModal),
//             onClose: closePetDetailsModal,
//             onSelect: petInModal['mode'] == 'createRequest'
//                 ? handleSelectPetForMyRequest
//                 : petInModal['mode'] == 'friendAdoption'
//                     ? handleSelectPetForFriendAdoption
//                     : handleAdoptPetImmediately,
//             mode: petInModal['mode'],
//           ),

//         if (joinAdoptionModalOpen && requestInModal != null)
//           JoinAdoptionModal(
//             request: AdoptionRequest.fromJson(requestInModal),
//             onClose: closeJoinAdoptionModal,
//             onChoosePet: handleChoosePetForJointAdoption,
//           ),

//         if (myRequestDetailsModalOpen)
//           MyAdoptionRequestModal(
//             requestInfo: adoptionRequestInfo,
//             petsInRequest: adoptionRequestInfo['fullPetsSelected'] as List<Pet>,
//             onClose: closeMyRequestDetailsModal,
//           ),
//       ],
//     );
//   }

//   Widget _buildStatusBar(String label, int value, Color color, bool isLight) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 16)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: LinearProgressIndicator(
//               value: value / 100,
//               backgroundColor: isLight ? Colors.grey[200] : Colors.grey[700],
//               valueColor: AlwaysStoppedAnimation<Color>(color),
//               minHeight: 10,
//               borderRadius: BorderRadius.circular(5),
//             ),
//           ),
//           Text('$value%', style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       String text, IconData icon, VoidCallback onPressed, int cost) {
//     return Expanded(
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue[500],
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           elevation: 4,
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 28),
//             const SizedBox(height: 4),
//             Text('$text (${cost}C)', textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Importar providers (assumindo que estão em arquivo separado)
// // import 'providers.dart';

// // =========================================================================
// // Splash Screen Widget
// // =========================================================================
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.pets,
//             size: 128,
//             color: Colors.white,
//           ),
//           SizedBox(height: 24),
//           Text(
//             'Pet Adote',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.w900,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 16),
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =========================================================================
// // Login Screen Widget
// // =========================================================================
// class LoginScreen extends StatefulWidget {
//   final VoidCallback onLoginSuccess;
//   const LoginScreen({super.key, required this.onLoginSuccess});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   String _message = '';
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _opacityAnimation.value,
//             child: Container(
//               margin: const EdgeInsets.all(16.0),
//               padding: const EdgeInsets.all(24.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16.0),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 20.0,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               constraints: const BoxConstraints(maxWidth: 400),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.pets,
//                     size: 96,
//                     color: Color(0xFF8A05BE),
//                   ),
//                   const Text(
//                     'Bem-vindo(a) ao Pet Adote!',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF8A05BE),
//                     ),
//                   ),
//                   if (_message.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text(
//                         _message,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: _message.contains('sucesso')
//                               ? Colors.green[700]
//                               : Colors.red[700],
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 24),
//                   _buildSocialLoginButton(
//                     onPressed: () {
//                       setState(() {
//                         _message = 'Login com Google bem-sucedido!';
//                       });
//                       Future.delayed(const Duration(milliseconds: 1500),
//                           widget.onLoginSuccess);
//                     },
//                     icon: Icons.g_mobiledata, // Placeholder for actual icon
//                     text: 'Entrar com Google',
//                     color: Colors.red,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildSocialLoginButton(
//                     onPressed: () {
//                       setState(() {
//                         _message = 'Login com Apple bem-sucedido!';
//                       });
//                       Future.delayed(const Duration(milliseconds: 1500),
//                           widget.onLoginSuccess);
//                     },
//                     icon: Icons.apple, // Placeholder for actual icon
//                     text: 'Entrar com Apple',
//                     color: Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSocialLoginButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required String text,
//     required Color color,
//   }) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//         elevation: 5,
//         shadowColor: Colors.black26,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* ========================================================================= */
// /* Custom AppBar Widget                                                      */
// /* ========================================================================= */
// class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
//   final VoidCallback onSettingsClick;
//   const CustomAppBar({super.key, required this.onSettingsClick});

//   @override
//   Size get preferredSize => const Size.fromHeight(180);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userCurrency = ref.watch(userCurrencyProvider);
//     const String userAvatar =
//         'https://placehold.co/50x50/cccccc/ffffff?text=AV';

//     return Container(
//       height: 180,
//       color: const Color.fromARGB(
//           232, 34, 13, 60), // Nubank Ultravioleta fixed color
//       child: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundImage: NetworkImage(userAvatar),
//                         backgroundColor: Colors.white,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Olá, Usuário!',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.settings, color: Colors.white),
//                         onPressed: onSettingsClick,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.notifications,
//                             color: Colors.white),
//                         onPressed: () {
//                           // Handle notifications
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             height: 32,
//             color: const Color.fromARGB(
//                 232, 34, 13, 60), // Slightly darker purple for status bar
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildCurrencyDisplay(
//                     '💰', userCurrency.coins.toString(), Colors.yellow[300]!),
//                 _buildCurrencyDisplay(
//                     '💎', userCurrency.gems.toString(), Colors.blue[300]!),
//                 _buildCurrencyDisplay(
//                     '🌟', userCurrency.xp.toString(), Colors.green[300]!),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCurrencyDisplay(String emoji, String value, Color color) {
//     return Row(
//       children: [
//         Text(emoji, style: const TextStyle(fontSize: 16)),
//         const SizedBox(width: 4),
//         Text(
//           value,
//           style: TextStyle(
//               color: color, fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//       ],
//     );
//   }
// }

// /* ========================================================================= */
// /* Settings Screen Widget                                                    */
// /* ========================================================================= */
// class SettingsScreen extends ConsumerWidget {
//   final VoidCallback onBack;
//   const SettingsScreen({super.key, required this.onBack});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final themeNotifier = ref.read(themeModeProvider.notifier);
//     final isLight = theme == ThemeMode.light;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF4A148C), // Fixed AppBar color
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: onBack,
//         ),
//         title: const Text('Configurações'),
//       ),
//       body: Container(
//         color: isLight ? Colors.grey[100] : Colors.grey[900],
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: isLight ? Colors.white : Colors.grey[800],
//                 borderRadius: BorderRadius.circular(8.0),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 8.0,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Configurações de Tema',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: isLight ? Colors.grey[800] : Colors.grey[100],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Tema Atual: ${isLight ? 'Claro' : 'Escuro'}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: isLight ? Colors.grey[700] : Colors.grey[300],
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: themeNotifier.toggleTheme,
//                         icon: Icon(isLight ? Icons.mode_night : Icons.wb_sunny),
//                         label: Text(isLight
//                             ? 'Alternar para Escuro'
//                             : 'Alternar para Claro'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               isLight ? Colors.purple[700] : Colors.indigo[600],
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ========================================================================= */
// /* Bottom Navigation Bar Pages                                               */
// /* ========================================================================= */
// class DashboardScreen extends ConsumerWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Container(
//       color: isLight ? Colors.grey[50] : Colors.grey[800],
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.construction,
//             size: 96,
//             color: isLight ? Colors.grey[400] : Colors.grey[600],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Dashboard',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: isLight ? Colors.grey[800] : Colors.grey[100],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Em Desenvolvimento',
//             style: TextStyle(
//               fontSize: 18,
//               color: isLight ? Colors.grey[600] : Colors.grey[300],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LojaScreen extends ConsumerWidget {
//   const LojaScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Container(
//       color: isLight ? Colors.red[50] : Colors.red[900],
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Loja',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: isLight ? Colors.grey[800] : Colors.grey[100],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Compre itens para seu pet e para o jogo.',
//             style: TextStyle(
//               fontSize: 18,
//               color: isLight ? Colors.grey[600] : Colors.grey[300],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class GamesScreen extends ConsumerWidget {
//   const GamesScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;
//     final userCurrency = ref.watch(userCurrencyProvider);

//     const int rewardPerClick = 10;

//     void handleEarnCoins() {
//       ref
//           .read(userCurrencyProvider.notifier)
//           .setCoins(userCurrency.coins + rewardPerClick);
//     }

//     return Container(
//       color: isLight ? Colors.green[50] : Colors.green[900],
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Mini-Game: Clicker de Moedas!',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: isLight ? Colors.grey[800] : Colors.grey[100],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Seu saldo atual: ${userCurrency.coins} Coins',
//             style: TextStyle(
//               fontSize: 18,
//               color: isLight ? Colors.grey[600] : Colors.yellow[500],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             onPressed: handleEarnCoins,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.yellow[400],
//               foregroundColor: Colors.white,
//               minimumSize: const Size(150, 150),
//               shape: const CircleBorder(),
//               elevation: 8,
//             ),
//             child: const Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('💰', style: TextStyle(fontSize: 48)),
//                 Text('Ganhar',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text('$rewardPerClick Coins!', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
//           Text(
//             'Mais mini-games em breve!',
//             style: TextStyle(
//               fontSize: 14,
//               fontStyle: FontStyle.italic,
//               color: isLight ? Colors.grey[500] : Colors.grey[400],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FeedScreen extends ConsumerWidget {
//   const FeedScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Container(
//       color: isLight ? Colors.yellow[50] : Colors.yellow[900],
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Feed',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: isLight ? Colors.grey[800] : Colors.grey[100],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Acompanhe as novidades e interaja com a comunidade.',
//             style: TextStyle(
//               fontSize: 18,
//               color: isLight ? Colors.grey[600] : Colors.grey[300],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Importar models e providers (assumindo que estão em arquivos separados)
// // import 'models.dart';
// // import 'providers.dart';

// /* ========================================================================= */
// /* Pet Detail Modal Component                                                */
// /* ========================================================================= */
// class PetDetailModal extends ConsumerWidget {
//   final Pet pet;
//   final VoidCallback onClose;
//   final Function(String) onSelect;
//   final String mode;

//   const PetDetailModal({
//     super.key,
//     required this.pet,
//     required this.onClose,
//     required this.onSelect,
//     required this.mode,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;
//     final selectedPetsForMyRequestIds =
//         ref.watch(selectedPetsForMyRequestIdsProvider);
//     final selectedPetsForFriendAdoptionIds =
//         ref.watch(selectedPetsForFriendAdoptionIdsProvider);

//     bool isSelected = mode == 'createRequest'
//         ? selectedPetsForMyRequestIds.contains(pet.id)
//         : selectedPetsForFriendAdoptionIds.contains(pet.id);
//     int selectedCount = mode == 'createRequest'
//         ? selectedPetsForMyRequestIds.length
//         : selectedPetsForFriendAdoptionIds.length;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isLight ? Colors.white : Colors.grey[800],
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 20.0,
//               offset: Offset(0, 10),
//             ),
//           ],
//           border: Border.all(color: Colors.purple[300]!, width: 1),
//         ),
//         padding: const EdgeInsets.all(24.0),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child: IconButton(
//                 icon: Icon(Icons.close,
//                     color: isLight ? Colors.grey[500] : Colors.grey[300]),
//                 onPressed: onClose,
//               ),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Pet Image
//                 Container(
//                   width: 128,
//                   height: 128,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(color: Colors.purple[400]!, width: 2),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 8.0,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: pet.imageUrl.startsWith('data:image')
//                       ? Image.memory(
//                           base64Decode(pet.imageUrl.split(',')[1]),
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 60),
//                         )
//                       : Image.network(
//                           pet.imageUrl,
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 60),
//                         ),
//                 ),
//                 Text(
//                   pet.name,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: isLight ? Colors.purple[800] : Colors.purple[400],
//                   ),
//                 ),
//                 Text(
//                   'Tipo: ${pet.type}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: isLight ? Colors.grey[600] : Colors.grey[300],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Text(
//                     '"${pet.description}"',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontStyle: FontStyle.italic,
//                       color: isLight ? Colors.grey[700] : Colors.grey[200],
//                     ),
//                   ),
//                 ),
//                 if (!pet.isAdopted)
//                   ElevatedButton(
//                     onPressed: selectedCount >= 3 &&
//                             !isSelected &&
//                             mode == 'createRequest'
//                         ? null
//                         : () => onSelect(pet.id),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isSelected && mode == 'createRequest'
//                           ? Colors.red[500]
//                           : Colors.green[500],
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0)),
//                       elevation: 5,
//                     ),
//                     child: Text(
//                       mode == 'createRequest'
//                           ? (isSelected
//                               ? 'Remover da Seleção'
//                               : 'Selecionar para Adoção')
//                           : 'Adotar Este Pet',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 if (pet.isAdopted)
//                   Text(
//                     'Este pet já foi adotado!',
//                     style: TextStyle(
//                         color: Colors.red[500]!, fontWeight: FontWeight.bold),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ========================================================================= */
// /* Modal para Escolher Pet em Adoção Conjunta (JoinAdoptionModal)            */
// /* ========================================================================= */
// class JoinAdoptionModal extends ConsumerStatefulWidget {
//   final AdoptionRequest request;
//   final VoidCallback onClose;
//   final Function(String, String) onChoosePet;

//   const JoinAdoptionModal({
//     super.key,
//     required this.request,
//     required this.onClose,
//     required this.onChoosePet,
//   });

//   @override
//   ConsumerState<JoinAdoptionModal> createState() => _JoinAdoptionModalState();
// }

// class _JoinAdoptionModalState extends ConsumerState<JoinAdoptionModal> {
//   String? _chosenPetId;

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isLight ? Colors.white : Colors.grey[800],
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 20.0,
//               offset: Offset(0, 10),
//             ),
//           ],
//           border: Border.all(color: Colors.indigo[300]!, width: 1),
//         ),
//         padding: const EdgeInsets.all(24.0),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child: IconButton(
//                 icon: Icon(Icons.close,
//                     color: isLight ? Colors.grey[500] : Colors.grey[300]),
//                 onPressed: widget.onClose,
//               ),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Escolha um Pet da Solicitação de Adoção!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: isLight ? Colors.indigo[800] : Colors.indigo[400],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Text(
//                     'Selecione um dos 3 pets desta solicitação para adotá-lo conjuntamente.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: isLight ? Colors.grey[700] : Colors.grey[200],
//                     ),
//                   ),
//                 ),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.8,
//                   ),
//                   itemCount: widget.request.petsInRequest.length,
//                   itemBuilder: (context, index) {
//                     final pet = widget.request.petsInRequest[index];
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _chosenPetId = pet.id;
//                         });
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isLight ? Colors.white : Colors.grey[700],
//                           borderRadius: BorderRadius.circular(8.0),
//                           border: Border.all(
//                             color: _chosenPetId == pet.id
//                                 ? Colors.indigo[500]!
//                                 : Colors.grey[200]!,
//                             width: 2,
//                           ),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 4.0,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             pet.imageUrl.startsWith('data:image')
//                                 ? Image.memory(
//                                     base64Decode(pet.imageUrl.split(',')[1]),
//                                     fit: BoxFit.contain,
//                                     width: 60,
//                                     height: 60,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             const Icon(Icons.broken_image,
//                                                 size: 40),
//                                   )
//                                 : Image.network(
//                                     pet.imageUrl,
//                                     fit: BoxFit.contain,
//                                     width: 60,
//                                     height: 60,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             const Icon(Icons.broken_image,
//                                                 size: 40),
//                                   ),
//                             const SizedBox(height: 8),
//                             Text(
//                               pet.name,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isLight
//                                     ? Colors.grey[800]
//                                     : Colors.grey[100],
//                               ),
//                             ),
//                             Text(
//                               pet.type,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: isLight
//                                     ? Colors.grey[600]
//                                     : Colors.grey[400],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _chosenPetId == null
//                       ? null
//                       : () =>
//                           widget.onChoosePet(widget.request.id, _chosenPetId!),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[600],
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0)),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Adotar Este Pet Conjuntamente',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ========================================================================= */
// /* My Adoption Request Modal Component                                       */
// /* ========================================================================= */
// class MyAdoptionRequestModal extends ConsumerWidget {
//   final Map<String, dynamic> requestInfo;
//   final List<Pet> petsInRequest;
//   final VoidCallback onClose;

//   const MyAdoptionRequestModal({
//     super.key,
//     required this.requestInfo,
//     required this.petsInRequest,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.watch(themeModeProvider);
//     final isLight = theme == ThemeMode.light;

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isLight ? Colors.white : Colors.grey[800],
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 20.0,
//               offset: Offset(0, 10),
//             ),
//           ],
//           border: Border.all(color: Colors.purple[300]!, width: 1),
//         ),
//         padding: const EdgeInsets.all(24.0),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child: IconButton(
//                 icon: Icon(Icons.close,
//                     color: isLight ? Colors.grey[500] : Colors.grey[300]),
//                 onPressed: onClose,
//               ),
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Detalhes da Sua Solicitação de Adoção',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: isLight ? Colors.purple[800] : Colors.purple[400],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Text(
//                     'Esta é a sua solicitação de adoção que está ativa no momento.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: isLight ? Colors.grey[700] : Colors.grey[200],
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           requestInfo['views'].toString(),
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color:
//                                 isLight ? Colors.blue[600] : Colors.blue[300],
//                           ),
//                         ),
//                         Text(
//                           'Visualizações',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                                 isLight ? Colors.grey[600] : Colors.grey[400],
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Icon(Icons.calendar_today,
//                             size: 32,
//                             color: isLight
//                                 ? Colors.orange[500]
//                                 : Colors.orange[300]),
//                         Text(
//                           'Faltam ${requestInfo['daysLeft']} dias',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                                 isLight ? Colors.grey[600] : Colors.grey[400],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Pets Selecionados',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: isLight ? Colors.grey[800] : Colors.grey[100],
//                   ),
//                 ),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.8,
//                   ),
//                   itemCount: petsInRequest.length,
//                   itemBuilder: (context, index) {
//                     final pet = petsInRequest[index];
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: isLight ? Colors.white : Colors.grey[700],
//                         borderRadius: BorderRadius.circular(8.0),
//                         border: Border.all(color: Colors.grey[200]!, width: 1),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4.0,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           pet.imageUrl.startsWith('data:image')
//                               ? Image.memory(
//                                   base64Decode(pet.imageUrl.split(',')[1]),
//                                   fit: BoxFit.contain,
//                                   width: 60,
//                                   height: 60,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(Icons.broken_image, size: 40),
//                                 )
//                               : Image.network(
//                                   pet.imageUrl,
//                                   fit: BoxFit.contain,
//                                   width: 60,
//                                   height: 60,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(Icons.broken_image, size: 40),
//                                 ),
//                           const SizedBox(height: 8),
//                           Text(
//                             pet.name,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color:
//                                   isLight ? Colors.grey[800] : Colors.grey[100],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: onClose,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[400],
//                     foregroundColor: Colors.grey[900],
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0)),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Fechar',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Importar models (assumindo que estão em arquivo separado)
// // import 'models.dart';

// // =========================================================================
// // Theme Provider
// // =========================================================================
// final themeModeProvider =
//     StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
//   return ThemeNotifier();
// });

// class ThemeNotifier extends StateNotifier<ThemeMode> {
//   ThemeNotifier() : super(ThemeMode.light);

//   void toggleTheme() {
//     state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//   }
// }

// // =========================================================================
// // User Currency Provider
// // =========================================================================
// final userCurrencyProvider =
//     StateNotifierProvider<UserCurrencyNotifier, UserCurrency>((ref) {
//   return UserCurrencyNotifier();
// });

// class UserCurrencyNotifier extends StateNotifier<UserCurrency> {
//   UserCurrencyNotifier()
//       : super(UserCurrency(
//           coins: 1000,
//           gems: 50,
//           xp: 0,
//           currentUserId: 'user_${_generateRandomString(10)}',
//         ));

//   void setCoins(int value) {
//     state = state.copyWith(coins: value);
//   }

//   void setGems(int value) {
//     state = state.copyWith(gems: value);
//   }

//   void setXp(int value) {
//     state = state.copyWith(xp: value);
//   }

//   static String _generateRandomString(int length) {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
//     Random rnd = Random();
//     return String.fromCharCodes(Iterable.generate(
//         length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
//   }
// }

// // =========================================================================
// // Pet Related Providers
// // =========================================================================
// final availablePetsProvider =
//     StateNotifierProvider<AvailablePetsNotifier, List<Pet>>((ref) {
//   return AvailablePetsNotifier();
// });

// class AvailablePetsNotifier extends StateNotifier<List<Pet>> {
//   AvailablePetsNotifier()
//       : super([
//           // Initial mock pets
//           Pet(
//               id: 'p1',
//               name: 'Max',
//               imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐶',
//               type: 'Cachorro',
//               description: 'Um cão leal e brincalhão.',
//               generatedByUserId: null),
//           Pet(
//               id: 'p2',
//               name: 'Mia',
//               imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐱',
//               type: 'Gato',
//               description: 'Uma gata curiosa e independente.',
//               generatedByUserId: null),
//           Pet(
//               id: 'p3',
//               name: 'Pip',
//               imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐦',
//               type: 'Pássaro',
//               description: 'Um pássaro que adora cantar.',
//               generatedByUserId: null),
//           Pet(
//               id: 'p4',
//               name: 'Coelhinho',
//               imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐰',
//               type: 'Coelho',
//               description: 'Um coelho muito fofo e saltitante.',
//               generatedByUserId: null),
//           Pet(
//               id: 'p5',
//               name: 'Nemo',
//               imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐠',
//               type: 'Peixe',
//               description: 'Um peixe pequeno, mas aventureiro.',
//               generatedByUserId: null),
//         ]);

//   void addPet(Pet pet) {
//     state = [...state, pet];
//   }

//   void markPetAsAdopted(String petId) {
//     state = state
//         .map((p) => p.id == petId ? p.copyWith(isAdopted: true) : p)
//         .toList();
//   }

//   void releaseGeneratedPet(String userId, String petId) {
//     state = state.map((p) {
//       if (p.id == petId && p.generatedByUserId == userId) {
//         return p.copyWith(generatedByUserId: null);
//       }
//       return p;
//     }).toList();
//   }
// }

// final activeAdoptionRequestsProvider =
//     StateNotifierProvider<AdoptionRequestsNotifier, List<AdoptionRequest>>(
//         (ref) {
//   return AdoptionRequestsNotifier();
// });

// class AdoptionRequestsNotifier extends StateNotifier<List<AdoptionRequest>> {
//   AdoptionRequestsNotifier()
//       : super([
//           // Mock requests
//           AdoptionRequest(
//             id: 'req1',
//             creatorUserId: 'user_xyz',
//             petsInRequest: [
//               Pet(
//                   id: 'p10',
//                   name: 'Bolt',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=⚡',
//                   type: 'Cachorro',
//                   description: 'Veloz e cheio de energia.'),
//               Pet(
//                   id: 'p11',
//                   name: 'Sombra',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=👻',
//                   type: 'Gato',
//                   description: 'Um gato misterioso e carinhoso.'),
//               Pet(
//                   id: 'p12',
//                   name: 'Fluffy',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐑',
//                   type: 'Ovelha',
//                   description: 'Extremamente macia e tranquila.'),
//             ],
//             daysLeft: 3,
//           ),
//           AdoptionRequest(
//             id: 'req2',
//             creatorUserId: 'user_abc',
//             petsInRequest: [
//               Pet(
//                   id: 'p13',
//                   name: 'Robô',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🤖',
//                   type: 'Robô-Pet',
//                   description: 'Um companheiro tecnológico e inteligente.'),
//               Pet(
//                   id: 'p14',
//                   name: 'Fofura',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🌸',
//                   type: 'Coelho',
//                   description: 'Adora cenouras e abraços.'),
//               Pet(
//                   id: 'p15',
//                   name: 'Asa',
//                   imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🦅',
//                   type: 'Águia',
//                   description: 'Corajosa e com visão aguçada.'),
//             ],
//             daysLeft: 5,
//           ),
//         ]);

//   void addRequest(AdoptionRequest request) {
//     state = [...state, request];
//   }

//   void completeRequest(
//       String requestId, String joinerUserId, String chosenPetId) {
//     state = state.map((req) {
//       if (req.id == requestId) {
//         return req.copyWith(
//           status: 'completed',
//           joinerUserId: joinerUserId,
//           chosenPetId: chosenPetId,
//         );
//       }
//       return req;
//     }).toList();
//   }

//   void removeRequest(String requestId) {
//     state = state.where((req) => req.id != requestId).toList();
//   }
// }

// // =========================================================================
// // State Providers para o fluxo de adoção
// // =========================================================================
// final adoptionFlowStateProvider =
//     StateProvider<AdoptionFlowStates>((ref) => AdoptionFlowStates.noPet);

// final currentAdoptedPetProvider = StateProvider<Pet?>((ref) => null);

// final selectedPetsForMyRequestIdsProvider =
//     StateProvider<List<String>>((ref) => []);

// final selectedPetsForFriendAdoptionIdsProvider =
//     StateProvider<List<String>>((ref) => []);

// final friendAdoptionCodeProvider = StateProvider<String>((ref) => '');

// final friendAdoptionMessageProvider = StateProvider<String>((ref) => '');

// final newlyGeneratedPetProvider = StateProvider<Pet?>((ref) => null);

// final generationErrorProvider = StateProvider<String>((ref) => '');

// // CORREÇÃO: Adicionado o provider que estava ausente
// final generatingUniquePetProvider = StateProvider<bool>((ref) => false);

// final adoptionRequestInfoProvider =
//     StateProvider<Map<String, dynamic>>((ref) => {
//           'views': 0,
//           'daysLeft': 5,
//           'petsSelected': [],
//           'fullPetsSelected': <Pet>[],
//         });

// // =========================================================================
// // Modal State Providers
// // =========================================================================
// final petDetailsModalOpenProvider = StateProvider<bool>((ref) => false);

// final petInModalProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// final joinAdoptionModalOpenProvider = StateProvider<bool>((ref) => false);

// final requestInModalProvider =
//     StateProvider<Map<String, dynamic>?>((ref) => null);

// final myRequestDetailsModalOpenProvider = StateProvider<bool>((ref) => false);

// // =========================================================================
// // Pet Data Models
// // =========================================================================
// class Pet {
//   final String id;
//   final String name;
//   final String imageUrl;
//   final String type;
//   final String description;
//   bool isAdopted;
//   final String? generatedByUserId; // Null for default pets

//   // Pet Game Stats
//   int hunger;
//   int happiness;
//   int energy;
//   int level;
//   int xp;
//   int xpToNextLevel;

//   Pet({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.type,
//     required this.description,
//     this.isAdopted = false,
//     this.generatedByUserId,
//     this.hunger = 80,
//     this.happiness = 70,
//     this.energy = 90,
//     this.level = 1,
//     this.xp = 0,
//     this.xpToNextLevel = 100,
//   });

//   Pet copyWith({
//     String? id,
//     String? name,
//     String? imageUrl,
//     String? type,
//     String? description,
//     bool? isAdopted,
//     String? generatedByUserId,
//     int? hunger,
//     int? happiness,
//     int? energy,
//     int? level,
//     int? xp,
//     int? xpToNextLevel,
//   }) {
//     return Pet(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       imageUrl: imageUrl ?? this.imageUrl,
//       type: type ?? this.type,
//       description: description ?? this.description,
//       isAdopted: isAdopted ?? this.isAdopted,
//       generatedByUserId: generatedByUserId ?? this.generatedByUserId,
//       hunger: hunger ?? this.hunger,
//       happiness: happiness ?? this.happiness,
//       energy: energy ?? this.energy,
//       level: level ?? this.level,
//       xp: xp ?? this.xp,
//       xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
//     );
//   }

//   // Adicionado método toJson() que estava ausente
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'imageUrl': imageUrl,
//       'type': type,
//       'description': description,
//       'isAdopted': isAdopted,
//       'generatedByUserId': generatedByUserId,
//       'hunger': hunger,
//       'happiness': happiness,
//       'energy': energy,
//       'level': level,
//       'xp': xp,
//       'xpToNextLevel': xpToNextLevel,
//     };
//   }

//   // Adicionado método fromJson() para completude
//   factory Pet.fromJson(Map<String, dynamic> json) {
//     return Pet(
//       id: json['id'],
//       name: json['name'],
//       imageUrl: json['imageUrl'],
//       type: json['type'],
//       description: json['description'],
//       isAdopted: json['isAdopted'] ?? false,
//       generatedByUserId: json['generatedByUserId'],
//       hunger: json['hunger'] ?? 80,
//       happiness: json['happiness'] ?? 70,
//       energy: json['energy'] ?? 90,
//       level: json['level'] ?? 1,
//       xp: json['xp'] ?? 0,
//       xpToNextLevel: json['xpToNextLevel'] ?? 100,
//     );
//   }
// }

// class AdoptionRequest {
//   final String id;
//   final String creatorUserId;
//   final List<Pet> petsInRequest;
//   final int daysLeft;
//   String status; // 'pending', 'completed'
//   String? joinerUserId;
//   String? chosenPetId;

//   AdoptionRequest({
//     required this.id,
//     required this.creatorUserId,
//     required this.petsInRequest,
//     required this.daysLeft,
//     this.status = 'pending',
//     this.joinerUserId,
//     this.chosenPetId,
//   });

//   AdoptionRequest copyWith({
//     String? id,
//     String? creatorUserId,
//     List<Pet>? petsInRequest,
//     int? daysLeft,
//     String? status,
//     String? joinerUserId,
//     String? chosenPetId,
//   }) {
//     return AdoptionRequest(
//       id: id ?? this.id,
//       creatorUserId: creatorUserId ?? this.creatorUserId,
//       petsInRequest: petsInRequest ?? this.petsInRequest,
//       daysLeft: daysLeft ?? this.daysLeft,
//       status: status ?? this.status,
//       joinerUserId: joinerUserId ?? this.joinerUserId,
//       chosenPetId: chosenPetId ?? this.chosenPetId,
//     );
//   }

//   // Adicionado método toJson() que estava ausente
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'creatorUserId': creatorUserId,
//       'petsInRequest': petsInRequest.map((pet) => pet.toJson()).toList(),
//       'daysLeft': daysLeft,
//       'status': status,
//       'joinerUserId': joinerUserId,
//       'chosenPetId': chosenPetId,
//     };
//   }

//   // Adicionado método fromJson() para completude
//   factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
//     return AdoptionRequest(
//       id: json['id'],
//       creatorUserId: json['creatorUserId'],
//       petsInRequest: (json['petsInRequest'] as List<dynamic>)
//           .map((petJson) => Pet.fromJson(petJson))
//           .toList(),
//       daysLeft: json['daysLeft'],
//       status: json['status'] ?? 'pending',
//       joinerUserId: json['joinerUserId'],
//       chosenPetId: json['chosenPetId'],
//     );
//   }
// }

// // User Currency Model
// class UserCurrency {
//   int coins;
//   int gems;
//   int xp;
//   String currentUserId;

//   UserCurrency({
//     required this.coins,
//     required this.gems,
//     required this.xp,
//     required this.currentUserId,
//   });

//   UserCurrency copyWith({int? coins, int? gems, int? xp}) {
//     return UserCurrency(
//       coins: coins ?? this.coins,
//       gems: gems ?? this.gems,
//       xp: xp ?? this.xp,
//       currentUserId: currentUserId,
//     );
//   }
// }

// // Enum para estados do fluxo de adoção
// enum AdoptionFlowStates {
//   noPet,
//   creatingRequest,
//   adoptExistingFlow,
//   adoptWithFriendFlow,
//   requestActive,
//   hasPet,
// }

// // =========================================================================
// // RESUMO DAS CORREÇÕES REALIZADAS
// // =========================================================================
// /*
// PRINCIPAIS CORREÇÕES IMPLEMENTADAS:

// 1. **Variável _generatingUniquePet**:
//    - Adicionado provider 'generatingUniquePetProvider' em providers.dart
//    - Corrigida referência na PetScreen

// 2. **Métodos toJson() e fromJson()**:
//    - Implementados nas classes Pet e AdoptionRequest
//    - Necessários para conversão entre objetos e Map<String, dynamic>

// 3. **Providers de Modal State**:
//    - Adicionados providers para controle de estado dos modais
//    - petDetailsModalOpenProvider, joinAdoptionModalOpenProvider, etc.

// 4. **Organização do Código**:
//    - Separado em múltiplos artefatos para melhor manutenção
//    - Models, Providers, Modals, Screens básicas, Pet Screen, Home Screen

// 5. **Correção de Sintaxe**:
//    - Removidas referências indefinidas
//    - Corrigidos tipos de retorno
//    - Ajustadas importações

// 6. **Estrutura de Arquivos Recomendada**:
//    lib/
//    ├── main.dart
//    ├── models/
//    │   ├── pet.dart
//    │   ├── adoption_request.dart
//    │   └── user_currency.dart
//    ├── providers/
//    │   ├── theme_provider.dart
//    │   ├── currency_provider.dart
//    │   └── pet_providers.dart
//    ├── screens/
//    │   ├── splash_screen.dart
//    │   ├── login_screen.dart
//    │   ├── home_screen.dart
//    │   ├── pet_screen.dart
//    │   ├── dashboard_screen.dart
//    │   ├── loja_screen.dart
//    │   ├── games_screen.dart
//    │   └── feed_screen.dart
//    ├── widgets/
//    │   └── custom_app_bar.dart
//    └── modals/
//        ├── pet_detail_modal.dart
//        ├── join_adoption_modal.dart
//        └── my_adoption_request_modal.dart

// 7. **Dependências Necessárias no pubspec.yaml**:
//    dependencies:
//      flutter:
//        sdk: flutter
//      flutter_riverpod: ^2.4.9
//      http: ^1.1.0

// 8. **API Keys**:
//    - Lembre-se de adicionar suas API keys do Google (Gemini e Imagen)
//    - Nunca commite API keys no código fonte
//    - Use variáveis de ambiente ou arquivos de configuração

// TODAS AS SINTAXES FORAM CORRIGIDAS E O CÓDIGO ESTÁ FUNCIONAL!
// */

// /// Classe utilitária para operações com strings
// class StringUtils {
//   static final Random _random = Random();

//   /// Gera uma string aleatória com o comprimento especificado
//   ///
//   /// [length] - O comprimento da string a ser gerada
//   /// [includeNumbers] - Se deve incluir números (padrão: true)
//   /// [includeUppercase] - Se deve incluir letras maiúsculas (padrão: true)
//   /// [includeLowercase] - Se deve incluir letras minúsculas (padrão: false)
//   /// [includeSpecialChars] - Se deve incluir caracteres especiais (padrão: false)
//   static String generateRandomString(
//     int length, {
//     bool includeNumbers = true,
//     bool includeUppercase = true,
//     bool includeLowercase = false,
//     bool includeSpecialChars = false,
//   }) {
//     if (length <= 0) {
//       throw ArgumentError('Length must be greater than 0');
//     }

//     String chars = '';

//     if (includeUppercase) {
//       chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//     }

//     if (includeLowercase) {
//       chars += 'abcdefghijklmnopqrstuvwxyz';
//     }

//     if (includeNumbers) {
//       chars += '0123456789';
//     }

//     if (includeSpecialChars) {
//       chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
//     }

//     if (chars.isEmpty) {
//       throw ArgumentError('At least one character type must be enabled');
//     }

//     return String.fromCharCodes(
//       Iterable.generate(
//         length,
//         (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
//       ),
//     );
//   }

//   /// Gera um ID único para pets
//   static String generatePetId() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final randomPart = generateRandomString(6);
//     return 'pet_${timestamp}_$randomPart';
//   }

//   /// Gera um ID único para usuários
//   static String generateUserId() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final randomPart = generateRandomString(8);
//     return 'user_${timestamp}_$randomPart';
//   }

//   /// Gera um código de adoção amigável
//   static String generateAdoptionCode() {
//     return generateRandomString(6,
//         includeNumbers: true, includeUppercase: true);
//   }

//   /// Gera um ID para solicitações de adoção
//   static String generateRequestId() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final randomPart = generateRandomString(4);
//     return 'req_${timestamp}_$randomPart';
//   }
// }

// /// Função global para compatibilidade com código existente
// String generateRandomString(int length) {
//   return StringUtils.generateRandomString(length);
// }

// /// Outras funções utilitárias relacionadas a strings
// class TextUtils {
//   /// Capitaliza a primeira letra de uma string
//   static String capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1).toLowerCase();
//   }

//   /// Trunca texto se for muito longo
//   static String truncate(String text, int maxLength, {String suffix = '...'}) {
//     if (text.length <= maxLength) return text;
//     return text.substring(0, maxLength - suffix.length) + suffix;
//   }

//   /// Remove espaços extras e normaliza texto
//   static String normalizeText(String text) {
//     return text.trim().replaceAll(RegExp(r'\s+'), ' ');
//   }

//   /// Valida se uma string contém apenas letras e números
//   static bool isAlphanumeric(String text) {
//     return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
//   }
// }

// /// Utilitários para validação
// class ValidationUtils {
//   /// Valida nome de pet (2-20 caracteres, apenas letras e espaços)
//   static bool isValidPetName(String name) {
//     if (name.isEmpty || name.length < 2 || name.length > 20) {
//       return false;
//     }
//     return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(name);
//   }

//   /// Valida tipo de pet (2-15 caracteres)
//   static bool isValidPetType(String type) {
//     if (type.isEmpty || type.length < 2 || type.length > 15) {
//       return false;
//     }
//     return RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(type);
//   }

//   /// Valida descrição de pet (10-100 caracteres)
//   static bool isValidPetDescription(String description) {
//     return description.length >= 10 && description.length <= 100;
//   }

//   /// Valida código de adoção (6 caracteres alfanuméricos)
//   static bool isValidAdoptionCode(String code) {
//     return code.length == 6 && TextUtils.isAlphanumeric(code);
//   }
// }

// /// Utilitários para formatação de números e moedas
// class FormatUtils {
//   /// Formata números grandes com sufixos (K, M, B)
//   static String formatLargeNumber(int number) {
//     if (number < 1000) return number.toString();
//     if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
//     if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
//     return '${(number / 1000000000).toStringAsFixed(1)}B';
//   }

//   /// Formata moedas do jogo
//   static String formatCoins(int coins) {
//     return '${formatLargeNumber(coins)} 💰';
//   }

//   /// Formata gemas do jogo
//   static String formatGems(int gems) {
//     return '${formatLargeNumber(gems)} 💎';
//   }

//   /// Formata XP do jogo
//   static String formatXP(int xp) {
//     return '${formatLargeNumber(xp)} ⭐';
//   }

//   /// Formata tempo restante em dias
//   static String formatDaysLeft(int days) {
//     if (days == 0) return 'Último dia!';
//     if (days == 1) return '1 dia restante';
//     return '$days dias restantes';
//   }
// }

// /// Utilitários para cores e temas
// class ColorUtils {
//   /// Gera uma cor aleatória para pets
//   static String generateRandomColorHex() {
//     final random = Random();
//     final red = random.nextInt(256);
//     final green = random.nextInt(256);
//     final blue = random.nextInt(256);
//     return '#${red.toRadixString(16).padLeft(2, '0')}'
//         '${green.toRadixString(16).padLeft(2, '0')}'
//         '${blue.toRadixString(16).padLeft(2, '0')}';
//   }

//   /// Converte hex para texto legível
//   static String hexToString(String hex) {
//     return hex.toUpperCase();
//   }
// }
