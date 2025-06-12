# Caminho da raiz do projeto
$rootPath = "lib"

# Encontra todos os arquivos .dart dentro da pasta lib
$dartFiles = Get-ChildItem -Path $rootPath -Recurse -Filter *.dart

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw

    # Regrava o conteúdo com encoding UTF-8
    $content | Out-File -FilePath $file.FullName -Encoding utf8

    Write-Host "Corrigido: $($file.FullName)" -ForegroundColor Green
}

Write-Host "`nTodos os arquivos .dart foram regravados com encoding UTF-8." -ForegroundColor Cyan
