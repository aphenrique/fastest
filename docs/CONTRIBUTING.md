# Guia de Contribuição

Obrigado por considerar contribuir com o FasTest! Este documento fornece diretrizes e melhores práticas para contribuir com o projeto.

## Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Padrões de Código](#padrões-de-código)
- [Processo de Desenvolvimento](#processo-de-desenvolvimento)
- [Testes](#testes)
- [Documentação](#documentação)
- [Pull Requests](#pull-requests)

## Código de Conduta

Este projeto adere a um código de conduta. Ao participar, você concorda em manter um ambiente respeitoso e inclusivo para todos.

### Nossos Valores
- 🤝 Respeito mútuo
- 💡 Colaboração construtiva
- 🎯 Foco em soluções
- 📚 Compartilhamento de conhecimento

## Como Contribuir

Existem várias formas de contribuir:

### 1. Reportar Bugs
- Use o template de issue para bugs
- Inclua informações do ambiente (OS, Dart/Flutter version)
- Forneça passos para reproduzir
- Adicione logs relevantes

### 2. Sugerir Melhorias
- Use o template de issue para features
- Explique o problema que a feature resolve
- Descreva a solução proposta
- Considere alternativas

### 3. Contribuir com Código
- Escolha uma issue existente ou crie uma nova
- Comente na issue que você vai trabalhar nela
- Faça fork do repositório
- Crie uma branch para sua feature
- Implemente e teste
- Submeta um Pull Request

### 4. Melhorar Documentação
- Corrija erros de digitação
- Adicione exemplos
- Melhore explicações
- Traduza documentação

## Configuração do Ambiente

### Pré-requisitos
- Dart SDK >= 3.5.0
- Flutter (para testes)
- Git

### Setup Inicial

```bash
# Clone o repositório
git clone https://github.com/aphenrique/fastest.git
cd fastest

# Instale dependências
dart pub get

# Execute os testes
dart test

# Ative localmente para testar
dart pub global activate --source path .

# Teste o comando
fastest --help
```

### Estrutura de Branches

- `main`: Branch principal, sempre estável
- `develop`: Branch de desenvolvimento
- `feature/*`: Novas funcionalidades
- `fix/*`: Correções de bugs
- `docs/*`: Melhorias na documentação
- `refactor/*`: Refatorações

## Padrões de Código

### Estilo de Código

Seguimos as [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart).

#### Formatação
```bash
# Formate o código antes de commitar
dart format .

# Verifique análise estática
dart analyze
```

#### Nomenclatura

**Classes e Enums**: PascalCase
```dart
class TestRunner {}
enum ConsoleColor {}
```

**Funções e Variáveis**: camelCase
```dart
void executeTests() {}
final testPath = '/path/to/tests';
```

**Constantes**: lowerCamelCase
```dart
const defaultConcurrency = 4;
```

**Arquivos**: snake_case
```dart
test_runner.dart
monorepo_executor.dart
```

### Princípios de Design

#### 1. SOLID Principles

**Single Responsibility**
```dart
// ❌ Evite classes que fazem muitas coisas
class TestManager {
  void findTests() {}
  void runTests() {}
  void generateReport() {}
  void sendNotification() {}
}

// ✅ Separe responsabilidades
class TestFinder {
  List<String> findTests() {}
}

class TestRunner {
  Future<int> runTests() {}
}

class TestReporter {
  void generateReport() {}
}
```

**Open/Closed**
```dart
// ✅ Use interfaces para extensibilidade
abstract class TestOutput {
  Stream<List<int>> output(Stream<List<int>> output);
}

class VerboseTestOutput implements TestOutput {
  // Implementação específica
}

class QuietTestOutput implements TestOutput {
  // Implementação específica
}
```

**Dependency Inversion**
```dart
// ✅ Dependa de abstrações
class TestRunner {
  TestRunner({
    required ProcessHandler processHandler, // Interface
  });
}

// ❌ Evite dependências concretas
class TestRunner {
  final Process _process; // Classe concreta
}
```

#### 2. Composition over Inheritance

```dart
// ✅ Prefira composição
class TestRunner {
  final TestOptimizer _optimizer;
  final CoverageHandler _coverage;
  final ProcessHandler _process;
  
  TestRunner({
    required TestOptimizer optimizer,
    required CoverageHandler coverage,
    required ProcessHandler process,
  }) : _optimizer = optimizer,
       _coverage = coverage,
       _process = process;
}

// ❌ Evite hierarquias profundas
class BaseRunner {}
class AbstractTestRunner extends BaseRunner {}
class ConcreteTestRunner extends AbstractTestRunner {}
```

#### 3. Fail Fast

```dart
// ✅ Valide cedo
Future<void> execute(String path) async {
  if (path.isEmpty) {
    throw ArgumentError('Path cannot be empty');
  }
  
  if (!Directory(path).existsSync()) {
    throw PathNotFoundException('Path does not exist: $path');
  }
  
  // Continua com lógica principal
}
```

### Documentação de Código

#### Comentários de Documentação

```dart
/// Executa testes em um ambiente monorepo.
///
/// Esta classe é responsável por:
/// - Descobrir pacotes com testes
/// - Executar testes em paralelo
/// - Coletar e reportar resultados
///
/// Exemplo:
/// ```dart
/// final runner = MonorepoRunner(
///   rootPath: '/path/to/monorepo',
///   concurrency: 4,
/// );
/// final exitCode = await runner.execute();
/// ```
class MonorepoRunner implements Runner {
  /// Cria uma nova instância de [MonorepoRunner].
  ///
  /// O parâmetro [rootPath] deve apontar para a raiz do monorepo.
  /// O parâmetro [concurrency] define quantos pacotes podem executar
  /// simultaneamente (padrão: número de processadores).
  MonorepoRunner({
    required this.rootPath,
    this.concurrency = 1,
  });
  
  /// Caminho raiz do monorepo
  final String rootPath;
  
  /// Número de pacotes executados em paralelo
  final int concurrency;
}
```

#### Comentários Inline

```dart
// Use comentários inline para explicar "por quê", não "o quê"

// ❌ Evite comentários óbvios
// Incrementa o contador
counter++;

// ✅ Explique decisões não óbvias
// Usamos Isolate.run() em vez de compute() porque precisamos
// de acesso completo ao sistema de arquivos e processos
final result = await Isolate.run(() => runner.execute());
```

### Tratamento de Erros

```dart
// ✅ Use exceções específicas
class TestExecutionException implements Exception {
  TestExecutionException(this.message, {this.cause});
  
  final String message;
  final Object? cause;
  
  @override
  String toString() => 'TestExecutionException: $message';
}

// ✅ Capture e trate erros apropriadamente
try {
  await runner.execute();
} on TestExecutionException catch (e) {
  ColoredOutput.writeln(ConsoleColor.red, e.message);
  exit(1);
} catch (e, stackTrace) {
  ColoredOutput.writeln(ConsoleColor.red, 'Unexpected error: $e');
  if (verbose) {
    print(stackTrace);
  }
  exit(1);
}
```

### Async/Await

```dart
// ✅ Use async/await para código assíncrono
Future<int> executeTests() async {
  final tests = await findTests();
  final results = await runTests(tests);
  return results.exitCode;
}

// ❌ Evite misturar then() com async/await
Future<int> executeTests() async {
  final tests = await findTests();
  return runTests(tests).then((results) => results.exitCode);
}

// ✅ Use Future.wait para operações paralelas
final results = await Future.wait([
  runTests(package1),
  runTests(package2),
  runTests(package3),
]);

// ✅ Use unawaited para fire-and-forget (com cuidado)
import 'package:meta/meta.dart';

unawaited(logAnalytics(event)); // Não bloqueia execução
```

## Processo de Desenvolvimento

### 1. Escolha uma Issue

- Procure issues com label `good first issue` para começar
- Comente na issue que você vai trabalhar nela
- Aguarde confirmação de um maintainer

### 2. Crie uma Branch

```bash
# Feature
git checkout -b feature/add-dashboard-output

# Bug fix
git checkout -b fix/handle-empty-test-directory

# Documentação
git checkout -b docs/improve-architecture-guide
```

### 3. Desenvolva

```bash
# Faça commits pequenos e frequentes
git add .
git commit -m "feat: add initial dashboard structure"

# Continue desenvolvendo
git commit -m "feat: implement real-time updates"
git commit -m "test: add dashboard tests"
git commit -m "docs: update README with dashboard usage"
```

### 4. Mantenha Atualizado

```bash
# Sincronize com main regularmente
git fetch origin
git rebase origin/main
```

### 5. Teste Localmente

```bash
# Execute todos os testes
dart test

# Execute análise estática
dart analyze

# Formate código
dart format .

# Teste o comando localmente
dart pub global activate --source path .
fastest --help
```

## Testes

### Estrutura de Testes

```
test/
├── src/
│   ├── args/
│   │   └── args_parser_test.dart
│   ├── runner/
│   │   ├── test_runner_test.dart
│   │   └── monorepo_executor_test.dart
│   └── view/
│       └── test_output_test.dart
└── integration/
    └── full_workflow_test.dart
```

### Escrevendo Testes

#### Testes Unitários

```dart
import 'package:test/test.dart';

void main() {
  group('ArgsParser', () {
    late ArgsParser parser;
    
    setUp(() {
      parser = ArgsParser();
    });
    
    test('should parse coverage flag', () async {
      await parser(['--coverage']);
      expect(parser.coverage, isTrue);
    });
    
    test('should throw on invalid path', () {
      expect(
        () => parser(['/invalid/path']),
        throwsA(isA<PathNotFoundException>()),
      );
    });
  });
}
```

#### Testes com Mocks

```dart
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProcessHandler extends Mock implements ProcessHandler {}

void main() {
  group('TestRunner', () {
    late MockProcessHandler mockProcess;
    late TestRunner runner;
    
    setUp(() {
      mockProcess = MockProcessHandler();
      runner = TestRunner(
        testPath: '/test',
        processHandler: mockProcess,
      );
    });
    
    test('should execute flutter test command', () async {
      when(() => mockProcess.startProcess(any(), any()))
          .thenAnswer((_) async => MockProcess());
      
      await runner.execute();
      
      verify(() => mockProcess.startProcess('flutter', any())).called(1);
    });
  });
}
```

#### Testes de Integração

```dart
void main() {
  group('Full Workflow', () {
    test('should execute tests in monorepo', () async {
      final tempDir = Directory.systemTemp.createTempSync('fastest_test');
      
      try {
        // Setup test environment
        await _createTestMonorepo(tempDir);
        
        // Execute
        final runner = MonorepoRunner(
          rootPath: tempDir.path,
          concurrency: 2,
        );
        final exitCode = await runner.execute();
        
        // Verify
        expect(exitCode, equals(0));
      } finally {
        // Cleanup
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
```

### Cobertura de Testes

```bash
# Gere relatório de cobertura
dart test --coverage=coverage
dart pub global activate coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# Visualize no navegador
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Meta**: Manter cobertura acima de 80%

## Documentação

### README.md
- Mantenha atualizado com novas features
- Adicione exemplos práticos
- Inclua troubleshooting comum

### CHANGELOG.md
- Siga [Keep a Changelog](https://keepachangelog.com/)
- Categorize mudanças: Added, Changed, Deprecated, Removed, Fixed, Security

```markdown
## [Unreleased]

### Added
- Dashboard interativo para visualização de testes em tempo real

### Changed
- Melhorada formatação de saída em modo monorepo

### Fixed
- Corrigido problema com paths contendo espaços
```

### Documentação de API
- Use `dart doc` para gerar documentação
- Documente todas as APIs públicas
- Inclua exemplos de uso

## Pull Requests

### Checklist

Antes de submeter um PR, verifique:

- [ ] Código formatado (`dart format .`)
- [ ] Análise estática passou (`dart analyze`)
- [ ] Todos os testes passam (`dart test`)
- [ ] Novos testes adicionados para novas features
- [ ] Documentação atualizada
- [ ] CHANGELOG.md atualizado
- [ ] Commits seguem convenção (ver abaixo)

### Convenção de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação, ponto e vírgula, etc
- `refactor`: Refatoração de código
- `test`: Adição ou correção de testes
- `chore`: Manutenção, dependências, etc

**Exemplos**:
```
feat(runner): add dashboard output mode

Implements real-time dashboard for test execution visualization.
Includes progress bars and package status indicators.

Closes #123
```

```
fix(parser): handle paths with spaces correctly

Previously, paths containing spaces would cause parsing errors.
Now properly escapes and handles such paths.

Fixes #456
```

### Template de PR

```markdown
## Descrição
Breve descrição das mudanças

## Motivação
Por que essa mudança é necessária?

## Mudanças
- Lista de mudanças principais
- Outra mudança

## Testes
Como foi testado?

## Screenshots (se aplicável)
Adicione screenshots para mudanças visuais

## Checklist
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] CHANGELOG.md atualizado
```

### Processo de Review

1. **Automated Checks**: CI/CD executa testes e análise
2. **Code Review**: Maintainer revisa código
3. **Feedback**: Discussão e ajustes se necessário
4. **Approval**: Maintainer aprova PR
5. **Merge**: PR é mergeado para main

### Respondendo a Feedback

- Seja receptivo a sugestões
- Faça perguntas se não entender
- Faça commits adicionais para ajustes
- Marque conversas como resolvidas

## Dicas para Contribuidores

### Performance

```dart
// ✅ Use const quando possível
const separator = '=' * 80;

// ✅ Evite operações desnecessárias em loops
final length = list.length; // Cache fora do loop
for (var i = 0; i < length; i++) {
  // ...
}

// ✅ Use StringBuffer para concatenação
final buffer = StringBuffer();
for (final item in items) {
  buffer.writeln(item);
}
```

### Debugging

```dart
// Use print statements temporários
print('DEBUG: testPath = $testPath');

// Use debugger breakpoint
import 'dart:developer';
debugger(); // Pausa execução no debugger

// Use assert para validações em desenvolvimento
assert(testPath.isNotEmpty, 'testPath should not be empty');
```

### Ferramentas Úteis

```bash
# Watch mode para desenvolvimento
dart test --watch

# Análise com fix automático
dart fix --apply

# Pub outdated
dart pub outdated

# Dependency tree
dart pub deps
```

## Comunidade

### Onde Pedir Ajuda

- 💬 GitHub Discussions: Perguntas gerais
- 🐛 GitHub Issues: Bugs e features
- 📧 Email: Para questões privadas

### Reconhecimento

Contribuidores são reconhecidos em:
- README.md (seção Contributors)
- Release notes
- CHANGELOG.md

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto (MIT).

---

**Obrigado por contribuir com o FasTest! 🚀**
