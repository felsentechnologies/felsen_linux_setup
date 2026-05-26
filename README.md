# Felsen Linux Setup

Instalador modular em Bash para preparar servidores Linux com Docker Swarm, Portainer, Traefik e um catalogo de stacks self-hosted.

Este projeto foi inspirado no **Setup Orion**, com uma proposta propria: manter a experiencia de instalacao simples, direta e previsivel, mas com uma base organizada em modulos, catalogos e comandos reutilizaveis.

## Principios

- **Sem telemetria**: o projeto nao coleta, rastreia ou envia dados de uso.
- **Sem coleta silenciosa**: nao ha envio de IP, identificadores, metricas ou eventos para endpoints externos.
- **Controle local**: a execucao acontece no servidor onde o script e iniciado.
- **Estrutura modular**: apps, comandos e instaladores ficam separados para facilitar manutencao.
- **Operacao direta**: cada stack pode ser chamada pelo menu, numero, alias ou comando.

## Uso

Abra o menu interativo:

```bash
bash menu.sh
```

Execute uma stack diretamente:

```bash
bash menu.sh n8n
bash menu.sh chatwoot cliente1
```

Execute comandos de manutencao:

```bash
bash menu.sh portainer.restart
bash menu.sh docker.fix
bash menu.sh dependencias
```

Veja a ajuda:

```bash
bash menu.sh --help
```

## Estrutura

- `menu.sh`: menu interativo e dispatcher principal.
- `config/apps.tsv`: catalogo de apps, numeros, aliases e scripts.
- `config/commands.tsv`: catalogo de comandos de manutencao.
- `apps/`: wrappers executaveis por aplicacao.
- `commands/`: wrappers executaveis por comando.
- `lib/core.sh`: runtime compartilhado do instalador.
- `lib/installers/`: modulos integrados de apps e comandos.
- `lib/`: bibliotecas auxiliares de UI, sistema, Docker e Portainer.

## Privacidade

O Felsen Linux Setup nao possui telemetria, rastreamento ou coleta de dados.

Esta versao remove qualquer funcao de rastreamento do instalador, chamadas para endpoints externos de rastreamento e coletas de IP usadas apenas para identificacao de uso. Flags de privacidade dos aplicativos foram mantidas ou ajustadas para desativar rastreamento quando suportado.

Alguns modulos podem baixar imagens Docker, pacotes ou arquivos oficiais exigidos pela stack escolhida. Esses downloads fazem parte da instalacao tecnica da aplicacao selecionada e nao representam coleta de dados pelo instalador.

## Arquivos gerados

Os arquivos gerados por heredoc usam o delimitador corporativo `__FELSEN_MANAGED_FILE__`. Isso deixa claro quais blocos sao artefatos gerenciados pelo instalador e evita delimitadores genericos como `EOF` ou `EOL`.

## Requisitos

- Servidor Linux com Bash.
- Permissoes administrativas para instalar pacotes e configurar Docker.
- Acesso de rede para baixar imagens e dependencias das stacks escolhidas.

Para preparar as dependencias base usadas pelos instaladores, execute:

```bash
bash menu.sh dependencias
```

## Creditos

Inspirado no **Setup Orion**.

Adaptado e organizado como Felsen Linux Setup, com foco em modularidade, manutencao e privacidade.
