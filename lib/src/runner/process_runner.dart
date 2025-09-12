import 'dart:async';
import 'dart:io';

import '../view/test_output.dart';

/// Interface base para execução de processos
abstract class ProcessRunner {
  /// Executa o processo e retorna o código de saída
  Future<int> execute();

  /// Inicia um processo com os argumentos fornecidos
  Future<Process> startProcess(
    String command,
    List<String> args, {
    required String workingDirectory,
  }) async {
    return Process.start(
      command,
      args,
      runInShell: true,
      workingDirectory: workingDirectory,
    );
  }

  /// Gerencia a saída do processo
  Future<int> handleProcessOutput(
    Process process,
    TestOutput output,
    bool failFast,
  ) async {
    output
      ..output(process.stdout)
      ..error(process.stderr);

    final exitCode = await process.exitCode;

    if (failFast && exitCode != 0) {
      exit(5);
    }

    return exitCode;
  }
}
