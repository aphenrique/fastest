import 'dart:io';

import '../domain/test_result.dart';
import 'colored_output.dart';
import 'console_color.dart';

/// Responsável por renderizar no terminal os resultados da execução.
///
/// Toda a formatação visual (tabela por pacote, contador de progresso e lista
/// de falhas) vive aqui, isolando a apresentação da lógica de execução.
class ResultReporter {
  const ResultReporter();

  static const _check = '✓';
  static const _cross = '✗';

  /// Cabeçalho exibido antes de iniciar a execução em monorepo.
  void announcePackages(List<String> packageNames) {
    ColoredOutput.writeln(
      ConsoleColor.cyan,
      'Encontrados ${packageNames.length} pacotes com testes:',
    );
    for (final name in packageNames) {
      ColoredOutput.writeln(ConsoleColor.yellow, '  • $name');
    }
    ColoredOutput.writeln(ConsoleColor.cyan, '\nExecutando testes...\n');
  }

  /// Linha de progresso impressa quando um pacote conclui (contador `[i/n]`).
  void reportProgress({
    required int current,
    required int total,
    required PackageResult result,
  }) {
    final counter = '[${_pad(current, total)}/$total]';
    final icon = result.success ? _check : _cross;
    final color = result.success ? ConsoleColor.green : ConsoleColor.red;
    final duration = _formatDuration(result.duration);

    ColoredOutput.writeln(
      color,
      '$counter $icon ${result.packageName}$duration',
    );
  }

  /// Resumo de um único pacote (modo single-package).
  void reportSingle(PackageResult result) {
    stdout.writeln();
    final icon = result.success ? _check : _cross;
    final color = result.success ? ConsoleColor.green : ConsoleColor.red;
    final status = result.success ? 'passou' : 'falhou';
    ColoredOutput.writeln(
      color,
      '$icon ${result.packageName} — $status${_formatDuration(result.duration)}',
    );
    _printFailures([result]);
  }

  /// Renderiza a tabela consolidada por pacote e a lista de falhas.
  void reportSummary(List<PackageResult> results) {
    if (results.isEmpty) return;

    _printTable(results);
    _printFailures(results);

    final failed = results.where((r) => !r.success).length;
    final passed = results.length - failed;

    stdout.writeln();
    if (failed == 0) {
      ColoredOutput.writeln(
        ConsoleColor.green,
        '$_check Todos os $passed pacotes passaram.',
      );
    } else {
      ColoredOutput.writeln(
        ConsoleColor.red,
        '$_cross $failed de ${results.length} pacotes falharam '
        '($passed ok).',
      );
    }
  }

  void _printTable(List<PackageResult> results) {
    final nameWidth = results
        .map((r) => r.packageName.length)
        .fold<int>('Pacote'.length, (max, len) => len > max ? len : max);

    final sorted = [...results]
      ..sort((a, b) {
        if (a.success == b.success) {
          return a.packageName.compareTo(b.packageName);
        }
        return a.success ? 1 : -1; // falhas primeiro
      });

    final divider = '┌${'─' * (nameWidth + 2)}┬────────┬──────────┬──────────┐';
    final middle = '├${'─' * (nameWidth + 2)}┼────────┼──────────┼──────────┤';
    final bottom = '└${'─' * (nameWidth + 2)}┴────────┴──────────┴──────────┘';

    stdout
      ..writeln()
      ..writeln(divider)
      ..writeln(
        '│ ${'Pacote'.padRight(nameWidth)} │ Status │ Falhas   │ Duração  │',
      )
      ..writeln(middle);

    for (final result in sorted) {
      final color = result.success ? ConsoleColor.green : ConsoleColor.red;
      // Texto com largura visível fixa (6) antes de aplicar a cor ANSI,
      // para não quebrar o alinhamento das colunas.
      final statusText = (result.success ? 'ok' : 'falhou').padRight(6);
      final statusCell = ColoredOutput.wrap(color, statusText);
      final failuresCell = result.success
          ? '—'.padRight(8)
          : result.failures.length.toString().padRight(8);
      final durationCell =
          _formatDuration(result.duration, prefix: false).padRight(8);

      stdout.writeln(
        '│ ${result.packageName.padRight(nameWidth)} │ '
        '$statusCell │ $failuresCell │ $durationCell │',
      );
    }

    stdout.writeln(bottom);
  }

  void _printFailures(List<PackageResult> results) {
    final failed = results.where((r) => !r.success).toList();
    if (failed.isEmpty) return;

    stdout.writeln();
    ColoredOutput.writeln(ConsoleColor.red, 'Falhas:');

    for (final result in failed) {
      ColoredOutput.writeln(ConsoleColor.red, '  ${result.packageName}');
      if (result.failures.isEmpty) {
        ColoredOutput.writeln(
          ConsoleColor.yellow,
          '    (falha na execução — veja a saída acima)',
        );
        continue;
      }
      for (final failure in result.failures) {
        ColoredOutput.writeln(ConsoleColor.yellow, '    • ${failure.file}');
        if (failure.description != null) {
          ColoredOutput.writeln(
            ConsoleColor.white,
            '        ${failure.description}',
          );
        }
      }
    }
  }

  String _formatDuration(Duration? duration, {bool prefix = true}) {
    if (duration == null) return '';
    final seconds = duration.inMilliseconds / 1000;
    final text = '${seconds.toStringAsFixed(1)}s';
    return prefix ? '  ($text)' : text;
  }

  String _pad(int value, int total) =>
      value.toString().padLeft(total.toString().length, '0');
}
