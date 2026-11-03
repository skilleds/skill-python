---
description: Mapa da skill schematize-python (o piso de Python da casa — ferramenta com governança).
---
**schematize-python** — o piso de Python da casa.

| Comando | O que faz |
|---|---|
| `/python-help` | esta lista |
| `/python-load` | carrega à força TODO o corpo normativo (piso, escopo, notebook) e passa a aplicá-lo |
| `/python-review` | revisa `.py`/`.ipynb` contra o piso: roda `scripts/check-python.sh` + `ruff` e lê o que a máquina não lê |
| `/python-claude` | cria ou mescla o `CLAUDE.md` sempre-on de Python na raiz do repo |
| `/python-cc` · `/python-handoff` | context compact / handoff no archive |

**A pergunta que vem antes de todas:** *é aqui?* API de produto nova **não é** — ver
`references/escopo.md`. Pareia com `schematize-data` (contrato de dado), `schematize-ai` (eval),
`schematize-qa` (teste) e `schematize-shell` (a fronteira: passou de parsing sério e retry, já não é
shell).
