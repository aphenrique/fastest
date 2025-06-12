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
      'concurrency',
      negatable: false,
      help: 'Habilita execução concorrente dos testes',
    )
    ..addFlag(
      'monorepo',
      abbr: 'm',
      negatable: false,
      help: 'Executa testes em modo monorepo, buscando packages em subpastas',
    )
    ..addFlag(
      'yes',
      abbr: 'y',
      negatable: false,
      help: 'Responde sim automaticamente para todas as confirmações',
    )
    ..addOption(
      'path',
      abbr: 'p',
      defaultsTo: Directory.current.path,
      help:
          'Caminho da pasta de testes (opcional, usa pasta atual se não informado)',
      valueHelp: 'path',
    );

  Future<ArgResults> call(List<String> args) async {
    return parser.parse(args);
  }

  String get usage => parser.usage;
}
