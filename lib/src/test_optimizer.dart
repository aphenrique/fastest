import 'dart:io';

import 'package:path/path.dart' as path;

import 'alias_generator.dart';
import 'colored_output.dart';
import 'console_color.dart';

class TestOptimizer {
  String call(String testPath) {
    final testDir = Directory(path.join(testPath, 'test')).absolute;
    if (!testDir.existsSync()) {
      ColoredOutput.writeln(
        ConsoleColor.red,
        'Diretório de testes não encontrado em: ${testDir.path}',
      );
      exit(1);
    }

    final testFiles = _findTestFiles(testDir);
    if (testFiles.isEmpty) {
      ColoredOutput.writeln(
        ConsoleColor.red,
        'Nenhum arquivo de teste encontrado em: ${testDir.path}',
      );
      exit(1);
    }

    final mainTestFilePath = path.join(testDir.path, '.test_optimizer.dart');
    final mainTestFile = File(mainTestFilePath);

    if (mainTestFile.existsSync()) {
      mainTestFile.deleteSync();
    }

    ColoredOutput.writeln(ConsoleColor.cyan, 'Caminho > $testPath');
    ColoredOutput.writeln(ConsoleColor.yellow, '... Otimizando os testes');

    final buffer = StringBuffer();
    final aliasGenerator = AliasGenerator();
    final aliasMap = <String, String>{};

    buffer
      ..writeln('// ATENÇÃO: Este arquivo é gerado automaticamente.')
      ..writeln(
        '// Não modifique manualmente, pois suas alterações serão sobrescritas.\n',
      )
      ..writeln("import 'package:flutter_test/flutter_test.dart';");

    /// Ordena os arquivos para garantir consistência nos aliases
    final sortedFiles = List<File>.from(testFiles)
      ..sort((a, b) => a.path.compareTo(b.path));

    /// Gera imports com aliases sequenciais
    for (final file in sortedFiles) {
      final relativePath = path.relative(file.path, from: testDir.path);
      final alias = aliasGenerator.nextAlias();
      aliasMap[file.path] = alias;
      buffer.writeln("import '$relativePath' as $alias;");
    }

    buffer.writeln('\nvoid main() {');

    /// Cria grupos para cada arquivo de teste
    for (final file in sortedFiles) {
      final fileName = path.basename(file.path);
      final alias = aliasMap[file.path]!;

      buffer
        ..write("  group('$fileName', () {")
        ..write('$alias.main();')
        ..writeln('});');
    }

    buffer.writeln('}');

    mainTestFile.writeAsStringSync(buffer.toString());

    return mainTestFilePath;
  }

  List<File> _findTestFiles(Directory directory) {
    final testFiles = <File>[];

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith('_test.dart') &&
          !entity.path.endsWith('.test_optimizer.dart')) {
        testFiles.add(entity);
      }
    }

    return testFiles;
  }
}
