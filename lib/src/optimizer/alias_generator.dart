class AliasGenerator {
  int _currentIndex = 0;
  final List<String> _alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
  // Palavras reservadas do Dart com até 3 letras
  final Set<String> _reservedWords = {
    'as',
    'do',
    'for',
    'get',
    'if',
    'in',
    'is',
    'new',
    'of',
    'on',
    'set',
    'try',
    'var',
  };

  String nextAlias() {
    String alias;
    do {
      alias = _generateAlias(_currentIndex);
      _currentIndex++;
    } while (_reservedWords.contains(alias));

    return alias;
  }

  String _generateAlias(int index) {
    if (index < _alphabet.length) {
      return _alphabet[index];
    }

    final prefixIndex = (index ~/ _alphabet.length) - 1;
    final currentIndex = index % _alphabet.length;

    return _generateAlias(prefixIndex) + _alphabet[currentIndex];
  }
}
