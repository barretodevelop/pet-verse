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


# 🚨 SECURITY AUDIT - Operações Inseguras Identificadas

## OPERAÇÕES CRÍTICAS INSEGURAS:

### 1. lib/services/firestore_service.dart - updateUser()
❌ PROBLEMA:
  - Qualquer usuário pode alterar coins/gems de qualquer outro
  - Sem validação server-side
  - Operação direta: updateUser(userId, {'coins': newAmount})

### 2. lib/providers/user_provider.dart - updateCoins/updateGems
❌ PROBLEMA:
  - Cliente controla valores de economia
  - Sem verificação de transação válida
  - Possível exploitar para gemas/coins infinitas

### 3. lib/services/firestore_service.dart - createPet/updatePet
❌ PROBLEMA:
  - Usuário pode criar pets para outros usuários
  - Sem validação de ownership
  - Stats de pets podem ser manipulados

### 4. Inventory Operations
❌ PROBLEMA:
  - addUserInventoryItem() sem verificação de compra
  - removeUserInventoryItem() sem validação de posse
  - Usuário pode adicionar itens sem pagar

### 5. Mission Progress
❌ PROBLEMA:
  - updateMissionProgress() pode ser chamado diretamente
  - Sem validação server-side de progresso real
  - Possible exploits para recompensas

## FIRESTORE COLLECTIONS SEM RULES:
- /users/{userId} - Completamente aberta
- /pets/{petId} - Sem ownership validation  
- /users/{userId}/inventory/{itemId} - Sem protection
- /feed/{postId} - Qualquer um pode postar
- /chats/{messageId} - Sem validation de pet ownership

## PRÓXIMAS AÇÕES:
1. Implementar Firestore Security Rules
2. Criar server-side validation functions
3. Refactor client code para usar secure operations
4. Implementar transaction-based operations


🚀 Plano de Correções PetCare - Roadmap Detalhado
📅 CRONOGRAMA GERAL (16 semanas)
┌─ FASE 1: P0 CRÍTICO (6 semanas) ─┐
│  Week 1-2: Setup & Security      │
│  Week 3-4: Core Features Fix     │  
│  Week 5-6: Testing & Validation  │
└───────────────────────────────────┘

┌─ FASE 2: P1 QUALIDADE (4 semanas) ─┐
│  Week 7-8: Error Handling & Performance │
│  Week 9-10: UX & Offline Support       │
└─────────────────────────────────────────┘

┌─ FASE 3: P2 MELHORIAS (4 semanas) ─┐
│  Week 11-12: Analytics & Monitoring │
│  Week 13-14: Performance & Polish   │
└──────────────────────────────────────┘

┌─ FASE 4: DEPLOY (2 semanas) ─┐
│  Week 15-16: Production Ready │
└────────────────────────────────┘

🔴 FASE 1: P0 - CRÍTICO (6 semanas)
📋 Sprint 1: Security & Infrastructure (Semanas 1-2)
Semana 1: Firestore Security
yamlTarefas:
  1.1: Implementar Firestore Security Rules
    - Arquivo: firestore.rules
    - Rules para users, pets, inventory, chats
    - Validação server-side de operações críticas
    - Tempo: 3 dias
    
  1.2: Audit de Security Issues
    - Revisar todas operações do FirestoreService
    - Implementar validações de ownership
    - Remover operações inseguras
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Usuário só pode editar seus próprios dados
  ✅ Operações de coins/gems validadas server-side
  ✅ Tests de security passando
Semana 2: Background Service
yamlTarefas:
  2.1: Implementar Background Service Real
    - Arquivo: lib/services/background_service.dart
    - WorkManager para Android / Background App Refresh iOS
    - Verificação de pets em risco a cada 4h
    - Tempo: 4 dias
    
  2.2: Push Notifications Setup
    - FCM configuration
    - Notificações de pet em risco (24h, 12h, 6h antes da morte)
    - Notificações de match encontrado
    - Tempo: 1 dia

Critério de Aceitação:
  ✅ App verifica pets mesmo fechado
  ✅ Usuário recebe notificações de alerta
  ✅ Sistema funciona offline-to-online
📋 Sprint 2: Core Features Fix (Semanas 3-4)
Semana 3: IA Service Real
yamlTarefas:
  3.1: Implementar IA Integration Real
    - Integração com Stability AI ou OpenAI DALL-E
    - Sistema de fallback se API falhar
    - Refund automático se geração falhar
    - Tempo: 3 dias
    
  3.2: Pet Generation Pipeline
    - Prompt processing + validation
    - Image upload para Firebase Storage
    - Metadata generation (name, stats)
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Gera imagem real baseada no prompt
  ✅ Refund automático em caso de falha
  ✅ Pets únicos têm imagens personalizadas
Semana 4: Matching System Real
yamlTarefas:
  4.1: Queue de Matching Real
    - Coleção 'pending_adoptions' no Firestore
    - Algoritmo de matching por preferências
    - Sistema de timeout (24h)
    - Tempo: 3 dias
    
  4.2: Real User Matching
    - Matching entre usuários reais
    - Sistema de notificação de match
    - Fallback para bot após 24h
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Usuários reais fazem match entre si
  ✅ Sistema transparente sobre bots vs humanos
  ✅ Queue funciona corretamente
📋 Sprint 3: Testing & Validation (Semanas 5-6)
Semana 5: Testes Críticos
yamlTarefas:
  5.1: Unit Tests para Core Services
    - PetCareService tests (morte, XP, stats)
    - AuthService tests (login flow)
    - FirestoreService tests (CRUD operations)
    - Tempo: 3 dias
    
  5.2: Widget Tests para Telas Principais
    - PetScreen tests
    - ShopScreen tests  
    - MissionsScreen tests
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ 70%+ code coverage em services críticos
  ✅ Todos os happy paths testados
  ✅ CI pipeline executando testes
Semana 6: Integration Tests
yamlTarefas:
  6.1: E2E Tests para Fluxos Críticos
    - Login → Adotar Pet → Cuidar → Level Up
    - Comprar Item → Usar Item → Verificar Stats
    - Pet Morte → Verificar Penalidade
    - Tempo: 3 dias
    
  6.2: Performance Tests
    - Memory leak detection
    - Loading time benchmarks
    - Database query optimization
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Fluxos principais funcionam end-to-end
  ✅ Sem memory leaks detectados
  ✅ Performance dentro de benchmarks

🟡 FASE 2: P1 - QUALIDADE (4 semanas)
📋 Sprint 4: Error Handling & Performance (Semanas 7-8)
Semana 7: Error Handling Robusto
yamlTarefas:
  7.1: Global Error Handler
    - Arquivo: lib/core/error_handler.dart
    - Try-catch com retry logic
    - User-friendly error messages
    - Tempo: 2 dias
    
  7.2: Network Error Recovery
    - Retry mechanism para network calls
    - Offline queue para operações
    - Connection status monitoring
    - Tempo: 3 dias

Critério de Aceitação:
  ✅ Errors são handled gracefully
  ✅ Retry automático para operações críticas
  ✅ UX clara sobre status de conexão
Semana 8: Memory & Performance Fixes
yamlTarefas:
  8.1: Provider Memory Leak Fixes
    - Audit todos os StreamSubscriptions
    - Implementar proper disposal
    - Memory profiling
    - Tempo: 3 dias
    
  8.2: Performance Optimization
    - Lazy loading para listas grandes
    - Image caching optimization
    - Database query optimization
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Zero memory leaks detectados
  ✅ App startup < 3 segundos
  ✅ Smooth scrolling em listas grandes
📋 Sprint 5: UX & Offline Support (Semanas 9-10)
Semana 9: Offline Support
yamlTarefas:
  9.1: Offline-First Architecture
    - Local SQLite cache
    - Sync queue para operações offline
    - Conflict resolution strategy
    - Tempo: 4 dias
    
  9.2: Offline UX
    - Connection status indicator
    - Offline mode feedback
    - Sync progress indication
    - Tempo: 1 dia

Critério de Aceitação:
  ✅ App funciona totalmente offline
  ✅ Sync automático quando online
  ✅ Conflicts resolvidos corretamente
Semana 10: Acessibilidade
yamlTarefas:
  10.1: Semantic Labels
    - Todas imagens com semanticLabel
    - Buttons com semantic meanings
    - Navigation accessibility
    - Tempo: 2 dias
    
  10.2: Contrast & High Contrast Support
    - Verificar contrast ratios (WCAG AA)
    - High contrast theme variant
    - Font scaling support
    - Tempo: 3 dias

Critério de Aceitação:
  ✅ Screen reader navigation funcional
  ✅ WCAG AA compliance
  ✅ High contrast mode disponível

🟢 FASE 3: P2 - MELHORIAS (4 semanas)
📋 Sprint 6: Analytics & Monitoring (Semanas 11-12)
Semana 11: Crash Reporting & Logging
yamlTarefas:
  11.1: Firebase Crashlytics Integration
    - Setup Crashlytics
    - Custom crash logging
    - Performance monitoring
    - Tempo: 2 dias
    
  11.2: Analytics Implementation
    - Firebase Analytics events
    - User behavior tracking
    - Business metrics tracking
    - Tempo: 3 dias

Critério de Aceitação:
  ✅ Crashes são automaticamente reportados
  ✅ Key metrics sendo tracked
  ✅ Performance metrics disponíveis
Semana 12: Advanced Logging
yamlTarefas:
  12.1: Structured Logging
    - Logger service com levels
    - Remote logging para debug
    - Log aggregation
    - Tempo: 2 dias
    
  12.2: Debug Tools
    - Debug menu em development
    - Performance overlay
    - State inspection tools
    - Tempo: 3 dias

Critério de Aceitação:
  ✅ Logs estruturados e searchable
  ✅ Debug tools para desenvolvimento
  ✅ Production debugging capability
📋 Sprint 7: Polish & Optimization (Semanas 13-14)
Semana 13: Responsividade Completa
yamlTarefas:
  13.1: Responsive Layout System
    - Breakpoints para tablet/desktop
    - Adaptive font scaling
    - Orientation support
    - Tempo: 3 dias
    
  13.2: Advanced Animations
    - Hero animations
    - Shared element transitions
    - Micro-interactions polish
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ Layout adapta para todas telas
  ✅ Animations polished e smooth
  ✅ Orientation changes handled
Semana 14: IAP Implementation
yamlTarefas:
  14.1: In-App Purchases Setup
    - Google Play Billing / App Store Connect
    - Purchase flow implementation
    - Receipt validation
    - Tempo: 4 dias
    
  14.2: Monetization Features
    - Gem purchase packages
    - Subscription model (optional)
    - Purchase restoration
    - Tempo: 1 dia

Critério de Aceitação:
  ✅ Usuários podem comprar gemas
  ✅ Purchases são validados server-side
  ✅ Purchase restoration funciona

🚀 FASE 4: PRODUÇÃO (2 semanas)
📋 Sprint 8: Production Ready (Semanas 15-16)
Semana 15: Production Setup
yamlTarefas:
  15.1: Environment Configuration
    - Production Firebase project
    - Release build optimization
    - Security audit final
    - Tempo: 2 dias
    
  15.2: App Store Preparation
    - App icons todas as resoluções
    - Screenshots e metadata
    - Privacy policy & terms
    - Tempo: 2 dias
    
  15.3: CI/CD Pipeline
    - GitHub Actions / GitLab CI
    - Automated testing
    - Release automation
    - Tempo: 1 dia

Critério de Aceitação:
  ✅ Build release sem warnings
  ✅ All app store requirements met
  ✅ CI/CD pipeline funcionando
Semana 16: Launch Preparation
yamlTarefas:
  16.1: Final Testing
    - QA testing em devices reais
    - Performance testing final
    - Security penetration testing
    - Tempo: 3 dias
    
  16.2: Soft Launch Preparation
    - Monitoring dashboards
    - Support documentation
    - Rollback procedures
    - Tempo: 2 dias

Critério de Aceitação:
  ✅ QA signoff completo
  ✅ Monitoring setup
  ✅ Ready for app store submission

📊 RECURSOS NECESSÁRIOS
👥 Equipe Recomendada

1 Flutter Developer Senior (Lead)
1 Flutter Developer Mid (Support)
1 Backend/Firebase Specialist (Part-time)
1 QA Engineer (Weeks 5-6, 15-16)

🛠️ Ferramentas Necessárias

Testing: flutter_test, integration_test, mockito
Performance: flutter_driver, firebase_performance
Monitoring: firebase_crashlytics, firebase_analytics
Background: workmanager, flutter_background_service
Offline: sqflite, connectivity_plus
IAP: in_app_purchase

💰 Estimativa de Custos

Development: 16 semanas × 2 devs = 32 person-weeks
Firebase: ~$50/mês (desenvolvimento + teste)
AI API: ~$100/mês (teste de integração)
App Store: $99 (iOS) + $25 (Google Play)
Testing Devices: ~$1000 (Android + iOS devices)


🎯 MARCOS CRÍTICOS
🚩 Milestone 1: Security & Background (Semana 2)
Critério: App seguro + background service funcionando
Validação: Pets não morrem inesperadamente, dados protegidos
🚩 Milestone 2: Real Features (Semana 4)
Critério: IA real + matching real implementados
Validação: Features não são mais simulações
🚩 Milestone 3: Quality Gate (Semana 6)
Critério: Testes passando + performance aceitável
Validação: Ready para testing interno
🚩 Milestone 4: Production Ready (Semana 16)
Critério: App store submission ready
Validação: All requirements met

⚠️ RISCOS E MITIGAÇÕES
🔴 RISCOS ALTOS

IA API Integration Complexity

Risco: APIs podem ser complexas ou caras
Mitigação: Testar APIs na semana 1, ter fallback plan


Background Service iOS Limitations

Risco: iOS restringe background processing
Mitigação: Usar push notifications como backup


Performance Degradation

Risco: Correções podem afetar performance
Mitigação: Benchmark em cada sprint



🟡 RISCOS MÉDIOS

Firebase Costs Escalation

Mitigação: Monitoring de usage, optimization


App Store Approval Delays

Mitigação: Submit 1 semana antes do deadline




📋 PRÓXIMOS PASSOS IMEDIATOS
🚀 Para Começar HOJE:
1. Setup do Ambiente (Dia 1)
bash# Criar branch para correções
git checkout -b feature/p0-critical-fixes

# Setup Firebase Security Rules
mkdir firebase
touch firebase/firestore.rules
2. Audit de Security (Dia 1-2)
yamlChecklist Imediato:
  □ Revisar lib/services/firestore_service.dart
  □ Identificar operações inseguras (updateUser, etc)
  □ Documentar todas as operations que precisam validation
  □ Criar lista de Firestore rules necessárias
3. Background Service Research (Dia 2-3)
yamlResearch Tasks:
  □ Estudar workmanager package
  □ Testar background processing no Android/iOS
  □ Documentar limitações de cada platform
  □ Criar POC de notification scheduling
4. Team Setup (Dia 3-5)
yamlPreparation:
  □ Definir team roles e responsibilities
  □ Setup development environment padrão
  □ Criar board do projeto (Jira/Trello)
  □ Schedule daily standups

📈 CRITÉRIOS DE SUCESSO
🎯 Objetivos Mensuráveis
Fim da Fase 1 (P0)

✅ Zero features simuladas/fake
✅ Background service 99% uptime
✅ Security audit clean
✅ 70%+ test coverage

Fim da Fase 2 (P1)

✅ <1% crash rate
✅ App funciona 100% offline
✅ WCAG AA compliance
✅ <3s startup time

Fim da Fase 3 (P2)

✅ Full analytics implementation
✅ IAP working
✅ Responsive em todos devices
✅ Production monitoring ativo

Production Launch

✅ App store approval
✅ <5% churn rate primeira semana
✅ >4.0 rating nas stores
✅ Zero security incidents


🔄 PROCESSO DE EXECUÇÃO
📅 Daily Routine

09:00: Daily standup (15min)
09:15-12:00: Deep work
14:00-17:00: Development + code review
17:00: Progress update no board

📊 Weekly Review

Sexta 16:00: Sprint review
Milestone check: Red/Green status
Risk assessment: Novos riscos identificados
Next week planning: Ajustes no roadmap

🚨 Escalation Process

Blocker > 24h: Escalate para lead
Milestone at risk: Emergency planning session
Major technical issue: All-hands technical review


💡 RECOMENDAÇÃO FINAL
COMEÇAR IMEDIATAMENTE com a Fase 1 - Sprint 1 (Security & Infrastructure).
Ordem de execução é crítica - não pular etapas pois existe dependência entre as correções.
Success metrics devem ser trackados semanalmente para garantir progresso mensurável.
Este plano transforma o projeto de "5.4/10" para "produção ready" em 16 semanas com risco controlado.

 ESTRUTURA DO PLANO: 16 SEMANAS
🔴 FASE 1: P0 CRÍTICO (6 semanas)
Bloqueadores que impedem produção

Semanas 1-2: Security + Background Service real
Semanas 3-4: IA real + Matching real (eliminar features fake)
Semanas 5-6: Testes críticos + validação

🟡 FASE 2: P1 QUALIDADE (4 semanas)
Problemas que afetam estabilidade

Semanas 7-8: Error handling + Memory leaks
Semanas 9-10: Offline support + Acessibilidade

🟢 FASE 3: P2 MELHORIAS (4 semanas)
Features que melhoram UX

Semanas 11-12: Analytics + Monitoring
Semanas 13-14: Responsividade + IAP

🚀 FASE 4: PRODUÇÃO (2 semanas)
Preparação final

Semanas 15-16: App store + Launch prep