import 'dart:io';

import 'package:path/path.dart' as path;

/// Classe responsável por gerenciar a cobertura de testes
class CoverageHandler {
  /// Verifica e prepara o diretório de cobertura
  void verifyCoverage(String testPath, bool coverage) {
    if (coverage) {
      final coverageDir = Directory(path.join(testPath, 'coverage'));

      if (coverageDir.existsSync()) {
        coverageDir.deleteSync(recursive: true);
      }
    }
  }

  /// Adiciona argumentos de cobertura se necessário
  void addCoverageArgs(List<String> args, bool coverage) {
    if (coverage) {
      args.add('--coverage');
    }
  }
}
