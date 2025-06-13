// firestore.rules - PetCare Security Rules
// Implementação incremental mantendo funcionalidades existentes

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================
    // USER COLLECTION SECURITY
    // ========================
    match /users/{userId} {
      // Usuário pode ler e criar apenas seus próprios dados
      allow read, create: if request.auth != null && request.auth.uid == userId;
      
      // Update com validações específicas
      allow update: if request.auth != null && 
                   request.auth.uid == userId &&
                   validateUserUpdate(resource.data, request.resource.data);
      
      // SUBCOLLECTION: User Inventory
      match /inventory/{itemId} {
        allow read, write: if request.auth != null && 
                          request.auth.uid == userId;
      }
    }
    
    // ========================
    // PETS COLLECTION SECURITY  
    // ========================
    match /pets/{petId} {
      // Usuário pode ler pets que possui ou colabora
      allow read: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        resource.data.partnerId == request.auth.uid
      );
      
      // Criar pet apenas para si mesmo
      allow create: if request.auth != null && 
                   request.resource.data.ownerId == request.auth.uid &&
                   validatePetCreation(request.resource.data);
      
      // Update apenas do próprio pet com validações
      allow update: if request.auth != null && 
                   resource.data.ownerId == request.auth.uid &&
                   validatePetUpdate(resource.data, request.resource.data);
      
      // Delete apenas próprios pets
      allow delete: if request.auth != null && 
                   resource.data.ownerId == request.auth.uid;
    }
    
    // ========================
    // FEED COLLECTION SECURITY
    // ========================
    match /feed/{postId} {
      // Todos podem ler feed posts
      allow read: if request.auth != null;
      
      // Apenas criar posts para si mesmo
      allow create: if request.auth != null && 
                   request.resource.data.userId == request.auth.uid &&
                   validateFeedPost(request.resource.data);
      
      // Não permitir update/delete de feed posts (são immutable)
      allow update, delete: if false;
    }
    
    // ========================
    // CHAT COLLECTION SECURITY
    // ========================
    match /chats/{messageId} {
      // Ler mensagens apenas se possui ou colabora no pet
      allow read: if request.auth != null && 
                 userOwnsOrCollaboratesOnPet(request.auth.uid, resource.data.petId);
      
      // Criar mensagem apenas se possui o pet e é sender
      allow create: if request.auth != null && 
                   request.resource.data.senderId == request.auth.uid &&
                   userOwnsOrCollaboratesOnPet(request.auth.uid, request.resource.data.petId);
      
      // Não permitir update/delete de mensagens
      allow update, delete: if false;
    }
    
    // ========================
    // VALIDATION FUNCTIONS
    // ========================
    
    // Validar updates de usuário - protege economia
    function validateUserUpdate(oldData, newData) {
      let allowedFields = ['username', 'avatar', 'level', 'xp', 'aiConfig', 'purchasedSlotsCount'];
      let economyFields = ['coins', 'gems'];
      
      // Campos básicos podem ser alterados livremente
      let basicUpdateValid = !hasAnyFields(newData, economyFields) ||
                            economyUpdateValid(oldData, newData);
      
      // Level e XP só podem aumentar
      let progressionValid = newData.level >= oldData.level && 
                           newData.xp >= oldData.xp;
      
      return basicUpdateValid && progressionValid;
    }
    
    // Validar mudanças na economia (coins/gems)
    function economyUpdateValid(oldData, newData) {
      // Coins podem aumentar moderadamente (missões, etc)
      let coinIncrease = newData.get('coins', 0) - oldData.get('coins', 0);
      let gemIncrease = newData.get('gems', 0) - oldData.get('gems', 0);
      
      // Permitir diminuição (gasto) ou aumento razoável
      let coinsValid = coinIncrease <= 200; // Max 200 coins por operação
      let gemsValid = gemIncrease <= 50;    // Max 50 gems por operação
      
      return coinsValid && gemsValid;
    }
    
    // Validar criação de pet
    function validatePetCreation(petData) {
      let requiredFields = ['name', 'emoji', 'type', 'ownerId', 'level', 'happiness', 'hunger', 'energy', 'health'];
      let hasAllRequired = hasAllFields(petData, requiredFields);
      
      // Stats devem estar em range válido
      let statsValid = petData.level >= 1 && petData.level <= 100 &&
                      petData.happiness >= 0 && petData.happiness <= 100 &&
                      petData.hunger >= 0 && petData.hunger <= 100 &&
                      petData.energy >= 0 && petData.energy <= 100 &&
                      petData.health >= 0 && petData.health <= 100;
      
      // Nome do pet deve ter tamanho válido
      let nameValid = petData.name.size() >= 2 && petData.name.size() <= 15;
      
      return hasAllRequired && statsValid && nameValid;
    }
    
    // Validar update de pet
    function validatePetUpdate(oldData, newData) {
      // Level e XP só podem aumentar
      let progressionValid = newData.level >= oldData.level && 
                           newData.xp >= oldData.xp;
      
      // Stats devem estar em range válido
      let statsValid = newData.happiness >= 0 && newData.happiness <= 100 &&
                      newData.hunger >= 0 && newData.hunger <= 100 &&
                      newData.energy >= 0 && newData.energy <= 100 &&
                      newData.health >= 0 && newData.health <= 100;
      
      // Não permitir mudança de owner ou campos críticos
      let immutableValid = newData.ownerId == oldData.ownerId &&
                          newData.type == oldData.type &&
                          newData.emoji == oldData.emoji;
      
      return progressionValid && statsValid && immutableValid;
    }
    
    // Validar feed post
    function validateFeedPost(postData) {
      let validTypes = ['adoption', 'death', 'level_up', 'collaboration', 'return', 'unique_generation'];
      let hasValidType = postData.type in validTypes;
      let hasContent = postData.content.size() > 0 && postData.content.size() <= 500;
      let hasTimestamp = postData.timestamp is timestamp;
      
      return hasValidType && hasContent && hasTimestamp;
    }
    
    // Verificar se usuário possui ou colabora no pet
    function userOwnsOrCollaboratesOnPet(userId, petId) {
      let petDoc = get(/databases/$(database)/documents/pets/$(petId));
      return petDoc.data.ownerId == userId || petDoc.data.partnerId == userId;
    }
    
    // Helper functions
    function hasAllFields(data, fields) {
      return fields.toSet().difference(data.keys().toSet()).size() == 0;
    }
    
    function hasAnyFields(data, fields) {
      return fields.toSet().intersection(data.keys().toSet()).size() > 0;
    }
  }
}