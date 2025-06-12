# petverse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.




# comandos uteis


# Para watch (recomendado durante desenvolvimento):
flutter pub run build_runner watch --delete-conflicting-outputs

# Para build único:
flutter pub run build_runner build --delete-conflicting-outputs

# Para limpar arquivos gerados:
flutter pub run build_runner clean

# Roadar os scripts no pubSpec
flutter pub run scripts watch


 



 🗺️ ROADMAP DE AJUSTES - FLUXO DE ADOÇÃO
📋 FASE 1: ESTRUTURAS BASE
1.1 Sistema de Economia do Usuário

 Criar model UserEconomy (coins, gems, xp)
 Criar providers para economia (userCoinsProvider, userGemsProvider, userXPProvider)
 Atualizar model AppUser com campos de economia
 Implementar lógica de save/load no Firestore

1.2 AppBar Customizada

 Criar CustomHomeAppBar widget
 Implementar height fixo de 80
 Adicionar cor roxa "nubank ultravioleta" fixa
 Adicionar avatar do usuário logado
 Adicionar 2 action buttons
 Criar container bottom com status (coins, gems, XP)

1.3 Sistema de Visualizações

 Adicionar campo viewCount no model AdoptionRequest
 Implementar tracking de visualizações no repository
 Criar provider para contar visualizações em tempo real


📋 FASE 2: CORREÇÃO DE LAYOUTS
2.1 Páginas Centrais Fixas
 
 Refatorar MyPetsScreen - layout fixo sem overflow
 Ajustar outras páginas do BottomNavigation para serem fixas
 Implementar FloatingActionButton central para Pet com animação

2.2 BottomNavigationBar

 Reorganizar ordem: Dashboard, Loja, Pet(FAB), Games, Feed
 Implementar Pet como FAB central com animações
 Ajustar navegação entre abas


📋 FASE 3: FLUXO "CRIAR ADOÇÃO"
3.1 Tela Intermediária de Adoção

 Criar AdoptionIntermediateScreen
 Adicionar card informativo sobre processo
 Adicionar botão "Exibir adoções em andamento"
 Adicionar botão "Solicitar nova adoção"
 Integrar no fluxo do botão "Criar"

3.2 Melhorar AdoptNewPetScreen

 Adicionar informação clara "Expira em 5 dias"
 Implementar contador regressivo visual
 Separar lógica de adoção pública vs. código de amigo
 Melhorar feedback visual pós-criação

3.3 Status de Solicitação Ativa

 Criar widget ActiveRequestStatusCard
 Exibir tempo restante dinamicamente
 Exibir número de visualizações
 Mostrar miniaturas dos 3 pets selecionados
 Adicionar botões "Ver Detalhes" e "Cancelar"


📋 FASE 4: FLUXO "ADOTAR EXISTENTE"
4.1 Melhorar Cards de Solicitação

 Refatorar AdoptionRequestCard para mostrar 3 pets
 Adicionar informações detalhadas da solicitação
 Mostrar tempo restante da solicitação
 Melhorar layout visual dos cards

4.2 Seleção de Pet Individual

 Implementar modal/tela de detalhes por pet
 Adicionar botão "Adotar Este Pet" em cada pet
 Criar confirmação de adoção específica
 Implementar feedback visual de seleção

4.3 Notificação em Tempo Real

 Implementar notificação para criador da solicitação
 Criar sistema de alertas de adoção aceita
 Configurar redirecionamento automático para ambos usuários


📋 FASE 5: FLUXO "COM AMIGO"
5.1 Criação de Código de Amigo

 Criar FriendAdoptionCreateScreen
 Implementar seleção de 3 pets (modo amigo)
 Criar geração de código curto otimizado
 Adicionar opções de compartilhamento do código

5.2 Uso de Código de Amigo

 Refatorar EnterFriendCodeScreen
 Implementar validação de código
 Mostrar os 3 pets pré-selecionados após validação
 Criar interface de escolha do pet pelo amigo

5.3 Finalização de Adoção com Amigo

 Implementar confirmação de escolha do pet
 Notificar ambos usuários da adoção
 Redirecionar para tela de cuidado colaborativo


📋 FASE 6: TELA DE CUIDADO DO PET
6.1 Interface de Cuidado

 Criar/melhorar PetCareScreen
 Implementar dados em tempo real para ambos cuidadores
 Mostrar informações do parceiro anônimo
 Adicionar ações de cuidado (alimentar, brincar, etc.)

6.2 Sistema Colaborativo

 Implementar sincronização instantânea de ações
 Criar notificações de ações do parceiro
 Adicionar histórico de cuidados compartilhado


📋 FASE 7: VALIDAÇÕES E LÓGICAS
7.1 Validação de Expiração

 Implementar auto-expiração de solicitações (5 dias)
 Criar Cloud Function para limpeza automática
 Adicionar validações no frontend

7.2 Regras de Negócio

 Validar limite de 1 solicitação ativa por usuário
 Implementar limite de 3 pets por solicitação
 Adicionar validações de estado do usuário

7.3 Tratamento de Erros

 Implementar tratamento de erros em todos os fluxos
 Adicionar fallbacks para falhas de rede
 Criar mensagens de erro amigáveis


📋 FASE 8: MELHORIAS DE UX
8.1 Animações e Transições

 Adicionar animações nos fluxos de adoção
 Implementar transições suaves entre telas
 Criar feedback visual para ações do usuário

8.2 Loading States

 Implementar loading adequado em todas as operações
 Criar skeleton screens para listas
 Adicionar progress indicators

8.3 Feedback e Confirmações

 Melhorar mensagens de sucesso/erro
 Implementar confirmações para ações críticas
 Adicionar haptic feedback


📋 FASE 9: TESTES E VALIDAÇÃO
9.1 Testes de Fluxo

 Testar fluxo completo "Criar → Adotar → Cuidar"
 Testar fluxo de código de amigo
 Validar notificações em tempo real

9.2 Testes de Edge Cases

 Testar solicitações expiradas
 Testar múltiplas tentativas de adoção
 Validar comportamento offline


📋 FASE 10: POLIMENTO FINAL
10.1 Otimizações

 Otimizar queries do Firestore
 Implementar cache inteligente
 Melhorar performance geral

10.2 Documentação

 Documentar fluxos implementados
 Criar guias de uso para desenvolvedores
 Atualizar comentários no código


🎯 PRIORIZAÇÃO SUGERIDA:
🔥 ALTA PRIORIDADE:

Fase 1.1, 1.2 (estruturas base)
Fase 3 (fluxo criar adoção)
Fase 4 (fluxo adotar existente)

⚡ MÉDIA PRIORIDADE:

Fase 2 (layouts)
Fase 5 (código de amigo)
Fase 6 (cuidado do pet)

✨ BAIXA PRIORIDADE:

Fase 7, 8, 9, 10 (validações e polimento)

Quer começar pela Fase 1.1 (Sistema de Economia)?




validar fluxo de adocao 
  baseado nessas informações crie o roadmap   para esse desenvolvimento  login --> home(appbarcustom com PreferredSize height 80 com avatar do usuario logado e dois action buttom , appbar tera cor fixa indepebndete do tema ecolhido roxo do "nubank ultravioleta" ainda dentro do appbar no bottom deve ter um container com  os status de gameuser tipo coins  , gems , xp do usuario   )

    (abaixo paginas acionadas pelo BottomNavigationBar) as paginas centrais nao devem ter rolagem devem ser fixa e sem ovrflow 

          -- > dashboard

          -- > Loja

          -- > pet (Floating in center com animacao ) 

                   se nao tem pet e (botao criar) --> tela de aodcao de Pet

                                                    --> card informativo 

                                                    --> botao exibir adocaoes em andamento 

                                                    --> solicitar nova aodcao (entra na tela para criar a solicitacao de adocao)

                                                                                --> a solicitacao de adocao duram somente 5 dias e deve ser exibido na infornmçao para o criador da solicitacao

                                                                                 --> regra para criar adocao --> selecionar 3 pets que deseja adotar para que o segundo adotador posso escolher entre um deles. 

                                                                                --> essas adocaoes deveram ser anonimas logo nao tera dados de que esta adotando , ate que o pet adotado cheque a um certo nivel onde desbloqueia o anonimato caso os dois usuarios aceitem  

                                                                                --> ao termina a solicitacao retorna e ja exibi ja tem uma solicitacao de adocao

                                                    --> gera codigo para adocao com amigo (gera um codigo e compartilha com amigo)

                    se nao tem pet e (botao Adotar) --> tela com lista adocao ja criada por outros

                                                    --exibir a lista com cards bem elaborados exibindo as informações de adocao e a imagem dos pets ao clicar em cada pet o usuario podera ver os detalhes e se acionar o botao adotar aparece a confirmacao ele ja adotara aquele pet sendo direcionad para a tela cuidado do pet o primeiro adotar e avisado os dados de cuidado do pet devem ser real time para ambos os cuidadores 

                     se nao tem pet e (botao com amigo) --> escolhe 3 pets e gera um codigo curto para ser enviado ao amigo que assim que colocar o codigo vai cair na tela com os pets esolhidos para que ele escolha 1 e comece a jornada

              se ja tem uma solicitacao de adocao --> mensagem sobre a adocao com informações da adocao tipo quando visualizcoes  

              se ja tem pet tela de cuidado do pet 

          -- > games  -minigames que sustentarao a economia do jogo

          -- > Feed  - de noticias onde podem ser compartilhado noticias postagem etc 


jogo precisa ter uma economia onde o usuario ganha coins para poder manter o cuidado do pet 







 🎯 OBJETIVO
Migrar aplicação mobile PetCare de React para Flutter + Firebase com Google Sign-in, mantendo todas funcionalidades, design e UX. Gerar projeto Flutter completo e funcional.
📋 ESPECIFICAÇÕES TÉCNICAS
Stack Obrigatória:

Flutter 3.16+ (Dart)
Firebase Auth (Google Sign-in)
Cloud Firestore (banco de dados)
Firebase Storage (imagens)
Provider/Riverpod (estado global)
GoRouter (navegação)
Animations (Lottie/Flutter built-in)


Dependências Necessárias:
yamldependencies:
  flutter: sdk: flutter
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  firebase_storage: latest
  google_sign_in: latest
  provider: latest # ou riverpod
  go_router: latest
  shared_preferences: latest
  http: latest
  cached_network_image: latest
  lottie: latest
  animations: latest
  shimmer: latest
  flutter_local_notifications: latest
🎮 FUNCIONALIDADES COMPLETAS
1. AUTENTICAÇÃO

Google Sign-in obrigatório
Avatar automático do Google
Persistência de sessão
Logout funcional

2. SISTEMA DE PETS

3 Tipos: Solo (básicos), Colaborativo (especiais), Únicos (IA)
Stats: felicidade, fome, energia, saúde (0-100)
Níveis: XP/100 = próximo nível
Sistema de morte: 5 dias sem cuidado = pet morre, usuário perde 50 XP
Devolução: custa 3 gemas
Slots: 2 iniciais + 1 a cada 5 níveis do usuário
Desbloqueio: 5 gemas por slot

3. PETS ÚNICOS COM IA

Custo: 10 gemas
Prompt do usuário → API de IA → imagem única
Configuração API: URL + Key definidos pelo usuário
Raridade: "único"
Badge especial: ✨
Missão específica: primeira geração

4. COLABORAÇÃO

Matching automático para pets colaborativos
Usuários anônimos até pet nível 5
Chat por pet colaborativo
Revelação de identidade opcional após nível 5
Avatares duplos no pet

5. ECONOMIA

Moedas: comprar pets solo e itens
Gemas: slots, devolução, pets únicos
Loja: 13 itens (comida, brinquedos, medicina, acessórios)
Inventário: categorizado

6. SISTEMA DE MISSÕES
dartList<Mission> missions = [
  Mission(id: 1, title: 'Alimentar 3 vezes', reward: 30, max: 3),
  Mission(id: 2, title: 'Brincar 5 vezes', reward: 50, max: 5),
  Mission(id: 3, title: 'Cuidar 10 vezes', reward: 40, max: 10),
  Mission(id: 4, title: 'Usar 5 itens', reward: 60, max: 5),
  Mission(id: 5, title: 'Gerar pet único', reward: 200, max: 1),
  Mission(id: 6, title: 'Alcançar Nível 5', reward: 100, max: 5),
];
7. FEED SOCIAL

Posts automáticos: adoções, mortes, níveis, colaborações, gerações IA
Timeline com ícones temáticos
Cores contextuais por tipo de evento

🎨 DESIGN & UX OBRIGATÓRIOS
Tema Dark/Light:
dartThemeData lightTheme = ThemeData(
  primarySwatch: Colors.purple,
  scaffoldBackgroundColor: Color(0xFFF8FAFC),
  // gradientes: purple-blue-teal
);
Navegação (5 tabs):

Feed (substitui colaboradores)
Missões
Pet (centro, flutuante)
Loja
Dashboard

Tela Pet - CRÍTICA:

Círculo central  com pet em um tamanho condizente com a tela
Barra XP circular ao redor (gradiente Cores ideais para exibicao de progree  )
Animações: breathing, bounce, wiggle (automáticas)
Partículas flutuantes: corações, estrelas, sparkles
Sistema humor: excited/happy/neutral/sad (baseado stats)
Stats visuais: barras coloridas com gradientes
Cards translúcidos com backdrop blur
Efeitos glow quando pet feliz

Partículas Obrigatórias:
dart// Partículas automáticas quando stats > 70%
// Partículas ao clicar em ações
// Tipos: heart (💖), star (⭐), coins (💰), sparkle (✨)
Slots de Pets:

Horizontal abaixo do app bar
Badges: nível, colaboração, únicos, acessórios
Slot bloqueado: 🔒 + gem badge podendo ser liberada sem compra com gem
Troca rápida ao clicar

🗂️ ESTRUTURA DE DADOS FIREBASE
Users Collection:
dartclass User {
  String id;
  String username;
  String avatar; // URL do Google
  String email;
  int level;
  int xp;
  int coins;
  int gems;
  DateTime createdAt;
  List<String> ownedPetIds;
  Map<String, dynamic> aiConfig; // {apiUrl, apiKey, enabled}
}
Pets Collection:
dartclass Pet {
  String id;
  String name;
  String emoji;
  String? imageUrl; // Para pets únicos
  String rarity; // comum, incomum, raro, épico, lendário, único
  String category;
  String type; // solo, collab, unique
  int level;
  int xp;
  int happiness;
  int hunger;
  int energy;
  int health;
  bool isCollab;
  bool isUnique;
  String? partnerId;
  String? partnerAvatar;
  bool identityRevealed;
  int revealLevel;
  List<Item> accessories;
  DateTime lastCared;
  DateTime adoptedAt;
  String ownerId;
  String? prompt; // Para pets únicos
  bool canInteract;
}
Inventory Collection:
dartclass InventoryItem {
  String id;
  String userId;
  Item item;
  DateTime acquiredAt;
}
Missions Collection:
dartclass UserMission {
  String id;
  String userId;
  int missionId;
  int progress;
  bool completed;
  DateTime lastUpdated;
}
Feed Collection:
dartclass FeedPost {
  String id;
  String type; // adoption, death, level_up, collaboration, unique_generation
  String content;
  String? petId;
  String userId;
  DateTime timestamp;
}
Chats Collection:
dartclass ChatMessage {
  String id;
  String petId;
  String senderId;
  String senderAvatar;
  String message;
  DateTime timestamp;
}
🎯 FUNCIONALIDADES CRÍTICAS
Sistema de Morte:  verificar uma possivel alteração na funcionalidade para talves desmaio antes da morte validar e implantar melhor fluxo 
dart// Background task: verificar pets não cuidados há 5 dias
// Mover para deadPets collection
// Penalizar usuário: -50 XP
// Post no feed
Matching System:
dart// Queue de pending adoptions
// Auto-match em background
// Notificação quando match encontrado
Geração IA:
dartFuture<Pet> generateUniqueP et(String prompt, String apiUrl, String apiKey) async {
  // HTTP request para API de IA
  // Upload imagem para Firebase Storage
  // Criar pet com imageUrl
  // Post no feed
}
Notificações:

Pet precisando cuidado
Match encontrado
Pet subiu nível
Missão completada

📱 TELAS OBRIGATÓRIAS

Splash → Login (Google) → Home
Home: 5 tabs + slots + pet central
Bottom Sheets: Adoção, Chat, Inventário, Configurações, IA
Perfil do usuário
Listas: pets ativos/mortos/devolvidos/únicos

🎨 ANIMAÇÕES OBRIGATÓRIAS

Pet breathing: scale 1.0 ↔ 1.05 (2s)
Partículas: spawn + movimento + fade
Stats bars: animated width
Barra XP: circular progress
Page transitions: slide up/fade
Hover effects: scale 1.0 → 1.05

⚙️ CONFIGURAÇÕES
Firebase Config:
dart// firebase_options.dart
// Configurar Android + iOS
// Habilitar Auth, Firestore, Storage
Google Sign-in:
dart// SHA-1 fingerprints
// OAuth 2.0 client IDs
// Configurar android/app/google-services.json
🚨 REGRAS CRÍTICAS

Mobile-first: sem scroll horizontal desnecessário
Performance: lazy loading, cached images
Offline: funcionar sem internet (cached data)
Real-time: streams para pets colaborativos
Segurança: rules do Firestore
Responsivo: adaptar a diferentes telas
Acessibilidade: semantic labels

🎯 DELIVERABLES
Gere o projeto Flutter COMPLETO com:

📁 Estrutura de pastas organizada
🔧 pubspec.yaml com todas dependências
🔥 Firebase setup completo
📱 Todas as telas funcionais
🎨 Theme system dark/light
💾 State management global
🌐 API integration (IA)
📊 Modelos de dados completos
🔔 Sistema notificações
🎬 Animações implementadas

O projeto deve ser 100% funcional e pronto para deploy na Play Store/App Store.

💡 IMPORTANTE: Manter EXATAMENTE as mesmas funcionalidades, UX e design do React original. O app deve ser viciante, profissional e com todas as mecânicas de gamificação funcionando perfeitamente.



voce agora e uma analista senior em desenvolvimento de aplicacao flutter e ira me ajudar nessa migração. Estou iniciando a migração de uma aplicação web desenvolvida em React  codigo disponivel na seja de conhecimento do porjeto , para Flutter, com o objetivo de manter 100% das funcionalidades atuais da aplicação. Já possuímos um roadmap definido disponivel tambem na seção de conhecimento para essa migração.

Requisitos principais:

Preservar toda a lógica funcional existente (fluxo de dados, integrações, estados, etc).

Recriar a interface no Flutter, aproveitando as vantagens do framework para otimizar e aprimorar o layout e a experiência do usuário, respeitando a identidade visual atual, mas com ajustes para maior responsividade e performance.

Garantir que todos os componentes da aplicação React sejam mapeados para equivalentes no Flutter, ou reconstruídos de forma a manter a usabilidade.

Seguir o roadmap já definido para etapas de migração e validação.

Preparar o código Flutter para facilitar manutenção futura e possíveis expansões.

Gostaria de sugestões detalhadas para:

Estrutura ideal do projeto Flutter considerando a complexidade da aplicação React atual.

Estratégias para manter consistência entre lógica de negócios e UI durante a migração.

Boas práticas para melhorar o layout e performance na transição para Flutter.

Possíveis desafios técnicos e como mitigá-los.   nao utilizar build runner no projeto


Ferramentas e bibliotecas recomendadas para auxiliar na migração e testes.


utilize o desenvolvimento incremental , para evitar reescrita de codigo , faça o mais otimizado possivel para evitar desperdicio de mensagem 
e evitar erro de limite de mensagem ou caracter 

seguir com a analise de todo projeto em memoria e so depois iniciar a geração de codigo para evitar atualizacao de codigo  e esquecimento de linhas ou classes  
antes de iniciar envie me uma script powershell criando toda a estrutura de pasta e arquivos na /lib
toda classe devera ter o nome da classe comentado no inicio para facilitar identifcao da mesma e em que pasta devo colocar
vamos trbalhar com paradas entao a cada 10 artefetos , solicite a continuacao , nao e necessario feedbacks , parciais , somente no final da migraçã desejo receber o feedbacks e sugestao de melhorias 
se detctar que algum fluxo possa ser melhorado ou incrementado com alguma inovação questionar a mudanca para aprovação.    





🐛 DEBUG PetCare Flutter

PROBLEMAS ATUAIS:
❌ Adoção slots não funcionam
❌ Botão IA não navega  
❌ Missões não aparecem
❌ Slots bloqueados sem dialog
⚠️ Overflow na loja
⚠️ CircleAvatar quebrado

ROTEIRO EXECUTADO:
[cole resultados dos testes acima]

PRIORIDADE: 
1. Sistema adoção
2. Missões 
3. Navegação IA
4. Dialogs confirmação

ARQUIVOS PRINCIPAIS:
- lib/widgets/pet_slots.dart
- lib/providers/mission_provider.dart  
- lib/screens/pet_screen.dart
- lib/config/app_router.dart






🐛 ROTEIRO DE DEBUG - PetCare Flutter
📋 PROBLEMAS IDENTIFICADOS
🚨 CRÍTICOS (Impedem uso básico)

❌ Slots de adoção não funcionam (onTap sem ação)
❌ Botão IA não navega para tela de geração
❌ Missões não carregam (lista vazia)
❌ Slots bloqueados sem dialog de compra de gemas

⚠️ IMPORTANTES (UX prejudicada)

⚠️ Overflow na loja (layout quebrado)
⚠️ CircleAvatar quebrado (imagens não carregam)


🔍 ROTEIRO DE TESTE SISTEMÁTICO
TESTE 1: Sistema de Adoção
1. Abrir app
2. Verificar slots horizontais no topo
3. Clicar em slot vazio (ícone +)
   ❌ ESPERADO: Abrir BottomSheet de adoção
   ❌ ATUAL: Nada acontece
4. Verificar console para erros
TESTE 2: Botão IA
1. Na tela Pet (centro)
2. Clicar "Gerar Pet Único com IA"
   ❌ ESPERADO: Navegar para AIGenerationScreen
   ❌ ATUAL: Nada acontece
3. Verificar se rota existe
TESTE 3: Sistema de Missões
1. Ir para tab "Missões"
2. Verificar se lista aparece
   ❌ ESPERADO: 6 missões com progresso
   ❌ ATUAL: Lista vazia
3. Verificar provider de missões
TESTE 4: Slots Bloqueados
1. Verificar slot com ícone 🔒
2. Clicar no slot bloqueado
   ❌ ESPERADO: Dialog "Desbloquear slot por 5 gemas"
   ❌ ATUAL: Nada acontece
TESTE 5: Loja (Overflow)
1. Ir para tab "Loja"
2. Verificar layout dos itens
   ⚠️ PROBLEMA: Texto cortado, overflow
TESTE 6: Avatares
1. Verificar avatar do usuário no header
2. Verificar avatares em pets colaborativos
   ⚠️ PROBLEMA: Imagens quebradas/não carregam

🔧 DIAGNÓSTICO RÁPIDO
Executar estes comandos:
dart// 1. Verificar providers inicializados
print('User: ${ref.read(userProvider)}');
print('Missions: ${ref.read(missionProvider)}');
print('Pets: ${ref.read(petProvider)}');

// 2. Verificar rotas registradas
print('Routes: ${GoRouter.of(context).routeInformationParser}');

// 3. Verificar callbacks de onTap
print('PetSlots onTap callback: ${widget.onSlotClick}');

🛠️ CORREÇÕES PRINCIPAIS
CORREÇÃO 1: PetSlots onTap
dart// lib/widgets/pet_slots.dart - Linha ~60
GestureDetector(
  onTap: () {
    if (pet != null) {
      ref.read(appProvider.notifier).setActivePetIndex(index);
    } else if (!isLocked) {
      // ❌ PROBLEMA: onSlotClick pode estar null
      onSlotClick?.call(); // Adicionar null safety
    } else {
      // ❌ PROBLEMA: Falta implementação para slot bloqueado
      _showUnlockDialog(context, ref);
    }
  },
)

// Adicionar método:
void _showUnlockDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Desbloquear Slot'),
      content: Text('Deseja desbloquear por 5 gemas?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(onPressed: () {
          // Implementar lógica de compra
          Navigator.pop(context);
        }, child: Text('Comprar')),
      ],
    ),
  );
}
CORREÇÃO 2: Navegação IA
dart// lib/screens/pet_screen.dart - Botão IA
ElevatedButton.icon(
  onPressed: () {
    // ❌ PROBLEMA: Falta implementação de navegação
    context.push('/ai-generation'); // Adicionar navegação
  },
  icon: const Icon(Icons.auto_awesome),
  label: const Text('Gerar Pet Único com IA'),
)
CORREÇÃO 3: Inicialização Missões
dart// lib/providers/mission_provider.dart
class MissionNotifier extends StateNotifier<List<MissionModel>> {
  MissionNotifier() : super([]) {
    _initializeMissions(); // ❌ FALTANDO: Inicialização
  }

  void _initializeMissions() {
    state = Constants.defaultMissions;
  }
}
CORREÇÃO 4: HomeScreen - onSlotClick
dart// lib/screens/home_screen.dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showAdoption = false; // ❌ FALTANDO: Estado para controlar modal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PetSlots(onSlotClick: () => setState(() => _showAdoption = true)), // ❌ FALTANDO: Callback
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      // ❌ FALTANDO: Modal de adoção
      body: Stack(
        children: [
          // ... conteúdo atual
          AdoptionFlow(
            show: _showAdoption,
            onClose: () => setState(() => _showAdoption = false),
          ),
        ],
      ),
    );
  }
}

📁 ARQUIVOS PARA VERIFICAR/CORRIGIR
PRIORIDADE 1 (Críticos):
lib/screens/home_screen.dart - Adicionar AdoptionFlow
lib/widgets/pet_slots.dart - Corrigir onTap + dialog
lib/providers/mission_provider.dart - Inicializar missões
lib/config/app_router.dart - Verificar rotas IA
PRIORIDADE 2 (Importantes):
lib/screens/shop_screen.dart - Corrigir overflow
lib/widgets/pet_circle.dart - Corrigir CircleAvatar
lib/screens/pet_screen.dart - Adicionar navegação IA

🧪 SCRIPT DE TESTE COMPLETO
dart// test_script.dart - Executar no projeto
import 'package:flutter/material.dart';

void debugApp(WidgetRef ref, BuildContext context) {
  print('=== DEBUG PETCARE ===');
  
  // Teste 1: Providers
  final user = ref.read(userProvider);
  final missions = ref.read(missionProvider);
  final pets = ref.read(petProvider);
  
  print('User: ${user?.username ?? "NULL"}');
  print('Missions count: ${missions.length}');
  print('Pets count: ${pets.length}');
  
  // Teste 2: Rotas
  try {
    context.push('/ai-generation');
    print('✅ Rota IA OK');
  } catch (e) {
    print('❌ Rota IA ERROR: $e');
  }
  
  // Teste 3: Constantes
  print('Default missions: ${Constants.defaultMissions.length}');
  print('Shop items: ${Constants.shopItems.length}');
  
  print('=== FIM DEBUG ===');
}

✅ CHECKLIST DE CORREÇÕES
Para executar na próxima conversa:
□ Corrigir PetSlots onTap (adoção + slot bloqueado)
□ Adicionar AdoptionFlow ao HomeScreen  
□ Inicializar missões no MissionProvider
□ Corrigir navegação para tela IA
□ Verificar/corrigir rotas no app_router.dart
□ Corrigir overflow na loja
□ Corrigir CircleAvatar quebrado
□ Testar cada funcionalidade individualmente
□ Verificar console para erros
□ Validar navegação entre telas

🎯 COMANDO PARA PRÓXIMA CONVERSA
Cole exatamente isto:
🐛 DEBUG PetCare Flutter

PROBLEMAS ATUAIS:
❌ Adoção slots não funcionam
❌ Botão IA não navega  
❌ Missões não aparecem
❌ Slots bloqueados sem dialog
⚠️ Overflow na loja
⚠️ CircleAvatar quebrado

ROTEIRO EXECUTADO:
[cole resultados dos testes acima]

PRIORIDADE: 
1. Sistema adoção
2. Missões 
3. Navegação IA
4. Dialogs confirmação

ARQUIVOS PRINCIPAIS:
- lib/widgets/pet_slots.dart
- lib/providers/mission_provider.dart  
- lib/screens/pet_screen.dart
- lib/config/app_router.dart