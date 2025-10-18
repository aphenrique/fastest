# API Reference - FasTest

Documentação completa da API pública do FasTest para desenvolvedores que desejam estender ou integrar a ferramenta.

## Índice

- [Visão Geral](#visão-geral)
- [Core APIs](#core-apis)
- [Runner APIs](#runner-apis)
- [View APIs](#view-apis)
- [Process APIs](#process-apis)
- [Optimizer APIs](#optimizer-apis)
- [Exemplos de Uso](#exemplos-de-uso)

---

## Visão Geral

O FasTest expõe APIs públicas através do pacote `fastest`. A maioria das implementações internas está em `lib/src/` e não deve ser considerada API pública estável.

### Importação

```dart
import 'package:fastest/fastest.dart';
```

---

## Core APIs

### Runner

Interface base para todos os executores de testes.

```dart
abstract class Runner {
  /// Cria uma nova instância de Runner baseada no tipo de projeto
  factory Runner({
    required bool isPackage,
    required String testPath,
    required bool coverage,
    required int concurrency,
    required bool failFast,
    required bool verbose,
    ProcessHandler? processHandler,
  });

  /// Executa a tarefa e retorna o código de saída
  /// 
  /// Retorna:
  /// - 0: Todos os testes passaram
  /// - 1: Pelo menos um teste falhou
  /// - >1: Erro de execução
  Future<int> execute();
}
```

#### Exemplo

```dart
final runner = Runner(
  isPackage: false,
  testPath: '/path/to/tests',
  coverage: true,
  concurrency: 4,
  failFast: false,
  verbose: true,
);

final exitCode = await runner.execute();
if (exitCode == 0) {
  print('Todos os testes passaram!');
} else {
  print('Alguns testes falharam.');
}
```

---

## Runner APIs

### TestRunner

Executor de testes para um único pacote.

```dart
class TestRunner implements Runner {
  /// Cria uma nova instância de TestRunner
  TestRunner({
    required String testPath,
    bool coverage = false,
    int concurrency = 1,
    bool failFast = false,
    bool verbose = false,
    ProcessHandler? processHandler,
    TestOutput? testOutput,
  });

  /// Caminho para os testes
  final String testPath;
  
  /// Habilita cobertura de código
  final bool coverage;
  
  /// Número de processos concorrentes
  final int concurrency;
  
  /// Interrompe no primeiro erro
  final bool failFast;
  
  /// Modo verbose
  final bool verbose;
  
  /// Nome do pacote (derivado do testPath)
  String get packageName;
  
  @override
  Future<int> execute();
}
```

#### Exemplo

```dart
final runner = TestRunner(
  testPath: '/path/to/my_package',
  coverage: true,
  concurrency: 4,
  verbose: true,
);

final exitCode = await runner.execute();
```

### MonorepoRunner

Executor de testes para ambientes monorepo.

```dart
class MonorepoRunner implements Runner {
  /// Cria uma nova instância de MonorepoRunner
  MonorepoRunner({
    required String rootPath,
    required bool coverage,
    required int concurrency,
    bool failFast = false,
    bool verbose = false,
    ProcessHandler? processHandler,
  });

  /// Caminho raiz do monorepo
  final String rootPath;
  
  /// Habilita cobertura de código
  final bool coverage;
  
  /// Número de pacotes executados em paralelo
  final int concurrency;
  
  /// Interrompe no primeiro erro
  final bool failFast;
  
  /// Modo verbose
  final bool verbose;
  
  @override
  Future<int> execute();
}
```

#### Exemplo

```dart
final runner = MonorepoRunner(
  rootPath: '/path/to/monorepo',
  coverage: false,
  concurrency: 4,
  failFast: true,
  verbose: false,
);

final exitCode = await runner.execute();
```

### MonorepoExecutor

Gerencia execução paralela de múltiplos pacotes.

```dart
class MonorepoExecutor {
  /// Cria uma nova instância de MonorepoExecutor
  MonorepoExecutor({
    required List<MonorepoPackage> packages,
    required int concurrency,
    bool coverage = false,
    bool failFast = false,
    bool verbose = false,
    ProcessHandler? processHandler,
  });

  /// Lista de pacotes a serem executados
  final List<MonorepoPackage> packages;
  
  /// Número de pacotes executados simultaneamente
  final int concurrency;
  
  /// Habilita cobertura de código
  final bool coverage;
  
  /// Interrompe no primeiro erro
  final bool failFast;
  
  /// Modo verbose
  final bool verbose;
  
  /// Executa os testes em paralelo para todos os pacotes
  Future<int> execute();
}
```

---

## View APIs

### TestOutput

Interface para gerenciar a saída dos testes.

```dart
abstract class TestOutput {
  /// Cria uma instância de TestOutput baseada no modo verbose
  factory TestOutput(
    bool verbose, {
    required String packageName,
    required bool failFast,
    bool isMonorepo = false,
    int? totalPackages,
    int? currentPackage,
  });

  /// Processa a saída padrão dos testes
  Stream<List<int>> output(Stream<List<int>> output);

  /// Processa a saída de erro dos testes
  Stream<List<int>> error(Stream<List<int>> output);

  /// Formata o nome do pacote para exibição
  String formatPackageName(String packageName);
}
```

#### Implementações

##### VerboseModeTestOutput

Exibe toda a saída em tempo real.

```dart
class VerboseModeTestOutput implements TestOutput {
  VerboseModeTestOutput({
    required String packageName,
    required bool failFast,
    bool isMonorepo = false,
    int? totalPackages,
    int? currentPackage,
  });
}
```

##### StandardModeTestOutput

Acumula saída e exibe ao final.

```dart
class StandardModeTestOutput implements TestOutput {
  StandardModeTestOutput({
    required String packageName,
    required bool failFast,
    bool isMonorepo = false,
    int? totalPackages,
    int? currentPackage,
  });
}
```

#### Exemplo de Uso Customizado

```dart
class CustomTestOutput implements TestOutput {
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();
    
    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        // Processamento customizado
        print('Custom: $event');
      },
      onDone: () => controller.close(),
    );
    
    return controller.stream;
  }
  
  @override
  Stream<List<int>> error(Stream<List<int>> output) {
    // Implementação similar
  }
  
  @override
  String formatPackageName(String packageName) {
    return '🎯 $packageName';
  }
}

// Uso
final runner = TestRunner(
  testPath: '/path/to/tests',
  testOutput: CustomTestOutput(),
);
```

### ColoredOutput

Utilitário para saída colorida no terminal.

```dart
class ColoredOutput {
  /// Escreve uma linha colorida no stdout
  static void writeln(ConsoleColor color, String message);
  
  /// Escreve texto colorido sem quebra de linha
  static void write(ConsoleColor color, String message);
  
  /// Retorna uma string formatada com cor
  static String line(ConsoleColor color, String message);
}
```

#### Exemplo

```dart
ColoredOutput.writeln(ConsoleColor.green, '✓ Teste passou!');
ColoredOutput.writeln(ConsoleColor.red, '✗ Teste falhou!');
ColoredOutput.write(ConsoleColor.yellow, 'Aviso: ');
print('mensagem de aviso');
```

### ConsoleColor

Enum com cores disponíveis.

```dart
enum ConsoleColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  reset,
}
```

### LoadingIndicator

Animação de loading no console.

```dart
class LoadingIndicator {
  /// Cria um novo indicador de loading
  LoadingIndicator({
    String message = 'Executando testes...',
  });

  /// Mensagem exibida durante o loading
  final String message;
  
  /// Inicia a animação de loading
  void start();
  
  /// Para a animação de loading
  void stop();
}
```

#### Exemplo

```dart
final loading = LoadingIndicator(message: 'Processando...');
loading.start();

try {
  await longRunningOperation();
} finally {
  loading.stop();
}
```

---

## Process APIs

### ProcessHandler

Interface para execução de processos.

```dart
abstract class ProcessHandler {
  /// Inicia um novo processo
  Future<Process> startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  });

  /// Gerencia a saída do processo
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  );
}
```

#### DefaultProcessHandler

Implementação padrão usando `Process.start()`.

```dart
class DefaultProcessHandler implements ProcessHandler {
  const DefaultProcessHandler();
  
  @override
  Future<Process> startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  });
  
  @override
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  );
}
```

#### Exemplo de Mock para Testes

```dart
class MockProcessHandler implements ProcessHandler {
  final int exitCode;
  final String stdout;
  final String stderr;
  
  MockProcessHandler({
    this.exitCode = 0,
    this.stdout = '',
    this.stderr = '',
  });
  
  @override
  Future<Process> startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    return MockProcess(
      exitCode: exitCode,
      stdout: stdout,
      stderr: stderr,
    );
  }
  
  @override
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  ) async {
    return exitCode;
  }
}

// Uso em testes
final mockHandler = MockProcessHandler(
  exitCode: 0,
  stdout: 'All tests passed!',
);

final runner = TestRunner(
  testPath: '/path/to/tests',
  processHandler: mockHandler,
);
```

---

## Optimizer APIs

### TestOptimizer

Otimiza testes agregando-os em um único arquivo.

```dart
class TestOptimizer {
  /// Otimiza os testes no caminho especificado
  /// 
  /// Retorna o caminho do arquivo otimizado gerado
  String call(String testPath);
}
```

#### Exemplo

```dart
final optimizer = TestOptimizer();
final optimizedFile = optimizer('/path/to/tests');
print('Arquivo otimizado: $optimizedFile');
// Output: Arquivo otimizado: /path/to/tests/.test_optimizer.dart
```

### TestFinder

Encontra arquivos de teste recursivamente.

```dart
class TestFinder {
  /// Encontra todos os arquivos *_test.dart no caminho especificado
  List<String> findTests(String path);
}
```

#### Exemplo

```dart
final finder = TestFinder();
final tests = finder.findTests('/path/to/tests');
for (final test in tests) {
  print('Encontrado: $test');
}
```

### AliasGenerator

Gera aliases únicos para evitar conflitos de nomes.

```dart
class AliasGenerator {
  /// Gera um alias único para o arquivo de teste
  String generateAlias(String testFilePath);
}
```

#### Exemplo

```dart
final generator = AliasGenerator();
final alias = generator.generateAlias('/path/to/user_test.dart');
print(alias); // Output: user_test_abc123
```

---

## Package APIs

### MonorepoPackage

Representa um pacote em um monorepo.

```dart
class MonorepoPackage {
  /// Cria uma nova instância de MonorepoPackage
  MonorepoPackage({
    required String name,
    required String path,
  });

  /// Nome do pacote
  final String name;
  
  /// Caminho absoluto do pacote
  final String path;
  
  @override
  String toString() => 'MonorepoPackage($name, $path)';
}
```

### PackageFinder

Encontra pacotes em um monorepo.

```dart
class PackageFinder {
  /// Cria uma nova instância de PackageFinder
  PackageFinder({
    required String rootPath,
  });

  /// Caminho raiz do monorepo
  final String rootPath;
  
  /// Encontra todos os pacotes com testes
  Future<List<MonorepoPackage>> findPackages();
}
```

#### Exemplo

```dart
final finder = PackageFinder(rootPath: '/path/to/monorepo');
final packages = await finder.findPackages();

for (final package in packages) {
  print('Pacote: ${package.name} em ${package.path}');
}
```

---

## Args APIs

### ArgsParser

Parser de argumentos de linha de comando.

```dart
class ArgsParser {
  /// Processa os argumentos fornecidos
  Future<void> call(List<String> args);

  /// Lista de argumentos posicionais não processados
  List<String> get rest;

  /// Indica se a coleta de cobertura está habilitada
  bool get coverage;

  /// Indica se o modo package está ativo
  bool get isPackage;

  /// Indica se deve confirmar automaticamente
  bool get autoConfirm;

  /// Indica se deve interromper no primeiro erro
  bool get failFast;

  /// Indica se deve exibir saída detalhada
  bool get verbose;

  /// Número de processos concorrentes
  int get concurrency;

  /// Caminho onde os testes serão executados
  String get testPath;

  /// Retorna o texto de ajuda
  String get usage;
}
```

#### Exemplo

```dart
final parser = ArgsParser();
await parser(['--coverage', '--package', '/path/to/monorepo']);

print('Coverage: ${parser.coverage}');
print('Is Package: ${parser.isPackage}');
print('Test Path: ${parser.testPath}');
```

---

## Coverage APIs

### CoverageCheck

Verifica instalação do pacote de cobertura.

```dart
class CoverageCheck {
  /// Verifica se full_coverage está instalado
  static Future<void> verify({
    bool autoConfirm = false,
  });
}
```

### CoverageHandler

Gerencia cobertura de código.

```dart
class CoverageHandler {
  /// Verifica se a estrutura de diretórios suporta cobertura
  void verifyCoverage(String testPath, bool coverage);
}
```

---

## Exemplos de Uso

### Exemplo 1: Execução Simples

```dart
import 'package:fastest/fastest.dart';

void main() async {
  final runner = Runner(
    isPackage: false,
    testPath: './test',
    coverage: false,
    concurrency: 4,
    failFast: false,
    verbose: true,
  );

  final exitCode = await runner.execute();
  exit(exitCode);
}
```

### Exemplo 2: Monorepo com Cobertura

```dart
import 'package:fastest/fastest.dart';

void main() async {
  final runner = Runner(
    isPackage: true,
    testPath: './packages',
    coverage: true,
    concurrency: 8,
    failFast: true,
    verbose: false,
  );

  final exitCode = await runner.execute();
  
  if (exitCode == 0) {
    print('✅ Todos os testes passaram!');
  } else {
    print('❌ Alguns testes falharam.');
  }
  
  exit(exitCode);
}
```

### Exemplo 3: Custom Output Handler

```dart
import 'dart:async';
import 'dart:io';
import 'package:fastest/fastest.dart';

class JsonTestOutput implements TestOutput {
  final List<Map<String, dynamic>> events = [];
  
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();
    
    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        events.add({
          'type': 'output',
          'message': event,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      onDone: () {
        // Salva eventos em arquivo JSON
        File('test-output.json').writeAsStringSync(
          jsonEncode(events),
        );
        controller.close();
      },
    );
    
    return controller.stream;
  }
  
  @override
  Stream<List<int>> error(Stream<List<int>> output) {
    // Similar ao output
  }
  
  @override
  String formatPackageName(String packageName) => packageName;
}

void main() async {
  final customOutput = JsonTestOutput();
  
  final runner = TestRunner(
    testPath: './test',
    testOutput: customOutput,
  );

  await runner.execute();
  
  print('Eventos salvos em test-output.json');
}
```

### Exemplo 4: Integração com CI/CD

```dart
import 'package:fastest/fastest.dart';

Future<void> main(List<String> args) async {
  // Parse argumentos do CI
  final parser = ArgsParser();
  await parser(args);

  // Configura runner
  final runner = Runner(
    isPackage: parser.isPackage,
    testPath: parser.testPath,
    coverage: parser.coverage,
    concurrency: parser.concurrency,
    failFast: true, // Sempre fail-fast no CI
    verbose: false, // Saída limpa no CI
  );

  // Executa testes
  final exitCode = await runner.execute();

  // Gera relatório
  if (exitCode != 0) {
    print('::error::Tests failed');
  } else {
    print('::notice::All tests passed');
  }

  exit(exitCode);
}
```

### Exemplo 5: Testes Unitários com Mock

```dart
import 'package:test/test.dart';
import 'package:fastest/fastest.dart';

class MockProcessHandler implements ProcessHandler {
  final int mockExitCode;
  
  MockProcessHandler(this.mockExitCode);
  
  @override
  Future<Process> startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    return MockProcess(exitCode: mockExitCode);
  }
  
  @override
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  ) async {
    return mockExitCode;
  }
}

void main() {
  test('TestRunner should return exit code from process', () async {
    final mockHandler = MockProcessHandler(0);
    
    final runner = TestRunner(
      testPath: '/test',
      processHandler: mockHandler,
    );

    final exitCode = await runner.execute();
    
    expect(exitCode, equals(0));
  });
}
```

---

## Versionamento e Compatibilidade

### Política de Versionamento

O FasTest segue [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs compatíveis

### Deprecation Policy

APIs deprecadas serão mantidas por pelo menos 2 minor versions antes de serem removidas.

```dart
@Deprecated('Use newMethod() instead. Will be removed in v0.5.0')
void oldMethod() {
  // ...
}
```

---

## Suporte e Contribuições

### Reportar Bugs na API
- Use o template de issue no GitHub
- Inclua versão do FasTest
- Forneça exemplo mínimo reproduzível

### Sugerir Melhorias na API
- Abra uma discussão no GitHub
- Explique o caso de uso
- Proponha interface

### Contribuir com Código
- Veja [CONTRIBUTING.md](CONTRIBUTING.md)
- Mantenha compatibilidade com API existente
- Adicione testes para novas APIs

---

## Recursos Adicionais

- [Arquitetura](ARCHITECTURE.md)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)
- [Melhorias Propostas](IMPROVEMENTS.md)

---

**Documentação gerada para FasTest v0.1.11**
