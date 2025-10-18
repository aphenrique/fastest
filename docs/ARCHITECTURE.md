# Arquitetura do FasTest

## Visão Geral

O FasTest é uma ferramenta CLI desenvolvida em Dart para otimizar a execução de testes em projetos Flutter e Dart. A arquitetura foi projetada para ser modular, extensível e eficiente, com foco em execução paralela e feedback claro ao usuário.

## Princípios Fundamentais

### 1. Otimização por Agregação
A premissa básica do FasTest é que **agregar todos os testes de um pacote em um único arquivo resulta em execução mais rápida**. Isso reduz o overhead de inicialização do Flutter/Dart test para cada arquivo individual.

### 2. Paralelização Inteligente
A segunda premissa é a **execução paralela de testes de diferentes pacotes** em ambientes monorepo, maximizando o uso de recursos computacionais disponíveis.

## Estrutura de Diretórios

```
lib/
├── fastest.dart                    # Ponto de entrada da biblioteca
└── src/
    ├── args/                       # Processamento de argumentos CLI
    │   └── args_parser.dart
    ├── coverage_check/             # Verificação e geração de cobertura
    │   ├── coverage_check.dart
    │   └── coverage_handler.dart
    ├── optimizer/                  # Otimização e agregação de testes
    │   ├── test_finder.dart
    │   ├── test_optimizer.dart
    │   └── alias_generator.dart
    ├── process/                    # Gerenciamento de processos
    │   └── process_handler.dart
    ├── runner/                     # Executores de testes
    │   ├── runner.dart
    │   ├── test_runner.dart
    │   ├── monorepo_runner.dart
    │   ├── process_runner.dart
    │   ├── test_arguments_builder.dart
    │   ├── executor/
    │   │   └── monorepo_executor.dart
    │   └── package/
    │       ├── package_finder.dart
    │       └── monorepo_package.dart
    └── view/                       # Interface e saída visual
        ├── colored_output.dart
        ├── console_color.dart
        ├── loading_indicator.dart
        └── test_output.dart
```

## Componentes Principais

### 1. Args Parser (`args/`)
**Responsabilidade**: Processar e validar argumentos da linha de comando.

**Componentes**:
- `ArgsParser`: Parser principal que processa flags e opções

**Flags Suportadas**:
- `--coverage` / `-c`: Habilita cobertura de código
- `--package` / `-p`: Modo monorepo
- `--verbose` / `-v`: Saída detalhada
- `--fail-fast`: Interrompe no primeiro erro
- `--concurrency N`: Define número de processos paralelos
- `--no-concurrency`: Desabilita paralelização

### 2. Optimizer (`optimizer/`)
**Responsabilidade**: Encontrar e agregar arquivos de teste em um único arquivo otimizado.

**Componentes**:
- `TestFinder`: Localiza arquivos `*_test.dart` recursivamente
- `TestOptimizer`: Gera arquivo `.test_optimizer.dart` com imports agregados
- `AliasGenerator`: Cria aliases únicos para evitar conflitos de nomes

**Fluxo**:
1. Busca todos os arquivos `*_test.dart`
2. Gera aliases únicos para cada arquivo
3. Cria arquivo `.test_optimizer.dart` com todos os imports
4. Invoca `main()` de cada teste sequencialmente

### 3. Runner (`runner/`)
**Responsabilidade**: Orquestrar a execução dos testes.

**Arquitetura**:
```
Runner (interface)
├── TestRunner (execução single-package)
└── MonorepoRunner (execução multi-package)
    └── MonorepoExecutor (gerencia paralelização)
```

**TestRunner**:
- Executa testes em um único pacote
- Usa `TestOptimizer` para agregar testes
- Gerencia saída via `TestOutput`

**MonorepoRunner**:
- Detecta múltiplos pacotes via `PackageFinder`
- Delega execução para `MonorepoExecutor`
- Coordena feedback visual

**MonorepoExecutor**:
- Implementa pool de execução com controle de concorrência
- Usa `Isolate.run()` para paralelização real
- Gerencia fila de pacotes pendentes
- Suporta `--fail-fast` para interrupção antecipada

### 4. Process Handler (`process/`)
**Responsabilidade**: Abstrair interação com processos do sistema.

**Componentes**:
- `ProcessHandler`: Interface para execução de processos
- `DefaultProcessHandler`: Implementação padrão usando `Process.start()`

**Benefícios**:
- Testabilidade (permite mocking)
- Isolamento de dependências do sistema
- Facilita tratamento de streams de saída

### 5. View (`view/`)
**Responsabilidade**: Gerenciar toda a saída visual para o usuário.

**Componentes**:

#### `ColoredOutput`
- Utilitário para saída colorida no terminal
- Suporta cores ANSI padrão

#### `ConsoleColor`
- Enum com cores disponíveis (red, green, yellow, cyan, etc.)

#### `LoadingIndicator`
- Animação de spinner durante execução
- Usa caracteres Braille para animação suave
- Atualização a cada 100ms

#### `TestOutput` (Strategy Pattern)
- Interface para processamento de saída de testes
- Duas implementações:
  - **VerboseModeTestOutput**: Exibe tudo em tempo real
  - **StandardModeTestOutput**: Acumula e exibe ao final

**StandardModeTestOutput**:
- Acumula saídas durante execução
- Filtra warnings repetidos
- Exibe resumo consolidado ao final
- Formato: `[XX/YY] package_name > mensagem`

**VerboseModeTestOutput**:
- Streaming em tempo real
- Útil para debugging
- Sempre ativo em modo single-package

### 6. Coverage (`coverage_check/`)
**Responsabilidade**: Gerenciar cobertura de código.

**Componentes**:
- `CoverageCheck`: Verifica instalação do `full_coverage`
- `CoverageHandler`: Valida estrutura de diretórios para cobertura

**Fluxo**:
1. Verifica se `full_coverage` está instalado
2. Oferece instalação interativa se necessário
3. Valida estrutura de pastas (`test/` e `lib/`)
4. Passa flag `--coverage` para Flutter test

## Fluxo de Execução

### Single Package
```
main()
  ↓
ArgsParser.parse()
  ↓
CoverageCheck.verify() [se --coverage]
  ↓
TestRunner.execute()
  ↓
TestOptimizer() → gera .test_optimizer.dart
  ↓
Process.start('flutter', ['test', ...])
  ↓
TestOutput.output/error() → processa streams
  ↓
exit(exitCode)
```

### Monorepo (Multi-Package)
```
main()
  ↓
ArgsParser.parse()
  ↓
MonorepoRunner.execute()
  ↓
PackageFinder.findPackages() → lista pacotes com testes
  ↓
MonorepoExecutor.execute()
  ↓
┌─────────────────────────────────┐
│ Pool de Execução (Concurrency)  │
│                                 │
│ Isolate 1: TestRunner(pkg1)    │
│ Isolate 2: TestRunner(pkg2)    │
│ Isolate N: TestRunner(pkgN)    │
└─────────────────────────────────┘
  ↓
Aguarda conclusão (respeitando concurrency)
  ↓
Coleta resultados
  ↓
exit(hasFailures ? 1 : 0)
```

## Padrões de Design Utilizados

### 1. Factory Pattern
- `Runner.factory()`: Cria `TestRunner` ou `MonorepoRunner` baseado em flags
- `TestOutput.factory()`: Cria modo verbose ou standard

### 2. Strategy Pattern
- `TestOutput`: Diferentes estratégias de exibição (verbose vs standard)
- `ProcessHandler`: Permite diferentes implementações de execução

### 3. Template Method
- `Runner.execute()`: Define contrato para execução

### 4. Builder Pattern
- `TestArgumentsBuilder`: Constrói argumentos para Flutter test

### 5. Dependency Injection
- Todos os runners aceitam `ProcessHandler` opcional
- Facilita testes unitários

## Isolamento e Paralelização

### Uso de Isolates
O FasTest usa `Isolate.run()` para execução verdadeiramente paralela:

```dart
final future = Isolate.run(runner.execute);
```

**Vantagens**:
- Paralelismo real (não apenas concorrência)
- Isolamento de memória entre execuções
- Melhor utilização de CPUs multi-core

**Desafios**:
- Saídas podem se misturar no console
- Necessidade de sincronização de I/O
- Complexidade no tratamento de erros

### Controle de Concorrência
```dart
while (queue.isNotEmpty || running.isNotEmpty) {
  // Preenche pool até limite de concurrency
  while (queue.isNotEmpty && running.length < concurrency) {
    final package = queue.removeFirst();
    running.add(Isolate.run(runner.execute));
  }
  
  // Aguarda pelo menos um completar
  await Future.wait([running.removeFirst()]);
}
```

## Otimizações Implementadas

### 1. Agregação de Testes
- Reduz overhead de inicialização do Flutter
- Um único processo para múltiplos arquivos de teste

### 2. Execução Paralela
- Usa todos os cores disponíveis por padrão
- Configurável via `--concurrency`

### 3. Filtragem de Saída
- Remove warnings repetidos (ex: file_picker platform warnings)
- Exibe apenas informações relevantes em modo standard

### 4. Loading Indicator
- Feedback visual durante execução
- Não interfere com saída dos testes

### 5. Fail-Fast
- Interrompe execução ao primeiro erro
- Economiza tempo em pipelines CI/CD

## Extensibilidade

### Adicionando Novos Runners
1. Implementar interface `Runner`
2. Adicionar lógica no factory de `Runner`
3. Criar testes unitários

### Adicionando Novos Modos de Saída
1. Implementar interface `TestOutput`
2. Adicionar lógica no factory de `TestOutput`
3. Processar streams `output` e `error`

### Adicionando Novas Flags
1. Adicionar flag em `ArgsParser.parser`
2. Expor propriedade em `ArgsParser`
3. Passar para runners apropriados

## Considerações de Performance

### Benchmarks Típicos
- **Single package**: 2-3x mais rápido que `flutter test`
- **Monorepo (4 packages)**: 4-5x mais rápido com concurrency=4

### Fatores que Afetam Performance
1. Número de arquivos de teste
2. Complexidade dos testes
3. Número de cores disponíveis
4. I/O de disco (geração de arquivo otimizado)

### Trade-offs
- **Agregação**: Mais rápido, mas falhas são menos granulares
- **Paralelização**: Mais rápido, mas saída pode ser confusa
- **Verbose mode**: Mais informação, mas mais poluição visual

## Testabilidade

### Estratégias Implementadas
1. **Dependency Injection**: `ProcessHandler` injetável
2. **Interfaces**: Contratos claros (`Runner`, `TestOutput`)
3. **Isolamento**: Lógica separada em módulos pequenos

### Cobertura de Testes
- `args_parser_test.dart`: Validação de argumentos
- `test_runner_test.dart`: Lógica de execução
- `process_runner_test.dart`: Gerenciamento de processos
- `test_arguments_builder_test.dart`: Construção de argumentos

## Limitações Conhecidas

1. **Saída Misturada**: Em modo monorepo, saídas de diferentes pacotes podem se intercalar
2. **Granularidade de Erros**: Agregação dificulta identificar arquivo específico com falha
3. **Dependência do Flutter**: Requer Flutter instalado e configurado
4. **Plataforma**: Otimizado para Unix-like systems (cores ANSI)

## Próximos Passos

Ver [ROADMAP.md](ROADMAP.md) para planos futuros de evolução da arquitetura.
