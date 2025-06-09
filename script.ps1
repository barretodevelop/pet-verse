# PowerShell Script - Criar Estrutura do Sistema de Adoção Colaborativa
# Execute no root do projeto Flutter

Write-Host "Criando estrutura do Sistema de Adoção Colaborativa..." -ForegroundColor Green

# Core - Enums
New-Item -ItemType Directory -Force -Path "lib\core\enums\collaboration"
New-Item -ItemType File -Force -Path "lib\core\enums\collaboration\collaboration_enums.dart"

# Domain - Entities
New-Item -ItemType Directory -Force -Path "lib\domain\entities\collaboration"
New-Item -ItemType File -Force -Path "lib\domain\entities\collaboration\collaborative_pet_entity.dart"
New-Item -ItemType File -Force -Path "lib\domain\entities\collaboration\collaborative_action_entity.dart"
New-Item -ItemType File -Force -Path "lib\domain\entities\collaboration\user_collaboration_data_entity.dart"
New-Item -ItemType File -Force -Path "lib\domain\entities\collaboration\reveal_request_entity.dart"

# Domain - Repositories
New-Item -ItemType File -Force -Path "lib\domain\repositories\collaborative_pet_repository.dart"

# Domain - Use Cases
New-Item -ItemType Directory -Force -Path "lib\domain\usecases\collaboration"
New-Item -ItemType File -Force -Path "lib\domain\usecases\collaboration\request_collaborative_adoption.dart"
New-Item -ItemType File -Force -Path "lib\domain\usecases\collaboration\sync_collaborative_action.dart"
New-Item -ItemType File -Force -Path "lib\domain\usecases\collaboration\process_reveal_request.dart"
New-Item -ItemType File -Force -Path "lib\domain\usecases\collaboration\get_available_collaborative_pets.dart"
New-Item -ItemType File -Force -Path "lib\domain\usecases\collaboration\check_collaboration_match.dart"

# Data - Models
New-Item -ItemType Directory -Force -Path "lib\data\models\collaboration"
New-Item -ItemType File -Force -Path "lib\data\models\collaboration\collaborative_pet_model.dart"
New-Item -ItemType File -Force -Path "lib\data\models\collaboration\collaborative_action_model.dart"
New-Item -ItemType File -Force -Path "lib\data\models\collaboration\user_collaboration_data_model.dart"

# Data - Repositories
New-Item -ItemType File -Force -Path "lib\data\repositories\collaborative_pet_repository_impl.dart"

# Services
New-Item -ItemType File -Force -Path "lib\services\real_time_sync_service.dart"
New-Item -ItemType File -Force -Path "lib\services\collaboration_matchmaking_service.dart"

# Presentation - Providers
New-Item -ItemType File -Force -Path "lib\presentation\providers\collaborative_pet_provider.dart"
New-Item -ItemType File -Force -Path "lib\presentation\providers\collaboration_slots_provider.dart"

# Presentation - Screens
New-Item -ItemType File -Force -Path "lib\presentation\screens\home\pet\collaborative_adoption_screen.dart"
New-Item -ItemType File -Force -Path "lib\presentation\screens\home\pet\collaborative_pet_detail_screen.dart"
New-Item -ItemType File -Force -Path "lib\presentation\screens\home\pet\reveal_request_screen.dart"

# Presentation - Widgets - Collaboration
New-Item -ItemType Directory -Force -Path "lib\presentation\widgets\collaboration"
New-Item -ItemType File -Force -Path "lib\presentation\widgets\collaboration\pet_slot_card.dart"
New-Item -ItemType File -Force -Path "lib\presentation\widgets\collaboration\collaborative_pet_card.dart"
New-Item -ItemType File -Force -Path "lib\presentation\widgets\collaboration\real_time_action_widget.dart"
New-Item -ItemType File -Force -Path "lib\presentation\widgets\collaboration\reveal_dialog_widget.dart"
New-Item -ItemType File -Force -Path "lib\presentation\widgets\collaboration\collaboration_stats_widget.dart"

Write-Host " Estrutura criada com sucesso!" -ForegroundColor Green
Write-Host " Total: 25 novos arquivos criados" -ForegroundColor Cyan
Write-Host " Pronto para implementar o sistema de adoção colaborativa!" -ForegroundColor Yellow