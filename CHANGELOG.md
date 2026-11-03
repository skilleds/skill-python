# Changelog — schematize-python

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]
### Corrigido
- **P0** Template de CI: gatilho `workflow_dispatch` + tags, `concurrency`; `uv sync --frozen` + `uv run`, sem `pip` e sem `|| true`; `pip-audit` sobre o `uv export` do lock.
- **P1** `check-python.sh`: timeout/`SafeLoader` conferidos por chamada (antes o arquivo inteiro era liberado por uma ocorrência); `# noqa` e `# type: ignore` nus reprovam; ssh/scp/rsync/paramiko/fabric/kubectl/`docker save|load` reprovam (pisos 23/24; exceção `# ponte-build-ok:`); sem `ruff` sai 2 (era 0); sem config de projeto aplica o `ruff.toml` da casa. 22 casos, 10 vermelhos antes.
- `ruff.toml`: `target-version = py313`, `PGH` e `RUF100`, `S603` ignorado (lista de args é o jeito certo).
- `check-external-effects.sh` (+ teste) distribuído; `piso.md` §5 documenta script sem deploy/ops.
- Versões (fonte: `endoflife.date/api/python.json`, 2026-11-03): 3.15 lançada em 2026-10-09; 3.13 só segurança; alvo 3.14.
- Pisos 22–29 da `schematize-engineering` herdados por ponteiro em `SKILL.md` e `assets/CLAUDE.md` (o texto completo vem do sync de herdados).
- `scripts/check-ci-triggers.sh` (+ teste) distribuído da engineering; `scripts/ci-template.test.sh` roda a regra sobre o template e o hook da própria skill.
### Em espera `[~]`
- Gate de framework web em projeto novo (P1-16); `mypy` no gate.

## [0.4.0] — 2026-10-14
Description reduzida para o orçamento de listagem do catálogo; sem mudança de piso.

### Alterado
- Description encurtada para ≤190 caracteres (catálogo estourou o orçamento de 9000 com 45 skills), mantendo O QUE + gatilho concreto + divisa com as irmãs.

## [0.3.1] — 2026-10-14
Ressincronização dos blocos herdados com a engineering v0.27.0; sem mudança de piso próprio.

### Alterado
- Description reduzida (≤235 chars) para caber no orçamento de listagem de skills (soma ≤8300); mesmo território, fronteiras com as irmãs preservadas.
- Blocos herdados ressincronizados com a `schematize-engineering` v0.27.0 (`tools/sync-herdados.mjs`): orquestração com a regra de imagem (nunca pelo Claude; detecta Codex/Gemini e pergunta ao usuário qual usar, Codex como sugestão) e `schematize overdev delegar` (comando do app) no lugar do falso nome de skill `schematize-overdev`.

## [0.3.0] — 2026-10-14
Saneamento: description válida e ancorada nos artefatos, herança explícita da base e CI de referência — porque a skill não dizia o que herdava (nem qual era o papel dela no §2.2 de `linguagens.md`) e o instalador prometia hooks que não existem.

### Corrigido
- `description` em bloco `>-`, ≤350 caracteres, YAML válido, ancorada nos artefatos da linguagem.
- Seção "Precedência e herança": §28 archive, §35 DoD, §39 índice, IAM, efeito externo, orquestração herdados da base; papel ancorado em `schematize-engineering → references/linguagens.md` §2.2; QA/ops/IAM/índice vêm de `/eng-*` (`/eng-overdev`, `/eng-plan`, `/eng-scan`, `/eng-review`).
- `install.sh`: removido o trecho que copiava `assets/hooks` e mandava registrar `assets/settings.claude.example.json` — nenhum dos dois existe (mensagem enganosa).
- `python-help`: `/python-load` listava "(piso, plataforma)"; corrigido para os arquivos reais.

### Adicionado
- `assets/ci/github-actions-ci.yml` (actions pinadas por SHA) e arquivo de config do linter em `assets/lint/`; referenciados no SKILL.md.

### Atualizado
- Anexo volátil: alvo 3.13/3.14, 3.10 EOL em out/2026, free-threaded suportado desde a 3.14 (PEP 779), sem fixar a versão da máquina.
- **Description** reduzida (~270 chars) para caber no orçamento de listagem (soma das 31 skills ≤ 8500; o Claude Code corta a listagem acima disso).

### Alterado
- Bloco "Precedência e herança" passa a ser herdado da base (`schematize-engineering` → `assets/herdados/precedencia.md`), gerado por `tools/sync-herdados.mjs`; corpo sem mudança de conteúdo.

## [0.2.2] — 2026-09-30
O piso de orquestração passa a ser **herdado** da base em vez de copiado à mão: uma mudança na engineering não exige mais editar 38 arquivos.

### Alterado
- Piso "Orquestrador não desenvolve; subagent barato executa" em `assets/CLAUDE.md` e `SKILL.md` agora é um bloco `<!-- herdado:engineering/orquestracao:… -->`, sincronizado de `schematize-engineering/assets/herdados/orquestracao.md` por `tools/sync-herdados.mjs` (checado no CI). Redação normalizada; conteúdo inalterado.

### Mantido (piso inalterado)
- Sonnet por default, escada até opus, sem frota ociosa (engineering `references/orquestracao.md` §9/§9.6).

## [0.2.1] — 2026-09-30
Pedido do dono: agents idle poluem a tela e seguram recurso.

### Adicionado
- Piso de orquestração ganha a regra de frota ociosa (idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata); detalhe na `schematize-engineering` §9.6.

## [0.2.0] — 2026-09-30

Pedido do dono, por **custo**: o orquestrador não desenvolve; ação onerosa vira micro-tasks baratas; `sonnet` é o default dos subagents e `opus` só entra após falha.

### Adicionado
- **Piso "Orquestrador não desenvolve; subagent barato executa"** no `assets/CLAUDE.md` e no `SKILL.md`: o agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para subagents em `sonnet` (falhou → o mesmo subagent corrige → re-decompõe → só então `opus`, com motivo). Detalhe na base: `schematize-engineering` → `references/orquestracao.md` §9.

### Mantido (piso inalterado)
- Todos os pisos anteriores e o gate de `scripts/` seguem exatamente como estavam; a mudança é só de orquestração, não de código.

## [0.1.0] — 2026-08-21

Primeira versão. Python **já estava na casa** — dados/ML, automação, o motor `simulated/run.py` que a `schematize-qa` distribui em 8 skills — e nunca tinha sido **decidido**. A vistoria de 2026-08-21 nomeou o desenho do problema: esse motor, *que a casa distribui e que tinha dois bugs reais achados na própria vistoria*, é Python sem governança; e `data` e `ai` pressupõem Python em toda parte **sem jamais dizê-lo**. Uso implícito é uso sem piso.

### Adicionado
- **`references/escopo.md`** — os dois lados da fronteira: **onde Python entra** (dados/ML, automação, ferramental interno, notebook de exploração) e **onde é VETADO** (API/serviço de produto novo, exatamente como Node), com o motivo que não é desempenho nem gosto: *a casa não quer manter piso de produção em mais um ecossistema, e um serviço de produto vive dez anos*. Mais a **forma da exceção** (serviço de inferência **fino, sem regra de negócio, atrás** de um serviço do rol que faz authz e validação) e a regra do legado que já é backend — migra por funcionalidade, e **enquanto vive, cumpre o piso**.
- **`references/piso.md`** — `uv` com **lock commitado** (sem ele "funciona na minha máquina" é literal); **`ruff`** como gate de lint **e** format (um só formatador — ter dois é ter dois resultados); tipagem que **trava** com catraca no legado, e **validação de fronteira em runtime** com pydantic (*anotação não valida nada, e é na borda que o dado mente*); **empacotamento de ferramenta isolado**; segurança (pickle é **execução de código**; `random` vs `secrets`; **HTTP sem timeout**, que `requests`/`httpx` não têm por default); **GIL** e as três concorrências; layout `src/`.
- **`references/dados-notebook.md`** — **notebook não é entregável**, com os três porquês: diff ilegível (JSON com saída embutida), **não reprodutível por construção** (a ordem de execução não é a ordem das células; célula apagada deixa a variável viva) e **inseguro** (a saída fica salva — amostra de dado real, token colado). Mais reprodutibilidade de pipeline (semente logada, dado identificado, ambiente travado) e as três armadilhas de pandas que mais mordem.
- **`scripts/check-python.sh`** + **`scripts/check-python.test.sh`** (**11 casos**, 9 vermelhos) — o gate: `ruff`, lock e `requires-python`, `shell=True`, `yaml.load` inseguro, `eval`/`exec`, **argumento default mutável**, HTTP sem timeout, `random` em contexto de segurança, `/tmp` previsível, e **notebook commitado com saída**.
- **`assets/lint/ruff.toml`** — o piso de lint da casa (`E`,`F`,`I`,`B`,`S`,`UP`,`SIM`,`RET`,`PTH`,`ASYNC`,`DTZ`,`T20`), para o projeto **estender**.

### Medido nesta versão
- `ruff` **instalado** (0.16.4) e rodado sobre o Python do catálogo: o `simulated/run.py` tinha **import block desordenado** e formatação fora do padrão — corrigido e **propagado para as 8 cópias** (md5 idêntico), com a suíte do `run.test.sh` verde depois.

### Corrigido durante a própria escrita (vale registro)
- A regra de `shell=True` acusava a **docstring do exemplo bom** ("nunca string com shell=True"). O gate ganhou `tirar_docstring`. *Gate que confunde documentação com código produz achado inventado — e achado inventado é o começo do gate ignorado.*
