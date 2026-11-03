---
description: schematize-python — carrega à força TODO o corpo normativo do piso de Python e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-python`. A partir daqui, nesta sessão, isto
**não é opcional**.

1. **Leia na íntegra** (`.claude/skills/schematize-python/references/*.md`):
   - `escopo.md` — **onde Python entra e onde é VETADO** (API de produto nova não é), a forma da
     exceção (servir modelo), e a regra do legado que já é backend.
   - `piso.md` — `uv` + **lock commitado**, `ruff` como gate de lint **e** format, tipagem que
     **trava** o CI (com catraca no legado) + validação de fronteira em runtime, empacotamento de
     ferramenta isolado, segurança (pickle é execução de código; `secrets` ≠ `random`; **timeout
     explícito**), GIL e as três concorrências, layout `src/`.
   - `dados-notebook.md` — **notebook não é entregável** e por quê; reprodutibilidade de pipeline;
     armadilhas de pandas; fronteira com `data` e `ai`.
   - `stack-versoes.md` — anexo volátil (versões, ferramental), com data de verificação.
2. **Rode o gate** antes de opinar: `bash .claude/skills/schematize-python/scripts/check-python.sh .`
3. **Aplique daqui em diante**, e diga qual piso está aplicando quando ele mudar o que você ia fazer.
