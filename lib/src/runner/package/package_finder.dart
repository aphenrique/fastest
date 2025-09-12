import 'dart:io';

import 'package:path/path.dart' as path;

import 'monorepo_package.dart';

/// Classe responsável por encontrar pacotes em um ambiente monorepo
class PackageFinder {
  PackageFinder({
    required String rootPath,
  }) : _rootPath = rootPath;

  final String _rootPath;

  /// Encontra todos os pacotes Dart/Flutter no monorepo que contêm testes
  Future<List<MonorepoPackage>> findPackages() async {
    final rootDir = Directory(_rootPath);
    if (!rootDir.existsSync()) {
      throw Exception('Diretório raiz não encontrado: $_rootPath');
    }

    final packages = <MonorepoPackage>[];

    for (final entity in rootDir.listSync()) {
      if (entity is! Directory) continue;

      final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) continue;

      final package = DartMonorepoPackage(directory: entity);
      if (package.hasTests) {
        packages.add(package);
      }
    }

    if (packages.isEmpty) {
      throw Exception('Nenhum pacote Dart/Flutter encontrado em: $_rootPath');
    }

    return packages;
  }
}
