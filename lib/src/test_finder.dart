import 'dart:io';

List<File> findTestFiles(Directory directory) {
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

Set<String> findFailedTests(String output) {
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
