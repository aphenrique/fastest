# Guia de Início Rápido - FasTest

Comece a usar o FasTest em menos de 5 minutos! 🚀

## Instalação Rápida

```bash
# Instalar FasTest
dart pub global activate fastest

# Adicionar ao PATH (se necessário)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Adicionar ao .gitignore
echo ".test_optimizer.dart" >> .gitignore
```

## Uso Básico

### 1. Executar Testes

```bash
# Na pasta atual
fastest

# Em uma pasta específica
fastest test/
```

### 2. Com Cobertura

```bash
fastest --coverage
```

### 3. Modo Verbose

```bash
fastest --verbose
```

### 4. Fail Fast (para no primeiro erro)

```bash
fastest --fail-fast
```

## Monorepo

```bash
# Executar todos os pacotes
fastest --package

# Com concorrência customizada
fastest --package --concurrency=4
```

## Comandos Úteis

```bash
# Ajuda
fastest --help

# Versão
fastest --version

# Atualizar
dart pub global activate fastest

# Desinstalar
dart pub global deactivate fastest
```

## Próximos Passos

- 📖 [Documentação Completa](README.md)
- ❓ [FAQ](FAQ.md)
- 💡 [Exemplos](EXAMPLES.md)
- 🏗️ [Arquitetura](ARCHITECTURE.md)

## Problemas Comuns

### Comando não encontrado

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### full_coverage não instalado

```bash
fastest --coverage -y
```

### Testes não encontrados

Verifique se existe um diretório `test/` com arquivos `*_test.dart`.

---

**Pronto para começar?** Execute `fastest` no seu projeto! 🎉
