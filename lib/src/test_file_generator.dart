import 'dart:io';

import 'package:path/path.dart' as path;

import 'alias_generator.dart';
import 'test_finder.dart';

String generateTestFile(String projectPath) {
  final testDir = Directory(path.join(projectPath, 'test'));
  if (!testDir.existsSync()) {
    print('Diretório de testes não encontrado em: ${testDir.path}');
    exit(1);
  }

  final testFiles = findTestFiles(testDir);
  if (testFiles.isEmpty) {
    print('Nenhum arquivo de teste encontrado em: ${testDir.path}');
    exit(1);
  }

  final mainTestFilePath = path.join(testDir.path, 'all_tests.dart');
  final mainTestFile = File(mainTestFilePath);

  if (mainTestFile.existsSync()) {
    print('Arquivo all_tests.dart encontrado. Removendo versão antiga...');
    mainTestFile.deleteSync();
  }

  final buffer = StringBuffer();
  final aliasGenerator = AliasGenerator();
  final aliasMap = <String, String>{};

  buffer.writeln("// ATENÇÃO: Este arquivo é gerado automaticamente.");
  buffer.writeln(
      "// Não modifique manualmente, pois suas alterações serão sobrescritas.\n");
  buffer.writeln("import 'package:flutter_test/flutter_test.dart';");

  // Ordena os arquivos para garantir consistência nos aliases
  final sortedFiles = List<File>.from(testFiles)
    ..sort((a, b) => a.path.compareTo(b.path));

  // Gera imports com aliases sequenciais
  for (final file in sortedFiles) {
    final relativePath = path.relative(file.path, from: testDir.path);
    final alias = aliasGenerator.nextAlias();
    aliasMap[file.path] = alias;
    buffer.writeln("import '$relativePath' as $alias;");
  }

  buffer.writeln('\nvoid main() {');

  // Cria grupos para cada arquivo de teste
  for (final file in sortedFiles) {
    final fileName = path.basename(file.path);
    final alias = aliasMap[file.path]!;

    buffer.writeln("  group('$fileName', () {");
    buffer.writeln("    $alias.main();");
    buffer.writeln("  });");
  }

  buffer.writeln('}');

  mainTestFile.writeAsStringSync(buffer.toString());
  print('Arquivo de testes gerado em: ${mainTestFile.path}');

  return path.join('test', 'all_tests.dart');
}
