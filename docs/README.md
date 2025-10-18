# Documentação do FasTest

Bem-vindo à documentação completa do FasTest! Este diretório contém toda a documentação técnica, guias e referências para desenvolvedores e contribuidores.

## 📚 Índice de Documentação

### Para Usuários

- **[QUICKSTART.md](QUICKSTART.md)** - Guia de início rápido (5 minutos)
- **[README.md](../README.md)** - Guia de início rápido e instalação
- **[FAQ.md](FAQ.md)** - Perguntas frequentes
- **[EXAMPLES.md](EXAMPLES.md)** - Exemplos práticos de uso
- **[CHANGELOG.md](../CHANGELOG.md)** - Histórico de versões e mudanças

### Para Desenvolvedores

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitetura e design do projeto
  - Estrutura de diretórios
  - Componentes principais
  - Fluxo de execução
  - Padrões de design utilizados
  - Otimizações implementadas

- **[API.md](API.md)** - Referência completa da API
  - Core APIs
  - Runner APIs
  - View APIs
  - Process APIs
  - Optimizer APIs
  - Exemplos de uso

### Para Contribuidores

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guia de contribuição
  - Como contribuir
  - Configuração do ambiente
  - Padrões de código
  - Processo de desenvolvimento
  - Testes
  - Pull requests

- **[IMPROVEMENTS.md](IMPROVEMENTS.md)** - Propostas de melhorias
  - Problemas atuais
  - Soluções propostas
  - Sistema de buffer
  - Dashboard interativo
  - Relatórios e analytics

### Planejamento

- **[ROADMAP.md](ROADMAP.md)** - Roadmap de evolução
  - Visão de longo prazo
  - Versões planejadas
  - Features futuras
  - Cronograma

## 🎯 Navegação Rápida

### Quero começar AGORA
→ Veja o [QUICKSTART.md](QUICKSTART.md) (5 minutos)

### Quero começar a usar o FasTest
→ Comece com [README.md](../README.md) e depois veja [EXAMPLES.md](EXAMPLES.md)

### Tenho dúvidas sobre o uso
→ Consulte o [FAQ.md](FAQ.md)

### Quero entender como o FasTest funciona
→ Comece com [ARCHITECTURE.md](ARCHITECTURE.md)

### Quero usar a API do FasTest no meu projeto
→ Veja [API.md](API.md)

### Quero ver exemplos práticos
→ Consulte [EXAMPLES.md](EXAMPLES.md)

### Quero contribuir com código
→ Leia [CONTRIBUTING.md](CONTRIBUTING.md)

### Quero propor uma nova feature
→ Consulte [ROADMAP.md](ROADMAP.md) e [IMPROVEMENTS.md](IMPROVEMENTS.md)

### Quero entender as melhorias planejadas
→ Veja [IMPROVEMENTS.md](IMPROVEMENTS.md)

## 📖 Guias por Tópico

### Arquitetura e Design

```
ARCHITECTURE.md
├── Visão Geral
├── Estrutura de Diretórios
├── Componentes Principais
│   ├── Args Parser
│   ├── Optimizer
│   ├── Runner
│   ├── Process Handler
│   ├── View
│   └── Coverage
├── Fluxo de Execução
├── Padrões de Design
└── Otimizações
```

### API Reference

```
API.md
├── Core APIs
│   └── Runner
├── Runner APIs
│   ├── TestRunner
│   ├── MonorepoRunner
│   └── MonorepoExecutor
├── View APIs
│   ├── TestOutput
│   ├── ColoredOutput
│   └── LoadingIndicator
├── Process APIs
│   └── ProcessHandler
├── Optimizer APIs
│   ├── TestOptimizer
│   ├── TestFinder
│   └── AliasGenerator
└── Exemplos de Uso
```

### Contribuição

```
CONTRIBUTING.md
├── Código de Conduta
├── Como Contribuir
├── Configuração do Ambiente
├── Padrões de Código
│   ├── Estilo de Código
│   ├── Princípios de Design
│   ├── Documentação
│   └── Tratamento de Erros
├── Processo de Desenvolvimento
├── Testes
│   ├── Testes Unitários
│   ├── Testes com Mocks
│   └── Testes de Integração
└── Pull Requests
```

### Melhorias Propostas

```
IMPROVEMENTS.md
├── Problema Atual
├── Propostas de Melhorias
│   ├── Sistema de Buffer
│   ├── Seções Visuais
│   ├── Dashboard Interativo
│   ├── Logs Estruturados
│   └── Sistema de Multiplexação
├── Melhorias Complementares
│   ├── Notificações de Eventos
│   ├── Resumo Final
│   ├── Modo Quiet
│   └── Exportação de Relatórios
└── Recomendação de Implementação
```

### Roadmap

```
ROADMAP.md
├── Visão
├── Versão Atual (0.1.11)
├── Versões Planejadas
│   ├── 0.2.0 - Melhorias de Visualização
│   ├── 0.3.0 - Sistema de Multiplexação
│   ├── 0.4.0 - Dashboard Interativo
│   ├── 0.5.0 - Relatórios e Analytics
│   ├── 0.6.0 - Otimizações Avançadas
│   ├── 0.7.0 - Extensibilidade e Plugins
│   ├── 0.8.0 - Debugging e Diagnóstico
│   └── 1.0.0 - Release Estável
├── Features Futuras
└── Como Contribuir
```

## 🔍 Busca Rápida

### Conceitos

- **Agregação de Testes**: [ARCHITECTURE.md](ARCHITECTURE.md#otimização-por-agregação)
- **Execução Paralela**: [ARCHITECTURE.md](ARCHITECTURE.md#paralelização-inteligente)
- **Isolates**: [ARCHITECTURE.md](ARCHITECTURE.md#isolamento-e-paralelização)
- **Monorepo**: [ARCHITECTURE.md](ARCHITECTURE.md#monorepo-multi-package)
- **Test Output**: [API.md](API.md#testoutput)

### Componentes

- **Runner**: [API.md](API.md#runner)
- **TestOptimizer**: [API.md](API.md#testoptimizer)
- **ProcessHandler**: [API.md](API.md#processhandler)
- **ColoredOutput**: [API.md](API.md#coloredoutput)
- **LoadingIndicator**: [API.md](API.md#loadingindicator)

### Padrões

- **Factory Pattern**: [ARCHITECTURE.md](ARCHITECTURE.md#factory-pattern)
- **Strategy Pattern**: [ARCHITECTURE.md](ARCHITECTURE.md#strategy-pattern)
- **Dependency Injection**: [CONTRIBUTING.md](CONTRIBUTING.md#dependency-inversion)
- **SOLID Principles**: [CONTRIBUTING.md](CONTRIBUTING.md#solid-principles)

### Processos

- **Como Contribuir**: [CONTRIBUTING.md](CONTRIBUTING.md#como-contribuir)
- **Escrevendo Testes**: [CONTRIBUTING.md](CONTRIBUTING.md#escrevendo-testes)
- **Pull Requests**: [CONTRIBUTING.md](CONTRIBUTING.md#pull-requests)
- **Convenção de Commits**: [CONTRIBUTING.md](CONTRIBUTING.md#convenção-de-commits)

## 💡 Exemplos Práticos

### Exemplo 1: Uso Básico
```dart
final runner = Runner(
  isPackage: false,
  testPath: './test',
  coverage: false,
  concurrency: 4,
  failFast: false,
  verbose: true,
);

final exitCode = await runner.execute();
```

Ver mais em: [API.md - Exemplos de Uso](API.md#exemplos-de-uso)

### Exemplo 2: Custom Output Handler
```dart
class CustomTestOutput implements TestOutput {
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    // Implementação customizada
  }
}
```

Ver mais em: [API.md - Custom Output Handler](API.md#exemplo-3-custom-output-handler)

### Exemplo 3: Testes com Mock
```dart
class MockProcessHandler implements ProcessHandler {
  // Implementação de mock
}

final runner = TestRunner(
  testPath: '/test',
  processHandler: MockProcessHandler(),
);
```

Ver mais em: [API.md - Testes com Mock](API.md#exemplo-5-testes-unitários-com-mock)

## 🚀 Começando

### Para Usuários Finais
1. Leia o [README.md](../README.md)
2. Instale: `dart pub global activate fastest`
3. Execute: `fastest test/`

### Para Desenvolvedores
1. Leia [ARCHITECTURE.md](ARCHITECTURE.md)
2. Explore [API.md](API.md)
3. Clone o repositório
4. Execute `dart pub get`
5. Execute `dart test`

### Para Contribuidores
1. Leia [CONTRIBUTING.md](CONTRIBUTING.md)
2. Configure o ambiente
3. Escolha uma issue
4. Faça um fork
5. Submeta um PR

## 📊 Diagramas

### Fluxo de Execução (Single Package)
```
main() → ArgsParser → CoverageCheck → TestRunner → TestOptimizer → Process → TestOutput → exit()
```

### Fluxo de Execução (Monorepo)
```
main() → ArgsParser → MonorepoRunner → PackageFinder → MonorepoExecutor
                                                              ↓
                                                    [Pool de Isolates]
                                                              ↓
                                                    TestRunner (por pacote)
                                                              ↓
                                                         Resultados
```

Ver diagramas detalhados em: [ARCHITECTURE.md](ARCHITECTURE.md#fluxo-de-execução)

## 🔧 Ferramentas e Recursos

### Desenvolvimento
- Dart SDK >= 3.5.0
- Flutter (para testes)
- Git

### Análise e Formatação
```bash
dart format .
dart analyze
dart test --coverage=coverage
```

### Documentação
```bash
dart doc
```

## 📝 Convenções

### Nomenclatura de Arquivos
- Documentação: `UPPERCASE.md`
- Código: `snake_case.dart`
- Testes: `*_test.dart`

### Estrutura de Documentos
- Título principal (H1)
- Índice
- Seções (H2)
- Subseções (H3)
- Exemplos de código
- Links relacionados

## 🤝 Comunidade

### Canais de Comunicação
- 💬 GitHub Discussions - Perguntas e discussões
- 🐛 GitHub Issues - Bugs e features
- 📧 Email - Questões privadas

### Como Pedir Ajuda
1. Verifique a documentação existente
2. Busque em issues fechadas
3. Abra uma nova discussão/issue
4. Forneça contexto e exemplos

## 📄 Licença

Este projeto está licenciado sob a licença MIT. Ver [LICENSE](../LICENSE) para mais detalhes.

## 🙏 Agradecimentos

Obrigado a todos os contribuidores que ajudam a melhorar o FasTest!

---

**Última atualização**: Janeiro 2024
**Versão da documentação**: 1.0.0
**Versão do FasTest**: 0.1.11

---

## Links Úteis

- [Repositório GitHub](https://github.com/aphenrique/fastest)
- [Pub.dev](https://pub.dev/packages/fastest)
- [Issues](https://github.com/aphenrique/fastest/issues)
- [Pull Requests](https://github.com/aphenrique/fastest/pulls)
- [Releases](https://github.com/aphenrique/fastest/releases)
