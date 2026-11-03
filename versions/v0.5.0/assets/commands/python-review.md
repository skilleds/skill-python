---
description: schematize-python — revisa Python contra o piso: roda o gate + ruff e depois lê o que a máquina não lê (fronteira, escopo, reprodutibilidade)
argument-hint: "[arquivo.py, notebook.ipynb ou diretório]"
---

# /python-review

## 0. A pergunta que vem antes

**É aqui?** Se o que está sendo escrito é **API/serviço de produto novo**, a resposta é não
(`references/escopo.md`) — e o review termina aqui, com o encaminhamento para o rol. Se é serviço de
inferência, ele é **fino, sem regra de negócio, atrás** de um serviço do rol.

## 1. A máquina

```bash
bash .claude/skills/schematize-python/scripts/check-python.sh .
ruff check . && ruff format --check .
mypy --strict <pacote-novo-ou-tocado>
```

`0` passa · `1` reprova · `2` **nada para verificar** — que não é aprovação.

O gate cobra: `ruff`; `uv.lock` e `requires-python`; `shell=True`; `yaml.load` sem SafeLoader;
`eval`/`exec`; **argumento default mutável**; HTTP **sem timeout**; `random` em contexto de
segurança; `/tmp` previsível; **notebook commitado com saída**.

## 2. O que a máquina não lê

- **Fronteira validada em runtime?** Todo I/O externo passa por `pydantic`, ou só tem anotação
  (que não valida nada)?
- **O `except` é específico?** `except Exception: pass` engole; `raise ... from e` preserva o
  traceback.
- **Concorrência:** o que é CPU-bound está em **processo**? há chamada bloqueante dentro de
  `async def` (que trava o event loop inteiro e cujo sintoma não aponta a causa)?
- **Reprodutibilidade** (se é dado/ML): semente fixa e **logada**, dado identificado, ambiente
  travado — senão a "melhora" pode ser variância.
- **Notebook:** sem saída, sem dado real, sem credencial. Virou produto? então virou **módulo** em
  `src/`, com teste e tipo.
- **Dinheiro em `float`?** Nunca (`Decimal` ou inteiro de centavos).
- **Piso comum:** segredo fora do código, **efeito externo não sai de não-produção**, log sem PII.
  *"É só um script"* é a frase que antecede o incidente — ele roda em produção, com credencial de
  produção, no cron das 3h.

## 3. Feche

Achado vira correção no mesmo PR ou item de checklist com dono. Ao mexer no gate, rode o vermelho
dele: `bash scripts/check-python.test.sh` (11 casos).
