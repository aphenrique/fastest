# FastTest 🚀

Uma ferramenta Dart para execução rápida e eficiente de testes unitários, especialmente otimizada para projetos Flutter.

## Características ✨

- **Saída Simplificada**: Mostra apenas nomes dos arquivos de testes com falhas
- **Suporte a Cobertura**: Geração de relatórios de cobertura de código
- **Performance**: Significativamente mais rápido que a execução padrão do Flutter test

## Instalação 📦

```bash
dart pub global activate fastest
```

## Uso 🔧

Execute os testes em seu projeto:

```bash
fastest .
```

Com cobertura de código:

```bash
fastest . --coverage
```

## Como Funciona 🛠

1. **Geração de Testes**: Cria um arquivo único que agrupa todos os testes e executa "flutter test" neste único arquivo
3. **Relatório Otimizado**: Mostra apenas os arquivos que falharam

## Roadmap 🗺

- [ ] Suporte a projetos modulares Flutter
  - [ ] Detecção automática de módulos
  - [ ] Execução paralela entre módulos
  - [ ] Relatório consolidado

## Contribuindo

Contribuições são bem-vindas! Por favor, leia nossas diretrizes de contribuição antes de submeter um PR.

## Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## Por que usar Speed Test?

- **Economia de Tempo**: Reduz significativamente o tempo de execução dos testes
- **Facilidade de Uso**: Interface simples e direta
- **Manutenção**: Saída limpa e focada no caso de falhas
- **Escalabilidade**: Preparado para projetos grandes e modulares

## Exemplos de Uso 📝

### Projeto Básico
```bash
fastest .
```

### Com Cobertura
```bash
fastest . --coverage
```

### Próximas Implementações (Em Breve)

#### Projetos Modulares
```bash
fastest . --modules=all
fastest . --modules=core,feature1,feature2
```

#### Configurações Personalizadas
```bash
fastest . --concurrency=8 --reporter=detailed
```

## Suporte

- Abra uma issue para reportar bugs
- Discussões para novas features
- Pull Requests são bem-vindos