import 'dart:io';

import 'package:args/args.dart';

class ArgsParser {
  ArgsParser();

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
        }
      },
    );

  Future<ArgResults> call(List<String> args) async {
    return parser.parse(args);
  }

  String get usage => parser.usage;
}
