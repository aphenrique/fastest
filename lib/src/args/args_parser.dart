import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import '../view/colored_output.dart';
import '../view/console_color.dart';

/// Parser de argumentos de linha de comando para o Fastest.
///
/// Responsável por processar e validar os argumentos fornecidos ao executar
/// o comando fastest.
class ArgsParser {
  /// Lista de argumentos posicionais não processados
  late final List<String> rest;

  /// Indica se a coleta de cobertura de código está habilitada
  late final bool coverage;

  /// Indica se o modo package está ativo (busca em subpastas)
  late final bool isPackage;

  /// Indica se deve confirmar automaticamente todas as operações
  late final bool autoConfirm;

  /// Indica se deve interromper a execução no primeiro teste que falhar
  late final bool failFast;

  /// Indica se deve exibir saída detalhada dos testes
  ///
  /// Nota: Sempre true quando não está em modo package
  late final bool verbose;

  /// Número de processos concorrentes para execução dos testes
  late final int concurrency;

  /// Caminho onde os testes serão executados
  late final String testPath;

  /// Processa os argumentos fornecidos na linha de comando
  ///
  /// Throws [ArgParserException] se os argumentos forem inválidos
  /// Throws [PathNotFoundException] se o caminho fornecido não existir
  Future<void> call(List<String> args) async {
    final results = parser.parse(args);

    rest = results.rest;
    final providedPath =
        rest.isNotEmpty ? rest.first : results['path'] as String;

    coverage = results['coverage'] as bool;
    isPackage = results['package'] as bool;
    autoConfirm = results['yes'] as bool;
    failFast = results['fail-fast'] as bool;
    verbose = results['verbose'] as bool || !isPackage;
    concurrency = results['no-concurrency'] as bool
        ? 1
        : int.parse(results['concurrency'] as String);

    testPath = _validatePath(providedPath);
  }

  /// Valida se o caminho fornecido existe e é acessível
  ///
  /// Retorna o caminho absoluto normalizado
  /// Throws [PathNotFoundException] se o caminho não existir
  String _validatePath(String providedPath) {
    final normalizedPath = path.normalize(path.absolute(providedPath));

    if (!Directory(normalizedPath).existsSync() &&
        !File(normalizedPath).existsSync()) {
      throw PathNotFoundException(
        'O caminho fornecido não existe: $normalizedPath',
      );
    }

    return normalizedPath;
  }

  /// Retorna o texto de ajuda do parser
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
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help:
          'Exibe saída detalhada dos testes (sempre ativo fora do modo package)',
    )
    ..addOption(
      'path',
      defaultsTo: Directory.current.path,
      help: 'Caminho da pasta ou arquivo de testes',
      valueHelp: 'path',
    )
    ..addOption(
      'concurrency',
      defaultsTo: Platform.numberOfProcessors.toString(),
      help: 'Define o número de núcleos de processamento a serem utilizados',
      valueHelp: 'concurrency',
      callback: (value) {
        final intValue = int.tryParse(value!);
        if (intValue == null || intValue < 1) {
          throw ArgParserException(
            'O valor de "concurrency" deve ser um número inteiro positivo',
          );
        }
        if (intValue > Platform.numberOfProcessors) {
          throw ArgParserException(
            'O valor de "concurrency" não deve ultrapassar o número de processadores disponíveis (${Platform.numberOfProcessors})',
          );
        }
        ColoredOutput.writeln(
          ConsoleColor.green,
          'Parallel cors: $intValue',
        );
      },
    );
}

/// Exceção lançada quando um caminho não existe
class PathNotFoundException implements Exception {
  PathNotFoundException(this.message);
  final String message;

  @override
  String toString() => message;
}
