# FAQ - Perguntas Frequentes

Respostas para as perguntas mais comuns sobre o FasTest.

## Índice

- [Geral](#geral)
- [Instalação](#instalação)
- [Uso](#uso)
- [Performance](#performance)
- [Cobertura](#cobertura)
- [Monorepo](#monorepo)
- [CI/CD](#cicd)
- [Troubleshooting](#troubleshooting)
- [Desenvolvimento](#desenvolvimento)

---

## Geral

### O que é o FasTest?

FasTest é uma ferramenta de linha de comando para executar testes Dart/Flutter de forma mais rápida e eficiente. Ele agrega todos os testes em um único arquivo e oferece execução paralela para monorepos.

### Por que o FasTest é mais rápido?

O FasTest otimiza a execução de testes de duas formas:
1. **Agregação**: Combina todos os testes em um único arquivo, reduzindo o overhead de inicialização
2. **Paralelização**: Executa testes de diferentes pacotes simultaneamente em monorepos

### O FasTest funciona com projetos Dart puro?

Sim! O FasTest funciona tanto com projetos Dart puros quanto com projetos Flutter.

### O FasTest substitui o `flutter test` ou `dart test`?

Não, o FasTest é um wrapper que otimiza a execução. Ele ainda usa `flutter test` ou `dart test` internamente.

### Qual a diferença entre FasTest e outros test runners?

- **Agregação automática**: Não precisa configurar nada
- **Saída limpa**: Mostra apenas falhas por padrão
- **Suporte a monorepo**: Execução paralela nativa
- **Instalação simples**: Um único comando

---

## Instalação

### Como instalar o FasTest?

```bash
dart pub global activate fastest
```

### O comando `fastest` não é reconhecido. O que fazer?

Adicione o diretório pub cache ao seu PATH:

**Linux/macOS (Bash/Zsh)**:
```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

**macOS (Zsh)**:
```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

**Windows (PowerShell)**:
```powershell
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

### Como atualizar o FasTest?

```bash
dart pub global activate fastest
```

O comando acima sempre instala a versão mais recente.

### Como desinstalar o FasTest?

```bash
dart pub global deactivate fastest
```

### Qual versão do Dart/Flutter é necessária?

- Dart SDK >= 3.5.0
- Flutter >= 3.16.0 (se usar Flutter)

### Posso usar o FasTest em projetos antigos?

Sim, desde que o projeto use Dart >= 3.5.0. Para projetos mais antigos, considere atualizar o SDK.

---

## Uso

### Como executar testes na pasta atual?

```bash
fastest
```

### Como executar testes em uma pasta específica?

```bash
fastest test/
fastest path/to/tests/
```

### Como ver toda a saída dos testes?

```bash
fastest --verbose
fastest -v
```

### Como parar no primeiro erro?

```bash
fastest --fail-fast
fastest -f
```

### Como controlar o número de processos paralelos?

```bash
# Usar 4 processos
fastest --concurrency=4

# Desabilitar paralelização
fastest --no-concurrency
```

### O que é o arquivo `.test_optimizer.dart`?

É o arquivo gerado pelo FasTest que agrega todos os seus testes. Ele deve ser adicionado ao `.gitignore`:

```bash
echo ".test_optimizer.dart" >> .gitignore
```

### Posso deletar o arquivo `.test_optimizer.dart`?

Sim, ele é regenerado automaticamente a cada execução.

### O FasTest modifica meus arquivos de teste?

Não, o FasTest apenas lê seus arquivos de teste e cria um arquivo agregado temporário.

---

## Performance

### Quanto mais rápido é o FasTest?

Depende do projeto, mas geralmente:
- **Projetos pequenos**: 20-40% mais rápido
- **Projetos médios**: 40-60% mais rápido
- **Projetos grandes**: 60-80% mais rápido
- **Monorepos**: Até 300% mais rápido (com paralelização)

### Por que meus testes não ficaram mais rápidos?

Possíveis razões:
1. **Projeto muito pequeno**: O overhead de agregação pode não compensar
2. **Testes lentos**: Se os testes em si são lentos, a agregação não ajuda muito
3. **Recursos limitados**: Em máquinas com poucos recursos, a paralelização pode não ajudar

### Como otimizar ainda mais?

1. Use `--concurrency` adequado ao seu hardware
2. Use `--fail-fast` para parar no primeiro erro
3. Divida testes grandes em arquivos menores
4. Use mocks para dependências externas

### O FasTest usa mais memória?

Sim, um pouco mais, pois agrega todos os testes. Mas o ganho de performance geralmente compensa.

---

## Cobertura

### Como gerar cobertura de código?

```bash
fastest --coverage
```

### O que é o `full_coverage`?

É um pacote Dart que o FasTest usa para gerar relatórios de cobertura mais completos.

### Como instalar o `full_coverage` automaticamente?

```bash
fastest --coverage -y
fastest --coverage --auto-confirm
```

### Onde fica o relatório de cobertura?

Em `coverage/lcov.info` na raiz do projeto.

### Como visualizar a cobertura?

**Opção 1: VS Code**
1. Instale a extensão "Coverage Gutters"
2. Execute `fastest --coverage`
3. Clique em "Watch" na barra de status

**Opção 2: HTML**
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Opção 3: Terminal**
```bash
lcov --summary coverage/lcov.info
```

### Como definir um threshold mínimo de cobertura?

```bash
# Executar testes
fastest --coverage

# Verificar threshold (exemplo: 80%)
lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//' | awk '{if ($1 < 80) exit 1}'
```

### A cobertura funciona em monorepos?

Sim, cada pacote terá seu próprio relatório em `coverage/lcov.info`.

---

## Monorepo

### Como executar testes em um monorepo?

```bash
fastest --package
```

### O FasTest detecta automaticamente os pacotes?

Sim, ele busca recursivamente por pastas com `pubspec.yaml` e diretório `test/`.

### Como controlar quantos pacotes executam em paralelo?

```bash
fastest --package --concurrency=4
```

### Como executar pacotes sequencialmente?

```bash
fastest --package --no-concurrency
```

### Posso executar apenas alguns pacotes?

Atualmente não, mas está no [roadmap](ROADMAP.md). Por enquanto, execute diretamente:

```bash
cd packages/my_package
fastest
```

### A saída fica confusa com muitos pacotes em paralelo

Use uma das opções:
1. Modo verbose: `fastest --package --verbose`
2. Reduzir concorrência: `fastest --package --concurrency=2`
3. Desabilitar paralelização: `fastest --package --no-concurrency`

Veja também [IMPROVEMENTS.md](IMPROVEMENTS.md) para melhorias planejadas.

### Como funciona a execução paralela?

O FasTest usa isolates do Dart para executar múltiplos pacotes simultaneamente, respeitando o limite de concorrência definido.

---

## CI/CD

### Como usar o FasTest no GitHub Actions?

```yaml
- name: Install FasTest
  run: dart pub global activate fastest

- name: Run tests
  run: fastest --fail-fast
```

Ver mais exemplos em [EXAMPLES.md](EXAMPLES.md#integração-cicd).

### Como usar com cobertura no CI?

```yaml
- name: Run tests with coverage
  run: fastest --coverage -y

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### O FasTest funciona em containers Docker?

Sim! Exemplo:

```dockerfile
FROM dart:stable

RUN dart pub global activate fastest
ENV PATH="${PATH}:/root/.pub-cache/bin"

WORKDIR /app
COPY . .

RUN dart pub get
CMD ["fastest", "--coverage", "-y"]
```

### Como usar em GitLab CI?

```yaml
test:
  image: dart:stable
  before_script:
    - dart pub global activate fastest
    - export PATH="$PATH:$HOME/.pub-cache/bin"
  script:
    - fastest --coverage -y
```

### Devo usar `--fail-fast` no CI?

Sim, recomendado para economizar tempo e recursos:

```bash
fastest --fail-fast
```

---

## Troubleshooting

### Erro: "Command not found: fastest"

**Solução**: Adicione pub cache ao PATH. Ver [Instalação](#instalação).

### Erro: "full_coverage not found"

**Solução**: 
```bash
fastest --coverage -y
```

### Erro: "No tests found"

**Solução**: Verifique se:
1. Existe um diretório `test/`
2. Os arquivos terminam com `_test.dart`
3. Você está na raiz do projeto

### Erro: "Permission denied"

**Solução**:
```bash
chmod +x ~/.pub-cache/bin/fastest
```

### Os testes passam localmente mas falham no CI

**Possíveis causas**:
1. Versões diferentes de Dart/Flutter
2. Dependências não instaladas
3. Variáveis de ambiente diferentes
4. Timezone/locale diferentes

**Solução**: Fixe as versões no CI:
```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.16.0'
```

### Erro de memória em monorepo grande

**Solução**: Reduza a concorrência:
```bash
fastest --package --concurrency=2
```

### A saída está truncada

**Solução**: Use modo verbose:
```bash
fastest --verbose
```

### Testes ficam travados

**Possíveis causas**:
1. Teste com loop infinito
2. Teste aguardando input
3. Deadlock em testes assíncronos

**Solução**: Execute com timeout:
```bash
timeout 300 fastest  # 5 minutos
```

---

## Desenvolvimento

### Como contribuir com o FasTest?

Veja o [Guia de Contribuição](CONTRIBUTING.md).

### Como reportar um bug?

1. Verifique se já não foi reportado
2. Abra uma [issue](https://github.com/aphenrique/fastest/issues/new)
3. Inclua:
   - Versão do FasTest
   - Versão do Dart/Flutter
   - Sistema operacional
   - Comando executado
   - Saída completa do erro

### Como sugerir uma feature?

1. Verifique o [Roadmap](ROADMAP.md)
2. Abra uma [discussão](https://github.com/aphenrique/fastest/discussions)
3. Descreva o caso de uso

### Como testar mudanças localmente?

```bash
# Clone o repositório
git clone https://github.com/aphenrique/fastest.git
cd fastest

# Instale dependências
dart pub get

# Execute testes
dart test

# Ative localmente
dart pub global activate --source path .

# Teste
fastest
```

### Como debugar o FasTest?

```bash
# Execute com verbose
fastest --verbose

# Ou adicione prints no código
print('Debug: $variable');
```

### Onde está a documentação da API?

Veja [API.md](API.md).

### Como funciona a arquitetura?

Veja [ARCHITECTURE.md](ARCHITECTURE.md).

### Posso usar o FasTest como biblioteca?

Sim! Veja exemplos em [API.md](API.md#exemplos-de-uso).

---

## Perguntas Não Respondidas?

- 💬 [Abra uma discussão](https://github.com/aphenrique/fastest/discussions)
- 🐛 [Reporte um bug](https://github.com/aphenrique/fastest/issues)
- 📖 [Consulte a documentação](README.md)

---

## Recursos Adicionais

- [Documentação Completa](README.md)
- [Exemplos Práticos](EXAMPLES.md)
- [Arquitetura](ARCHITECTURE.md)
- [API Reference](API.md)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)

---

**Última atualização**: Janeiro 2024  
**Versão**: 1.0.0
