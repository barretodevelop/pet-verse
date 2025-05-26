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