import 'dart:io';

import 'package:fastest/src/coverage_check/coverage_handler.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late CoverageHandler coverageHandler;
  late Directory tempDir;
  late String testPath;

  setUp(() {
    coverageHandler = CoverageHandler();
    tempDir = Directory.systemTemp.createTempSync('coverage_test_');
    testPath = tempDir.path;
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('CoverageHandler', () {
    test(
        'verifyCoverage deve remover diretório de cobertura existente quando coverage é true',
        () {
      // Arrange
      final coverageDir = Directory(path.join(testPath, 'coverage'))
        ..createSync();
      final testFile = File(path.join(coverageDir.path, 'test.txt'))
        ..writeAsStringSync('test');

      expect(coverageDir.existsSync(), isTrue);
      expect(testFile.existsSync(), isTrue);

      // Act
      coverageHandler.verifyCoverage(testPath, true);

      // Assert
      expect(coverageDir.existsSync(), isFalse);
      expect(testFile.existsSync(), isFalse);
    });

    test('verifyCoverage não deve fazer nada quando coverage é false', () {
      // Arrange
      final coverageDir = Directory(path.join(testPath, 'coverage'))
        ..createSync();
      final testFile = File(path.join(coverageDir.path, 'test.txt'))
        ..writeAsStringSync('test');

      expect(coverageDir.existsSync(), isTrue);
      expect(testFile.existsSync(), isTrue);

      // Act
      coverageHandler.verifyCoverage(testPath, false);

      // Assert
      expect(coverageDir.existsSync(), isTrue);
      expect(testFile.existsSync(), isTrue);
    });

    test('addCoverageArgs deve adicionar --coverage quando coverage é true',
        () {
      // Arrange
      final args = <String>[];

      // Act
      coverageHandler.addCoverageArgs(args, true);

      // Assert
      expect(args, contains('--coverage'));
    });

    test(
        'addCoverageArgs não deve adicionar --coverage quando coverage é false',
        () {
      // Arrange
      final args = <String>[];

      // Act
      coverageHandler.addCoverageArgs(args, false);

      // Assert
      expect(args, isEmpty);
    });
  });
}
