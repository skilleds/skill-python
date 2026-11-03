# Piso de Python (schematize-python) — sempre-on

1. **Python é ferramenta, não backend de produto novo.** Dados/ML, automação e ferramental: sim.
   **API/serviço de produto novo: VETADO** — nasce no rol (Go/Rust/Elixir/C#/Zig/Ruby) com ADR.
   Servir modelo é a exceção: serviço **fino, sem regra de negócio, atrás** de um serviço do rol.
2. **`uv` + `uv.lock` commitado**; `uv sync --frozen` no CI; `requires-python` declarado.
3. **`ruff check` e `ruff format --check` travam o merge.** `# noqa` sempre com código e motivo.
4. **Tipagem trava o CI** no novo/tocado (`mypy --strict`); legado por catraca. **Fronteira validada
   em runtime** com `pydantic` — anotação não valida nada.
5. **Ferramenta isolada** (`uv tool`/`pipx`), nunca nas dependências do app. `pip install` global é
   VETADO.
6. **Segurança:** `pickle` é **execução de código** (nunca sobre dado externo); sem `eval`/`exec`
   sobre entrada; `yaml.safe_load`; `subprocess([...])` com lista, nunca `shell=True`; `assert` não
   é validação (o `-O` remove).
7. **`secrets`, não `random`,** para token/OTP/salt/nonce.
8. **`timeout` explícito em toda chamada de rede** — `requests`/`httpx` não têm por default.
9. **CPU-bound → processo** (GIL); nada de chamada bloqueante dentro de `async def`.
10. **Notebook não é entregável:** sem saída, sem dado real, sem credencial; virou produto, virou
    módulo em `src/` com teste e tipo.
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

Gate: `bash .claude/skills/schematize-python/scripts/check-python.sh .`

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
