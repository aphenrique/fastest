import 'dart:async';
import 'dart:io';

/// Classe responsável por exibir uma animação de loading no console
class LoadingIndicator {
  LoadingIndicator({
    this.message = 'Executando testes...',
  });

  final String message;
  Timer? _timer;
  bool _isRunning = false;

  static const _loadingChars = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  /// Inicia a animação de loading
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    var loadingIndex = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      stdout.write('\r${_loadingChars[loadingIndex]} $message\x1B[K');
      loadingIndex = (loadingIndex + 1) % _loadingChars.length;
    });
  }

  /// Para a animação de loading
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    stdout.write('\r');
  }
}
