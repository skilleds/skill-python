---
name: schematize-python
metadata:
  version: 0.5.0
description: >-
  Piso de Python como ferramenta (dados/ML, automação), nunca serviço novo. Use ao tocar pyproject.toml ou *.py: ruff, mypy --strict, pytest, uv, subprocess e pickle seguros.
---
<!-- cross-skill: linguagens.md, efeitos-externos.md -> schematize-engineering -->

# O piso de Python da casa (schematize-python)

Python **está na casa e continua** — dados/ML, automação, ferramental. O que faltava era decisão:
até 2026-08-21 esse uso era **implícito**, e uso implícito é **uso sem piso**. Esta skill escreve os
dois lados: **onde ele entra** e **onde é vetado**.

**Versão:** skill `schematize-python` v0.5.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:foraRol intro="Esta skill é o recorte **Python** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2 e §2.1): **ferramenta** — dados/ML, automação, ferramental; nunca serviço de produto novo." cmd="python" -->Esta skill é o recorte **Python** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2 e §2.1): **ferramenta** — dados/ML, automação, ferramental; nunca serviço de produto novo.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização — a lib, o gate, a
   sintaxe da linguagem. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/python-*` cobrem só o piso da linguagem.<!-- /herdado -->

## Por que ela nasceu

A vistoria de 2026-08-21 achou o desenho do problema: o motor `simulated/run.py` — **que a casa
distribui em 8 skills e que tinha dois bugs reais** achados na própria vistoria — é Python **sem
governança**; e as skills `data` e `ai` pressupõem Python em toda parte **sem jamais dizê-lo**.
Ferramenta sem piso não fica neutra: ela vira o lugar por onde o piso das outras vaza.

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/python-help` | lista os comandos |
| `/python-load` | carrega à força o corpo normativo (piso, escopo, notebook) |
| `/python-review` | revisa `.py`/`.ipynb` contra o piso: roda o gate + `ruff` e lê o que a máquina não lê |
| `/python-claude` | cria/mescla o `CLAUDE.md` sempre-on de Python na raiz do repo |
| `/python-cc` · `/python-handoff` | context compact / handoff arquivado |

## Como usar

1. **Antes de escrever**, saiba **se é aqui**: `references/escopo.md`. API de produto nova **não é**.
2. **Rode o gate:** `bash scripts/check-python.sh .` (sem `ruff` ele sai 2; aplica o `ruff.toml` da casa se o projeto não tiver config) e `scripts/check-external-effects.sh .` — `0` passa · `1` reprova · `2` **nada para
   verificar** (que não é aprovação).
3. **Piso técnico** em `references/piso.md`: `uv` + lock, `ruff` como gate, tipos que travam,
   empacotamento, segurança, concorrência, estrutura.
4. **Se há notebook**, ele é exploração: `references/dados-notebook.md`.

Mapa de references:

| Tarefa | Reference |
|---|---|
| O piso executável: `uv`/lock, `ruff`, tipagem que trava, empacotamento de ferramenta, segurança, GIL e concorrência, estrutura | `references/piso.md` |
| **Onde Python entra e onde é VETADO**; a forma da exceção (servir modelo); legado que já é backend | `references/escopo.md` |
| **Notebook não é entregável**; reprodutibilidade de pipeline; armadilhas de pandas; fronteira com `data` e `ai` | `references/dados-notebook.md` |
| Versões e ferramental (`uv`, `ruff`, `mypy`, `pytest`, `pydantic`), com data de verificação | `references/stack-versoes.md` |

Assets prontos para copiar: `assets/ci/github-actions-ci.yml` (ruff, mypy --strict, pytest, pip-audit) · `assets/lint/ruff.toml`.

## Pisos inegociáveis (vetam o atalho)

1. **Python é ferramenta, não backend de produto novo.** API/serviço novo nasce no rol
   (`schematize-engineering` → `references/linguagens.md` §2.1). A exceção — servir modelo — tem
   forma: serviço fino, sem regra de negócio, atrás de um serviço do rol.
2. **`uv` com `uv.lock` commitado**, `uv sync --frozen` no CI. Sem lock, o transitivo sobe sozinho no
   runner e "funciona na minha máquina" é literal.
3. **`ruff check` e `ruff format --check` travam o merge.** Um só formatador. `# noqa` nu é VETADO —
   sempre com o código e o motivo.
4. **Tipagem trava o CI** no código novo/tocado (`mypy --strict`); legado por catraca que só encolhe.
   E **a fronteira valida em runtime** (`pydantic`) — anotação não valida nada.
5. **Ferramenta instala isolada** (`uv tool`/`pipx`), nunca junto das dependências do app.
   `pip install` global é VETADO.
6. **`pickle` é execução de código** — nunca sobre dado externo. Junto: `eval`/`exec` sobre entrada,
   `yaml.load` sem `SafeLoader`, `subprocess(shell=True)`, `assert` como validação (o `-O` remove).
7. **`secrets`, não `random`,** para qualquer coisa de segurança.
8. **Toda chamada de rede tem `timeout` explícito** — `requests`/`httpx` **não** têm por default: a
   chamada pendura para sempre e o worker morre segurando a conexão.
9. **CPU-bound vai para processo, não thread** (GIL); chamada bloqueante dentro de `async def` trava
   o event loop inteiro.
10. **Notebook não é entregável:** vai sem saída, sem dado real, sem credencial — e quando vira
    produto, vira **módulo** em `src/`, com teste e tipo.
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Relação com as outras skills

- **`schematize-engineering`** — a base e o rol; o veto de API nova mora lá (§2.1 de `linguagens.md`).
- **`schematize-data`** — contrato de dado, qualidade, lineage, backfill. Aqui é o **como escrever**;
  lá, **o que o dado precisa cumprir**.
- **`schematize-ai`** — eval, guardrail, custo. O runner de eval é Python, e obedece a este piso.
- **`schematize-qa`** — a disciplina de teste (`pytest` é o runner); o `simulated/run.py` dela é
  Python da casa e é código de produção.
- **`schematize-shell`** — a fronteira prática: passou de parsing sério, retry e dado estruturado,
  já não é shell.

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
