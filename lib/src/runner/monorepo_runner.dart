import '../process/process_handler.dart';
import 'executor/monorepo_executor.dart';
import 'package/package_finder.dart';
import 'runner.dart';

/// Runner responsável por executar testes em um ambiente monorepo.
class MonorepoRunner implements Runner {
  MonorepoRunner({
    required this.rootPath,
    required this.coverage,
    required this.concurrency,
    this.failFast = false,
    this.verbose = false,
    this.fvm = false,
    ProcessHandler? processHandler,
  }) : _processHandler = processHandler;

  final String rootPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;
  final bool fvm;
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
      fvm: fvm,
      processHandler: _processHandler,
    );

    return executor.execute();
  }
}
