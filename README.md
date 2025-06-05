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