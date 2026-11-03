# O piso de Python da casa — ferramenta com governança, não terra sem lei

> Parte da skill **schematize-python**. Aqui está o que o gate cobra
> (`scripts/check-python.sh`) e o que reprova o merge. O lugar de Python no rol e o **veto a API
> nova** estão em `escopo.md`; notebook e o recorte de dados/ML, em `dados-notebook.md`.

Convenção: **MUST** = o gate cobra · **VETADO** = piso.

---

## 1. Ambiente e dependências — `uv`, e o lockfile é o contrato

- **MUST: `uv`** para ambiente, dependência e execução. `pyproject.toml` declara,
  **`uv.lock` commitado** fixa — inclusive as **transitivas** e os hashes. `uv sync --frozen` no CI:
  se o lock não bate com o `pyproject`, o build **falha** em vez de resolver sozinho.
- **VETADO:** `pip install` direto no sistema ou dentro do container de app;
  `requirements.txt` gerado à mão como se fosse lock; venv criado "na mão" e não declarado.
- **Por que lock e não faixa de versão:** Python não tem resolução determinística sem ele. Sem lock,
  "funciona na minha máquina" é literal — e a diferença aparece semanas depois, num transitivo que
  subiu sozinho no runner.
- **Python é declarado**, não herdado: `requires-python` no `pyproject` e `.python-version` no repo.
  A versão corrente e a janela de suporte estão no anexo volátil (`stack-versoes.md`).

## 2. `ruff` — lint e format, e é gate

- **MUST:** `ruff check` **e** `ruff format --check` travando o merge. Config **no repo**
  (`assets/lint/ruff.toml` é o piso da casa: estende, não reinventa).
- **Um só formatador.** Nada de `black` + `ruff format` brigando, nem `isort` separado — o `ruff`
  faz os três, e ter dois é ter dois resultados.
- **Silenciar é rastreável:** `# noqa: RUF001` **com o código específico e o motivo**; `# noqa` nu é
  VETADO (desliga tudo naquela linha, inclusive o que ninguém viu chegar).
- O que o piso liga além do default: `E`/`F` (erros), `I` (imports ordenados), `B` (bugbear — pega o
  **argumento default mutável**, o clássico `def f(x=[])`), `S` (bandit: `subprocess` com
  `shell=True`, `yaml.load` sem `SafeLoader`, `assert` em produção), `UP` (sintaxe moderna),
  `SIM`, `RET`, `PTH`.

## 3. Tipagem que TRAVA — e a catraca do legado

- **MUST:** `mypy --strict` (ou `pyright` em modo strict) sobre o **código novo e o tocado**,
  travando o CI. Tipo que ninguém verifica é comentário.
- **Legado entra por catraca, não por decreto:** `mypy` com `--strict` só nos pacotes já limpos e a
  lista **que só encolhe**; `# type: ignore` **existente** é dívida rastreada, **novo** é VETADO —
  e sempre com o código específico (`# type: ignore[arg-type]`), nunca nu.
- **A fronteira é validada em runtime**, não só tipada: todo I/O externo (payload, env, resposta de
  terceiro, arquivo de config) passa por **`pydantic`** e o tipo é **derivado do modelo**. Anotação
  não valida nada em tempo de execução — e é exatamente na borda que o dado mente.
- **`from __future__ import annotations`** e sintaxe moderna (`X | None`, `list[str]`), com o
  `requires-python` sustentando.

## 4. Empacotamento de ferramenta ≠ dependência de app

- **Ferramenta** (formatter, linter, CLI que você usa) instala-se **isolada**: `uv tool install` ou
  `pipx`. **VETADO** misturá-la nas dependências do app — ela arrasta transitivas que vão para o
  container de produção e criam conflito de resolução com o que importa.
- **App** declara só o que ele **importa em runtime**; o resto vai em grupo de dev
  (`[dependency-groups]`).
- **VETADO `pip install` global no sistema** — em Linux moderno isso quebra pacote do SO (e o
  próprio Python do sistema avisa: *externally-managed-environment*). O caminho é `uv tool`/`pipx`.

## 5. Segurança — o que morde em Python

- **VETADO:** `eval`/`exec` sobre dado externo · `pickle` para dado que veio de fora (**pickle é
  execução de código**, não formato de dados) · `yaml.load` sem `SafeLoader` ·
  `subprocess(..., shell=True)` com string montada · `assert` como validação (o `-O` remove) ·
  `input()` que decide fluxo em serviço.
- **MUST:** `subprocess.run([...])` com **lista**, nunca string; `secrets` (não `random`) para
  qualquer coisa de segurança; `tempfile.mkstemp`/`TemporaryDirectory`, nunca caminho previsível em
  `/tmp`; timeout explícito em **toda** chamada de rede (`requests`/`httpx` **não** têm timeout por
  default — a chamada pendura para sempre e o worker morre segurando a conexão).
- **O script não faz deploy nem operação (pisos 23 e 24):** automação em Python **nunca** manda código à VPS (`scp`/`rsync`/`paramiko`/`fabric`/`docker save|load`), **nunca** muda servidor por `ssh`/`kubectl` e **nunca** monta SQL ad-hoc: pede uma **operação nomeada** ao `<projeto>_ops`. Única exceção: ponte direta à máquina de build/teste dev/hml (piso 29), marcada na linha com `# ponte-build-ok: <host de maquinas.yml>`. O gate reprova o resto.
- **Efeito externo (piso 18):** e-mail, cobrança e webhook reais nunca saem de não-produção; `scripts/check-external-effects.sh` roda junto com o gate.
- **Supressão exige código:** `# noqa: S101` e `# type: ignore[arg-type]` sim; `# noqa` e `# type: ignore` nus não (o gate reprova).
- Dependência: `uv.lock` + varredura de vulnerabilidade no CI (`stack-versoes.md`), e **pin por
  hash** onde o lock permite.

## 6. Concorrência — saiba qual das três você tem

- **I/O-bound** → `asyncio` (ou threads, se a lib é síncrona). **CPU-bound** → **processos**
  (`multiprocessing`, `ProcessPoolExecutor`): o **GIL** serializa bytecode, e thread não dá
  paralelismo de CPU.
- **VETADO** chamada **bloqueante** dentro de `async def` sem `run_in_executor`/`asyncio.to_thread`
  — ela trava o event loop inteiro, e o sintoma (latência de todos os endpoints) não aponta para a
  causa.
- **`free-threaded` (sem GIL)** existe a partir do 3.13 como build opcional: é **decisão com ADR**,
  não default — muita lib nativa ainda não é compatível, e o ganho depende do perfil.

## 7. Estrutura e execução

- **Layout `src/`** (`src/pacote/…`) — evita importar acidentalmente o diretório de trabalho em vez
  do pacote instalado, que é como um teste passa localmente e falha no CI.
- **`if __name__ == "__main__":`** com uma função `main()` — script importável é script testável.
- **Logging pelo `logging`**, com formato estruturado; `print` só em CLI que fala com humano.
- **Erro nunca engolido:** `except Exception: pass` é VETADO. Capture o específico, e se relançar,
  use `raise ... from e` (senão o traceback original some).
- **Teste com `pytest`**; a disciplina é da `schematize-qa` (pirâmide, cobertura útil, flaky).
