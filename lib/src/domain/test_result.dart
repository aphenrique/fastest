/// Modelos de domínio que representam o resultado da execução dos testes.
///
/// São objetos puros (sem `dart:io` nem dependência de apresentação) e
/// serializáveis por isolate, para que a execução em paralelo possa devolver
/// resultados que a camada de apresentação renderiza depois.

/// Representa uma falha detectada na saída dos testes.
class TestFailure {
  const TestFailure({required this.file, this.description});

  /// Nome do arquivo de teste que falhou (ex: `home_page_test.dart`).
  final String file;

  /// Descrição opcional da falha (linha bruta reportada pelo runner).
  final String? description;
}

/// Resultado agregado da execução dos testes de um único pacote.
class PackageResult {
  const PackageResult({
    required this.packageName,
    required this.success,
    required this.exitCode,
    this.duration,
    this.failures = const [],
    this.errorLines = const [],
  });

  /// Nome do pacote executado.
  final String packageName;

  /// Indica se todos os testes do pacote passaram.
  final bool success;

  /// Código de saída do processo `flutter test`.
  final int exitCode;

  /// Tempo total de execução do pacote.
  final Duration? duration;

  /// Falhas encontradas, agrupadas por arquivo de teste.
  final List<TestFailure> failures;

  /// Linhas de erro brutas capturadas (para exibição detalhada).
  final List<String> errorLines;
}
