# Script para criar a estrutura de pastas Feature-First para o projeto PetVerse

# Define o diretório base (dentro de 'lib')
$baseDir = "lib\src"

# Cria o diretório 'src' se não existir
if (-not (Test-Path $baseDir)) {
    New-Item -ItemType Directory -Path $baseDir
    Write-Host "Criado diretório: $baseDir"
}

# --- Estrutura Core ---
$coreDir = "$baseDir\core"
New-Item -ItemType Directory -Path $coreDir -Force | Out-Null
Write-Host "Criado diretório: $coreDir"

$coreSubDirs = @(
    "theme",
    "navigation",
    "utils",
    "widgets",
    "providers",
    "models" # Modelos globais, se houver
)
foreach ($subDir in $coreSubDirs) {
    New-Item -ItemType Directory -Path "$coreDir\$subDir" -Force | Out-Null
    Write-Host "Criado diretório: $coreDir\$subDir"
}

# --- Estrutura Features ---
$featuresDir = "$baseDir\features"
New-Item -ItemType Directory -Path $featuresDir -Force | Out-Null
Write-Host "Criado diretório: $featuresDir"

# Funcionalidade: Auth
$authDir = "$featuresDir\auth"
New-Item -ItemType Directory -Path $authDir -Force | Out-Null
Write-Host "Criado diretório: $authDir"
$authSubDirs = @{
    "data" = @()
    "domain" = @("entities")
    "presentation" = @("providers", "screens", "widgets")
}
$authSubDirs.GetEnumerator() | ForEach-Object {
    $featureSubDir = $_.Key
    $subSubDirs = $_.Value
    New-Item -ItemType Directory -Path "$authDir\$featureSubDir" -Force | Out-Null
    Write-Host "Criado diretório: $authDir\$featureSubDir"
    foreach ($subSubDir in $subSubDirs) {
        New-Item -ItemType Directory -Path "$authDir\$featureSubDir\$subSubDir" -Force | Out-Null
        Write-Host "Criado diretório: $authDir\$featureSubDir\$subSubDir"
    }
}

# Funcionalidade: Pets
$petsDir = "$featuresDir\pets"
New-Item -ItemType Directory -Path $petsDir -Force | Out-Null
Write-Host "Criado diretório: $petsDir"
$petsSubDirs = @{
    "data" = @()
    "domain" = @("entities")
    "presentation" = @("providers", "screens", "widgets")
}
$petsSubDirs.GetEnumerator() | ForEach-Object {
    $featureSubDir = $_.Key
    $subSubDirs = $_.Value
    New-Item -ItemType Directory -Path "$petsDir\$featureSubDir" -Force | Out-Null
    Write-Host "Criado diretório: $petsDir\$featureSubDir"
    foreach ($subSubDir in $subSubDirs) {
        New-Item -ItemType Directory -Path "$petsDir\$featureSubDir\$subSubDir" -Force | Out-Null
        Write-Host "Criado diretório: $petsDir\$featureSubDir\$subSubDir"
    }
}

# Funcionalidade: Onboarding
$onboardingDir = "$featuresDir\onboarding"
New-Item -ItemType Directory -Path $onboardingDir -Force | Out-Null
Write-Host "Criado diretório: $onboardingDir"
$onboardingSubDirs = @{
    "presentation" = @("screens", "widgets") # Adicionando widgets para consistência
}
$onboardingSubDirs.GetEnumerator() | ForEach-Object {
    $featureSubDir = $_.Key
    $subSubDirs = $_.Value
    New-Item -ItemType Directory -Path "$onboardingDir\$featureSubDir" -Force | Out-Null
    Write-Host "Criado diretório: $onboardingDir\$featureSubDir"
    foreach ($subSubDir in $subSubDirs) {
        New-Item -ItemType Directory -Path "$onboardingDir\$featureSubDir\$subSubDir" -Force | Out-Null
        Write-Host "Criado diretório: $onboardingDir\$featureSubDir\$subSubDir"
    }
}

# Funcionalidade: Settings
$settingsDir = "$featuresDir\settings"
New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
Write-Host "Criado diretório: $settingsDir"
$settingsSubDirs = @{
    "presentation" = @("screens", "widgets") # Adicionando widgets para consistência
}
$settingsSubDirs.GetEnumerator() | ForEach-Object {
    $featureSubDir = $_.Key
    $subSubDirs = $_.Value
    New-Item -ItemType Directory -Path "$settingsDir\$featureSubDir" -Force | Out-Null
    Write-Host "Criado diretório: $settingsDir\$featureSubDir"
    foreach ($subSubDir in $subSubDirs) {
        New-Item -ItemType Directory -Path "$settingsDir\$featureSubDir\$subSubDir" -Force | Out-Null
        Write-Host "Criado diretório: $settingsDir\$featureSubDir\$subSubDir"
    }
}

Write-Host "Estrutura de pastas criada com sucesso!"
