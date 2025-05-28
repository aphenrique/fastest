import 'dart:io';

import 'package:path/path.dart' as path;

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Por favor, forneça o caminho do projeto como argumento.');
    exit(1);
  }

  final projectPath = args[0];
  final testFile = generateTestFile(projectPath);

  print('\nExecutando os testes...\n');

  final result = await Process.run(
    'flutter',
    ['test', testFile],
    runInShell: true,
    workingDirectory: projectPath,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // Analisa os resultados dos testes
  final failedTests = _findFailedTests(result.stdout.toString());
  if (failedTests.isNotEmpty) {
    print('\nArquivos com falha:');
    for (final test in failedTests) {
      print('- $test');
    }
  }

  exit(result.exitCode);
}

Set<String> _findFailedTests(String output) {
  final failedTests = <String>{};
  final lines = output.split('\n');

  for (final line in lines) {
    if (line.contains('_test.dart') && line.contains('[E]')) {
      final fileName = line.trim().split(' ').first;
      failedTests.add(fileName);
    }
  }

  return failedTests;
}

class AliasGenerator {
  int _currentIndex = 0;
  final List<String> _alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
  final Set<String> _reservedWords = {
    'as',
    'do',
    'for',
    'get',
    'if',
    'in',
    'is',
    'new',
    'of',
    'on',
    'set',
    'try',
    'var'
  };

  String nextAlias() {
    String alias;
    do {
      alias = _generateAlias(_currentIndex);
      _currentIndex++;
    } while (_reservedWords.contains(alias));

    return alias;
  }

  String _generateAlias(int index) {
    if (index < _alphabet.length) {
      return _alphabet[index];
    }

    final prefixIndex = (index ~/ _alphabet.length) - 1;
    final currentIndex = index % _alphabet.length;

    return _generateAlias(prefixIndex) + _alphabet[currentIndex];
  }
}

String generateTestFile(String projectPath) {
  final testDir = Directory(path.join(projectPath, 'test'));
  if (!testDir.existsSync()) {
    print('Diretório de testes não encontrado em: ${testDir.path}');
    exit(1);
  }

  final testFiles = _findTestFiles(testDir);
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

  final sortedFiles = List<File>.from(testFiles)
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in sortedFiles) {
    final relativePath = path.relative(file.path, from: testDir.path);
    final alias = aliasGenerator.nextAlias();
    aliasMap[file.path] = alias;
    buffer.writeln("import '$relativePath' as $alias;");
  }

  buffer.writeln('\nvoid main() {');

  buffer.writeln('  TestWidgetsFlutterBinding.ensureInitialized();');
  buffer.writeln();

  for (final file in sortedFiles) {
    final fileName = path.basename(file.path);
    final alias = aliasMap[file.path]!;
    buffer.writeln("  group('$fileName', () {");
    buffer.writeln("    $alias.main();");
    buffer.writeln("  });");
    buffer.writeln();
  }

  buffer.writeln('}');

  mainTestFile.writeAsStringSync(buffer.toString());
  print('Arquivo de testes gerado em: ${mainTestFile.path}');

  return path.join('test', 'all_tests.dart');
}

List<File> _findTestFiles(Directory directory) {
  final testFiles = <File>[];

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('_test.dart') &&
        !entity.path.endsWith('all_tests.dart')) {
      testFiles.add(entity);
    }
  }

  return testFiles;
}
