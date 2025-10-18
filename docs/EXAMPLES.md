# Exemplos Práticos - FasTest

Este documento contém exemplos práticos de uso do FasTest em diferentes cenários.

## Índice

- [Uso Básico](#uso-básico)
- [Projetos Flutter](#projetos-flutter)
- [Monorepo](#monorepo)
- [Cobertura de Código](#cobertura-de-código)
- [Integração CI/CD](#integração-cicd)
- [Uso Programático](#uso-programático)
- [Troubleshooting](#troubleshooting)

---

## Uso Básico

### Executar testes na pasta atual

```bash
fastest
```

### Executar testes em uma pasta específica

```bash
fastest test/
fastest packages/my_package/test/
```

### Executar com modo verbose

```bash
fastest --verbose
fastest -v
```

### Executar com fail-fast (para no primeiro erro)

```bash
fastest --fail-fast
fastest -f
```

---

## Projetos Flutter

### Projeto Flutter Simples

```bash
cd my_flutter_app
fastest test/
```

### Projeto Flutter com Cobertura

```bash
cd my_flutter_app
fastest --coverage
```

O FasTest irá:
1. Verificar se `full_coverage` está instalado
2. Oferecer instalação interativa se necessário
3. Executar os testes com cobertura
4. Gerar relatório em `coverage/lcov.info`

### Instalação Automática de Dependências

```bash
# Instala full_coverage automaticamente sem perguntar
fastest --coverage -y
fastest --coverage --auto-confirm
```

---

## Monorepo

### Estrutura de Exemplo

```
my_monorepo/
├── packages/
│   ├── core/
│   │   ├── lib/
│   │   └── test/
│   ├── ui/
│   │   ├── lib/
│   │   └── test/
│   └── api/
│       ├── lib/
│       └── test/
└── pubspec.yaml
```

### Executar todos os pacotes

```bash
cd my_monorepo
fastest --package
```

### Executar com concorrência customizada

```bash
# Executa 2 pacotes em paralelo
fastest --package --concurrency=2

# Executa 8 pacotes em paralelo
fastest --package --concurrency=8
```

### Executar sem concorrência (sequencial)

```bash
fastest --package --no-concurrency
```

### Monorepo com Cobertura

```bash
fastest --package --coverage
```

Cada pacote terá seu próprio relatório de cobertura em `coverage/lcov.info`.

---

## Cobertura de Código

### Gerar Cobertura Básica

```bash
fastest --coverage
```

### Visualizar Cobertura no VS Code

1. Instale a extensão "Coverage Gutters"
2. Execute: `fastest --coverage`
3. Abra um arquivo de código
4. Clique em "Watch" na barra de status

### Gerar Relatório HTML

```bash
# Executar testes com cobertura
fastest --coverage

# Gerar relatório HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Verificar Threshold de Cobertura

```bash
# Executar testes
fastest --coverage

# Verificar cobertura mínima (exemplo: 80%)
lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//' | awk '{if ($1 < 80) exit 1}'
```

---

## Integração CI/CD

### GitHub Actions

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      
      - name: Install FasTest
        run: dart pub global activate fastest
      
      - name: Get dependencies
        run: dart pub get
      
      - name: Run tests
        run: fastest --fail-fast
      
      - name: Run tests with coverage
        run: fastest --coverage -y
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### GitHub Actions - Monorepo

```yaml
name: Monorepo Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install FasTest
        run: dart pub global activate fastest
      
      - name: Run all packages tests
        run: fastest --package --concurrency=4 --fail-fast
```

### GitLab CI

```yaml
test:
  image: dart:stable
  
  before_script:
    - dart pub global activate fastest
    - export PATH="$PATH:$HOME/.pub-cache/bin"
  
  script:
    - fastest --coverage -y
  
  coverage: '/lines\.*: \d+\.\d+%/'
  
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/lcov.info
```

### CircleCI

```yaml
version: 2.1

jobs:
  test:
    docker:
      - image: cirrusci/flutter:stable
    
    steps:
      - checkout
      
      - run:
          name: Install FasTest
          command: dart pub global activate fastest
      
      - run:
          name: Run tests
          command: fastest --coverage -y
      
      - store_artifacts:
          path: coverage
```

### Bitbucket Pipelines

```yaml
pipelines:
  default:
    - step:
        name: Test
        image: dart:stable
        script:
          - dart pub global activate fastest
          - export PATH="$PATH:$HOME/.pub-cache/bin"
          - fastest --coverage -y
        artifacts:
          - coverage/**
```

---

## Uso Programático

### Exemplo 1: Script Dart Simples

```dart
import 'dart:io';
import 'package:fastest/fastest.dart';

Future<void> main() async {
  final runner = Runner(
    isPackage: false,
    testPath: './test',
    coverage: false,
    concurrency: 4,
    failFast: false,
    verbose: true,
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

### Exemplo 2: Integração com Build Runner

```dart
import 'dart:io';
import 'package:fastest/fastest.dart';

Future<void> main() async {
  // 1. Gerar código
  print('Gerando código...');
  final buildResult = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  );
  
  if (buildResult.exitCode != 0) {
    print('Erro ao gerar código');
    exit(1);
  }
  
  // 2. Executar testes
  print('Executando testes...');
  final runner = Runner(
    isPackage: false,
    testPath: './test',
    coverage: true,
    concurrency: 4,
    failFast: true,
    verbose: false,
  );

  final exitCode = await runner.execute();
  exit(exitCode);
}
```

### Exemplo 3: Custom Test Output

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fastest/fastest.dart';

class JsonTestOutput implements TestOutput {
  final List<Map<String, dynamic>> events = [];
  final String packageName;
  
  JsonTestOutput(this.packageName);
  
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();
    
    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        events.add({
          'type': 'output',
          'package': packageName,
          'message': event,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      onDone: () {
        // Salva eventos em arquivo JSON
        File('test-output-$packageName.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(events),
        );
        controller.close();
      },
    );
    
    return controller.stream;
  }
  
  @override
  Stream<List<int>> error(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();
    
    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        events.add({
          'type': 'error',
          'package': packageName,
          'message': event,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      onDone: () => controller.close(),
    );
    
    return controller.stream;
  }
  
  @override
  String formatPackageName(String packageName) => packageName;
}

Future<void> main() async {
  final customOutput = JsonTestOutput('my_package');
  
  final runner = TestRunner(
    testPath: './test',
    testOutput: customOutput,
  );

  await runner.execute();
  
  print('Eventos salvos em test-output-my_package.json');
}
```

### Exemplo 4: Testes com Mock

```dart
import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:fastest/fastest.dart';

class MockProcess implements Process {
  final int mockExitCode;
  final String mockStdout;
  final String mockStderr;
  
  MockProcess({
    required this.mockExitCode,
    this.mockStdout = '',
    this.mockStderr = '',
  });
  
  @override
  int get pid => 12345;
  
  @override
  Future<int> get exitCode => Future.value(mockExitCode);
  
  @override
  Stream<List<int>> get stdout => 
    Stream.value(mockStdout.codeUnits);
  
  @override
  Stream<List<int>> get stderr => 
    Stream.value(mockStderr.codeUnits);
  
  @override
  IOSink get stdin => throw UnimplementedError();
  
  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;
}

class MockProcessHandler implements ProcessHandler {
  final int mockExitCode;
  final String mockStdout;
  final String mockStderr;
  
  MockProcessHandler({
    this.mockExitCode = 0,
    this.mockStdout = '',
    this.mockStderr = '',
  });
  
  @override
  Future<Process> startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    return MockProcess(
      mockExitCode: mockExitCode,
      mockStdout: mockStdout,
      mockStderr: mockStderr,
    );
  }
  
  @override
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  ) async {
    await outputHandler(process.stdout).drain();
    await errorHandler(process.stderr).drain();
    return mockExitCode;
  }
}

void main() {
  test('TestRunner should return success exit code', () async {
    final mockHandler = MockProcessHandler(
      mockExitCode: 0,
      mockStdout: 'All tests passed!',
    );
    
    final runner = TestRunner(
      testPath: '/test',
      processHandler: mockHandler,
    );

    final exitCode = await runner.execute();
    
    expect(exitCode, equals(0));
  });
  
  test('TestRunner should return failure exit code', () async {
    final mockHandler = MockProcessHandler(
      mockExitCode: 1,
      mockStderr: 'Test failed!',
    );
    
    final runner = TestRunner(
      testPath: '/test',
      processHandler: mockHandler,
    );

    final exitCode = await runner.execute();
    
    expect(exitCode, equals(1));
  });
}
```

---

## Troubleshooting

### Problema: "Command not found: fastest"

**Solução**: Adicione o diretório pub cache ao PATH

```bash
# Bash/Zsh
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc

# Fish
set -Ua fish_user_paths $HOME/.pub-cache/bin

# Windows (PowerShell)
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

### Problema: "full_coverage not found"

**Solução**: Instale manualmente ou use `-y`

```bash
# Opção 1: Instalação automática
fastest --coverage -y

# Opção 2: Instalação manual
dart pub global activate full_coverage
```

### Problema: Testes não são encontrados

**Solução**: Verifique a estrutura de diretórios

```bash
# Estrutura esperada
project/
├── lib/
└── test/
    ├── widget_test.dart
    └── unit_test.dart

# Execute na raiz do projeto
fastest test/
```

### Problema: Erro de permissão no CI

**Solução**: Adicione permissões de execução

```yaml
# GitHub Actions
- name: Install FasTest
  run: |
    dart pub global activate fastest
    export PATH="$PATH:$HOME/.pub-cache/bin"
    chmod +x $HOME/.pub-cache/bin/fastest
```

### Problema: Saída confusa em modo paralelo

**Solução**: Use modo verbose ou reduza concorrência

```bash
# Opção 1: Modo verbose
fastest --package --verbose

# Opção 2: Reduzir concorrência
fastest --package --concurrency=1

# Opção 3: Desabilitar concorrência
fastest --package --no-concurrency
```

### Problema: Cobertura não é gerada

**Solução**: Verifique instalação do full_coverage

```bash
# Verificar instalação
dart pub global list | grep full_coverage

# Reinstalar se necessário
dart pub global activate full_coverage

# Executar com verbose para debug
fastest --coverage --verbose
```

### Problema: Memória insuficiente em monorepo grande

**Solução**: Reduza a concorrência

```bash
# Reduzir para 2 pacotes simultâneos
fastest --package --concurrency=2

# Executar sequencialmente
fastest --package --no-concurrency
```

### Problema: Testes passam localmente mas falham no CI

**Solução**: Verifique versões e dependências

```yaml
# GitHub Actions - Fixar versões
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.16.0'  # Versão específica

- name: Get dependencies
  run: flutter pub get

- name: Run tests
  run: fastest --fail-fast --verbose
```

---

## Dicas e Boas Práticas

### 1. Use .gitignore

Sempre adicione o arquivo otimizado ao `.gitignore`:

```bash
echo ".test_optimizer.dart" >> .gitignore
```

### 2. Configure Concorrência Adequada

```bash
# Para máquinas com 4 cores
fastest --concurrency=4

# Para máquinas com 8+ cores
fastest --concurrency=8

# Para CI com recursos limitados
fastest --concurrency=2
```

### 3. Use Fail-Fast em CI

```bash
# Para no primeiro erro, economizando tempo de CI
fastest --fail-fast
```

### 4. Combine com Outras Ferramentas

```bash
# Análise + Testes + Cobertura
dart analyze && fastest --coverage
```

### 5. Scripts NPM/Makefile

**package.json**:
```json
{
  "scripts": {
    "test": "fastest",
    "test:coverage": "fastest --coverage",
    "test:verbose": "fastest --verbose",
    "test:ci": "fastest --fail-fast --coverage -y"
  }
}
```

**Makefile**:
```makefile
.PHONY: test coverage test-verbose test-ci

test:
	fastest

coverage:
	fastest --coverage

test-verbose:
	fastest --verbose

test-ci:
	fastest --fail-fast --coverage -y
```

---

## Recursos Adicionais

- [Documentação Completa](README.md)
- [Arquitetura](ARCHITECTURE.md)
- [API Reference](API.md)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)

---

**Última atualização**: Janeiro 2024  
**Versão**: 1.0.0
