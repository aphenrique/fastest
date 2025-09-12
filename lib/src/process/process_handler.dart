import 'dart:async';
import 'dart:io';

/// Interface para gerenciamento de processos do sistema
abstract class ProcessHandler {
  /// Inicia um processo com os argumentos fornecidos
  Future<Process> startProcess(
    String command,
    List<String> args, {
    required String workingDirectory,
  });

  /// Gerencia a saída do processo
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  );
}

/// Implementação padrão do ProcessHandler
class DefaultProcessHandler implements ProcessHandler {
  const DefaultProcessHandler();

  @override
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

  @override
  Future<int> handleProcessOutput(
    Process process,
    Stream<List<int>> Function(Stream<List<int>>) outputHandler,
    Stream<List<int>> Function(Stream<List<int>>) errorHandler,
  ) async {
    outputHandler(process.stdout);
    errorHandler(process.stderr);
    return process.exitCode;
  }
}
