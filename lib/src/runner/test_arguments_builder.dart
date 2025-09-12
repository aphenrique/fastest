/// Classe responsável por construir os argumentos de teste
class TestArgumentsBuilder {
  /// Constrói a lista de argumentos para execução dos testes
  List<String> build({
    required String testFile,
    required bool coverage,
    required int concurrency,
  }) {
    final testArgs = ['test', testFile];

    if (concurrency > 1) {
      testArgs.add('--concurrency=$concurrency');
    }

    if (coverage) {
      testArgs.add('--coverage');
    }

    return testArgs;
  }
}
