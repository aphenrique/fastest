import 'dart:io';

/// Interface que representa um pacote em um ambiente monorepo
abstract class MonorepoPackage {
  /// Caminho do pacote
  String get path;

  /// Nome do pacote
  String get name;

  /// Diretório do pacote
  Directory get directory;

  /// Verifica se o pacote tem testes
  bool get hasTests;

  /// Retorna a lista de arquivos de teste
  List<File> get testFiles;
}

/// Implementação padrão de [MonorepoPackage]
class DartMonorepoPackage implements MonorepoPackage {
  DartMonorepoPackage({
    required Directory directory,
  }) : _directory = directory {
    _testFiles = _findTestFiles();
  }

  final Directory _directory;
  late final List<File> _testFiles;

  @override
  String get path => _directory.path;

  @override
  String get name => _directory.path.split('/').last;

  @override
  Directory get directory => _directory;

  @override
  bool get hasTests => _testFiles.isNotEmpty;

  @override
  List<File> get testFiles => List.unmodifiable(_testFiles);

  List<File> _findTestFiles() {
    final testDir = Directory('${_directory.path}/test');
    if (!testDir.existsSync()) return [];

    return testDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .toList();
  }
}
