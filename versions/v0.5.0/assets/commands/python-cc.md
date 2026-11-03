---
description: schematize-python — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/`, no par
context + checklist do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`). Inclua: o que
foi escrito/revisado em Python, o que o `check-python.sh` acusou e ficou aberto, decisões de escopo
(entrou como ferramenta? foi encaminhado ao rol?) e dívidas de tipagem registradas na catraca. Só
então rode `/compact`.
