<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# Speed Test

Um pacote Dart para executar testes em paralelo usando shards.

## Características

- Executa testes em paralelo usando shards
- Configurável para diferentes números de shards e testes concorrentes
- Suporte a diretórios de teste personalizados
- Interface de linha de comando amigável

## Instalação

```yaml
dependencies:
  speed_test: ^1.0.0
```

## Uso

### Via linha de comando

```bash
# Executar todos os testes em um único shard
dart bin/speed_test.dart

# Executar testes divididos em 2 shards
# Terminal 1
dart bin/speed_test.dart -t 2 -i 0

# Terminal 2
dart bin/speed_test.dart -t 2 -i 1

# Opções disponíveis
dart bin/speed_test.dart --help
```

### Via código

```dart
import 'package:speed_test/src/test_sharding.dart';

void main() async {
  final config = ShardConfig(
    totalShards: 2,
    shardIndex: 0,
    maxConcurrentTests: 4,
    testDir: 'test',
  );

  final sharding = TestSharding(config);
  final success = await sharding.runTests();

  print('Execução ${success ? 'bem-sucedida' : 'falhou'}');
}
```

## Opções

- `--total-shards, -t`: Número total de shards (padrão: 1)
- `--shard-index, -i`: Índice do shard atual, 0-based (padrão: 0)
- `--max-concurrent, -m`: Número máximo de testes executando simultaneamente (padrão: 4)
- `--test-dir, -d`: Diretório base dos testes (padrão: test)
- `--help, -h`: Mostra a ajuda

## Exemplo de uso em CI

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [0, 1]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart bin/speed_test.dart -t 2 -i ${{ matrix.shard }}
```

## Licença

MIT
