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

class TestFailure {
  final String fileName;
  final String executionTime;

  TestFailure(this.fileName, this.executionTime);
}

Set<String> findFailedTests(String output) {
  final failedTests = <String>{};

  for (final line in output.split('\n')) {
    if (line.contains('[E]')) {
      for (final part in line.split(' ')) {
        if (part.endsWith('_test.dart')) {
          failedTests.add(part);
          break;
        }
      }
    }
  }

  return failedTests;
}
