import 'dart:io';

import 'colored_output.dart';
import 'console_color.dart';

abstract class TestOutput {
  factory TestOutput(
    bool verbose, {
    required String packageName,
    required bool failFast,
  }) {
    switch (verbose) {
      case true:
        return VerboseModeTestOutput(
          packageName: packageName,
          failFast: failFast,
        );
      case false:
        return StandardModeTestOutput(
          packageName: packageName,
          failFast: failFast,
        );
    }
  }

  void output(Stream<List<int>> output);
  void error(Stream<List<int>> output);
}

class VerboseModeTestOutput implements TestOutput {
  VerboseModeTestOutput({
    required this.packageName,
    required this.failFast,
  });

  final String packageName;
  final bool failFast;

  @override
  void output(Stream<List<int>> output) {
    output.transform(const SystemEncoding().decoder).listen((event) {
      if (event.isEmpty) return;

      if (event.contains('[E]') || event.contains('Some tests failed')) {
        ColoredOutput.writeln(
          ConsoleColor.red,
          '$packageName > $event',
        );

        return;
      }

      ColoredOutput.writeln(
        ConsoleColor.green,
        '$packageName > $event',
      );

      return;
    });
  }

  @override
  void error(Stream<List<int>> output) {
    output.transform(const SystemEncoding().decoder).listen((event) {
      if (event.isEmpty ||
          event.startsWith('Waiting for another flutter command')) return;

      ColoredOutput.writeln(
        ConsoleColor.red,
        '$packageName > $event',
      );
    });
  }
}

class StandardModeTestOutput implements TestOutput {
  StandardModeTestOutput({
    required this.packageName,
    required this.failFast,
  }) {
    outputList.add(
      ColoredOutput.line(
        ConsoleColor.yellow,
        '$packageName > Executando testes...',
      ),
    );
  }

  final String packageName;
  final bool failFast;

  final outputList = <String>[];
  final errorsList = <String>[];

  @override
  void output(Stream<List<int>> output) {
    output.transform(const SystemEncoding().decoder).listen((event) {
      if (event.isEmpty) return;

      if (event.contains('All tests passed!')) {
        outputList.add(
          ColoredOutput.line(
            ConsoleColor.green,
            '$packageName > $event',
          ),
        );
        return;
      }

      if (event.contains('[E]') || event.contains('Some tests failed')) {
        errorsList.add(
          ColoredOutput.line(
            ConsoleColor.red,
            '$packageName > $event',
          ),
        );
        return;
      }
    });
  }

  @override
  void error(Stream<List<int>> output) {
    output.transform(const SystemEncoding().decoder).listen((event) {
      if (event.isEmpty ||
          event.startsWith('Waiting for another flutter command')) return;

      errorsList.add(event);
    });

    if (errorsList.isNotEmpty) {
      stdout
        ..writeln('\r\x1B[K') // Limpa a linha do loading
        ..writeln(errorsList.join());
    }

    if (failFast) {
      exit(1);
    }
  }
}
