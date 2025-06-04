Roadmap de Desenvolvimento: ComPets - Amigos para Cuidar (Revisão Detalhada)
Este roadmap descreve as fases de desenvolvimento planejadas para o aplicativo ComPets, desde o MVP Real até funcionalidades mais avançadas e pós-lançamento, incorporando os feedbacks e detalhes fornecidos.

Visão Geral do Produto
ComPets é um jogo mobile de pet virtual colaborativo onde dois jogadores (inicialmente anônimos ou amigos por código) se unem para adotar e cuidar de um animal de estimação digital. O foco é na cooperação, responsabilidade compartilhada, engajamento progressivo para conhecer o parceiro (no caso de adoção anônima) e na criação de laços entre os jogadores e seus pets virtuais.

Fases do Desenvolvimento
MVP Real (Fase 1 de Desenvolvimento)
Objetivo: Lançar uma versão funcional com o core loop do jogo, fluxo de adoção detalhado, persistência de dados essenciais e uma interface de usuário polida.

1. Configuração e Base do Projeto:
* Estrutura do projeto Flutter.
* Configuração inicial do Firebase (Authentication, Firestore, Analytics, Messaging).
* Inclusão das dependências principais (Riverpod, google_fonts, flutter_animate, cloud_firestore, firebase_auth, firebase_analytics, firebase_messaging, cached_network_image, go_router, shared_preferences, google_sign_in, sign_in_with_apple).

2. Autenticação de Usuário:
* Login com Google.
* Login com Apple (Sign in with Apple).
* Armazenamento seguro dos dados do usuário no Firebase Authentication e perfil básico no Firestore.

3. Gerenciamento de Tema e Configurações:
* Tema claro com AppBar roxa (tom "Nubank Ultravioleta") e tema escuro.
* Persistência da escolha do tema (shared_preferences).
* Tela de Perfil/Configurações:
* Botão de Logout.
* Opção para alternar tema.
* Opção para ligar/desligar funcionalidade de ciclo dia/noite (a funcionalidade em si será desenvolvida na próxima fase, mas o toggle pode existir).

4. Fluxo de Adoção Colaborativa Detalhado:
* Tela Inicial de Adoção (para usuários sem pet):
* Opção 1: "Ver lista de pets aguardando um parceiro" -> Direciona para lista filtrada.
* Opção 2: "Adotar um novo pet" -> Direciona para seleção de pets disponíveis.
* Opção 3: "Inserir código de amigo" -> Campo para inserir código e, se válido, tela de confirmação para aceitar a adoção com o amigo.
* Mecânica de Adoção (Novo Pet):
* Primeiro jogador seleciona 3 pets que gostou de uma lista de disponíveis.
* A "solicitação de adoção" com esses 3 pets fica pendente e visível na lista de "pets aguardando parceiro".
* Mecânica de Adoção (Juntar-se):
* Segundo jogador (anônimo ou amigo com código) visualiza a solicitação.
* Card da solicitação pendente exibe os 3 pets escolhidos pelo primeiro jogador (ex: lista horizontal pequena).
* Ao clicar em cada um dos 3 pets, o segundo jogador pode ver detalhes básicos.
* Segundo jogador escolhe 1 dos 3 pets para adotar. Adoção é concluída.
* Geração de Código para Amigo:
* Após o primeiro jogador selecionar os 3 pets, o sistema gera um código único.
* O primeiro jogador pode compartilhar este código com um amigo.
* O amigo insere o código (Opção 3 acima) e vê os 3 pets para escolher um.
* Adoção Anônima: Por padrão, se um jogador se junta a uma adoção da lista pública, os perfis são inicialmente anônimos (apenas avatares genéricos ou gerados).

5. Tela Principal do Pet (Home):
* Estrutura: AppBar e BottomNavigationBar.
* BottomNavigationBar (5 itens):
* Pet: Tela principal com o pet.
* Dashboard: (Design inicial, funcionalidade básica a ser definida, ex: resumo das necessidades, log de atividades).
* FloatingActionButton (Games): Botão central para acesso futuro a minijogos (inicialmente pode estar desabilitado ou levar a uma tela "Em breve").
* Loja: (Design inicial, funcionalidade básica a ser definida, ex: itens de customização "Em breve").
* Feed/Social: (Design inicial, funcionalidade básica a ser definida, ex: log de atividades do pet, interações com parceiro "Em breve").
* Página do Pet (Item "Pet" do BottomNav):
* Mensagem de boas-vindas do pet na primeira vez que a dupla acessa a tela após a adoção.
* Exibição do pet adotado (com animações básicas usando flutter_animate).
* Parceiro de Cuidados:
* Se adoção por código de amigo: Exibe avatar (se disponível do Google/Apple) e nome do amigo.
* Se adoção anônima: Exibe um avatar genérico/temático para o parceiro. Haverá um indicador ou pequena interação para sugerir o engajamento e o futuro desbloqueio do perfil.
* Barras de necessidades básicas do pet (Fome, Carinho, Diversão) – dados lidos e atualizados no Cloud Firestore.
* Ações básicas com o pet (Alimentar, Cuidar, Brincar) que afetam as barras de necessidades e são salvas no Firestore.
* AppBar: Exibirá o avatar do usuário logado e o nome do pet (ou nome do app).

6. Interface do Usuário e UX:
* Design limpo, amigável e com foco na experiência do usuário.
* Uso de google_fonts para tipografia.
* Uso de cached_network_image para avatares.
* Feedback visual para ações: BottomSheet para algumas interações (ex: detalhes do pet antes de adotar), SnackBar para confirmações rápidas.
* Navegação gerenciada por go_router.

7. Tecnologias Chave para o MVP Real:
* Flutter
* Riverpod (Gerenciamento de Estado)
* Cloud Firestore (Persistência de dados de pets, usuários, adoções)
* Firebase Authentication (Google, Apple)
* Firebase Analytics (Monitoramento básico de eventos)
* Firebase Messaging (Configuração inicial para futuras notificações)
* flutter_animate (Animações)
* google_fonts (Tipografia)
* cached_network_image (Cache de imagens)
* go_router (Roteamento)
* shared_preferences (Preferências locais como tema)
* google_sign_in, sign_in_with_apple
* (Considerar push_notifications ou flutter_local_notifications para a configuração inicial de notificações)

Fase 2: Aprofundamento e Engajamento
Objetivo: Tornar a experiência do pet mais imersiva e interativa, e fortalecer o laço entre os cuidadores.

Aprimoramento das Necessidades e Comportamento do Pet:

Lógica para as necessidades do pet diminuírem com o tempo de forma balanceada.

Consequências visuais e comportamentais claras para necessidades baixas (pet triste, animações de fome/tédio, menos responsivo).

Estados de humor do pet (feliz, neutro, triste, com sono) refletidos visualmente.

Interações Ricas com o Pet:

Animações mais elaboradas e contextuais para o pet.

Feedback sonoro opcional para ações e estados do pet (com controle de volume/mutar).

Ciclo Dia/Noite no Jogo:

Implementação visual baseada no horário real do dispositivo do usuário (customizável nas configurações).

Pet pode ter comportamentos diferentes (ex: dormir à noite, mais ativo de dia).

Notificações Push Detalhadas (Firebase Cloud Messaging):

Alertas sobre necessidades críticas do pet.

Notificações quando o parceiro realiza uma ação importante com o pet.

Lembretes amigáveis para interagir com o pet.

Comunicação e Colaboração (Adoção Anônima):

Log de Atividades do Pet: Visível para ambos os cuidadores na tela Dashboard ou Feed.

Interações Anônimas Iniciais: Possibilidade de enviar "cutucadas" (pings/emojis predefinidos) para o parceiro anônimo.

Sistema de Nível do Pet/Relacionamento: O pet (ou o "nível de colaboração" da dupla) sobe conforme cuidam juntos.

Desbloqueio de Perfil do Parceiro Anônimo: Ao atingir um certo nível, surge a opção para ambos os jogadores revelarem seus perfis (nome/avatar real, se consentirem). Se ambos aceitarem, os perfis são exibidos.

Dashboard do Pet:

Estatísticas de cuidado, gráfico de evolução das necessidades, log de atividades detalhado.

Fase 3: Expansão de Conteúdo e Socialização
Objetivo: Adicionar mais variedade, permitir maior personalização e introduzir elementos sociais mais amplos.

Minijogos com o Pet:

Implementar 1-2 minijogos simples e divertidos (ex: buscar objeto, jogo da memória com o pet).

Recompensas: moedas do jogo, aumento de felicidade do pet.

Customização:

Pet: Loja com acessórios (coleiras, chapéus, roupinhas) compráveis com moedas do jogo.

Ambiente do Pet: Itens decorativos para a "casa" do pet na tela principal.

Sistema de Conquistas (Achievements):

Conquistas por marcos de cuidado, tempo de adoção, desbloqueio de itens, etc.

Feed/Mural Social (Evolução do Item do BottomNav):

Além do log do pet, permitir pequenas postagens ou fotos do "momento do pet" que o parceiro pode ver.

Pets podem receber "likes" de seus cuidadores (e futuramente de amigos).

Lista de Amigos (Após Desbloqueio de Perfil ou Adição Direta):

Conectar-se com outros jogadores que também usam o app.

Visitar os pets dos amigos (visualização, deixar um "like" ou um pequeno presente virtual).

Fase 4: Monetização Ética e Eventos
Objetivo: Explorar formas de monetização que não prejudiquem a experiência gratuita e manter o jogo interessante com eventos.

Novas Espécies de Pets: Introdução gradual.

Eventos Sazonais/Temáticos:

Desafios, itens de customização exclusivos e por tempo limitado.

Monetização (Opcional e Cuidadosa):

Itens Cosméticos Premium: Venda de acessórios ou temas de ambiente exclusivos.

Pacotes de Moedas do Jogo: Para acelerar a compra de itens cosméticos (não essenciais).

Opção para Remover Anúncios: Se anúncios intersticiais ou banners forem introduzidos de forma muito leve.

Foco: Manter o jogo justo e divertido para todos, com monetização focada em itens que não dão vantagens competitivas.

Pós-Lançamento e Melhoria Contínua
Objetivo: Manter o jogo relevante, engajador e estável com base no feedback da comunidade.

Coleta Ativa de Feedback: Fóruns, redes sociais, formulários no app.

Análise de Dados (Firebase Analytics): Entender o comportamento do jogador, pontos de atrito, popularidade de funcionalidades.

Ciclos de Atualização Regulares: Correção de bugs, otimizações de performance, pequenas melhorias de UX.

Desenvolvimento de Novas Funcionalidades: Baseado no feedback da comunidade e na visão de longo prazo.

Suporte à Comunidade e Moderação.

Este roadmap revisado tenta ser mais granular, especialmente para o MVP Real, e incorpora suas excelentes ideias. Ele serve como um guia flexível. As prioridades podem e devem ser reavaliadas conforme o desenvolvimento avança e o feedback dos primeiros usuários (mesmo que internos) começa a surgir.

O que acha desta versão? Podemos começar a detalhar as tarefas específicas dentro do "MVP Real" se estiver de acordo!