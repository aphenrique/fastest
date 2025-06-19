import 'dart:io';

import 'package:args/args.dart';

import '../output/colored_output.dart';
import '../output/console_color.dart';

class ArgsParser {
  ArgsParser._();

  static final ArgsParser instance = ArgsParser._();

  late final List<String> rest;
  late final bool coverage;
  late final bool isPackage;
  late final bool autoConfirm;
  late final bool failFast;
  late final int concurrency;

  late final String testPath;

  Future<void> call(List<String> args) async {
    final results = parser.parse(args);

    rest = results.rest;

    coverage = results['coverage'] as bool;
    isPackage = results['package'] as bool;
    autoConfirm = results['yes'] as bool;
    failFast = results['fail-fast'] as bool;
    concurrency = results['no-concurrency'] as bool
        ? 1
        : int.parse(results['concurrency'] as String);

    // Se houver um argumento posicional, usa ele como caminho
    // Caso contrário, usa o valor da opção --path
    testPath = rest.isNotEmpty ? rest.first : results['path'] as String;
  }

  String get usage => parser.usage;
  final parser = ArgParser()
    ..addFlag(
      'coverage',
      abbr: 'c',
      negatable: false,
      help: 'Habilita a coleta de cobertura de código',
    )
    ..addFlag(
      'package',
      abbr: 'p',
      negatable: false,
      help: 'Executa testes em modo package, buscando packages em subpastas',
    )
    ..addFlag(
      'yes',
      abbr: 'y',
      negatable: false,
      help: 'Responde sim automaticamente para todas as confirmações',
    )
    ..addFlag(
      'no-concurrency',
      negatable: false,
      help: 'Desabilita execução concorrente dos testes',
    )
    ..addFlag(
      'fail-fast',
      negatable: false,
      help: 'Interrompe a execução ao primeiro teste que falhar',
    )
    ..addOption(
      'path',
      defaultsTo: Directory.current.path,
      help:
          'Caminho da pasta de testes (opcional, usa pasta atual se não informado)',
      valueHelp: 'path',
    )
    ..addOption(
      'concurrency',
      defaultsTo: Platform.numberOfProcessors.toString(),
      help: 'Define o número de núcleos de processamento a serem utilizados',
      valueHelp: 'concurrency',
      callback: (value) {
        final intValue = int.tryParse(value!);
        if (intValue == null || intValue > Platform.numberOfProcessors) {
          throw ArgParserException(
            'O valor de "concurrency" não deve ultrapassar o número de processadores disponíveis (${Platform.numberOfProcessors})',
          );
        } else {
          ColoredOutput.writeln(
            ConsoleColor.green,
            'Parallel cores: $intValue',
          );
        }
      },
    );
}
