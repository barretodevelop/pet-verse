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




apos adotar o pet a tela de chat fica com a mensagem aguardado parceiro e na do parceiro o botao adotar pet porem ja foi adotado

o botao de chat apos a adocao deveria estar na tela de cuidado do pet , para falar com o 

acho que seria interressante a pessoa poder adotar um pet e aparecer uma lista com os que precisa do segundo dono

ao cicar em meu pet deve abrir uma pagina mostrando os meus pets  o no centro o favorito que eu marcar logo o usuario podera ter ate 4 pets em cuidado 


no perfil nao atualizou a qtd de pets adotados

assim que a pessoa aceitou o convite ele teve acesso a tela de adocao e escolheu o que queria bao gostei dessa forma 


ao entrar com o google da erro ao fazer login porem entra


que tal implementar a logica de se o pet alcancar o nivel maximo os adotadores do pet destravam o perfil para o outro , talvez seja uma forma de enganjamento.



Histórico limitado (50 msgs)  ---> poder compra mais mensagens






## 🎮 Fluxo de Uso

1. **Primeiro Acesso**
   - Criar conta ou fazer login 
      --> ao fazer login no mesmo celular com conta diferente ainda sim aparece o pet do primeiro login 
      --> ao fazer login aparece uma mensagem erro de login porem , entra no app
      --> criar conta com email e senha , nao funciona erro ao fazer login tente novamente
      --> nao foi possivel fazer login sem internet - quando ja nao esta logado se ja tiver feito o login entra direto na tela e pet

     erro : Failed to decode image  --> o retorno do icone do botao e SVG entao tem que usar FlutterSVG nao ImageNEtwork
     
   - Ver tela inicial vazia

2. **Criar/Entrar em Sala**
   - Aba "Salas" → Criar Nova Sala
     --> estando offline o chat envia a mensagem e nao limpa o textbox
     --> nao existe a opção de apagar a mensagem enviada - criar
   - Compartilhar código gerado
   - Ou entrar com código recebido

3. **Adotar Pet (após formar dupla)**
   - Quando 2 pessoas na sala
   - Escolher tipo de pet juntos
         --> o funcionamento nao foi assim somente a pessoa convidade poe escolher o pet e assim que escolheu atualizou na tela do outro o ideal e que ao entra na tela de adocao , haja uma forma de esolherem junto realmente , precisa pensar nessa logica

   - Dar nome ao pet

4. **Cuidar do Pet**
   - Alimentar, brincar, dar banho
   - Ver animações e partículas
   - Status degradam com o tempo
        -- nao esta ocorrendo esta com 100 desde que fiz todos os afazeres

5. **Jogar Mini-Games**
   - Botão central (FAB) → Escolher jogo
   - Ganhar moedas baseado no score

6. **Comprar na Loja**
   - Usar moedas ganhas
     --> nao funciona nao existe o usuario e nem criou a tabela no firebase , imaginei que ao fazer login o usuario ja seria criado no firebase porem nem criou a tabela, logo toda movimentacao com COIN nao funciona


   1 - Criar conta ou fazer login 
      --> ao fazer login no mesmo celular com conta diferente ainda sim aparece o pet do primeiro login 
      --> ao fazer login aparece uma mensagem erro de login porem , entra no app
      --> criar conta com email e senha , nao funciona erro ao fazer login tente novamente
      --> nao foi possivel fazer login sem internet - quando ja nao esta logado se ja tiver feito o login entra direto na tela e pet

     erro : Failed to decode image  --> o retorno do icone do botao e SVG entao tem que usar FlutterSVG nao ImageNEtwork
     

   3. **Adotar Pet (após formar dupla)**
   - Quando 2 pessoas na sala
   - Escolher tipo de pet juntos
         --> o funcionamento nao foi assim somente a pessoa convidade poe escolher o pet e assim que escolheu atualizou na tela do outro o ideal e que ao entra na tela de adocao , haja uma forma de esolherem junto realmente , precisa pensar nessa logica

   - Dar nome ao pet

   4. **Cuidar do Pet**
   - Alimentar, brincar, dar banho
   - Ver animações e partículas
   - Status degradam com o tempo
        -- nao esta ocorrendo esta com 100 desde que fiz todos os afazeres

   6. **Comprar na Loja**
   - Usar moedas ganhas
     --> nao funciona nao existe o usuario e nem criou a tabela no firebase , imaginei que ao fazer login o usuario ja seria criado no firebase porem nem criou a tabela, logo toda movimentacao com COIN nao funciona


     outras considerações
   quero criar a economia do jogo global para o usuario , cada usuario tera sua economia no jogo e o seu inventario
   de itens que poderao usar em qualquer pet que ele esteja cuidando , o usuario tera um Slot de pets que se inicia com 4 slots que poderão se auemntado com compra de slote, o usuario podera adotar inicialmente ate 2 petz um solo e outro em co parent o usuario podera marca petz favoritos. e preciso ter o inventario do User as compras irao para o inventario , no momento de alimentar o item deve sair do inventario do usuario que execuou a ação , assim como todos os outros itens incluir na econia os tipos de moedas PETCOIN  e PETGEN que serão outras formas de pagamento. as missoes diarias nao estao funcionando , mesmo fazendo nao dao os pontos e nem atualiza a tela de missao  o jogos estao com erro , a comida nao caem , o o de pulo tambem esta ruim , diminuir tambem a scala de tamanho do itens no s jogos ,  diminuir tambem os itens na loja grid de 4x4 sera melhor   o status do pet nao esta se degradando automaticamente  , exibir informações do cuidadores na tela do pet o usuario logado exibir o Avatar o do outro um avatar com  interrogação incluir na loja itens de higiene para o banho , seguir mesma logica de comida abrir bootmsheet com os itens de higiene para a opção de banho , esse mecanismo e para toda a iteração com o pet liste todas as correções e mudancas que fara para vermos se esta correto.   






 
🏠 2. Tela Home – Lógica de Entrada

    Verificação: o usuário já possui um pet?

        Sim → Redireciona para a tela do pet principal.

        Não → Redireciona para a tela: “Você precisa adotar um pet!”

🐾 3. Tela "Você precisa adotar um pet"

    Exibe:

        Explicação do processo de adoção colaborativa.

        Botão "Explorar pets disponíveis"

        Botão "Criar pedido de adoção"

        Botão "Indicar adoção a um amigo (share)"

📜 4. Sistema de Adoção Colaborativa
4.1 Criar pedido de adoção:

Lista de pets gerados automaticamente (mock).

Usuário seleciona até 3 pets.

Ao confirmar, a solicitação entra em uma lista pública de adoções pendentes (tempo de expiração: 5 dias).

    Adição de tags no pedido: [Data criação], [ID usuário criador].

4.2 Lista pública de adoções pendentes:

Co-parent visualiza a lista.

Pode abrir qualquer pedido e ver os 3 pets disponíveis.

Escolhe 1 → Confirma → Adoção finalizada.

Ambos usuários recebem o pet nas telas.

    O “cuidador primário” recebe notificação interna.

4.3 Compartilhar solicitação de adoção:

Compartilhamento via Share Plus (link com identificador único).

Receptor pode criar conta e aceitar a adoção.

Após aceite, pet é atribuído a ambos os usuários.






FASE - 2  iniciando


🗺️ ROADMAP - LAYOUTS COM DADOS MOCK
📋 FASE 1: Telas Básicas de Adoção
1.1 Tela Lista de Adoções Anônimas

Layout de cards com dados mock
Contador de visualizações e interesse
Sistema de filtros visuais
Estados: Loading, vazio, lista cheia

1.2 Tela Detalhes da Missão

Card expandido com 3 pets
Perfil anônimo do criador
Botão "Quero Participar"
Galeria de fotos dos pets

1.3 Tela Criar Nova Adoção

Formulário de seleção de 3 pets
Preview do card que será criado
Configurações de preferências
Confirmação de criação


📱 FASE 2: Sistema de Parceria Ativa
2.1 Dashboard de Parceria

Card do pet atual com barra de progresso
Perfis anônimos dos parceiros
Botões de ação rápida
Histórico de cuidados

2.2 Tela de Chat Pré-definido

Interface com templates por categoria
Histórico de mensagens enviadas
Indicadores de status do pet
Botões de ação rápida

2.3 Tela de Progresso do Pet

Gráfico de evolução por nível
Conquistas desbloqueadas
Timeline de cuidados
Stats detalhadas


🏆 FASE 3: Sistema de Revelação
3.1 Modal de Revelação Disponível

Notificação especial de nível 10+
Explicação do sistema
Botões de aceitar/recusar
Preview do que será revelado

3.2 Tela de Parceiros Revelados

Perfis reais dos colaboradores
Chat liberado
Histórico da parceria
Opções de continuar juntos

3.3 Tela de Gerenciar Choice

Opções pós-revelação
Configurações de privacidade
Sistema de avaliação mútua


💰 FASE 4: Sistema de Penalidades
4.1 Modal de Confirmação de Desistência

Cálculo de penalidade em coins
Opções disponíveis
Consequências explicadas
Botões de confirmar/cancelar

4.2 Tela de Transição Solo

Novo status de cuidador único
Recursos extras desbloqueados
Opção de buscar novo parceiro
Timeline ajustada

4.3 Tela de Solicitar Novo Parceiro

Formulário de preferências
Card do pet atualizado
Lista de interessados
Sistema de match


🔄 FASE 5: Sistema de Recolocação
5.1 Tela de Pets Veteranos

Lista especial de pets experientes
Badges e histórico visível
Bonus XP destacado
Filtro por experiência

5.2 Modal de Devolução ao Sistema

Confirmação de devolução
Preview do status do pet
Impacto no ranking
Última chance de reconsiderar

5.3 Tela de Adoção de Pet Experiente

Layout diferenciado
Histórico de cuidados anterior
Bonus e vantagens
Responsabilidades especiais


📊 FASE 6: Dashboards e Analytics
6.1 Perfil do Usuário

Estatísticas pessoais
Badges conquistadas
Histórico de parcerias
Ranking de cuidador

6.2 Tela de Rankings

Top parceiros estáveis
Melhores tutores anônimos
Heróis da segunda chance
Stats da comunidade

6.3 Dashboard Administrativo

Métricas do sistema
Pets em andamento
Parcerias ativas
Sistema de coins


🎨 COMPONENTES REUTILIZÁVEIS
Componentes Base:

AnonymousProfileCard - Perfil anônimo
PetProgressBar - Barra de progresso
ChatTemplate - Templates de chat
PenaltyCalculator - Calculadora de multas
RevelationModal - Modal de revelação
VeteranPetCard - Card de pet experiente

Componentes de Layout:

GameHeader - Header com stats
BottomNavigation - Navegação principal
FloatingChatButton - Chat flutuante
NotificationBanner - Banners de notificação


🎯 ORDEM DE DESENVOLVIMENTO SUGERIDA
Sprint 1 (Semana 1-2):

Fase 1.1: Lista de Adoções Anônimas
Fase 1.2: Detalhes da Missão
Componentes base

Sprint 2 (Semana 3-4):

Fase 2.1: Dashboard de Parceria
Fase 2.2: Chat Pré-definido
Fase 2.3: Progresso do Pet

Sprint 3 (Semana 5-6):

Fase 3.1: Sistema de Revelação
Fase 4.1: Sistema de Penalidades
Refinamentos e ajustes

Sprint 4 (Semana 7-8):

Fase 5: Sistema de Recolocação
Fase 6: Dashboards
Polimento final





glassmorphism 3.0.0



comandos : prompt 

voce e um analista senior em desenvolvimento de sotware especialidade em games com adocao de melhores praticas de desenvolvimento e arquitetura clean com altos conhecimentos em design e modelagem de jogos,  para analisar o código e corrigir os erros encontrados  ou incrmentar funcionalidades estaremos usando a estratégia de desenvolvimento incremental.
Usar Artifacts  para cada arquivo Se o código não couber numa resposta,  usar a função update para adicionar mais partes. para evitar atingir o limite de mensagem.nao precisa enviar feeedback completo da alteração apenas se solicitado , sempre incluir  o nome e caminho do arquivo no inicio e add comentarios se e alteracao ou nova inclusao. enviar a resposta em portugues.  criar um minigame RockPaperScissors profissional com design ux 
 
erros localizados nao cria o pet no firebase 
ficara atualizando a tela dem 50 em 30 segundos sempre voltando pra home 
no fluxo esta grando o campo id do usuario porem deveria ser o campo uui 


recebi essa analise do projeto vamos seguir gerando a correção para cada arquivo e gerando os novo necessarios , oriente-me tambem dos arquivo desse fluxo que poderam ser removidos apos o novo fluxo de adocao conforme abaixo ser implantado. nao usar build runner 

RESUMO EXECUTIVO DA ANÁLISE
🎯 PROBLEMAS CRÍTICOS ENCONTRADOS:

Estado Fragmentado - 7 providers diferentes gerenciando o mesmo conceito
Falta de Sincronização - Adoção não atualiza estado local automaticamente
Race Conditions - Navegação acontece antes da sincronização
Lógica Espalhada - Decisão "o que exibir" em múltiplos lugares
Ausência de Estados Transitórios - UX ruim durante mudanças
Cache Desatualizado - Providers não invalidados após operações críticas

🚀 SOLUÇÃO IMPLEMENTADA:
✅ Provider Unificado - UnifiedUserStateProvider centraliza todo o estado
✅ Fluxo de Adoção Robusto - Com verificação de integridade e retry
✅ Estados Transitórios - Loading específico para cada etapa
✅ Invalidação em Cascata - Atualização automática de todos os providers
✅ Verificação de Integridade - Garante consistência pós-operação
✅ UX Aprimorada - Feedback claro e transições suaves
📈 BENEFÍCIOS ESPERADOS:

99% menos bugs relacionados a estado inconsistente
3x melhor UX com loading states claros
50% menos código com lógica centralizada
100% confiabilidade no fluxo de adoção
Manutenibilidade alta com arquitetura clara

⏱️ IMPLEMENTAÇÃO RECOMENDADA:
FASE 1 (CRÍTICA): 3-4 dias - Implementar provider unificado e fluxo corrigido
FASE 2 (MÉDIA): 2-3 dias - Estados transitórios e cache inteligente
FASE 3 (BAIXA): 2-3 dias - Otimizações e melhorias adicionais
FASE 4 (TESTES): 1-2 dias - Validação completa do fluxo
🎯 VALIDAÇÃO DE SUCESSO:
O fluxo estará corrigido quando:

Usuário sem pet → escolhe da lista → aceita → automaticamente vê pet na home
Zero estados inconsistentes ou conflitantes
Loading states claros em todas as transições
100% de confiabilidade na sincronização de estado