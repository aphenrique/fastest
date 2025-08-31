import 'dart:io';

import 'package:args/args.dart';
import 'package:fastest/src/args/args_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('ArgsParser', () {
    late ArgsParser parser;
    late Directory tempDir;

    setUp(() {
      parser = ArgsParser();
      tempDir = Directory.systemTemp.createTempSync('fastest_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test(
      'deve processar argumentos com valores padrão quando nenhum argumento é fornecido',
      () async {
        await parser([]);

        expect(parser.coverage, isFalse);
        expect(parser.isPackage, isFalse);
        expect(parser.autoConfirm, isFalse);
        expect(parser.failFast, isFalse);
        expect(parser.verbose, isTrue); // verbose é true quando não é package
        expect(parser.concurrency, equals(Platform.numberOfProcessors));
        expect(
          parser.testPath,
          equals(path.normalize(path.absolute(Directory.current.path))),
        );
        expect(parser.rest, isEmpty);
      },
    );

    test(
      'deve processar todas as flags corretamente quando fornecidas',
      () async {
        await parser([
          '--coverage',
          '--package',
          '--yes',
          '--fail-fast',
          '--verbose',
          '--path',
          tempDir.path,
        ]);

        expect(parser.coverage, isTrue);
        expect(parser.isPackage, isTrue);
        expect(parser.autoConfirm, isTrue);
        expect(parser.failFast, isTrue);
        expect(parser.verbose, isTrue);
        expect(
          parser.testPath,
          equals(path.normalize(path.absolute(tempDir.path))),
        );
      },
    );

    test('deve processar aliases (abreviações) corretamente', () async {
      await parser(['-c', '-p', '-y', '-v', '--path', tempDir.path]);

      expect(parser.coverage, isTrue);
      expect(parser.isPackage, isTrue);
      expect(parser.autoConfirm, isTrue);
      expect(parser.verbose, isTrue);
    });

    test(
      'deve usar o primeiro argumento rest como testPath quando fornecido',
      () async {
        await parser([tempDir.path, '--coverage']);

        expect(
          parser.testPath,
          equals(path.normalize(path.absolute(tempDir.path))),
        );
        expect(parser.coverage, isTrue);
        expect(parser.rest, equals([tempDir.path]));
      },
    );

    test('deve configurar concurrency corretamente', () async {
      await parser(['--concurrency', '2', '--path', tempDir.path]);

      expect(parser.concurrency, equals(2));
    });

    test(
      'deve definir concurrency como 1 quando no-concurrency é true',
      () async {
        await parser(['--no-concurrency', '--path', tempDir.path]);

        expect(parser.concurrency, equals(1));
      },
    );

    test(
      'deve lançar exceção quando concurrency é maior que número de processadores',
      () {
        expect(
          () => parser([
            '--concurrency',
            '${Platform.numberOfProcessors + 1}',
            '--path',
            tempDir.path,
          ]),
          throwsA(isA<ArgParserException>()),
        );
      },
    );

    test('deve lançar exceção quando concurrency não é um número válido', () {
      expect(
        () => parser(['--concurrency', 'invalid', '--path', tempDir.path]),
        throwsA(isA<ArgParserException>()),
      );
    });

    test('deve lançar exceção quando concurrency é menor que 1', () {
      expect(
        () => parser(['--concurrency', '0', '--path', tempDir.path]),
        throwsA(isA<ArgParserException>()),
      );
    });

    test('verbose deve ser true por padrão quando não é package mode',
        () async {
      await parser(['--path', tempDir.path]);
      expect(parser.verbose, isTrue);
    });

    test('verbose deve ser false quando em package mode sem flag verbose',
        () async {
      await parser(['--package', '--path', tempDir.path]);
      expect(parser.verbose, isFalse);
    });

    test('deve lançar exceção quando o caminho não existe', () {
      expect(
        () => parser(['--path', '/caminho/inexistente']),
        throwsA(isA<PathNotFoundException>()),
      );
    });

    test('deve normalizar caminhos relativos', () async {
      final relativeDir = './temp_test';
      final tempTestDir = Directory(relativeDir)..createSync();
      addTearDown(tempTestDir.deleteSync);

      await parser(['--path', relativeDir]);

      expect(
        parser.testPath,
        equals(path.normalize(path.absolute(relativeDir))),
      );
    });
  });
}
