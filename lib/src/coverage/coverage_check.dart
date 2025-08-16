import 'dart:io';

import '../view/colored_output.dart';
import '../view/console_color.dart';

class CoverageCheck {
  /// Verifica se o pacote full_coverage está instalado globalmente.
  /// Se não estiver, pergunta ao usuário se deseja instalar.
  ///
  /// Retorna `true` se o pacote está disponível (já instalado ou instalado com sucesso).
  /// Retorna `false` se houve algum erro na verificação ou instalação.
  static Future<bool> verify({bool autoConfirm = false}) async {
    try {
      final result = await Process.run('dart', ['pub', 'global', 'list']);
      final hasFullCoverage =
          result.stdout.toString().contains('full_coverage ');

      if (!hasFullCoverage) {
        ColoredOutput.writeln(
          ConsoleColor.red,
          '\nPacote full_coverage não encontrado.',
        );

        if (!autoConfirm) {
          ColoredOutput.write(
            ConsoleColor.yellow,
            'Deseja instalar o pacote full_coverage? (S/n) ',
          );

          final response = stdin.readLineSync()?.toLowerCase();
          if (response != '' && response != 's' && response != 'sim') {
            ColoredOutput.writeln(
              ConsoleColor.yellow,
              '\nPara instalar manualmente mais tarde, execute:',
            );
            ColoredOutput.writeln(
              ConsoleColor.white,
              '> dart pub global activate full_coverage\n',
            );
            return false;
          }
        }

        ColoredOutput.writeln(
          ConsoleColor.yellow,
          '\nInstalando pacote full_coverage...',
        );

        final install = await Process.run(
          'dart',
          ['pub', 'global', 'activate', 'full_coverage'],
        );

        if (install.exitCode != 0) {
          ColoredOutput.writeln(
            ConsoleColor.red,
            'Erro ao instalar o pacote full_coverage. Por favor, instale manualmente:',
          );
          ColoredOutput.writeln(
            ConsoleColor.yellow,
            'dart pub global activate full_coverage',
          );
          return false;
        }

        ColoredOutput.writeln(
          ConsoleColor.green,
          'Pacote full_coverage instalado com sucesso!\n',
        );
      }

      return true;
    } catch (e) {
      ColoredOutput.writeln(
        ConsoleColor.red,
        'Erro ao verificar/instalar o pacote full_coverage: $e',
      );
      throw Exception('Erro ao verificar/instalar o pacote full_coverage');
    }
  }
}
