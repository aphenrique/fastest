import 'package:fastest/src/runner/test_arguments_builder.dart';
import 'package:test/test.dart';

void main() {
  late TestArgumentsBuilder argsBuilder;

  setUp(() {
    argsBuilder = TestArgumentsBuilder();
  });

  group('TestArgumentsBuilder', () {
    test(
        'build deve retornar argumentos básicos quando não há flags adicionais',
        () {
      final args = argsBuilder.build(
        testFile: 'test/example_test.dart',
        coverage: false,
        concurrency: 1,
      );

      expect(args, equals(['test', 'test/example_test.dart']));
    });

    test('build deve adicionar --coverage quando coverage é true', () {
      final args = argsBuilder.build(
        testFile: 'test/example_test.dart',
        coverage: true,
        concurrency: 1,
      );

      expect(args, equals(['test', 'test/example_test.dart', '--coverage']));
    });

    test('build deve adicionar --concurrency quando concurrency é maior que 1',
        () {
      final args = argsBuilder.build(
        testFile: 'test/example_test.dart',
        coverage: false,
        concurrency: 4,
      );

      expect(
        args,
        equals(['test', 'test/example_test.dart', '--concurrency=4']),
      );
    });

    test(
        'build deve adicionar todas as flags quando todas as opções estão ativas',
        () {
      final args = argsBuilder.build(
        testFile: 'test/example_test.dart',
        coverage: true,
        concurrency: 4,
      );

      expect(
        args,
        equals([
          'test',
          'test/example_test.dart',
          '--concurrency=4',
          '--coverage',
        ]),
      );
    });
  });
}
