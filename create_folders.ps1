# Pasta raiz do projeto Flutter
$root = "lib"

# Criar pasta lib
New-Item -ItemType Directory -Force -Path $root

# Criar main.dart
Set-Content -Path "$root/main.dart" -Value "// Entry point da aplicação"

# Core
$core = "$root/core"
New-Item -ItemType Directory -Path $core
New-Item -ItemType Directory -Path "$core/constants"
New-Item -ItemType Directory -Path "$core/utils"
New-Item -ItemType Directory -Path "$core/theme"
New-Item -ItemType Directory -Path "$core/config"

# Data
$data = "$root/data"
New-Item -ItemType Directory -Path $data
New-Item -ItemType Directory -Path "$data/models"
New-Item -ItemType Directory -Path "$data/repositories"
New-Item -ItemType Directory -Path "$data/services"

# Presentation
$presentation = "$root/presentation"
New-Item -ItemType Directory -Path $presentation
New-Item -ItemType Directory -Path "$presentation/screens"
New-Item -ItemType Directory -Path "$presentation/widgets"
New-Item -ItemType Directory -Path "$presentation/modals"
New-Item -ItemType Directory -Path "$presentation/providers"

# Domain
$domain = "$root/domain"
New-Item -ItemType Directory -Path $domain
New-Item -ItemType Directory -Path "$domain/entities"
New-Item -ItemType Directory -Path "$domain/use_cases"

Write-Host "✅ Estrutura criada com sucesso em: .\$root\"








📋 ANÁLISE GERAL
Pontos Positivos:

✅ Uso adequado do Riverpod para gerenciamento de estado
✅ Implementação de temas claro/escuro
✅ Estrutura de navegação básica funcional
✅ Integração com APIs externas (Gemini/Imagen)
✅ Sistema de gamificação interessante

Problemas Críticos Identificados:

🚨 Arquitetura monolítica - Todo código em um arquivo
🚨 Segurança - API keys expostas
🚨 Manutenibilidade - Código muito verboso e repetitivo
🚨 Performance - Possíveis memory leaks e rebuilds desnecessários


🎯 PLANO DE AÇÃO DETALHADO
FASE 1: REESTRUTURAÇÃO ARQUITETURAL (ALTA PRIORIDADE)
1.1 Separação de Arquivos

1.2 Implementação de Clean Architecture

Separar models de entities
Criar repositories para abstração de dados
Implementar use cases para lógica de negócio
Criar services para APIs externas

FASE 2: SEGURANÇA E CONFIGURAÇÃO (ALTA PRIORIDADE)
2.1 Gerenciamento de API Keys

 Mover API keys para .env files
 Implementar flutter_dotenv ou similar
 Adicionar .env no .gitignore
 Criar configuração diferente para dev/prod

2.2 Validação e Sanitização

 Implementar validação de entrada robusta
 Sanitizar dados antes de enviar para APIs
 Adicionar rate limiting local
 Implementar retry logic com backoff

FASE 3: OTIMIZAÇÃO DE ESTADO (MÉDIA PRIORIDADE)
3.1 Refatoração dos Providers
3.2 Otimização de Performance

 Implementar select() nos Consumer widgets
 Usar ConsumerStatefulWidget apenas quando necessário
 Implementar cache local para pets
 Otimizar rebuilds com Selector

FASE 4: MELHORIA DA NAVEGAÇÃO (MÉDIA PRIORIDADE)
4.1 Sistema de Navegação Robusto

 Implementar go_router ou auto_route
 Criar navegação declarativa
 Implementar deep linking
 Adicionar guards de navegação

4.2 Gerenciamento de Estado de Navegação

 Estado de navegação centralizado
 Controle de back button
 Transições customizadas

FASE 5: REFATORAÇÃO DA UI (MÉDIA PRIORIDADE)
5.1 Componentização
5.2 Design System

 Criar theme completo com cores, tipografia, espaçamentos
 Implementar componentes consistentes
 Padronizar animações e transições
 Criar guia de estilo

FASE 6: TRATAMENTO DE ERROS (MÉDIA PRIORIDADE)
6.1 Error Handling Global

 Implementar ErrorBoundary equivalente
 Sistema de notificações/toast
 Logging estruturado
 Fallbacks para falhas de API

6.2 Estados de Loading

 Skeleton screens
 Progress indicators adequados
 Timeouts configuráveis
 Cancelamento de requests

FASE 7: OTIMIZAÇÃO DE PERFORMANCE (BAIXA PRIORIDADE)
7.1 Gerenciamento de Imagens

 Implementar cache de imagens
 Lazy loading
 Otimização de tamanho
 Placeholder adequados

7.2 Otimização de Listas

 Usar ListView.builder otimizado
 Implementar paginação
 Virtual scrolling para listas grandes

FASE 8: ACESSIBILIDADE E UX (BAIXA PRIORIDADE)
8.1 Acessibilidade

 Adicionar Semantics widgets
 Suporte a screen readers
 Navegação por teclado
 Contraste de cores adequado

8.2 Internacionalização

 Implementar flutter_localizations
 Extrair strings para arquivos de tradução
 Suporte a RTL languages

FASE 9: TESTES E QUALIDADE (BAIXA PRIORIDADE)
9.1 Estratégia de Testes
9.2 Coverage e CI/CD

 Configurar code coverage
 Lint rules rigorosas
 Pre-commit hooks
 Pipeline CI/CD


🚀 CRONOGRAMA SUGERIDO
Semana 1-2: Fase 1 (Reestruturação)

Separação de arquivos
Setup da nova arquitetura

Semana 3: Fase 2 (Segurança)

Configuração de environment
API security

Semana 4-5: Fase 3 (Estado)

Refatoração dos providers
Otimização de performance

Semana 6: Fase 4 (Navegação)

Implementação do router
Sistema de navegação

Semana 7-8: Fases 5-6 (UI e Errors)

Componentização
Error handling

Semana 9-10: Fases 7-9 (Performance e Qualidade)

Otimizações finais
Testes


📊 MÉTRICAS DE SUCESSO

Redução de 80% no tamanho do main.dart
Cobertura de testes > 80%
Lighthouse score > 90
Zero API keys expostas
Tempo de build < 2min

Esta reestruturação transformará o código de protótipo em uma aplicação robusta, escalável e mantível, seguindo as melhores práticas do Flutter e padrões da indústria.