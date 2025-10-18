# Propostas de Melhorias para Exibição de Testes Paralelos

## Problema Atual

Quando múltiplos pacotes executam testes em paralelo usando Isolates, as saídas podem se misturar no console, causando:

1. **Confusão Visual**: Mensagens de diferentes pacotes intercaladas
2. **Perda de Contexto**: Difícil associar mensagens a pacotes específicos
3. **Poluição de Saída**: Warnings e mensagens repetidas
4. **Falta de Progresso**: Usuário não sabe quantos pacotes faltam
5. **Debugging Difícil**: Identificar origem de erros é complicado

### Exemplo do Problema
```
[01/04] package_a > Executando testes...
[02/04] package_b > Executando testes...
[02/04] package_b > Warning: deprecated API
[01/04] package_a > All tests passed!
[03/04] package_c > Executando testes...
[02/04] package_b > [E] Test failed: assertion error
[03/04] package_c > Warning: deprecated API
```

## Propostas de Melhorias

### 1. Sistema de Buffer por Pacote com Exibição Sequencial

#### Descrição
Cada pacote acumula sua saída em um buffer isolado. Quando um pacote termina, sua saída completa é exibida de uma vez, evitando intercalação.

#### Implementação
```dart
class BufferedTestOutput implements TestOutput {
  final StringBuffer _outputBuffer = StringBuffer();
  final StringBuffer _errorBuffer = StringBuffer();
  final String packageName;
  final Completer<void> _completer = Completer();
  
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        _outputBuffer.writeln('$packageName > $event');
      },
      onDone: () {
        _completer.complete();
      },
    );
    return Stream.empty();
  }
  
  Future<void> flush() async {
    await _completer.future;
    stdout.write(_outputBuffer.toString());
    if (_errorBuffer.isNotEmpty) {
      stderr.write(_errorBuffer.toString());
    }
  }
}
```

#### Vantagens
✅ Saída limpa e organizada  
✅ Fácil de implementar  
✅ Mantém ordem cronológica de conclusão  

#### Desvantagens
❌ Usuário não vê progresso em tempo real  
❌ Pode parecer "travado" em testes longos  
❌ Não funciona bem com `--verbose`  

---

### 2. Sistema de Seções Visuais com Separadores

#### Descrição
Usar separadores visuais claros entre saídas de diferentes pacotes, com cabeçalhos destacados.

#### Implementação
```dart
class SectionedTestOutput implements TestOutput {
  static const String _separator = '═' * 80;
  static const String _thinSeparator = '─' * 80;
  
  void _printHeader() {
    ColoredOutput.writeln(ConsoleColor.cyan, _separator);
    ColoredOutput.writeln(
      ConsoleColor.cyan,
      '  📦 ${formatPackageName(packageName)}',
    );
    ColoredOutput.writeln(ConsoleColor.cyan, _thinSeparator);
  }
  
  void _printFooter(bool success) {
    ColoredOutput.writeln(
      success ? ConsoleColor.green : ConsoleColor.red,
      _thinSeparator,
    );
    ColoredOutput.writeln(
      success ? ConsoleColor.green : ConsoleColor.red,
      success ? '  ✓ Testes concluídos' : '  ✗ Testes falharam',
    );
    ColoredOutput.writeln(ConsoleColor.cyan, _separator);
  }
}
```

#### Exemplo de Saída
```
════════════════════════════════════════════════════════════════════════════════
  📦 [01/04] package_a
────────────────────────────────────────────────────────────────────────────────
  Running tests...
  All tests passed!
────────────────────────────────────────────────────────────────────────────────
  ✓ Testes concluídos
════════════════════════════════════════════════════════════════════════════════

════════════════════════════════════════════════════════════════════════════════
  📦 [02/04] package_b
────────────────────────────────────────────────────────────────────────────────
  Running tests...
  [E] Test failed
────────────────────────────────────────────────────────────────────────────────
  ✗ Testes falharam
════════════════════════════════════════════════════════════════════════════════
```

#### Vantagens
✅ Separação visual clara  
✅ Fácil identificar início/fim de cada pacote  
✅ Funciona com saída em tempo real  

#### Desvantagens
❌ Ocupa mais espaço vertical  
❌ Ainda pode haver intercalação  

---

### 3. Dashboard Interativo em Tempo Real (TUI)

#### Descrição
Criar uma interface de terminal interativa (TUI) que mostra status de todos os pacotes simultaneamente, similar ao `docker-compose` ou `k9s`.

#### Implementação
Usar biblioteca como `dart_console` ou implementar com ANSI escape codes.

```dart
class DashboardTestOutput {
  final Map<String, PackageStatus> _packages = {};
  
  void render() {
    // Limpa tela
    stdout.write('\x1B[2J\x1B[H');
    
    // Header
    _printHeader();
    
    // Status de cada pacote
    for (final entry in _packages.entries) {
      _printPackageStatus(entry.key, entry.value);
    }
    
    // Footer com resumo
    _printSummary();
  }
  
  void _printPackageStatus(String name, PackageStatus status) {
    final icon = status.icon;
    final color = status.color;
    final progress = status.progress;
    
    ColoredOutput.writeln(
      color,
      '$icon [$progress] $name - ${status.message}',
    );
  }
}

class PackageStatus {
  final String state; // 'pending', 'running', 'success', 'failed'
  final String message;
  final int testsRun;
  final int testsFailed;
  
  String get icon {
    switch (state) {
      case 'pending': return '⏳';
      case 'running': return '🔄';
      case 'success': return '✅';
      case 'failed': return '❌';
      default: return '❓';
    }
  }
  
  String get progress => '$testsRun tests';
}
```

#### Exemplo de Saída
```
╔════════════════════════════════════════════════════════════════╗
║                    FasTest - Execution Dashboard                ║
║                    Running: 2/4 | Completed: 2/4                ║
╚════════════════════════════════════════════════════════════════╝

✅ [100%] package_a - All tests passed! (45 tests)
🔄 [ 60%] package_b - Running tests... (12/20 tests)
🔄 [ 30%] package_c - Running tests... (5/15 tests)
⏳ [  0%] package_d - Waiting...

╔════════════════════════════════════════════════════════════════╗
║ Total: 62/80 tests | Passed: 57 | Failed: 0 | Elapsed: 12.5s  ║
╚════════════════════════════════════════════════════════════════╝
```

#### Vantagens
✅ Visão completa do progresso  
✅ Atualização em tempo real  
✅ Experiência profissional  
✅ Fácil identificar gargalos  

#### Desvantagens
❌ Complexidade de implementação  
❌ Requer parsing de saída do Flutter test  
❌ Pode não funcionar em todos os terminais  
❌ Dificulta copiar/colar saída  

---

### 4. Sistema de Logs Estruturados com Timestamps

#### Descrição
Adicionar timestamps precisos a cada linha de saída e usar prefixos coloridos consistentes.

#### Implementação
```dart
class TimestampedTestOutput implements TestOutput {
  final DateTime _startTime = DateTime.now();
  
  String _formatTimestamp() {
    final elapsed = DateTime.now().difference(_startTime);
    final seconds = elapsed.inSeconds.toString().padLeft(3, '0');
    final millis = (elapsed.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$seconds.$millis';
  }
  
  String _formatLine(String message) {
    final timestamp = _formatTimestamp();
    final prefix = _getColoredPrefix();
    return '[$timestamp] $prefix $message';
  }
  
  String _getColoredPrefix() {
    // Atribui cor única por pacote usando hash
    final colors = [
      ConsoleColor.cyan,
      ConsoleColor.magenta,
      ConsoleColor.yellow,
      ConsoleColor.blue,
    ];
    final colorIndex = packageName.hashCode % colors.length;
    return ColoredOutput.line(colors[colorIndex], packageName.padRight(20));
  }
}
```

#### Exemplo de Saída
```
[000.123] package_a            > Running tests...
[000.456] package_b            > Running tests...
[001.234] package_a            > Test: user_service_test
[001.567] package_c            > Running tests...
[002.345] package_b            > [E] Test failed: assertion
[003.456] package_a            > All tests passed!
[004.567] package_c            > All tests passed!
```

#### Vantagens
✅ Fácil rastrear ordem cronológica  
✅ Cores ajudam a identificar pacotes  
✅ Útil para debugging  
✅ Compatível com logs  

#### Desvantagens
❌ Saída mais verbosa  
❌ Ainda pode haver confusão visual  

---

### 5. Sistema de Canais com Multiplexação (Recomendado)

#### Descrição
Combinar múltiplas estratégias: buffer + seções + progresso. Cada pacote tem seu "canal" e a saída é multiplexada de forma inteligente.

#### Implementação
```dart
class MultiplexedTestOutput {
  static final _outputQueue = <PackageOutput>[];
  static final _lock = Lock();
  
  Future<void> writeOutput(PackageOutput output) async {
    await _lock.synchronized(() async {
      _outputQueue.add(output);
      await _flushQueue();
    });
  }
  
  Future<void> _flushQueue() async {
    while (_outputQueue.isNotEmpty) {
      final output = _outputQueue.removeAt(0);
      
      // Imprime header
      _printSectionHeader(output.packageName, output.status);
      
      // Imprime conteúdo
      if (output.hasContent) {
        stdout.write(output.content);
      }
      
      // Imprime footer
      _printSectionFooter(output.packageName, output.status);
      
      // Atualiza dashboard de progresso
      _updateProgressBar();
    }
  }
  
  void _updateProgressBar() {
    final completed = _completedPackages.length;
    final total = _totalPackages;
    final percentage = (completed / total * 100).toInt();
    
    stdout.write('\r\x1B[K'); // Limpa linha
    ColoredOutput.write(
      ConsoleColor.cyan,
      'Progress: [${'█' * (percentage ~/ 5)}${' ' * (20 - percentage ~/ 5)}] '
      '$percentage% ($completed/$total packages)',
    );
  }
}

class PackageOutput {
  final String packageName;
  final String content;
  final TestStatus status;
  final Duration elapsed;
  final int testsRun;
  final int testsFailed;
  
  bool get hasContent => content.isNotEmpty;
}
```

#### Exemplo de Saída
```
Progress: [████████████        ] 60% (3/5 packages)

╔════════════════════════════════════════════════════════════════╗
║ 📦 [01/05] package_a                                    ✓ 2.3s ║
╚════════════════════════════════════════════════════════════════╝
  ✓ All tests passed! (23 tests)

╔════════════════════════════════════════════════════════════════╗
║ 📦 [02/05] package_b                                    ✗ 3.1s ║
╚════════════════════════════════════════════════════════════════╝
  [E] Test failed: user_service_test.dart
  Expected: true
  Actual: false
  
  ✗ 1 test failed (19 passed, 1 failed)

╔════════════════════════════════════════════════════════════════╗
║ 📦 [03/05] package_c                                    ✓ 1.8s ║
╚════════════════════════════════════════════════════════════════╝
  ✓ All tests passed! (15 tests)

Progress: [████████████        ] 60% (3/5 packages)
```

#### Vantagens
✅ Melhor de todos os mundos  
✅ Saída organizada e informativa  
✅ Progresso visível  
✅ Fácil debugging  
✅ Profissional  

#### Desvantagens
❌ Complexidade moderada  
❌ Requer sincronização cuidadosa  

---

## Melhorias Complementares

### 6. Sistema de Notificações de Eventos

Adicionar eventos importantes com destaque visual:

```dart
enum TestEvent {
  packageStarted,
  packageCompleted,
  testFailed,
  allCompleted,
}

class EventNotifier {
  void notify(TestEvent event, Map<String, dynamic> data) {
    switch (event) {
      case TestEvent.packageStarted:
        _notifyPackageStarted(data['package']);
        break;
      case TestEvent.testFailed:
        _notifyTestFailed(data['package'], data['test']);
        break;
      case TestEvent.allCompleted:
        _notifyAllCompleted(data['summary']);
        break;
    }
  }
  
  void _notifyPackageStarted(String package) {
    ColoredOutput.writeln(
      ConsoleColor.cyan,
      '🚀 Iniciando testes: $package',
    );
  }
}
```

### 7. Resumo Final Aprimorado

```dart
class TestSummary {
  void printSummary(List<PackageResult> results) {
    final totalDuration = results.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + r.duration,
    );
    
    final totalTests = results.fold<int>(0, (sum, r) => sum + r.testsRun);
    final totalFailed = results.fold<int>(0, (sum, r) => sum + r.testsFailed);
    
    print('\n');
    ColoredOutput.writeln(ConsoleColor.cyan, '═' * 80);
    ColoredOutput.writeln(ConsoleColor.cyan, '  📊 RESUMO DA EXECUÇÃO');
    ColoredOutput.writeln(ConsoleColor.cyan, '═' * 80);
    
    print('');
    print('  Pacotes executados: ${results.length}');
    print('  Testes executados:  $totalTests');
    print('  Testes aprovados:   ${totalTests - totalFailed}');
    print('  Testes falhados:    $totalFailed');
    print('  Tempo total:        ${totalDuration.inSeconds}s');
    print('');
    
    if (totalFailed > 0) {
      ColoredOutput.writeln(ConsoleColor.red, '  ❌ Pacotes com falhas:');
      for (final result in results.where((r) => r.testsFailed > 0)) {
        ColoredOutput.writeln(
          ConsoleColor.red,
          '     • ${result.packageName} (${result.testsFailed} falhas)',
        );
      }
    } else {
      ColoredOutput.writeln(
        ConsoleColor.green,
        '  ✅ Todos os testes passaram!',
      );
    }
    
    ColoredOutput.writeln(ConsoleColor.cyan, '═' * 80);
  }
}
```

### 8. Modo Quiet para CI/CD

```dart
class QuietTestOutput implements TestOutput {
  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    // Não imprime nada durante execução
    return Stream.empty();
  }
  
  void printFinalResult(bool success, List<String> failures) {
    if (success) {
      print('✓ All tests passed');
    } else {
      print('✗ Tests failed:');
      for (final failure in failures) {
        print('  - $failure');
      }
    }
  }
}
```

### 9. Exportação de Relatórios

```dart
class TestReporter {
  Future<void> exportJson(List<PackageResult> results, String path) async {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'packages': results.map((r) => r.toJson()).toList(),
      'summary': {
        'total_packages': results.length,
        'total_tests': results.fold<int>(0, (sum, r) => sum + r.testsRun),
        'total_failures': results.fold<int>(0, (sum, r) => sum + r.testsFailed),
      },
    };
    
    await File(path).writeAsString(jsonEncode(report));
  }
  
  Future<void> exportMarkdown(List<PackageResult> results, String path) async {
    final buffer = StringBuffer();
    buffer.writeln('# Test Report');
    buffer.writeln('');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');
    buffer.writeln('## Results');
    buffer.writeln('');
    buffer.writeln('| Package | Tests | Passed | Failed | Duration |');
    buffer.writeln('|---------|-------|--------|--------|----------|');
    
    for (final result in results) {
      buffer.writeln(
        '| ${result.packageName} | ${result.testsRun} | '
        '${result.testsRun - result.testsFailed} | ${result.testsFailed} | '
        '${result.duration.inSeconds}s |',
      );
    }
    
    await File(path).writeAsString(buffer.toString());
  }
}
```

---

## Recomendação de Implementação

### Fase 1: Melhorias Imediatas (Curto Prazo)
1. ✅ Implementar **Sistema de Seções Visuais** (Proposta #2)
2. ✅ Adicionar **Resumo Final Aprimorado** (Proposta #7)
3. ✅ Implementar **Timestamps** opcionais (Proposta #4)

### Fase 2: Melhorias Intermediárias (Médio Prazo)
4. ✅ Implementar **Sistema de Multiplexação** (Proposta #5)
5. ✅ Adicionar **Modo Quiet** para CI/CD (Proposta #8)
6. ✅ Sistema de **Notificações de Eventos** (Proposta #6)

### Fase 3: Melhorias Avançadas (Longo Prazo)
7. ✅ Implementar **Dashboard TUI** (Proposta #3)
8. ✅ Adicionar **Exportação de Relatórios** (Proposta #9)
9. ✅ Integração com ferramentas de CI/CD

---

## Flags Propostas

```bash
# Controle de saída
--output-mode=<standard|verbose|quiet|dashboard>
--timestamps              # Adiciona timestamps a cada linha
--no-colors              # Desabilita cores (útil para logs)

# Relatórios
--report-json=<path>     # Exporta relatório JSON
--report-markdown=<path> # Exporta relatório Markdown
--report-html=<path>     # Exporta relatório HTML

# Comportamento
--buffer-output          # Acumula saída por pacote
--show-progress          # Mostra barra de progresso
```

---

## Métricas de Sucesso

Para avaliar se as melhorias foram efetivas:

1. **Clareza**: Usuários conseguem identificar rapidamente qual pacote está executando?
2. **Debugging**: É fácil encontrar a origem de um erro?
3. **Performance**: As melhorias não impactam negativamente o tempo de execução?
4. **Usabilidade**: A saída é útil tanto para desenvolvimento quanto para CI/CD?
5. **Feedback**: Usuários sentem que têm visibilidade do progresso?

---

## Exemplos de Uso

### Desenvolvimento Local
```bash
# Modo verbose com timestamps para debugging
fastest --package --verbose --timestamps

# Dashboard interativo
fastest --package --output-mode=dashboard
```

### CI/CD
```bash
# Modo quiet com relatório JSON
fastest --package --output-mode=quiet --report-json=test-results.json

# Sem cores para logs limpos
fastest --package --no-colors --report-markdown=TESTS.md
```

### Debugging
```bash
# Verbose com buffer para saída organizada
fastest --package --verbose --buffer-output --timestamps
```
