import 'dart:convert';

import 'test_result.dart';

/// Interpreta a saída do `flutter test` e a transforma em um [PackageResult].
///
/// Concentra toda a lógica de parsing que antes vivia espalhada na camada de
/// apresentação. Não escreve nada no terminal — apenas acumula e interpreta.
class ResultParser {
  ResultParser({required this.packageName});

  /// Nome do pacote associado a este parser.
  final String packageName;

  final _failuresByFile = <String, TestFailure>{};
  final _errorLines = <String>[];
  bool _hasFailureMarker = false;

  /// Captura o token de nome de arquivo de teste dentro de uma linha.
  static final _filePattern = RegExp(r'([\w./-]+_test\.dart)');

  /// Processa um trecho da saída padrão (stdout) do processo.
  void addStdout(String chunk) {
    for (final line in const LineSplitter().convert(chunk)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.contains('[E]') || trimmed.contains('Some tests failed')) {
        _hasFailureMarker = true;
        _errorLines.add(trimmed);
        _registerFailure(trimmed);
      }
    }
  }

  /// Processa um trecho da saída de erro (stderr) do processo.
  void addStderr(String chunk) {
    for (final line in const LineSplitter().convert(chunk)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('Waiting for another flutter command')) continue;

      _errorLines.add(trimmed);
      _registerFailure(trimmed);
    }
  }

  void _registerFailure(String line) {
    final match = _filePattern.firstMatch(line);
    if (match == null) return;

    final file = match.group(1)!.split('/').last;
    _failuresByFile.putIfAbsent(
      file,
      () => TestFailure(file: file, description: _describe(line)),
    );
  }

  /// Extrai uma descrição enxuta da falha a partir da linha bruta.
  String? _describe(String line) {
    final marker = line.indexOf('[E]');
    if (marker == -1) return null;
    final description = line.substring(marker + 3).trim();
    return description.isEmpty ? null : description;
  }

  /// Constrói o resultado final do pacote.
  PackageResult build({required int exitCode, Duration? duration}) {
    final success = exitCode == 0 && !_hasFailureMarker;
    return PackageResult(
      packageName: packageName,
      success: success,
      exitCode: exitCode,
      duration: duration,
      failures: List.unmodifiable(_failuresByFile.values),
      errorLines: List.unmodifiable(_errorLines),
    );
  }
}
