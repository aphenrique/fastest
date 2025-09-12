import 'dart:async';
import 'dart:io';

import 'colored_output.dart';
import 'console_color.dart';

/// Interface para gerenciar a saída dos testes
abstract class TestOutput {
  /// Cria uma instância de [TestOutput] baseada no modo verbose
  factory TestOutput(
    bool verbose, {
    required String packageName,
    required bool failFast,
    bool isMonorepo = false,
    int? totalPackages,
    int? currentPackage,
  }) {
    switch (verbose) {
      case true:
        return VerboseModeTestOutput(
          packageName: packageName,
          failFast: failFast,
          isMonorepo: isMonorepo,
          totalPackages: totalPackages,
          currentPackage: currentPackage,
        );
      case false:
        return StandardModeTestOutput(
          packageName: packageName,
          failFast: failFast,
          isMonorepo: isMonorepo,
          totalPackages: totalPackages,
          currentPackage: currentPackage,
        );
    }
  }

  /// Processa a saída padrão dos testes
  Stream<List<int>> output(Stream<List<int>> output);

  /// Processa a saída de erro dos testes
  Stream<List<int>> error(Stream<List<int>> output);

  /// Formata o nome do pacote para exibição
  String formatPackageName(String packageName);
}

class VerboseModeTestOutput implements TestOutput {
  VerboseModeTestOutput({
    required this.packageName,
    required this.failFast,
    this.isMonorepo = false,
    this.totalPackages,
    this.currentPackage,
  });

  final String packageName;
  final bool failFast;
  final bool isMonorepo;
  final int? totalPackages;
  final int? currentPackage;

  @override
  String formatPackageName(String packageName) {
    if (!isMonorepo) return packageName;

    final current = currentPackage?.toString().padLeft(2, '0') ?? '--';
    final total = totalPackages?.toString().padLeft(2, '0') ?? '--';
    return '[$current/$total] $packageName';
  }

  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();

    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        if (event.isEmpty) return;

        final formattedName = formatPackageName(packageName);

        if (event.contains('[E]') || event.contains('Some tests failed')) {
          ColoredOutput.writeln(
            ConsoleColor.red,
            '$formattedName > $event',
          );
          return;
        }

        ColoredOutput.writeln(
          ConsoleColor.green,
          '$formattedName > $event',
        );
      },
      onDone: () => controller.close(),
      onError: controller.addError,
    );

    return controller.stream;
  }

  @override
  Stream<List<int>> error(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();

    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        if (event.isEmpty ||
            event.startsWith('Waiting for another flutter command')) return;

        final formattedName = formatPackageName(packageName);
        ColoredOutput.writeln(
          ConsoleColor.red,
          '$formattedName > $event',
        );
      },
      onDone: () => controller.close(),
      onError: controller.addError,
    );

    return controller.stream;
  }
}

class StandardModeTestOutput implements TestOutput {
  StandardModeTestOutput({
    required this.packageName,
    required this.failFast,
    this.isMonorepo = false,
    this.totalPackages,
    this.currentPackage,
  }) {
    outputList.add(
      ColoredOutput.line(
        ConsoleColor.yellow,
        '${formatPackageName(packageName)} > Executando testes...',
      ),
    );
  }

  final String packageName;
  final bool failFast;
  final bool isMonorepo;
  final int? totalPackages;
  final int? currentPackage;

  final outputList = <String>[];
  final errorsList = <String>[];
  final _seenWarnings = <String>{};

  @override
  String formatPackageName(String packageName) {
    if (!isMonorepo) return packageName;

    final current = currentPackage?.toString().padLeft(2, '0') ?? '--';
    final total = totalPackages?.toString().padLeft(2, '0') ?? '--';
    return '[$current/$total] $packageName';
  }

  @override
  Stream<List<int>> output(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();

    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        if (event.isEmpty) return;

        final formattedName = formatPackageName(packageName);

        if (event.contains('All tests passed!')) {
          outputList.add(
            ColoredOutput.line(
              ConsoleColor.green,
              '$formattedName > $event',
            ),
          );
          return;
        }

        if (event.contains('[E]') || event.contains('Some tests failed')) {
          errorsList.add(
            ColoredOutput.line(
              ConsoleColor.red,
              '$formattedName > $event',
            ),
          );
          return;
        }
      },
      onDone: () {
        // Exibe a saída acumulada
        if (outputList.isNotEmpty) {
          stdout.writeln(outputList.join('\n').replaceAll('\n\n\n', '\n'));
        }
        controller.close();
      },
      onError: controller.addError,
    );

    return controller.stream;
  }

  @override
  Stream<List<int>> error(Stream<List<int>> output) {
    final controller = StreamController<List<int>>();

    output.transform(const SystemEncoding().decoder).listen(
      (event) {
        if (event.isEmpty ||
            event.startsWith('Waiting for another flutter command')) return;

        // Filtra warnings repetidos
        if (event.contains('default plugin')) {
          final platform = event.contains('linux')
              ? 'linux'
              : event.contains('macos')
                  ? 'macos'
                  : 'windows';
          final key = 'file_picker:$platform';
          if (!_seenWarnings.add(key)) return;
        }

        final formattedName = formatPackageName(packageName);
        errorsList.add('$formattedName > $event');
      },
      onDone: () {
        if (errorsList.isNotEmpty) {
          stdout
            ..writeln('\r\x1B[K') // Limpa a linha do loading
            ..writeln(errorsList.join('\n').replaceAll('\n\n\n', '\n'));

          if (failFast) {
            exit(1);
          }
        }
        controller.close();
      },
      onError: controller.addError,
    );

    return controller.stream;
  }
}
