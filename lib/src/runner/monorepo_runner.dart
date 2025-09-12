import '../process/process_handler.dart';
import '../view/loading_indicator.dart';
import 'executor/monorepo_executor.dart';
import 'package/package_finder.dart';
import 'runner.dart';

/// Runner responsável por executar testes em um ambiente monorepo
class MonorepoRunner implements Runner {
  MonorepoRunner({
    required this.rootPath,
    required this.coverage,
    required this.concurrency,
    this.failFast = false,
    this.verbose = false,
    ProcessHandler? processHandler,
  }) : _processHandler = processHandler;

  final String rootPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;
  final ProcessHandler? _processHandler;

  @override
  Future<int> execute() async {
    final finder = PackageFinder(rootPath: rootPath);
    final packages = await finder.findPackages();

    final executor = MonorepoExecutor(
      packages: packages,
      concurrency: concurrency,
      coverage: coverage,
      failFast: failFast,
      verbose: verbose,
      processHandler: _processHandler,
    );

    final loading = LoadingIndicator()
    ..start();

    try {
      return await executor.execute();
    } finally {
      loading.stop();
    }
  }
}
