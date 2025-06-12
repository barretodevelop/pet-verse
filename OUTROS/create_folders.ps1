# Script PowerShell para criar estrutura de pastas do Pet Game Flutter
# Execute este script na raiz do projeto Flutter

Write-Host "`nCriando estrutura de pastas do Pet Game Flutter..." -ForegroundColor Green

# Lista de pastas que serão criadas
$folders = @(
    "lib/core/config",
    "lib/core/constants",
    "lib/core/errors",
    "lib/core/utils",
    "lib/core/widgets",
    "lib/core/enums",
    "lib/core/routes",
    "lib/data/datasources/remote",
    "lib/data/datasources/local",
    "lib/data/models",
    "lib/data/repositories",
    "lib/domain/entities",
    "lib/domain/repositories",
    "lib/domain/usecases/auth",
    "lib/domain/usecases/user",
    "lib/domain/usecases/pet",
    "lib/presentation/providers",
    "lib/presentation/screens/splash/widgets",
    "lib/presentation/screens/auth/widgets",
    "lib/presentation/screens/home/dashboard/widgets",
    "lib/presentation/screens/home/shop/widgets",
    "lib/presentation/screens/home/pet/widgets",
    "lib/presentation/screens/home/games/widgets",
    "lib/presentation/screens/home/feed/widgets",
    "lib/presentation/screens/settings/widgets",
    "lib/presentation/widgets/common",
    "lib/presentation/widgets/animations",
    "lib/presentation/widgets/forms",
    "lib/services"
)

# Criar as pastas
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Criado: $folder" -ForegroundColor Cyan
    } else {
        Write-Host "Já existe: $folder" -ForegroundColor Yellow
    }
}

Write-Host "`nTotal de pastas: $($folders.Count)" -ForegroundColor Blue

# Criar arquivos .gitkeep em cada pasta para manter no Git
Write-Host "`nCriando arquivos .gitkeep..." -ForegroundColor Magenta

foreach ($folder in $folders) {
    $gitkeepPath = "$folder/.gitkeep"
    if (!(Test-Path $gitkeepPath)) {
        New-Item -ItemType File -Path $gitkeepPath -Force | Out-Null
        Write-Host ".gitkeep criado em: $folder" -ForegroundColor DarkGray
    }
}

Write-Host "`nEstrutura criada com sucesso!" -ForegroundColor Gre
